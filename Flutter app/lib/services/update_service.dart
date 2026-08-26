import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  // Podmień na link do Twojego surowego pliku z wersją (np. z Githuba, Raw File)
  // Przykładowy format pliku json pod tym adresem:
  // { "version": "1.0.1", "downloadUrl": "https://github.com/TwojLogin/TwojeRepo/releases/download/v1.0.1/app-release.apk", "releaseNotes": "Poprawki bezpieczeństwa" }
  static const String _updateUrl = 'https://raw.githubusercontent.com/twoj-login/twoje-repo/main/version.json';

  Future<void> checkForUpdates(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(_updateUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final latestVersion = data['version'] as String;
        final downloadUrl = data['downloadUrl'] as String;
        final releaseNotes = data['releaseNotes'] ?? 'Dostępna nowa wersja.';

        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version;

        if (_isNewerVersion(currentVersion, latestVersion)) {
          if (context.mounted) {
            _showUpdateDialog(context, latestVersion, releaseNotes, downloadUrl);
          }
        }
      }
    } catch (e) {
      print('Błąd podczas sprawdzania aktualizacji: $e');
    }
  }

  bool _isNewerVersion(String current, String latest) {
    final currentParts = current.split('.').map(int.parse).toList();
    final latestParts = latest.split('.').map(int.parse).toList();

    for (int i = 0; i < currentParts.length; i++) {
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  void _showUpdateDialog(BuildContext context, String version, String notes, String url) {
    showDialog(
      context: context,
      barrierDismissible: false, // Wymusza podjęcie decyzji (ustaw na true jeśli opcjonalne)
      builder: (ctx) => AlertDialog(
        title: Text('Nowa aktualizacja: v$version'),
        content: Text(notes),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Później', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('Aktualizuj'),
          ),
        ],
      ),
    );
  }
}
