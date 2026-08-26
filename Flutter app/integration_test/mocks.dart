import 'package:flutter/foundation.dart';
import 'package:timeapp_flutter/services/auth_service.dart';
import 'package:timeapp_flutter/services/sync_service.dart';
import 'package:timeapp_flutter/services/geofence_service.dart';
import 'package:timeapp_flutter/database/database.dart';
import 'package:flutter/foundation.dart';

class FakeAuthService extends ChangeNotifier implements AuthService {
  bool _isAuthenticated;
  String? _username;
  String? _userId;
  String? _role;

  FakeAuthService({bool isAuthenticated = false}) 
      : _isAuthenticated = isAuthenticated,
        _username = isAuthenticated ? 'admin' : null,
        _userId = isAuthenticated ? '1' : null,
        _role = isAuthenticated ? 'ADMIN' : null;

  @override
  bool get isAuthenticated => _isAuthenticated;
  @override
  String? get username => _username;
  @override
  String? get userId => _userId;
  @override
  String? get role => _role;
  @override
  bool get isAdmin => _role == 'ADMIN';

  @override
  Future<bool> checkLoginStatus() async {
    return _isAuthenticated;
  }

  @override
  Future<String?> login(String username, String password) async {
    // W testach wpuszczamy admin/admin zawsze jako admina
    if (username == 'admin' && password == 'admin') {
      _isAuthenticated = true;
      _userId = "1";
      _username = "admin";
      _role = "ADMIN";
      notifyListeners();
      return null;
    }
    return "Błędne dane logowania w FakeAuthService";
  }

  @override
  Future<String?> loginWithPin(String pin) async {
    if (pin == '1234') {
      _isAuthenticated = true;
      _userId = "2";
      _username = "test";
      _role = "WORKER";
      notifyListeners();
      return null;
    }
    return "Błędny kod PIN w FakeAuthService";
  }

  @override
  Future<bool> autoLoginWithSavedPin() async {
    return false;
  }

  @override
  Future<void> logout() async {
    _isAuthenticated = false;
    _userId = null;
    _username = null;
    _role = null;
    notifyListeners();
  }
}

class FakeSyncService extends ChangeNotifier implements SyncService {
  bool _isSyncing = false;

  @override
  bool get isSyncing => _isSyncing;

  @override
  Future<String> syncAll() async {
    _isSyncing = true;
    notifyListeners();
    
    // Symulacja czasu trwania
    await Future.delayed(const Duration(milliseconds: 500));
    
    _isSyncing = false;
    notifyListeners();
    return "Synchronizacja zakończona (Fake)";
  }
  
  void syncMeasurementsInBackground() {}
  
  void startPeriodicSync() {}

  @override
  Future<String?> fetchAttractions({bool notify = true}) async { return null; }

  @override
  Future<void> syncAttractionsCoordinates() async {}

  @override
  Future<String?> syncMeasurements({bool notify = true}) async { return null; }

  @override
  Future<void> syncNewAttractions() async {}

  @override
  Future<void> syncUsers() async {}
}

class FakeGeofenceService extends ChangeNotifier implements GeofenceService {
  String? _currentActiveAttractionId;
  DateTime? _currentMeasurementStartTime;

  @override
  String? get currentActiveAttractionId => _currentActiveAttractionId;
  @override
  DateTime? get currentMeasurementStartTime => _currentMeasurementStartTime;
  @override
  bool get isMeasurementActive => _currentMeasurementStartTime != null;

  @override
  Future<void> startGeofencing() async {}

  @override
  Future<void> stopGeofencing() async {}

  @override
  Future<void> startMeasurementManually() async {
    _currentMeasurementStartTime = DateTime.now();
    notifyListeners();
  }

  Future<void> stopMeasurementManually() async {
    _currentMeasurementStartTime = null;
    _currentActiveAttractionId = null;
    notifyListeners();
  }
  
  @override
  Future<void> rejectMeasurement() async {
    _currentMeasurementStartTime = null;
    _currentActiveAttractionId = null;
    notifyListeners();
  }
  
  @override
  Future<void> stopCurrentMeasurement() async {
    _currentMeasurementStartTime = null;
    _currentActiveAttractionId = null;
    notifyListeners();
  }
}
