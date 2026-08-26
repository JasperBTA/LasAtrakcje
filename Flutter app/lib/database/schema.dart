import 'package:drift/drift.dart';

// Używamy UUID jako stringów (TEXT), ponieważ SQLite nie posiada wbudowanego typu UUID.
// Drift automatycznie zmapuje kolumny dateTime() do unix timestamp w SQLite.
// W logice aplikacji musimy pamiętać, by operować na `DateTime.now().toUtc()`.

@DataClassName('User')
class Users extends Table {
  TextColumn get id => text()(); // UUID z serwera
  TextColumn get username => text()();
  TextColumn get passwordHash => text()();
  TextColumn get pinHash => text()();
  TextColumn get role => text().withDefault(const Constant('WORKER'))();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Attraction')
class Attractions extends Table {
  TextColumn get id => text()(); // UUID z serwera
  TextColumn get name => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get radius => real()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get syncStatus => text().withDefault(const Constant('SYNCED'))();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Measurement')
class Measurements extends Table {
  // UUID generowane po stronie urządzenia mobilnego przy starcie pomiaru
  // Będzie użyte jako Idempotency Key na backendzie
  TextColumn get id => text()(); 
  
  TextColumn get operatorId => text().references(Users, #id)();
  TextColumn get attractionId => text().references(Attractions, #id)();
  
  // Daty (wymuszone UTC podczas przypisywania)
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get stopTime => dateTime().nullable()();
  
  // Czas trwania kalkulowany lokalnie 
  IntColumn get totalDurationSeconds => integer().nullable()();
  
  // Status synchronizacji: PENDING, SYNCED, FAILED
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING'))();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Survey')
class Surveys extends Table {
  TextColumn get id => text()();
  TextColumn get operatorId => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get rating => integer()();
  TextColumn get strengths => text()();
  TextColumn get improvements => text()();
  IntColumn get recommendRating => integer()();
  TextColumn get source => text()();
  TextColumn get sourceOther => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('GlobalSetting')
class GlobalSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get gpsAccuracyThreshold => integer().withDefault(const Constant(50))();
  IntColumn get entryBufferSeconds => integer().withDefault(const Constant(4))();
  IntColumn get exitBufferSeconds => integer().withDefault(const Constant(45))();
  IntColumn get hysteresisMargin => integer().withDefault(const Constant(10))();

  @override
  Set<Column> get primaryKey => {id};
}
