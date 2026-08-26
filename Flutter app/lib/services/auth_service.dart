import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dbcrypt/dbcrypt.dart';
import '../database/database.dart';
import '../api/api_client.dart';

class AuthService extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final AppDatabase _database;
  
  bool _isAuthenticated = false;
  String? _username;
  String? _userId;
  String? _role;

  bool get isAuthenticated => _isAuthenticated;
  String? get username => _username;
  String? get userId => _userId;
  String? get role => _role;
  bool get isAdmin => _role == 'ADMIN';
  bool get isSurveyor => _role == 'SURVEYOR';

  double _gpsTolerance = 1.0;
  double get gpsTolerance => _gpsTolerance;

  AuthService(this._database);

  Future<void> loadTolerance() async {
    String? val = await _storage.read(key: 'gps_tolerance');
    if (val != null) {
      _gpsTolerance = double.tryParse(val) ?? 1.0;
    }
  }

  Future<void> setTolerance(double value) async {
    _gpsTolerance = value;
    await _storage.write(key: 'gps_tolerance', value: value.toString());
    notifyListeners();
  }

  Future<bool> checkLoginStatus() async {
    await loadTolerance();
    String? token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      _isAuthenticated = true;
      _username = await _storage.read(key: 'username');
      _userId = await _storage.read(key: 'userId');
      _role = await _storage.read(key: 'role');
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<String?> login(String username, String password) async {
    try {
      print('--- PRÓBA LOGOWANIA ONLINE DLA $username ---');
      final response = await _apiClient.post('/auth/login', {
        'username': username,
        'password': password,
      });
      print('--- ODPOWIEDŹ LOGOWANIA: ${response.statusCode} ---');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final returnedUserId = data['userId'];
        final returnedUsername = data['username'];
        final returnedRole = data['role'] ?? 'WORKER';

        await _storage.write(key: 'jwt_token', value: token);
        await _storage.write(key: 'userId', value: returnedUserId);
        await _storage.write(key: 'username', value: returnedUsername);
        await _storage.write(key: 'role', value: returnedRole);
        await _storage.write(key: 'saved_password', value: password);
        await _storage.delete(key: 'saved_pin'); // Upewnijmy się, że pin jest wyczyszczony

        _isAuthenticated = true;
        _userId = returnedUserId;
        _username = returnedUsername;
        _role = returnedRole;
        notifyListeners();
        return null; // Brak błędu = Sukces
      } else {
        return "Błędne dane logowania.";
      }
    } catch (e) {
      print('Błąd sieci: $e');
      // Logowanie offline: Szukamy użytkownika w pobranej bazie
      final user = await (_database.select(_database.users)..where((t) => t.username.equals(username))).getSingleOrNull();
      print('Logowanie offline: znaleziono w bazie usera: ${user?.username}');
      
      if (user != null) {
        final dbc = DBCrypt();
        bool isPasswordValid = false;
        
        // Próba weryfikacji jako hasło BCrypt
        if (user.passwordHash.isNotEmpty) {
          isPasswordValid = dbc.checkpw(password, user.passwordHash);
        }
        
        // Jeśli wpisane słowo nie pasuje do hasła, może to PIN? Sprawdźmy PIN.
        if (!isPasswordValid && user.pinHash.isNotEmpty) {
           isPasswordValid = dbc.checkpw(password, user.pinHash);
        }

        if (isPasswordValid) {
          // Generujemy wirtualny token dla trybu offline (ponieważ serwer go nie wydał)
          final token = "offline_token_${user.id}";
          
          await _storage.write(key: 'jwt_token', value: token);
          await _storage.write(key: 'userId', value: user.id);
          await _storage.write(key: 'username', value: user.username);
          await _storage.write(key: 'role', value: user.role);
          await _storage.write(key: 'saved_password', value: password); // Zapisujemy hasło do auto-logowania

          _isAuthenticated = true;
          _userId = user.id;
          _username = user.username;
          _role = user.role;
          notifyListeners();
          return null; // Sukces
        }
      }
      return "Brak internetu, a wpisane dane nie pasują do bazy offline.";
    }
  }

  Future<String?> loginWithPin(String pin) async {
    try {
      print('--- PRÓBA LOGOWANIA ONLINE PIN-EM ---');
      final response = await _apiClient.post('/auth/login-pin', {
        'pin': pin,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final returnedUserId = data['userId'];
        final returnedUsername = data['username'];
        final returnedRole = data['role'] ?? 'WORKER';

        await _storage.write(key: 'jwt_token', value: token);
        await _storage.write(key: 'userId', value: returnedUserId);
        await _storage.write(key: 'username', value: returnedUsername);
        await _storage.write(key: 'role', value: returnedRole);
        await _storage.write(key: 'saved_pin', value: pin);
        await _storage.delete(key: 'saved_password');

        _isAuthenticated = true;
        _userId = returnedUserId;
        _username = returnedUsername;
        _role = returnedRole;
        notifyListeners();
        return null; // Sukces
      } else {
        return "Błędny kod PIN.";
      }
    } catch (e) {
      print('Błąd sieci: $e');
      // Logowanie offline: Szukamy wszystkich użytkowników w bazie
      final users = await _database.select(_database.users).get();
      final dbc = DBCrypt();
      
      for (var user in users) {
        if (user.pinHash.isNotEmpty && dbc.checkpw(pin, user.pinHash)) {
          final token = "offline_token_${user.id}";
          
          await _storage.write(key: 'jwt_token', value: token);
          await _storage.write(key: 'userId', value: user.id);
          await _storage.write(key: 'username', value: user.username);
          await _storage.write(key: 'role', value: user.role);
          await _storage.write(key: 'saved_pin', value: pin);

          _isAuthenticated = true;
          _userId = user.id;
          _username = user.username;
          _role = user.role;
          notifyListeners();
          return null;
        }
      }
      return "Brak internetu, a podany PIN nie pasuje do żadnego użytkownika offline.";
    }
  }

  Future<bool> autoLoginWithSavedCredentials() async {
    String? savedPassword = await _storage.read(key: 'saved_password');
    if (savedPassword != null && savedPassword.isNotEmpty) {
      String? username = await _storage.read(key: 'username');
      if (username != null) {
        try {
          final response = await _apiClient.post('/auth/login', {
            'username': username,
            'password': savedPassword
          });
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            await _storage.write(key: 'jwt_token', value: data['token']);
            return true;
          }
        } catch (e) {
          // Ignore
        }
      }
    }

    String? savedPin = await _storage.read(key: 'saved_pin');
    if (savedPin == null || savedPin.isEmpty) return false;
    
    // Próbujemy uderzyć do endpointu online
    try {
      final response = await _apiClient.post('/auth/login-pin', {'pin': savedPin});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'jwt_token', value: data['token']);
        return true;
      }
    } catch (e) {
      // Ignorujemy błędy, bo to jest tylko ciche logowanie
    }
    return false;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'userId');
    await _storage.delete(key: 'username');
    await _storage.delete(key: 'role');
    await _storage.delete(key: 'saved_pin');
    _isAuthenticated = false;
    _userId = null;
    _username = null;
    _role = null;
    notifyListeners();
  }
}
