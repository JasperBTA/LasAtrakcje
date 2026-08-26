import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timeapp_flutter/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:timeapp_flutter/database/database.dart';
import 'package:timeapp_flutter/services/auth_service.dart';
import 'package:timeapp_flutter/services/sync_service.dart';
import 'package:dbcrypt/dbcrypt.dart';
import 'package:timeapp_flutter/api/api_client.dart';
import 'package:drift/drift.dart';
import 'mocks.dart';
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test trybu Offline (Brak połączenia z siecią, użycie PINu bazy lokalnej)', (WidgetTester tester) async {
    // 1. Zepsucie adresu API (Symulacja trybu offline - port 9999 jest wyłączony)
    ApiClient.baseUrl = 'http://127.0.0.1:9999/api';

    // 2. Inicjalizacja bazy
    final db = AppDatabase.memory();

    // 3. Tworzymy lokalnego pracownika z zaszyfrowanym PIN-em 1234
    final dbc = DBCrypt();
    final hashedPin = dbc.hashpw('1234', dbc.gensalt());

    await db.into(db.users).insert(
      UsersCompanion.insert(
        id: 'test_worker_1',
        username: 'worker_offline',
        role: const Value('WORKER'),
        pinHash: hashedPin,
        passwordHash: '',
      )
    );

    // 4. Tworzymy lokalną atrakcję, żeby było co pokazać
    await db.into(db.attractions).insert(
      AttractionsCompanion.insert(
        id: 'attr_1',
        name: 'Główny Szlak',
        latitude: 50.0,
        longitude: 20.0,
        radius: 100.0,
        isActive: const Value(true),
      )
    );

    // 5. Inicjalizujemy Prawdziwy AuthService i SyncService, ale z FAŁSZYWYM GEOFENCE (aby ominąć monit o GPS)
    final authService = AuthService(db);
    final syncService = SyncService(db, authService);
    final geofenceService = FakeGeofenceService();

    // Uruchomienie aplikacji
    await app.runTimeApp(
      db: db,
      authService: authService,
      syncService: syncService,
      geofenceService: geofenceService,
    );
    
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Ekran główny to teraz panel logowania PIN (niezalogowani jesteśmy)
    expect(find.text('Wprowadź PIN'), findsWidgets);

    // Szukamy klawiatury numerycznej i wpisujemy 1234
    await tester.tap(find.text('1'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('2'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('3'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('4'));
    await tester.pumpAndSettle(const Duration(seconds: 3)); // Czekamy na przetworzenie offline loginu

    // Zalogowani! Powinniśmy być na ekranie atrakcji (Wybierz Atrakcję)
    expect(find.text('Wybierz Atrakcję'), findsOneWidget);
    expect(find.text('Główny Szlak'), findsOneWidget);

    // Wchodzimy w ekran pracy (WorkScreen) dla Głównego Szlaku
    await tester.tap(find.text('Główny Szlak'));
    await tester.pumpAndSettle();

    expect(find.text('Gotowy do pracy'), findsOneWidget);

    // Klikamy start pracy
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.text('Czas pracy:'), findsOneWidget);

    // Odczekujemy "1 sekundę pracy"
    await tester.pump(const Duration(seconds: 1));

    // Kończymy pracę
    await tester.tap(find.text('Zakończ Pomiar'));
    await tester.pumpAndSettle();

    // Szukamy snackbara informującego, że pomiar zapisany lokalnie
    expect(find.text('Pomiar zapisany lokalnie i zakolejkowany do wysyłki!'), findsOneWidget);

    // SPRAWDZENIE BAZY LOKALNEJ
    // Zapewniamy, że pomiar fizycznie zrzucił się na dysk (Pamięć RAM z testu) ze statusem PENDING_CREATE
    final measurements = await db.select(db.measurements).get();
    expect(measurements.length, 1);
    expect(measurements.first.syncStatus, 'PENDING_CREATE');
    expect(measurements.first.operatorId, 'test_worker_1');

    // 6. Magiczne PRZYWRÓCENIE INTERNETU
    ApiClient.baseUrl = 'http://10.0.2.2:8080/api'; // Wracamy do prawdziwego serwera Spring Boot

    // Teraz aplikacja powinna spróbować automatycznie to wypchnąć kiedyśtam, ale my wymusimy to ręcznie np. klikając sync
    // Wracamy na ekran główny
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Wymuszamy synchronizację w tle
    await syncService.syncAll();
    
    // Ponieważ pomiar się wysłał do naszego działającego na PC Spring Boota, status powinien się zmienić w lokalnej na SYNCED
    final updatedMeasurements = await db.select(db.measurements).get();
    expect(updatedMeasurements.first.syncStatus, 'SYNCED');
    
    // Test kończy się tu (Sukces offline i zapis na dysku)
    debugPrint('=== ZAKOŃCZONO TEST OFFLINE: ZNALEZIONO 1 PENDING_CREATE W BAZIE I APLIKACJA NIE SPADŁA Z ROWERKA ===');
  });
}
