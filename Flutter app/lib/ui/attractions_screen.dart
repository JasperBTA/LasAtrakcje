import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/sync_service.dart';
import '../database/database.dart';
import 'login_screen.dart';
import 'work_screen.dart';
import 'admin_screen.dart';
import 'dart:async';
import '../services/geofence_service.dart';
import '../api/api_client.dart';
import 'radar_screen.dart';

class AttractionsScreen extends StatefulWidget {
  const AttractionsScreen({Key? key}) : super(key: key);

  @override
  _AttractionsScreenState createState() => _AttractionsScreenState();
}

class _AttractionsScreenState extends State<AttractionsScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Pobierz z API od razu po otwarciu ekranu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final syncService = Provider.of<SyncService>(context, listen: false);
      syncService.syncAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = value;
        });
      }
    });
  }

  void _logout() async {
    await Provider.of<AuthService>(context, listen: false).logout();
    if (mounted) {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => const LoginScreen())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // NIE nasłuchujemy całej klasy SyncService ani GeofenceService, żeby nie odświeżać całego ekranu
    final db = Provider.of<AppDatabase>(context, listen: false);
    
    // Przebuduje się jedynie wtedy, kiedy zatwierdzimy nową frazę (dzięki debounce)
    final stream = db.watchActiveAttractions(_searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Tryb Odkrywcy 📡'),
                content: const Text('Czy chcesz otworzyć radar sferyczny?'),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Anuluj'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RadarScreen()));
                    },
                    child: const Text('Otwórz Radar'),
                  ),
                ],
              ),
            );
          },
          child: const Text('Wybierz Atrakcję'),
        ),
        actions: [
          if (Provider.of<AuthService>(context, listen: false).isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Panel Administratora',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen()));
              },
            ),
          Consumer<SyncService>(
            builder: (context, syncService, child) {
              return IconButton(
                icon: syncService.isSyncing 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.sync),
                onPressed: () async {
                  final message = await syncService.syncAll();
                  if (context.mounted && message.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message), duration: const Duration(seconds: 4)),
                    );
                    // Jeżeli pracownik stoi w miejscu podczas pobierania bazy,
                    // wymuszamy ręczne sprawdzenie promienia GPS.
                    Provider.of<GeofenceService>(context, listen: false).forceLocationCheck();
                  }
                },
              );
            }
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Consumer<GeofenceService>(
            builder: (context, geofenceService, child) {
              return _ActiveMeasurementBanner(
                geofenceService: geofenceService,
                attractionsStream: db.select(db.attractions).watch(),
              );
            }
          ),
          
          if (Provider.of<AuthService>(context, listen: false).isAdmin) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  labelText: 'Szukaj atrakcji...',
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
                stream: stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  
                  final attractions = snapshot.data!;

                  if (attractions.isEmpty) {
                    if (_searchQuery.isNotEmpty) {
                      return const Center(child: Text('Nie znaleziono atrakcji dla tego hasła.'));
                    }
                    return const Center(child: Text('Brak zapisanych atrakcji. Kliknij ikonę synchronizacji.'));
                  }

                  return ListView.builder(
                    itemCount: attractions.length,
                    itemBuilder: (context, index) {
                      final attraction = attractions[index];
                      // Consumer punktowy tylko dla konkretnego elementu listy
                      return Consumer<GeofenceService>(
                        builder: (context, geofenceService, child) {
                          final isActiveGeofence = geofenceService.currentActiveAttractionId == attraction.id;
                          return AttractionListItem(
                            attraction: attraction,
                            isActiveGeofence: isActiveGeofence,
                          );
                        }
                      );
                    },
                  );
                },
              ),
            ),
          ] else ...[
            const Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.radar, size: 80, color: Colors.grey),
                      SizedBox(height: 24),
                      Text(
                        'Oczekiwanie na strefę...',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Aplikacja automatycznie rozpocznie pomiar czasu, gdy zbliżysz się do przypisanej atrakcji w lesie.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AttractionListItem extends StatelessWidget {
  final Attraction attraction;
  final bool isActiveGeofence;

  const AttractionListItem({
    Key? key,
    required this.attraction,
    required this.isActiveGeofence,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: isActiveGeofence ? Colors.green.withValues(alpha: 0.2) : null,
      title: Text(attraction.name, style: TextStyle(fontWeight: isActiveGeofence ? FontWeight.bold : FontWeight.normal)),
      subtitle: isActiveGeofence ? const Text('Trwa automatyczny pomiar (Jesteś w strefie)', style: TextStyle(color: Colors.green)) : null,
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkScreen(attraction: attraction),
          ),
        );
      },
    );
  }
}

class _ActiveMeasurementBanner extends StatefulWidget {
  final GeofenceService geofenceService;
  final Stream<List<Attraction>>? attractionsStream;

  const _ActiveMeasurementBanner({
    Key? key,
    required this.geofenceService,
    required this.attractionsStream,
  }) : super(key: key);

  @override
  __ActiveMeasurementBannerState createState() => __ActiveMeasurementBannerState();
}

class __ActiveMeasurementBannerState extends State<_ActiveMeasurementBanner> {
  Timer? _timer;
  String _formattedTime = "00:00:00";

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (widget.geofenceService.currentMeasurementStartTime != null) {
        final duration = DateTime.now().difference(widget.geofenceService.currentMeasurementStartTime!);
        final hours = duration.inHours.toString().padLeft(2, '0');
        final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
        final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
        if (mounted) {
          setState(() {
            _formattedTime = "$hours:$minutes:$seconds";
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.geofenceService.currentActiveAttractionId == null) {
      return const SizedBox.shrink(); // Ukryty, jeśli brak aktywnego pomiaru (brak strefy)
    }

    return StreamBuilder<List<Attraction>>(
      stream: widget.attractionsStream,
      builder: (context, snapshot) {
        String attractionName = "Nieznana strefa";
        if (snapshot.hasData) {
          final matched = snapshot.data!.where((a) => a.id == widget.geofenceService.currentActiveAttractionId);
          if (matched.isNotEmpty) {
            attractionName = matched.first.name;
          }
        }

        final bool isMeasurementActive = widget.geofenceService.isMeasurementActive;
        // Zdobądź Auth z drzewa za pomocą GeofenceService, upewniając się że jest adminem
        final authService = Provider.of<AuthService>(context, listen: false);
        final isAdmin = authService.isAdmin;

        if (!isMeasurementActive) {
          // Admin jest w strefie, ale jeszcze nie kliknął startu
          return Container(
            width: double.infinity,
            color: Colors.blueAccent, // Zmiana koloru dla oczekiwania
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              children: [
                Text('JESTEŚ W STREFIE: $attractionName', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blueAccent),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("ROZPOCZNIJ POMIAR"),
                  onPressed: () {
                    widget.geofenceService.startMeasurementManually();
                  },
                )
              ],
            ),
          );
        }

        // Pomiar trwa
        return Container(
          width: double.infinity,
          color: const Color(0xFFF47C20), // Pomarańcz z logo
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.timer, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TRWA POMIAR GEOFENCE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(attractionName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Text(
                    _formattedTime,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                ],
              ),
              if (isAdmin) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.redAccent.withValues(alpha: 0.8)),
                      icon: const Icon(Icons.delete_forever),
                      label: const Text("Odrzuć pomiar (Pomyłka)"),
                      onPressed: () {
                        widget.geofenceService.rejectMeasurement();
                      },
                    ),
                  ],
                ),
              ]
            ],
          ),
        );
      },
    );
  }
}
