import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import 'auth_service.dart';
import 'notification_service.dart';

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

  void startGeofencing() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2, // aktualizacja co 2 metry
        forceLocationManager: true,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText: "Monitorowanie wejść i wyjść ze stref w tle.",
          notificationTitle: "Śledzenie Stref Aktywne",
          enableWakeLock: true,
        ),
      ),
    ).listen((Position position) {
      _processLocation(position);
    });
  }

  void stopGeofencing() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  Future<void> _processLocation(Position position) async {
    if (!_authService.isAuthenticated) return;

    final allAttractions = await _db.select(_db.attractions).get();
    final attractions = allAttractions.where((a) => a.isActive).toList();
    
    Attraction? closestAttraction;
    double minDistance = double.infinity;

    for (var attraction in attractions) {
      if (!attraction.isActive) continue;
      
      double distance = Geolocator.distanceBetween(
        position.latitude, position.longitude,
        attraction.latitude, attraction.longitude,
      );

      // Margines 5 metrów jak prosił użytkownik
      double triggerRadius = attraction.radius + 5.0;

      if (distance <= triggerRadius && distance < minDistance) {
        minDistance = distance;
        closestAttraction = attraction;
      }
    }

    if (closestAttraction != null) {
      // Jesteśmy w zasięgu jakiejś atrakcji
      if (_currentActiveAttractionId != closestAttraction.id) {
        // Zmieniliśmy strefę! Albo weszliśmy z zewnątrz.
        if (_currentActiveAttractionId != null) {
          await stopCurrentMeasurement(); // Zakończ poprzedni
        }
        await _handleZoneEntry(closestAttraction);
      }
    } else {
      // Wyszliśmy ze wszystkich stref
      if (_currentActiveAttractionId != null) {
        await stopCurrentMeasurement();
      }
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

  // Funkcja używana przez UI dla Admina do manualnego startu
  Future<void> startMeasurementManually() async {
    if (_currentActiveAttractionId == null) return;
    
    _currentMeasurementId = const Uuid().v4();
    _currentMeasurementStartTime = DateTime.now();
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
        final stopTime = DateTime.now();
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
