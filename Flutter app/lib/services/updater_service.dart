import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdaterService {
  // TODO: Zmień ten URL na link do pliku raw na Twoim GitHubie (version.json)
  static const String _versionUrl = 'https://raw.githubusercontent.com/twoj-profil/twoje-repo/main/version.json';
  
  // Plik version.json powinien wyglądać tak na GitHubie:
  // {
  //   "version": "1.0.1",
  //   "android_apk_url": "https://github.com/...",
  //   "ios_url": "https://testflight.apple.com/join/..."
  // }

  static Future<void> checkForUpdates(BuildContext context, {bool showNoUpdateMessage = false}) async {
    try {
      final dio = Dio();
      final response = await dio.get(_versionUrl);
      
      if (response.statusCode == 200) {
        final data = response.data is String ? jsonDecode(response.data) : response.data;
        final latestVersion = data['version'] as String;
        
        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version;

        if (_isNewerVersion(currentVersion, latestVersion)) {
          if (context.mounted) {
            _showUpdateDialog(
              context, 
              latestVersion, 
              data['android_apk_url'] as String?,
              data['ios_url'] as String?,
            );
          }
        } else {
          if (context.mounted && showNoUpdateMessage) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Aplikacja jest aktualna!')),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Błąd sprawdzania aktualizacji: $e');
      if (context.mounted && showNoUpdateMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nie udało się sprawdzić aktualizacji.')),
        );
      }
    }
  }

  static bool _isNewerVersion(String current, String latest) {
    final currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final latestParts = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    
    for (int i = 0; i < latestParts.length; i++) {
      int curr = i < currentParts.length ? currentParts[i] : 0;
      if (latestParts[i] > curr) return true;
      if (latestParts[i] < curr) return false;
    }
    return false;
  }

  static void _showUpdateDialog(BuildContext context, String newVersion, String? androidUrl, String? iosUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Aktualizacja Dostępna'),
        content: Text('Nowa wersja $newVersion jest dostępna do pobrania. Czy chcesz ją zainstalować teraz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Później', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B8B39), 
              foregroundColor: Colors.white
            ),
            onPressed: () {
              Navigator.pop(context);
              if (Platform.isAndroid && androidUrl != null) {
                _downloadAndInstallApk(context, androidUrl);
              } else if (Platform.isIOS && iosUrl != null) {
                launchUrl(Uri.parse(iosUrl), mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Brak linku aktualizacji dla Twojej platformy.')),
                );
              }
            },
            child: const Text('Zaktualizuj'),
          ),
        ],
      ),
    );
  }

  static Future<void> _downloadAndInstallApk(BuildContext context, String apkUrl) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF1B8B39)),
            SizedBox(height: 16),
            Text('Pobieranie aktualizacji...\nProszę czekać.'),
          ],
        ),
      ),
    );

    try {
      final dio = Dio();
      final tempDir = await getTemporaryDirectory();
      final savePath = '${tempDir.path}/app-update.apk';

      await dio.download(apkUrl, savePath);

      if (context.mounted) Navigator.pop(context); // Zamknij dialog ładowania

      final result = await OpenFilex.open(savePath);
      debugPrint('Status instalacji: ${result.message}');
      
      if (result.type != ResultType.done && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd uruchamiania instalatora: ${result.message}')),
        );
      }

    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Wystąpił błąd podczas pobierania: $e')),
        );
      }
    }
  }
}
