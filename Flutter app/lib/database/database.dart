import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'schema.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Users, Attractions, Measurements, Surveys, GlobalSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  // Zwraca strumień aktywnych atrakcji, opcjonalnie filtrując je po tytule prosto w bazie SQL (bardzo szybkie)
  Stream<List<Attraction>> watchActiveAttractions(String query) {
    if (query.isEmpty) {
      return (select(attractions)..where((a) => a.isActive.equals(true))).watch();
    } else {
      return (select(attractions)
            ..where((a) =>
                a.isActive.equals(true) &
                a.name.like('%$query%')))
          .watch();
    }
  }

  // Konstruktor dla testów w pamięci RAM
  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from == 1) {
          await m.addColumn(attractions, attractions.syncStatus);
        }
        if (from < 3) {
          await m.addColumn(users, users.passwordHash);
          await m.addColumn(users, users.pinHash);
          await m.addColumn(users, users.role);
        }
        if (from < 4) {
          await m.createTable(surveys);
        }
        if (from < 5) {
          await m.createTable(globalSettings);
          await into(globalSettings).insert(const GlobalSettingsCompanion(
            id: Value(1),
          ), mode: InsertMode.insertOrIgnore);
        }
      },
      beforeOpen: (details) async {
        if (details.wasCreated) {
          await into(globalSettings).insert(const GlobalSettingsCompanion(
            id: Value(1),
          ), mode: InsertMode.insertOrIgnore);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
