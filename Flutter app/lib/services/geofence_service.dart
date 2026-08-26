import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ntp/ntp.dart';
import '../database/database.dart';
import 'auth_service.dart';
import 'notification_service.dart';

import 'package:flutter/foundation.dart'; // dla defaultTargetPlatform

class GeofenceService extends ChangeNotifier {
  final AppDatabase _db;
  final AuthService _authService;
  StreamSubscription<Position>? _positionStream;

  String? _currentActiveAttractionId;
  String? _currentMeasurementId;
  DateTime? _currentMeasurementStartTime;
  bool _isMeasurementActive = false; // Rozróżnienie, czy admin zaakceptował start

  String? get currentActiveAttractionId => _currentActiveAttractionId;
  DateTime? get currentMeasurementStartTime => _currentMeasurementStartTime;
  bool get isMeasurementActive => _isMeasurementActive;

  GeofenceService(this._db, this._authService);

  Timer? _fallbackTimer;
  Timer? _exitBufferTimer;
  Timer? _entryBufferTimer;
  String? _pendingEntryAttractionId;

  void startGeofencing() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      if (await Permission.ignoreBatteryOptimizations.isDenied) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    }

    late LocationSettings locationSettings;
    
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0, // 0 = Zgłaszaj każdy ruch / czas
        intervalDuration: const Duration(seconds: 5), // Częste odświeżanie
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText: "Śledzenie aktywności w terenie...",
          notificationTitle: "Geofence Pracuje",
          enableWakeLock: true,
        ),
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      );
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _processLocation(position);
    });
    
    // Zabezpieczenie na wypadek uśpienia strumienia przez Android
    _fallbackTimer?.cancel();
    _fallbackTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      forceLocationCheck();
    });

    // Wymuszenie natychmiastowego sprawdzenia stref
    forceLocationCheck();
  }

  void stopGeofencing() {
    _positionStream?.cancel();
    _positionStream = null;
    _fallbackTimer?.cancel();
    _fallbackTimer = null;
    _exitBufferTimer?.cancel();
    _exitBufferTimer = null;
    _entryBufferTimer?.cancel();
    _entryBufferTimer = null;
    _pendingEntryAttractionId = null;
  }

  Future<void> _processLocation(Position position) async {
    if (!_authService.isAuthenticated) return;

    // 1. Pobranie globalnych ustawień konfiguracyjnych (z opóźnieniem domyślnym)
    final settingsList = await _db.select(_db.globalSettings).get();
    final settings = settingsList.isNotEmpty ? settingsList.first : const GlobalSetting(
        id: 1, gpsAccuracyThreshold: 50, entryBufferSeconds: 4, exitBufferSeconds: 45, hysteresisMargin: 10
    );

    // 2. Accuracy Filter (Odrzucanie anomalii np. z masztów GSM)
    if (position.accuracy > settings.gpsAccuracyThreshold) {
      debugPrint("Zignorowano pozycję: dokładność ${position.accuracy}m jest gorsza niż próg ${settings.gpsAccuracyThreshold}m.");
      return;
    }

    final allAttractions = await _db.select(_db.attractions).get();
    final attractions = allAttractions.where((a) => a.isActive).toList();
    
    Attraction? bestAttraction;
    double bestRelativeDepth = double.infinity;

    for (var attraction in attractions) {
      if (!attraction.isActive) continue;
      
      double distance = Geolocator.distanceBetween(
        position.latitude, position.longitude,
        attraction.latitude, attraction.longitude,
      );

      bool isCurrentlyActive = _currentActiveAttractionId == attraction.id;
      
      // 3. Histereza - Strefa wyjścia jest powiększona o margines dla obecnej strefy
      double triggerRadius = attraction.radius + (isCurrentlyActive ? settings.hysteresisMargin : 0);

      if (distance <= triggerRadius) {
        // 4. Priorytetyzacja Głębi (Relative Depth Priority)
        // Jeśli strefy się nakładają, faworyzujemy tę, w której jesteśmy najgłębiej
        double relativeDepth = distance - attraction.radius;
        if (relativeDepth < bestRelativeDepth) {
          bestRelativeDepth = relativeDepth;
          bestAttraction = attraction;
        }
      }
    }

    if (bestAttraction != null) {
      // Jesteśmy w zasięgu atrakcji. Anulujemy ewentualne odliczanie wyjścia.
      _exitBufferTimer?.cancel();
      _exitBufferTimer = null;
      
      if (_currentActiveAttractionId != bestAttraction.id) {
        // Weszliśmy w nową strefę (lub przenieśliśmy się do głębszej)
        if (_pendingEntryAttractionId != bestAttraction.id) {
          _pendingEntryAttractionId = bestAttraction.id;
          
          _entryBufferTimer?.cancel();
          _entryBufferTimer = Timer(Duration(seconds: settings.entryBufferSeconds), () async {
            // Po odczekaniu bufora wejścia ostatecznie przełączamy strefę
            if (_currentActiveAttractionId != null) {
              await stopCurrentMeasurement(); // Zakończ poprzedni bezzwłocznie
            }
            await _handleZoneEntry(bestAttraction!);
            _pendingEntryAttractionId = null;
          });
        }
      } else {
        // Jesteśmy wciąż w naszej aktywnej strefie, anulujemy wszelkie próby przejęcia przez inne poboczne strefy
        _pendingEntryAttractionId = null;
        _entryBufferTimer?.cancel();
      }
    } else {
      // Wyszliśmy ze wszystkich stref
      _pendingEntryAttractionId = null;
      _entryBufferTimer?.cancel();

      if (_currentActiveAttractionId != null && _exitBufferTimer == null) {
        // 5. Bufor Wyjścia (Exit Buffer / GPS Drift protection)
        _exitBufferTimer = Timer(Duration(seconds: settings.exitBufferSeconds), () async {
          await stopCurrentMeasurement();
          _exitBufferTimer = null;
        });
      }
    }
  }

  // Wymusza jednorazowe sprawdzenie strefy (np. zaraz po zsynchronizowaniu nowych atrakcji)
  Future<void> forceLocationCheck() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _processLocation(position);
    } catch (e) {
      print("Błąd pobierania wymuszonej lokalizacji: $e");
    }
  }

  Future<void> _handleZoneEntry(Attraction attraction) async {
    _currentActiveAttractionId = attraction.id;
    final isAdmin = _authService.isAdmin;

    if (isAdmin) {
      // Admin: Wszedł do strefy, ale nie zaczynamy pomiaru automatycznie
      _isMeasurementActive = false;
      NotificationService().showNotification(
        "Jesteś w strefie", 
        "Jesteś przy: ${attraction.name}. Otwórz aplikację, aby ręcznie rozpocząć pomiar."
      );
    } else {
      // Pracownik: Automatyczny pomiar
      await startMeasurementManually(); 
      NotificationService().showNotification(
        "Rozpoczęto pomiar", 
        "Rozpoczęto naliczanie czasu na atrakcji: ${attraction.name}"
      );
    }
    notifyListeners();
  }

  Future<DateTime> _getPreciseTime() async {
    try {
      // Szybki timeout 2 sekundy - jeśli jesteśmy głęboko w lesie bez zasięgu, natychmiast wraca do czasu systemowego
      return await NTP.now(timeout: const Duration(seconds: 2));
    } catch (e) {
      return DateTime.now();
    }
  }

  // Funkcja używana przez UI dla Admina do manualnego startu
  Future<void> startMeasurementManually() async {
    if (_currentActiveAttractionId == null) return;
    
    _currentMeasurementId = const Uuid().v4();
    _currentMeasurementStartTime = await _getPreciseTime();
    _isMeasurementActive = true;

    await _db.into(_db.measurements).insert(
      MeasurementsCompanion(
        id: drift.Value(_currentMeasurementId!),
        operatorId: drift.Value(_authService.userId!),
        attractionId: drift.Value(_currentActiveAttractionId!),
        startTime: drift.Value(_currentMeasurementStartTime!),
        syncStatus: const drift.Value('PENDING'),
      ),
    );
    notifyListeners();
  }

  // Używana również do odrzucenia pomiaru przez Admina
  Future<void> rejectMeasurement() async {
    if (_currentMeasurementId != null) {
      // Usuwamy niechciany pomiar z lokalnej bazy danych całkowicie
      await (_db.delete(_db.measurements)..where((t) => t.id.equals(_currentMeasurementId!))).go();
    }
    _isMeasurementActive = false;
    _currentMeasurementId = null;
    _currentMeasurementStartTime = null;
    notifyListeners();
  }

  Future<void> stopCurrentMeasurement() async {
    // Jeśli pomiar faktycznie trwał (albo u pracownika, albo admin go odpalił ręcznie)
    if (_isMeasurementActive && _currentMeasurementId != null) {
      final measurement = await (_db.select(_db.measurements)
            ..where((t) => t.id.equals(_currentMeasurementId!)))
          .getSingleOrNull();

      if (measurement != null) {
        final stopTime = await _getPreciseTime();
        final duration = stopTime.difference(measurement.startTime).inSeconds;

        await (_db.update(_db.measurements)..where((t) => t.id.equals(_currentMeasurementId!)))
            .write(MeasurementsCompanion(
          stopTime: drift.Value(stopTime),
          totalDurationSeconds: drift.Value(duration),
          syncStatus: const drift.Value('PENDING'),
        ));
      }
      
      // Powiadomienie tylko jeśli faktycznie zapisaliśmy pomiar
      NotificationService().showNotification(
        "Zakończono pomiar", 
        "Czas pracy w strefie został zapisany."
      );
    }

    _currentActiveAttractionId = null;
    _currentMeasurementId = null;
    _currentMeasurementStartTime = null;
    _isMeasurementActive = false;
    notifyListeners();
  }

}
