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

  AuthService(this._database);

  Future<bool> checkLoginStatus() async {
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
      final response = await _apiClient.post('/auth/login', {
        'username': username,
        'password': password,
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

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'userId');
    await _storage.delete(key: 'username');
    await _storage.delete(key: 'role');
    _isAuthenticated = false;
    _userId = null;
    _username = null;
    _role = null;
    notifyListeners();
  }
}
