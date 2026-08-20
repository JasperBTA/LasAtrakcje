import 'dart:convert';
import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../database/database.dart';
import 'package:drift/drift.dart' as drift;

class SyncService extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final AppDatabase _database;
  bool _isSyncing = false;

  bool get isSyncing => _isSyncing;

  SyncService(this._database);

  Future<String> syncAll() async {
    if (_isSyncing) return "Synchronizacja już trwa...";
    _isSyncing = true;
    notifyListeners();

    try {
      final resultMeasurements = await syncMeasurements(notify: false);
      await syncAttractionsCoordinates();
      await syncNewAttractions();
      await syncUsers();
      final resultAttractions = await fetchAttractions(notify: false);

      final message = [resultMeasurements, resultAttractions]
          .where((e) => e != null)
          .toSet()
          .join('\n');
      return message.isEmpty ? "Zsynchronizowano." : message;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<String?> fetchAttractions({bool notify = true}) async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await _apiClient.get('/attractions');
      final httpTime = stopwatch.elapsedMilliseconds;
      
      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is List) {
          stopwatch.reset();
          await _database.transaction(() async {
            for (var item in decoded) {
              await _database.into(_database.attractions).insertOnConflictUpdate(
                AttractionsCompanion(
                  id: drift.Value(item['id'] ?? ''),
                  name: drift.Value(item['name'] ?? 'Nieznana'),
                  latitude: drift.Value((item['latitude'] as num?)?.toDouble() ?? 0.0),
                  longitude: drift.Value((item['longitude'] as num?)?.toDouble() ?? 0.0),
                  radius: drift.Value((item['radius'] as num?)?.toDouble() ?? 10.0),
                  isActive: drift.Value(item['isActive'] ?? item['active'] ?? true),
                  syncStatus: const drift.Value('SYNCED'),
                )
              );
            }
          });
          final sqlTime = stopwatch.elapsedMilliseconds;
          return "Pobrano atrakcje (HTTP: ${httpTime}ms, SQL: ${sqlTime}ms)";
        } else {
          return 'Błąd: Nieoczekiwany format danych (HTTP: ${httpTime}ms)';
        }
      } else {
        return 'Błąd HTTP ${response.statusCode} (${httpTime}ms)';
      }
    } catch (e) {
      return 'Brak połączenia z siecią, spróbuj ponownie gdy odzyskasz połączenie';
    }
  }

  Future<String?> syncMeasurements({bool notify = true}) async {
    if (_isSyncing && notify) return null; // Zabezpieczenie przed podwójnym kliknięciem, jeśli notify = true
    if (notify) {
      _isSyncing = true;
      notifyListeners();
    }

    final stopwatch = Stopwatch()..start();
    try {
      final pendingMeasurements = await (_database.select(_database.measurements)
            ..where((t) => t.syncStatus.equals('PENDING') | t.syncStatus.equals('FAILED')))
          .get();

      if (pendingMeasurements.isEmpty) {
        return "Brak nowych pomiarów do wysłania.";
      }

      final payload = {
        'measurements': pendingMeasurements.map((m) => {
          'id': m.id,
          'operatorId': m.operatorId,
          'attractionId': m.attractionId,
          'startTime': m.startTime.toIso8601String(),
          'stopTime': m.stopTime?.toIso8601String(),
          'totalDurationSeconds': m.totalDurationSeconds,
        }).toList()
      };

      stopwatch.reset();
      final response = await _apiClient.post('/sync/measurements', payload);
      final httpTime = stopwatch.elapsedMilliseconds;

      stopwatch.reset();
      if (response.statusCode == 200) {
        for (var m in pendingMeasurements) {
          await (_database.update(_database.measurements)..where((t) => t.id.equals(m.id)))
              .write(const MeasurementsCompanion(syncStatus: drift.Value('SYNCED')));
        }
        final sqlTime = stopwatch.elapsedMilliseconds;
        return "Wysłano pomiary (${pendingMeasurements.length}) -> HTTP: ${httpTime}ms, SQL: ${sqlTime}ms";
      } else {
        for (var m in pendingMeasurements) {
          await (_database.update(_database.measurements)..where((t) => t.id.equals(m.id)))
              .write(const MeasurementsCompanion(syncStatus: drift.Value('FAILED')));
        }
        print('HTTP ${response.statusCode} BODY: ${response.body}');
        return "Błąd wysyłania (HTTP ${response.statusCode}, ${httpTime}ms) - ${response.body}";
      }
    } catch (e) {
      return 'Brak połączenia z siecią, spróbuj ponownie gdy odzyskasz połączenie';
    } finally {
      if (notify) {
        _isSyncing = false;
        notifyListeners();
      }
    }
  }

  Future<void> syncAttractionsCoordinates() async {
    try {
      final pendingAttractions = await (_database.select(_database.attractions)
            ..where((t) => t.syncStatus.equals('PENDING_UPDATE')))
          .get();

      if (pendingAttractions.isEmpty) return;

      final payload = {
        'attractions': pendingAttractions.map((a) => {
          'id': a.id,
          'latitude': a.latitude,
          'longitude': a.longitude,
          'name': a.name,
          'radius': a.radius,
          'isActive': a.isActive,
        }).toList()
      };

      final response = await _apiClient.post('/attractions/sync', payload);

      if (response.statusCode == 200) {
        for (var a in pendingAttractions) {
          await (_database.update(_database.attractions)..where((t) => t.id.equals(a.id)))
              .write(const AttractionsCompanion(syncStatus: drift.Value('SYNCED')));
        }
      }
    } catch (e) {
      print('Sync attractions error: $e');
    }
  }

  Future<void> syncNewAttractions() async {
    try {
      final newAttractions = await (_database.select(_database.attractions)
            ..where((t) => t.syncStatus.equals('PENDING_CREATE')))
          .get();

      if (newAttractions.isEmpty) return;

      for (var a in newAttractions) {
        final payload = {
          'name': a.name,
          'latitude': a.latitude,
          'longitude': a.longitude,
          'radius': a.radius,
        };
        final response = await _apiClient.post('/admin/attractions', payload);
        
        if (response.statusCode == 200) {
          // Usuwamy tymczasowy lokalny rekord, zaraz i tak zostanie pobrany z bazy z nowym UUID z serwera
          await (_database.delete(_database.attractions)..where((t) => t.id.equals(a.id))).go();
        }
      }
    } catch (e) {
      print('Sync new attractions error: $e');
    }
  }

  Future<void> syncUsers() async {
    try {
      final response = await _apiClient.get('/sync/users');
      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is List) {
          await _database.transaction(() async {
            for (var item in decoded) {
              await _database.into(_database.users).insertOnConflictUpdate(
                UsersCompanion(
                  id: drift.Value(item['id'] ?? ''),
                  username: drift.Value(item['username'] ?? ''),
                  passwordHash: drift.Value(item['passwordHash'] ?? ''),
                  pinHash: drift.Value(item['pinHash'] ?? ''),
                  role: drift.Value(item['role'] ?? 'WORKER'),
                )
              );
            }
          });
        }
      } else {
        print('Sync users failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Sync users error: $e');
    }
  }
}
