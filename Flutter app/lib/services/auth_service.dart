import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';

class AuthService extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  bool _isAuthenticated = false;
  String? _username;
  String? _userId;
  String? _role;

  bool get isAuthenticated => _isAuthenticated;
  String? get username => _username;
  String? get userId => _userId;
  String? get role => _role;
  bool get isAdmin => _role == 'ADMIN';

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

  Future<bool> login(String username, String password) async {
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
        return true;
      }
    } catch (e) {
      print('Login error: $e');
    }
    return false;
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
