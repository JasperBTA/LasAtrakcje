import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:drift/drift.dart' as drift;
import '../database/database.dart';
import '../api/api_client.dart';
import 'dart:convert';

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
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Brak uprawnień do lokalizacji!')),
      );
      return;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Włącz usługi lokalizacyjne (GPS)!')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      // Aktualizacja w bazie (zmiana statusu na PENDING)
      await (db.update(db.attractions)..where((t) => t.id.equals(attraction.id)))
          .write(AttractionsCompanion(
            latitude: drift.Value(position.latitude),
            longitude: drift.Value(position.longitude),
            syncStatus: const drift.Value('PENDING'),
          ));

      Navigator.pop(context); // Zamknij spinner

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Zapisano GPS dla: ${attraction.name}')),
      );
    } catch (e) {
      Navigator.pop(context); // Zamknij spinner
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd pobierania pozycji: $e')),
      );
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
                  
                  // Update API
                  try {
                    final apiClient = ApiClient();
                    final response = await apiClient.put('/admin/attractions/${attraction.id}', {
                      'name': newName,
                      'radius': newRadius,
                      'isActive': isActive,
                    });
                    if (response.statusCode == 200) {
                      // Zapisz lokalnie by odzwierciedlić zmianę na liście (jeśli używamy strumienia z lokalnej bazy)
                      await (db.update(db.attractions)..where((t) => t.id.equals(attraction.id)))
                        .write(AttractionsCompanion(
                          name: drift.Value(newName),
                          radius: drift.Value(newRadius),
                          isActive: drift.Value(isActive),
                        ));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Zaktualizowano atrakcję!')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Błąd serwera.')));
                    }
                  } catch (e) {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Błąd połączenia.')));
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

  Widget _buildGpsManagementTab(AppDatabase db) {
    _attractionsStream ??= db.select(db.attractions).watch();
    return Column(
      children: [
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
                  final isPending = attraction.syncStatus == 'PENDING';
                  
                  return ListTile(
                    title: Text(attraction.name),
                    subtitle: Text(
                      isPending ? 'Niezsynchronizowane' : (attraction.isActive ? 'Zgrane z serwerem' : 'Nieaktywna'),
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Użytkownik usunięty.')));
        _fetchUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd: Nie można usunąć admina.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Błąd połączenia.')));
    }
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
              return ListTile(
                leading: CircleAvatar(child: Icon(u['role'] == 'ADMIN' ? Icons.admin_panel_settings : Icons.person)),
                title: Text(u['username']),
                subtitle: Text(u['role']),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteUser(u['id']),
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
  String _role = 'WORKER';
  bool _isLoading = false;

  void _submit() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final apiClient = ApiClient();
      final response = await apiClient.post('/admin/users', {
        'username': _usernameController.text.trim(),
        'password': _passwordController.text.trim(),
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
          DropdownButtonFormField<String>(
            value: _role,
            items: const [
              DropdownMenuItem(value: 'WORKER', child: Text('Pracownik')),
              DropdownMenuItem(value: 'ADMIN', child: Text('Administrator')),
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
      var status = await Permission.location.request();
      if (!status.isGranted) throw Exception('Brak uprawnień GPS');

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

      final apiClient = ApiClient();
      final response = await apiClient.post('/admin/attractions', {
        'name': _nameController.text.trim(),
        'latitude': position.latitude,
        'longitude': position.longitude,
        'radius': double.tryParse(_radiusController.text) ?? 10.0,
      });

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Atrakcja dodana na serwer!')));
          _nameController.clear();
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd: ${response.statusCode}')));
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
