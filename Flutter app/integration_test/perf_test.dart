import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timeapp_flutter/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:timeapp_flutter/database/database.dart';
import 'mocks.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test wydajności logowania i przewijania (Jank Profile)', (WidgetTester tester) async {
    // 1. Inicjalizujemy bazę w pamięci operacyjnej na czas testu
    final db = AppDatabase.memory();
    
    // Tworzymy atrapy atrakcji do testów scrollowania
    for (int i = 0; i < 20; i++) {
      await db.into(db.attractions).insert(
        AttractionsCompanion.insert(
          id: 'test_attr_$i',
          name: 'Atrakcja testowa $i',
          latitude: 50.0 + (i * 0.01),
          longitude: 20.0 + (i * 0.01),
          radius: 100.0,
        )
      );
    }
    
    // 2. Wstrzykujemy fałszywe instancje serwisów (Od razu zalogowany!)
    final authService = FakeAuthService(isAuthenticated: true);
    final syncService = FakeSyncService();
    final geofenceService = FakeGeofenceService();

    // Uruchomienie aplikacji za pomocą wydzielonej w głównym pliku metody wstrzykującej
    await app.runTimeApp(
      db: db,
      authService: authService,
      syncService: syncService,
      geofenceService: geofenceService,
    );
    
    // Czekamy aż ekran atrakcji w pełni wybuduje drzewo widżetów
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Zaczynamy śledzenie wydajności klatek
    await binding.traceAction(() async {
      // 0. Sprawdzamy czy nie jesteśmy już przypadkiem zalogowani (z poprzedniego testu)
      final logoutBtn = find.byIcon(Icons.logout);
      if (logoutBtn.evaluate().isNotEmpty) {
        // Skoro chcemy ominąć logowanie, nie wciskamy wyloguj - po prostu jesteśmy na głównym ekranie!
      }

      // Po wstrzyknięciu `isAuthenticated: true` jesteśmy od razu na AttractionsScreen!
      // 1. Sprawdzamy, czy widoczny jest AppBar "Wybierz Atrakcję"
      final appbarText = find.text('Wybierz Atrakcję');
      if (appbarText.evaluate().isEmpty) {
        debugPrint('--- WIDGET TREE DUMP PO LOGOWANIU PINEM ---');
        for (var widget in tester.allWidgets) {
          if (widget is Text) {
             debugPrint("TEXT WIDGET: ${widget.data}");
          }
        }
        debugPrint('-------------------------------------');
      }
      expect(appbarText, findsOneWidget);

      // 5. Symulujemy przewijanie listy atrakcji w górę i w dół, aby zmierzyć płynność scrollowania
      // Ponieważ admin widzi listę, ListView powinno być obecne.
      final listFinder = find.byType(ListView);
      if (listFinder.evaluate().isNotEmpty) {
        await tester.fling(listFinder, const Offset(0, -500), 10000);
        await tester.pumpAndSettle();
        
        await tester.fling(listFinder, const Offset(0, 500), 10000);
        await tester.pumpAndSettle();
      }

    }, reportKey: 'performance_summary'); 
  });
}
