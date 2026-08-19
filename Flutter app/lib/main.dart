import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/database.dart';
import 'services/auth_service.dart';
import 'services/sync_service.dart';
import 'services/geofence_service.dart';
import 'ui/login_screen.dart';
import 'ui/attractions_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final db = AppDatabase();
  final authService = AuthService();
  final syncService = SyncService(db);
  final geofenceService = GeofenceService(db, authService);

  // Sprawdź czy token jest w secure storage i jeśli tak, zaloguj automatycznie
  await authService.checkLoginStatus();
  
  if (authService.isAuthenticated) {
    geofenceService.startGeofencing();
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: db),
        ChangeNotifierProvider<AuthService>.value(value: authService),
        ChangeNotifierProvider<SyncService>.value(value: syncService),
        ChangeNotifierProvider<GeofenceService>.value(value: geofenceService),
      ],
      child: const TimeApp(),
    ),
  );
}

class TimeApp extends StatelessWidget {
  const TimeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return MaterialApp(
      title: 'Czas Pracy - Atrakcje',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E8B57), // Zieleń
          primary: const Color(0xFF2E8B57),
          secondary: const Color(0xFFF47C20), // Pomarańcz
          tertiary: const Color(0xFF8B5A2B), // Brąz
          background: const Color(0xFFF9F9F9),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E8B57),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF47C20),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2E8B57)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFF47C20), width: 2),
          ),
        ),
      ),
      home: authService.isAuthenticated 
          ? const AttractionsScreen() 
          : const LoginScreen(),
    );
  }
}
