import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:drift/drift.dart' as drift;
import '../database/database.dart';
import '../api/api_client.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'radar_screen.dart';
import '../services/auth_service.dart';
import '../services/updater_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _currentIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Stream<List<Attraction>>? _attractionsStream;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _updateLocation(Attraction attraction, AppDatabase db) async {
    // Sprawdzenie uprawnień
    var status = await Permission.location.request();
    if (!mounted) return;
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Brak uprawnień do lokalizacji!')),
      );
      return;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!mounted) return;
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Włącz usługi lokalizacyjne (GPS)!')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Stabilizowanie sygnału GPS...', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Zajmie to około 10 sekund. Proszę czekać.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );

    try {
      // Dajemy czujnikowi 5 sekund na ustabilizowanie "pływającej" pozycji po wyciągnięciu telefonu
      await Future.delayed(const Duration(seconds: 5));
      
      int samplesCount = 7;
      List<Position> samples = [];
      
      for (int i = 0; i < samplesCount; i++) {
        Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation,
        ).timeout(const Duration(seconds: 15), onTimeout: () {
          throw Exception('Brak sygnału GPS (pomiar ${i+1}/$samplesCount). Spróbuj wyjść na zewnątrz.');
        });
        samples.add(pos);
        if (i < samplesCount - 1) {
          await Future.delayed(const Duration(seconds: 1));
        }
      }

      // Wyliczanie środka ciężkości dla wszystkich 7 próbek
      double initialLatSum = 0;
      double initialLonSum = 0;
      for (var p in samples) {
        initialLatSum += p.latitude;
        initialLonSum += p.longitude;
      }
      double centerLat = initialLatSum / samplesCount;
      double centerLon = initialLonSum / samplesCount;

      // Sortowanie próbek po odległości od środka (od najmniejszej do największej)
      samples.sort((a, b) {
        double distA = Geolocator.distanceBetween(centerLat, centerLon, a.latitude, a.longitude);
        double distB = Geolocator.distanceBetween(centerLat, centerLon, b.latitude, b.longitude);
        return distA.compareTo(distB);
      });

      // Odrzucenie 2 najbardziej odchylonych próbek (outlierów) i uśrednienie pozostałych 5
      int keptSamplesCount = 5;
      double finalLatSum = 0;
      double finalLonSum = 0;
      for (int i = 0; i < keptSamplesCount; i++) {
        finalLatSum += samples[i].latitude;
        finalLonSum += samples[i].longitude;
      }

      double avgLat = finalLatSum / keptSamplesCount;
      double avgLon = finalLonSum / keptSamplesCount;

      // Aktualizacja w bazie (zmiana statusu na PENDING_UPDATE)
      await (db.update(db.attractions)..where((t) => t.id.equals(attraction.id)))
          .write(AttractionsCompanion(
            latitude: drift.Value(avgLat),
            longitude: drift.Value(avgLon),
            syncStatus: const drift.Value('PENDING_UPDATE'),
          ));

      // Próba wysłania od razu do serwera (opcjonalne)
      try {
        final apiClient = ApiClient();
        final response = await apiClient.post('/attractions/sync', {
          'attractions': [{
            'id': attraction.id,
            'latitude': avgLat,
            'longitude': avgLon,
          }]
        });

        if (response.statusCode == 200) {
          await (db.update(db.attractions)..where((t) => t.id.equals(attraction.id)))
              .write(const AttractionsCompanion(syncStatus: drift.Value('SYNCED')));
        }
      } catch (e) {
        // Zostawiamy jako PENDING_UPDATE - zsynchronizuje się później
      }

      if (!mounted) return;
      Navigator.pop(context); // Zamknij spinner

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Zapisano GPS dla: ${attraction.name}')),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Zamknij spinner
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd: $e')),
      );
    }
  }

  Future<void> _verifyLocationOnMap() async {
    var status = await Permission.location.request();
    if (!mounted) return;
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Brak uprawnień do lokalizacji!')));
      return;
    }
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!mounted) return;
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Włącz usługi lokalizacyjne (GPS)!')));
      return;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 20), onTimeout: () {
        throw Exception('Brak sygnału GPS. Spróbuj na otwartej przestrzeni.');
      });
      
      if (!mounted) return;
      Navigator.pop(context); // Zamknij spinner

      // Zmiana na "geo:" - to bezpośrednia komenda dla aplikacji map, która wymusza tryb natywny (offline) i pomija przeglądarkę
      final url = Uri.parse('geo:${position.latitude},${position.longitude}?q=${position.latitude},${position.longitude}');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nie można otworzyć mapy. Brak aplikacji.')));
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd: $e')));
    }
  }

  void _editAttraction(Attraction attraction, AppDatabase db) {
    final nameCtrl = TextEditingController(text: attraction.name);
    final radiusCtrl = TextEditingController(text: attraction.radius.toString());
    bool isActive = attraction.isActive;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateSB) {
          return AlertDialog(
            title: const Text('Edytuj Atrakcję'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nazwa')),
                  const SizedBox(height: 16),
                  TextField(controller: radiusCtrl, decoration: const InputDecoration(labelText: 'Promień (m)'), keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Aktywna'),
                    value: isActive,
                    onChanged: (val) => setStateSB(() => isActive = val),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Anuluj')),
              ElevatedButton(
                onPressed: () async {
                  final newName = nameCtrl.text.trim();
                  final newRadius = double.tryParse(radiusCtrl.text) ?? attraction.radius;
                  
                  // Zapisz lokalnie w bazie od razu ze statusem PENDING_UPDATE
                  await (db.update(db.attractions)..where((t) => t.id.equals(attraction.id)))
                    .write(AttractionsCompanion(
                      name: drift.Value(newName),
                      radius: drift.Value(newRadius),
                      isActive: drift.Value(isActive),
                      syncStatus: const drift.Value('PENDING_UPDATE'),
                    ));

                  // Update API
                  try {
                    final apiClient = ApiClient();
                    final response = await apiClient.put('/admin/attractions/${attraction.id}', {
                      'name': newName,
                      'radius': newRadius,
                      'isActive': isActive,
                    });
                    
                    if (response.statusCode == 200) {
                      await (db.update(db.attractions)..where((t) => t.id.equals(attraction.id)))
                        .write(const AttractionsCompanion(syncStatus: drift.Value('SYNCED')));
                    }
                  } catch (e) {
                    // Pozostanie jako PENDING_UPDATE i wyśle się przy najbliższej synchronizacji w tle
                  }

                  if (!mounted) return;
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Zaktualizowano atrakcję!')));
                },
                child: const Text('Zapisz'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGpsManagementTab(AppDatabase db) {
    _attractionsStream ??= db.select(db.attractions).watch();
    return Column(
      children: [
        ExpansionTile(
          title: const Text('Narzędzia GPS i Mapa', style: TextStyle(fontWeight: FontWeight.bold)),
          leading: const Icon(Icons.satellite_alt, color: Colors.deepOrange),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.explore),
                  label: const Text('Sprawdź moją aktualną pozycję na mapie', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B8B39), // Logo Green
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _verifyLocationOnMap,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.radar),
                  label: const Text('Otwórz Radar Offline', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF6C20), // Logo Orange
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RadarScreen()));
                  },
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings_input_component, color: Colors.orange),
              title: const Text('Zarządzanie Czułością Aplikacji (Geofencing)'),
              subtitle: const Text('Ustawienia globalne filtrów GPS i buforów czasu'),
              trailing: ElevatedButton(
                onPressed: () => _showGlobalSettingsDialog(context, db),
                child: const Text('Zmień'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.system_update, color: Colors.blue),
              title: const Text('Sprawdź Aktualizacje'),
              subtitle: const Text('Pobierz i zainstaluj nową wersję z GitHub'),
              trailing: ElevatedButton(
                onPressed: () => UpdaterService.checkForUpdates(context, showNoUpdateMessage: true),
                child: const Text('Sprawdź'),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Szukaj atrakcji do edycji...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Attraction>>(
            stream: _attractionsStream!,
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text('Błąd bazy danych: ${snapshot.error}'));
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              
              final allAttractions = snapshot.data!;
              final attractions = allAttractions.where((a) => 
                a.name.toLowerCase().contains(_searchQuery.toLowerCase())
              ).toList();

              if (attractions.isEmpty) {
                return const Center(child: Text('Brak wyników.'));
              }

              return ListView.builder(
                itemCount: attractions.length,
                itemBuilder: (context, index) {
                  final attraction = attractions[index];
                  final isPending = attraction.syncStatus == 'PENDING_UPDATE' || attraction.syncStatus == 'PENDING_CREATE';
                  
                  return ListTile(
                    title: Text(attraction.name),
                    subtitle: Text(
                      isPending ? 'Oczekuje na synchronizację' : (attraction.isActive ? 'Zgrane z serwerem' : 'Nieaktywna'),
                      style: TextStyle(color: isPending ? Colors.red : (attraction.isActive ? Colors.green : Colors.grey)),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editAttraction(attraction, db),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.pin_drop),
                          label: const Text('Zapisz GPS'),
                          onPressed: () => _updateLocation(attraction, db),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showGlobalSettingsDialog(BuildContext context, AppDatabase db) async {
    final settingsList = await db.select(db.globalSettings).get();
    final settings = settingsList.isNotEmpty ? settingsList.first : const GlobalSetting(
        id: 1, gpsAccuracyThreshold: 50, entryBufferSeconds: 4, exitBufferSeconds: 45, hysteresisMargin: 10
    );

    int gpsAccuracy = settings.gpsAccuracyThreshold;
    int entryBuffer = settings.entryBufferSeconds;
    int exitBuffer = settings.exitBufferSeconds;
    int hysteresis = settings.hysteresisMargin;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(child: Text('Globalne filtry Geofence')),
                IconButton(
                  icon: const Icon(Icons.help_outline, color: Colors.blue),
                  onPressed: () {
                    showDialog(
                      context: ctx,
                      builder: (_) => AlertDialog(
                        title: const Text('Jak to działa?'),
                        content: const SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('1. Filtr GPS:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('Odrzuca pomiary z dokładnością (błędem) gorszą niż podana. Zapobiega to łapaniu stref ze zbyt dużej odległości.'),
                              SizedBox(height: 8),
                              Text('2. Bufor wejścia:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('Pracownik musi utrzymać się w strefie przez określoną ilość sekund by rozpoczął się pomiar. Zapobiega błędnym wejściom przy przechodzeniu obok.'),
                              SizedBox(height: 8),
                              Text('3. Bufor wyjścia:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('Gdy pracownik wyjdzie ze strefy (bądź straci sygnał), pomiar nie urywa się przez T sekund. Jeśli w tym czasie wróci, pomiar jest kontynuowany bez dziur.'),
                              SizedBox(height: 8),
                              Text('4. Histereza:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('Promień wyjścia z obecnej strefy jest wirtualnie powiększany o ten margines, by uniknąć efektu "ping ponga" na samym obrzeżu atrakcji.'),
                            ],
                          ),
                        ),
                        actions: [TextButton(onPressed: () => Navigator.pop(_), child: const Text('Rozumiem'))],
                      )
                    );
                  }
                )
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Filtr dokładności GPS (m)'),
                  TextFormField(
                    initialValue: gpsAccuracy.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(suffixText: 'm', border: OutlineInputBorder()),
                    onChanged: (v) => gpsAccuracy = int.tryParse(v) ?? gpsAccuracy,
                  ),
                  const SizedBox(height: 16),
                  
                  const Text('Bufor wejścia (sekundy)'),
                  TextFormField(
                    initialValue: entryBuffer.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(suffixText: 'sek.', border: OutlineInputBorder()),
                    onChanged: (v) => entryBuffer = int.tryParse(v) ?? entryBuffer,
                  ),
                  const SizedBox(height: 16),
                  
                  const Text('Bufor wyjścia (sekundy)'),
                  TextFormField(
                    initialValue: exitBuffer.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(suffixText: 'sek.', border: OutlineInputBorder()),
                    onChanged: (v) => exitBuffer = int.tryParse(v) ?? exitBuffer,
                  ),
                  const SizedBox(height: 16),
                  
                  const Text('Histereza Krawędzi (m)'),
                  TextFormField(
                    initialValue: hysteresis.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(suffixText: 'm', border: OutlineInputBorder()),
                    onChanged: (v) => hysteresis = int.tryParse(v) ?? hysteresis,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Anuluj')),
              ElevatedButton(
                onPressed: () async {
                  // Zapisz do API
                  try {
                    final apiClient = ApiClient();
                    final response = await apiClient.post('/settings', {
                      'gpsAccuracyThreshold': gpsAccuracy,
                      'entryBufferSeconds': entryBuffer,
                      'exitBufferSeconds': exitBuffer,
                      'hysteresisMargin': hysteresis,
                    });
                    
                    if (response.statusCode == 200) {
                      await db.into(db.globalSettings).insert(
                        GlobalSettingsCompanion(
                          id: const drift.Value(1),
                          gpsAccuracyThreshold: drift.Value(gpsAccuracy),
                          entryBufferSeconds: drift.Value(entryBuffer),
                          exitBufferSeconds: drift.Value(exitBuffer),
                          hysteresisMargin: drift.Value(hysteresis),
                        ),
                        mode: drift.InsertMode.insertOrReplace,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ustawienia globalne zapisane pomyślnie!')));
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Błąd zapisu na serwerze!')));
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd połączenia: $e')));
                    }
                  }
                  if (context.mounted) Navigator.pop(ctx);
                },
                child: const Text('Zastosuj Globalnie'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddAttractionTab() {
    return _AddAttractionForm();
  }

  Widget _buildUsersManagementTab() {
    return _UsersManagementTab();
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);

    final tabs = [
      _buildGpsManagementTab(db),
      _buildAddAttractionTab(),
      _buildUsersManagementTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Administratora'),
        backgroundColor: Colors.deepOrange,
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepOrange,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Zarządzanie GPS'),
          BottomNavigationBarItem(icon: Icon(Icons.add_location), label: 'Nowe Atrakcje'),
          BottomNavigationBarItem(icon: Icon(Icons.person_add), label: 'Pracownicy'),
        ],
      ),
    );
  }
}

class _UsersManagementTab extends StatefulWidget {
  @override
  __UsersManagementTabState createState() => __UsersManagementTabState();
}

class __UsersManagementTabState extends State<_UsersManagementTab> {
  List<dynamic> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final apiClient = ApiClient();
      final response = await apiClient.get('/admin/users');
      if (response.statusCode == 200) {
        setState(() {
           _users = jsonDecode(response.body);
           _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteUser(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Usuń użytkownika'),
        content: const Text('Czy na pewno chcesz trwale usunąć to konto?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Anuluj')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Usuń', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final apiClient = ApiClient();
      final response = await apiClient.delete('/admin/users/$id');
      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Użytkownik usunięty.')));
        _fetchUsers();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Błąd: Nie można usunąć admina.')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Błąd połączenia.')));
    }
  }

  void _editUser(dynamic user) {
    final _passwordCtrl = TextEditingController();
    final _pinCtrl = TextEditingController();
    String _role = user['role'] ?? 'WORKER';
    bool _isUpdating = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateSB) {
          return AlertDialog(
            title: Text('Edytuj ${user['username']}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Pozostaw puste, jeśli nie chcesz zmieniać.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 16),
                  TextField(controller: _passwordCtrl, decoration: const InputDecoration(labelText: 'Nowe Hasło'), obscureText: true),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _pinCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nowy Kod PIN (4 cyfry)',
                      counterText: '',
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _role,
                    items: const [
                      DropdownMenuItem(value: 'WORKER', child: Text('Pracownik')),
                      DropdownMenuItem(value: 'ADMIN', child: Text('Administrator')),
                      DropdownMenuItem(value: 'SURVEYOR', child: Text('Ankieter (Tylko Ankiety)')),
                    ],
                    onChanged: (v) => setStateSB(() => _role = v!),
                    decoration: const InputDecoration(labelText: 'Rola'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Anuluj')),
              _isUpdating 
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      if (_pinCtrl.text.isNotEmpty && _pinCtrl.text.length != 4) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kod PIN musi składać się dokładnie z 4 cyfr.')));
                        return;
                      }

                      setStateSB(() => _isUpdating = true);
                      try {
                        final apiClient = ApiClient();
                        final response = await apiClient.put('/admin/users/${user['id']}', {
                          'password': _passwordCtrl.text.trim(),
                          'pin': _pinCtrl.text.trim(),
                          'role': _role,
                        });
                        
                        if (response.statusCode == 200) {
                          if (!mounted) return;
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Użytkownik zaktualizowany!')));
                          _fetchUsers();
                        } else {
                          setStateSB(() => _isUpdating = false);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Błąd aktualizacji')));
                        }
                      } catch (e) {
                        setStateSB(() => _isUpdating = false);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Błąd połączenia')));
                      }
                    },
                    child: const Text('Zapisz'),
                  ),
            ],
          );
        },
      ),
    );
  }

  void _showAddUserDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _AddUserForm(onUserAdded: () {
          Navigator.pop(ctx);
          _fetchUsers();
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.person_add),
            label: const Text('Dodaj pracownika'),
            onPressed: _showAddUserDialog,
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final u = _users[index];
              final isAdmin = u['username'].toString().toLowerCase() == 'admin' || u['role'] == 'ADMIN';
              return ListTile(
                leading: CircleAvatar(child: Icon(u['role'] == 'ADMIN' ? Icons.admin_panel_settings : Icons.person)),
                title: Text(u['username']),
                subtitle: Text(u['role']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editUser(u),
                    ),
                    if (!isAdmin)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteUser(u['id']),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AddUserForm extends StatefulWidget {
  final VoidCallback onUserAdded;
  const _AddUserForm({Key? key, required this.onUserAdded}) : super(key: key);

  @override
  __AddUserFormState createState() => __AddUserFormState();
}

class __AddUserFormState extends State<_AddUserForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pinController = TextEditingController();
  String _role = 'WORKER';
  bool _isLoading = false;

  void _submit() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) return;

    if (_pinController.text.isNotEmpty && _pinController.text.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kod PIN musi składać się dokładnie z 4 cyfr.')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final apiClient = ApiClient();
      final response = await apiClient.post('/admin/users', {
        'username': _usernameController.text.trim(),
        'password': _passwordController.text.trim(),
        'pin': _pinController.text.trim(),
        'role': _role,
      });

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Użytkownik utworzony pomyślnie!')));
          widget.onUserAdded();
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd: ${response.statusCode}')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd połączenia: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Dodaj nowego pracownika', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Nazwa użytkownika')),
          const SizedBox(height: 16),
          TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Hasło'), obscureText: true),
          const SizedBox(height: 16),
          TextField(
            controller: _pinController, 
            decoration: const InputDecoration(
              labelText: 'Kod PIN (np. 1234)',
              counterText: '',
            ), 
            keyboardType: TextInputType.number, 
            obscureText: true,
            maxLength: 4,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _role,
            items: const [
              DropdownMenuItem(value: 'WORKER', child: Text('Pracownik')),
              DropdownMenuItem(value: 'ADMIN', child: Text('Administrator')),
              DropdownMenuItem(value: 'SURVEYOR', child: Text('Ankieter (Tylko Ankiety)')),
            ],
            onChanged: (v) => setState(() => _role = v!),
            decoration: const InputDecoration(labelText: 'Rola'),
          ),
          const SizedBox(height: 32),
          _isLoading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
            child: const Text('Utwórz Użytkownika'),
          ),
        ],
      ),
    );
  }
}

class _AddAttractionForm extends StatefulWidget {
  @override
  __AddAttractionFormState createState() => __AddAttractionFormState();
}

class __AddAttractionFormState extends State<_AddAttractionForm> {
  final _nameController = TextEditingController();
  final _radiusController = TextEditingController(text: '10.0');
  bool _isLoading = false;

  void _submit() async {
    if (_nameController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Włącz moduł GPS w ustawieniach telefonu!');

      var status = await Permission.location.request();
      if (!status.isGranted) throw Exception('Brak uprawnień GPS');

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: AndroidSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Nie można złapać sygnału GPS. Wyjdź na zewnątrz!');
      });

      final newId = const Uuid().v4();
      final db = Provider.of<AppDatabase>(context, listen: false);

      await db.into(db.attractions).insert(
        AttractionsCompanion(
          id: drift.Value(newId),
          name: drift.Value(_nameController.text.trim()),
          latitude: drift.Value(position.latitude),
          longitude: drift.Value(position.longitude),
          radius: drift.Value(double.tryParse(_radiusController.text) ?? 10.0),
          isActive: const drift.Value(true),
          syncStatus: const drift.Value('PENDING_CREATE'),
        )
      );

      // Spróbuj wysłać, ale jak się nie uda, to zostaje w lokalnej bazie jako PENDING_CREATE
      try {
        final apiClient = ApiClient();
        final response = await apiClient.post('/admin/attractions', {
          'name': _nameController.text.trim(),
          'latitude': position.latitude,
          'longitude': position.longitude,
          'radius': double.tryParse(_radiusController.text) ?? 10.0,
        });

        if (response.statusCode == 200) {
          await (db.update(db.attractions)..where((t) => t.id.equals(newId)))
              .write(const AttractionsCompanion(syncStatus: drift.Value('SYNCED')));
        }
      } catch (e) {
        // Ignorujemy - wyśle się przy najbliższej synchronizacji w SyncService
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Atrakcja zapisana pomyślnie!')));
        _nameController.clear();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Dodaj nową atrakcję na mapie', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nazwa Atrakcji (np. Stary Dąb)')),
          const SizedBox(height: 16),
          TextField(controller: _radiusController, decoration: const InputDecoration(labelText: 'Promień wykrywania (w metrach)'), keyboardType: TextInputType.number),
          const SizedBox(height: 32),
          _isLoading ? const Center(child: CircularProgressIndicator()) : ElevatedButton.icon(
            icon: const Icon(Icons.my_location),
            label: const Text('Pobierz GPS i Zapisz'),
            onPressed: _submit,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
          ),
        ],
      ),
    );
  }
}
