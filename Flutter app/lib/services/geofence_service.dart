import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import 'auth_service.dart';

class GeofenceService extends ChangeNotifier {
  final AppDatabase _db;
  final AuthService _authService;
  StreamSubscription<Position>? _positionStream;

  String? _currentActiveAttractionId;
  String? _currentMeasurementId;
  DateTime? _currentMeasurementStartTime;

  String? get currentActiveAttractionId => _currentActiveAttractionId;
  DateTime? get currentMeasurementStartTime => _currentMeasurementStartTime;

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
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2, // aktualizacja co 2 metry
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

    final attractions = await _db.select(_db.attractions).get();
    
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
        await _stopCurrentMeasurement();
        await _startMeasurement(closestAttraction.id);
      }
    } else {
      // Wyszliśmy ze wszystkich stref
      if (_currentActiveAttractionId != null) {
        await _stopCurrentMeasurement();
      }
    }
  }

  Future<void> _startMeasurement(String attractionId) async {
    _currentActiveAttractionId = attractionId;
    _currentMeasurementId = const Uuid().v4();
    _currentMeasurementStartTime = DateTime.now();

    await _db.into(_db.measurements).insert(
      MeasurementsCompanion(
        id: drift.Value(_currentMeasurementId!),
        operatorId: drift.Value(_authService.userId!),
        attractionId: drift.Value(attractionId),
        startTime: drift.Value(_currentMeasurementStartTime!),
        syncStatus: const drift.Value('PENDING'),
      ),
    );
    notifyListeners();
  }

  Future<void> _stopCurrentMeasurement() async {
    if (_currentMeasurementId == null) return;

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

    _currentActiveAttractionId = null;
    _currentMeasurementId = null;
    _currentMeasurementStartTime = null;
    notifyListeners();
  }
}
