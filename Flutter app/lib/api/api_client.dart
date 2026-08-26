import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  // Adres produkcyjny VM w lesie (zmień na 10.0.2.2 dla emulatora)
  // Adres serwera LAN / Roboczego
  static String baseUrl = 'http://192.168.151.13:8080/api';
  
  static String get mapUrl {
    return baseUrl.replaceAll('/api', '/mapa.html');
  }

  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    String? token = await _storage.read(key: 'jwt_token');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    debugPrint('--- WYSYŁAMY ŻĄDANIE Z TOKENEM: $token ---');
    return headers;
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    return http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 5));
  }

  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    return http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    ).timeout(const Duration(seconds: 5));
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    return http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 5));
  }

  Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    return http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    ).timeout(const Duration(seconds: 5));
  }
}
