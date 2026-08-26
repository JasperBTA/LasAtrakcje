// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _passwordHashMeta =
      const VerificationMeta('passwordHash');
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
      'password_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pinHashMeta =
      const VerificationMeta('pinHash');
  @override
  late final GeneratedColumn<String> pinHash = GeneratedColumn<String>(
      'pin_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('WORKER'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, username, passwordHash, pinHash, role];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
          _passwordHashMeta,
          passwordHash.isAcceptableOrUnknown(
              data['password_hash']!, _passwordHashMeta));
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('pin_hash')) {
      context.handle(_pinHashMeta,
          pinHash.isAcceptableOrUnknown(data['pin_hash']!, _pinHashMeta));
    } else if (isInserting) {
      context.missing(_pinHashMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      passwordHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password_hash'])!,
      pinHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pin_hash'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String username;
  final String passwordHash;
  final String pinHash;
  final String role;
  const User(
      {required this.id,
      required this.username,
      required this.passwordHash,
      required this.pinHash,
      required this.role});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['username'] = Variable<String>(username);
    map['password_hash'] = Variable<String>(passwordHash);
    map['pin_hash'] = Variable<String>(pinHash);
    map['role'] = Variable<String>(role);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      username: Value(username),
      passwordHash: Value(passwordHash),
      pinHash: Value(pinHash),
      role: Value(role),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      pinHash: serializer.fromJson<String>(json['pinHash']),
      role: serializer.fromJson<String>(json['role']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'username': serializer.toJson<String>(username),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'pinHash': serializer.toJson<String>(pinHash),
      'role': serializer.toJson<String>(role),
    };
  }

  User copyWith(
          {String? id,
          String? username,
          String? passwordHash,
          String? pinHash,
          String? role}) =>
      User(
        id: id ?? this.id,
        username: username ?? this.username,
        passwordHash: passwordHash ?? this.passwordHash,
        pinHash: pinHash ?? this.pinHash,
        role: role ?? this.role,
      );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      pinHash: data.pinHash.present ? data.pinHash.value : this.pinHash,
      role: data.role.present ? data.role.value : this.role,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('pinHash: $pinHash, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, username, passwordHash, pinHash, role);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.username == this.username &&
          other.passwordHash == this.passwordHash &&
          other.pinHash == this.pinHash &&
          other.role == this.role);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> username;
  final Value<String> passwordHash;
  final Value<String> pinHash;
  final Value<String> role;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String username,
    required String passwordHash,
    required String pinHash,
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        username = Value(username),
        passwordHash = Value(passwordHash),
        pinHash = Value(pinHash);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? username,
    Expression<String>? passwordHash,
    Expression<String>? pinHash,
    Expression<String>? role,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (pinHash != null) 'pin_hash': pinHash,
      if (role != null) 'role': role,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? id,
      Value<String>? username,
      Value<String>? passwordHash,
      Value<String>? pinHash,
      Value<String>? role,
      Value<int>? rowid}) {
    return UsersCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      pinHash: pinHash ?? this.pinHash,
      role: role ?? this.role,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (pinHash.present) {
      map['pin_hash'] = Variable<String>(pinHash.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('pinHash: $pinHash, ')
          ..write('role: $role, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttractionsTable extends Attractions
    with TableInfo<$AttractionsTable, Attraction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttractionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _radiusMeta = const VerificationMeta('radius');
  @override
  late final GeneratedColumn<double> radius = GeneratedColumn<double>(
      'radius', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('SYNCED'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, latitude, longitude, radius, isActive, syncStatus];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attractions';
  @override
  VerificationContext validateIntegrity(Insertable<Attraction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('radius')) {
      context.handle(_radiusMeta,
          radius.isAcceptableOrUnknown(data['radius']!, _radiusMeta));
    } else if (isInserting) {
      context.missing(_radiusMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attraction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attraction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude'])!,
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude'])!,
      radius: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}radius'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $AttractionsTable createAlias(String alias) {
    return $AttractionsTable(attachedDatabase, alias);
  }
}

class Attraction extends DataClass implements Insertable<Attraction> {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radius;
  final bool isActive;
  final String syncStatus;
  const Attraction(
      {required this.id,
      required this.name,
      required this.latitude,
      required this.longitude,
      required this.radius,
      required this.isActive,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['radius'] = Variable<double>(radius);
    map['is_active'] = Variable<bool>(isActive);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  AttractionsCompanion toCompanion(bool nullToAbsent) {
    return AttractionsCompanion(
      id: Value(id),
      name: Value(name),
      latitude: Value(latitude),
      longitude: Value(longitude),
      radius: Value(radius),
      isActive: Value(isActive),
      syncStatus: Value(syncStatus),
    );
  }

  factory Attraction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attraction(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      radius: serializer.fromJson<double>(json['radius']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'radius': serializer.toJson<double>(radius),
      'isActive': serializer.toJson<bool>(isActive),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Attraction copyWith(
          {String? id,
          String? name,
          double? latitude,
          double? longitude,
          double? radius,
          bool? isActive,
          String? syncStatus}) =>
      Attraction(
        id: id ?? this.id,
        name: name ?? this.name,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        radius: radius ?? this.radius,
        isActive: isActive ?? this.isActive,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  Attraction copyWithCompanion(AttractionsCompanion data) {
    return Attraction(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      radius: data.radius.present ? data.radius.value : this.radius,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attraction(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('radius: $radius, ')
          ..write('isActive: $isActive, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, latitude, longitude, radius, isActive, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attraction &&
          other.id == this.id &&
          other.name == this.name &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.radius == this.radius &&
          other.isActive == this.isActive &&
          other.syncStatus == this.syncStatus);
}

class AttractionsCompanion extends UpdateCompanion<Attraction> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double> radius;
  final Value<bool> isActive;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const AttractionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.radius = const Value.absent(),
    this.isActive = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttractionsCompanion.insert({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    required double radius,
    this.isActive = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        latitude = Value(latitude),
        longitude = Value(longitude),
        radius = Value(radius);
  static Insertable<Attraction> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? radius,
    Expression<bool>? isActive,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (radius != null) 'radius': radius,
      if (isActive != null) 'is_active': isActive,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttractionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<double>? latitude,
      Value<double>? longitude,
      Value<double>? radius,
      Value<bool>? isActive,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return AttractionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      isActive: isActive ?? this.isActive,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (radius.present) {
      map['radius'] = Variable<double>(radius.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttractionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('radius: $radius, ')
          ..write('isActive: $isActive, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MeasurementsTable extends Measurements
    with TableInfo<$MeasurementsTable, Measurement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operatorIdMeta =
      const VerificationMeta('operatorId');
  @override
  late final GeneratedColumn<String> operatorId = GeneratedColumn<String>(
      'operator_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _attractionIdMeta =
      const VerificationMeta('attractionId');
  @override
  late final GeneratedColumn<String> attractionId = GeneratedColumn<String>(
      'attraction_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES attractions (id)'));
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _stopTimeMeta =
      const VerificationMeta('stopTime');
  @override
  late final GeneratedColumn<DateTime> stopTime = GeneratedColumn<DateTime>(
      'stop_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _totalDurationSecondsMeta =
      const VerificationMeta('totalDurationSeconds');
  @override
  late final GeneratedColumn<int> totalDurationSeconds = GeneratedColumn<int>(
      'total_duration_seconds', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('PENDING'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        operatorId,
        attractionId,
        startTime,
        stopTime,
        totalDurationSeconds,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurements';
  @override
  VerificationContext validateIntegrity(Insertable<Measurement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('operator_id')) {
      context.handle(
          _operatorIdMeta,
          operatorId.isAcceptableOrUnknown(
              data['operator_id']!, _operatorIdMeta));
    } else if (isInserting) {
      context.missing(_operatorIdMeta);
    }
    if (data.containsKey('attraction_id')) {
      context.handle(
          _attractionIdMeta,
          attractionId.isAcceptableOrUnknown(
              data['attraction_id']!, _attractionIdMeta));
    } else if (isInserting) {
      context.missing(_attractionIdMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('stop_time')) {
      context.handle(_stopTimeMeta,
          stopTime.isAcceptableOrUnknown(data['stop_time']!, _stopTimeMeta));
    }
    if (data.containsKey('total_duration_seconds')) {
      context.handle(
          _totalDurationSecondsMeta,
          totalDurationSeconds.isAcceptableOrUnknown(
              data['total_duration_seconds']!, _totalDurationSecondsMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Measurement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Measurement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      operatorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operator_id'])!,
      attractionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}attraction_id'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time'])!,
      stopTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}stop_time']),
      totalDurationSeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}total_duration_seconds']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $MeasurementsTable createAlias(String alias) {
    return $MeasurementsTable(attachedDatabase, alias);
  }
}

class Measurement extends DataClass implements Insertable<Measurement> {
  final String id;
  final String operatorId;
  final String attractionId;
  final DateTime startTime;
  final DateTime? stopTime;
  final int? totalDurationSeconds;
  final String syncStatus;
  const Measurement(
      {required this.id,
      required this.operatorId,
      required this.attractionId,
      required this.startTime,
      this.stopTime,
      this.totalDurationSeconds,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['operator_id'] = Variable<String>(operatorId);
    map['attraction_id'] = Variable<String>(attractionId);
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || stopTime != null) {
      map['stop_time'] = Variable<DateTime>(stopTime);
    }
    if (!nullToAbsent || totalDurationSeconds != null) {
      map['total_duration_seconds'] = Variable<int>(totalDurationSeconds);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  MeasurementsCompanion toCompanion(bool nullToAbsent) {
    return MeasurementsCompanion(
      id: Value(id),
      operatorId: Value(operatorId),
      attractionId: Value(attractionId),
      startTime: Value(startTime),
      stopTime: stopTime == null && nullToAbsent
          ? const Value.absent()
          : Value(stopTime),
      totalDurationSeconds: totalDurationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(totalDurationSeconds),
      syncStatus: Value(syncStatus),
    );
  }

  factory Measurement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Measurement(
      id: serializer.fromJson<String>(json['id']),
      operatorId: serializer.fromJson<String>(json['operatorId']),
      attractionId: serializer.fromJson<String>(json['attractionId']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      stopTime: serializer.fromJson<DateTime?>(json['stopTime']),
      totalDurationSeconds:
          serializer.fromJson<int?>(json['totalDurationSeconds']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'operatorId': serializer.toJson<String>(operatorId),
      'attractionId': serializer.toJson<String>(attractionId),
      'startTime': serializer.toJson<DateTime>(startTime),
      'stopTime': serializer.toJson<DateTime?>(stopTime),
      'totalDurationSeconds': serializer.toJson<int?>(totalDurationSeconds),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Measurement copyWith(
          {String? id,
          String? operatorId,
          String? attractionId,
          DateTime? startTime,
          Value<DateTime?> stopTime = const Value.absent(),
          Value<int?> totalDurationSeconds = const Value.absent(),
          String? syncStatus}) =>
      Measurement(
        id: id ?? this.id,
        operatorId: operatorId ?? this.operatorId,
        attractionId: attractionId ?? this.attractionId,
        startTime: startTime ?? this.startTime,
        stopTime: stopTime.present ? stopTime.value : this.stopTime,
        totalDurationSeconds: totalDurationSeconds.present
            ? totalDurationSeconds.value
            : this.totalDurationSeconds,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  Measurement copyWithCompanion(MeasurementsCompanion data) {
    return Measurement(
      id: data.id.present ? data.id.value : this.id,
      operatorId:
          data.operatorId.present ? data.operatorId.value : this.operatorId,
      attractionId: data.attractionId.present
          ? data.attractionId.value
          : this.attractionId,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      stopTime: data.stopTime.present ? data.stopTime.value : this.stopTime,
      totalDurationSeconds: data.totalDurationSeconds.present
          ? data.totalDurationSeconds.value
          : this.totalDurationSeconds,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Measurement(')
          ..write('id: $id, ')
          ..write('operatorId: $operatorId, ')
          ..write('attractionId: $attractionId, ')
          ..write('startTime: $startTime, ')
          ..write('stopTime: $stopTime, ')
          ..write('totalDurationSeconds: $totalDurationSeconds, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, operatorId, attractionId, startTime,
      stopTime, totalDurationSeconds, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Measurement &&
          other.id == this.id &&
          other.operatorId == this.operatorId &&
          other.attractionId == this.attractionId &&
          other.startTime == this.startTime &&
          other.stopTime == this.stopTime &&
          other.totalDurationSeconds == this.totalDurationSeconds &&
          other.syncStatus == this.syncStatus);
}

class MeasurementsCompanion extends UpdateCompanion<Measurement> {
  final Value<String> id;
  final Value<String> operatorId;
  final Value<String> attractionId;
  final Value<DateTime> startTime;
  final Value<DateTime?> stopTime;
  final Value<int?> totalDurationSeconds;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const MeasurementsCompanion({
    this.id = const Value.absent(),
    this.operatorId = const Value.absent(),
    this.attractionId = const Value.absent(),
    this.startTime = const Value.absent(),
    this.stopTime = const Value.absent(),
    this.totalDurationSeconds = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MeasurementsCompanion.insert({
    required String id,
    required String operatorId,
    required String attractionId,
    required DateTime startTime,
    this.stopTime = const Value.absent(),
    this.totalDurationSeconds = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        operatorId = Value(operatorId),
        attractionId = Value(attractionId),
        startTime = Value(startTime);
  static Insertable<Measurement> custom({
    Expression<String>? id,
    Expression<String>? operatorId,
    Expression<String>? attractionId,
    Expression<DateTime>? startTime,
    Expression<DateTime>? stopTime,
    Expression<int>? totalDurationSeconds,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operatorId != null) 'operator_id': operatorId,
      if (attractionId != null) 'attraction_id': attractionId,
      if (startTime != null) 'start_time': startTime,
      if (stopTime != null) 'stop_time': stopTime,
      if (totalDurationSeconds != null)
        'total_duration_seconds': totalDurationSeconds,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MeasurementsCompanion copyWith(
      {Value<String>? id,
      Value<String>? operatorId,
      Value<String>? attractionId,
      Value<DateTime>? startTime,
      Value<DateTime?>? stopTime,
      Value<int?>? totalDurationSeconds,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return MeasurementsCompanion(
      id: id ?? this.id,
      operatorId: operatorId ?? this.operatorId,
      attractionId: attractionId ?? this.attractionId,
      startTime: startTime ?? this.startTime,
      stopTime: stopTime ?? this.stopTime,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (operatorId.present) {
      map['operator_id'] = Variable<String>(operatorId.value);
    }
    if (attractionId.present) {
      map['attraction_id'] = Variable<String>(attractionId.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (stopTime.present) {
      map['stop_time'] = Variable<DateTime>(stopTime.value);
    }
    if (totalDurationSeconds.present) {
      map['total_duration_seconds'] = Variable<int>(totalDurationSeconds.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementsCompanion(')
          ..write('id: $id, ')
          ..write('operatorId: $operatorId, ')
          ..write('attractionId: $attractionId, ')
          ..write('startTime: $startTime, ')
          ..write('stopTime: $stopTime, ')
          ..write('totalDurationSeconds: $totalDurationSeconds, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SurveysTable extends Surveys with TableInfo<$SurveysTable, Survey> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SurveysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operatorIdMeta =
      const VerificationMeta('operatorId');
  @override
  late final GeneratedColumn<String> operatorId = GeneratedColumn<String>(
      'operator_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
      'rating', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _strengthsMeta =
      const VerificationMeta('strengths');
  @override
  late final GeneratedColumn<String> strengths = GeneratedColumn<String>(
      'strengths', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _improvementsMeta =
      const VerificationMeta('improvements');
  @override
  late final GeneratedColumn<String> improvements = GeneratedColumn<String>(
      'improvements', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recommendRatingMeta =
      const VerificationMeta('recommendRating');
  @override
  late final GeneratedColumn<int> recommendRating = GeneratedColumn<int>(
      'recommend_rating', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceOtherMeta =
      const VerificationMeta('sourceOther');
  @override
  late final GeneratedColumn<String> sourceOther = GeneratedColumn<String>(
      'source_other', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('PENDING'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        operatorId,
        createdAt,
        rating,
        strengths,
        improvements,
        recommendRating,
        source,
        sourceOther,
        notes,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'surveys';
  @override
  VerificationContext validateIntegrity(Insertable<Survey> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('operator_id')) {
      context.handle(
          _operatorIdMeta,
          operatorId.isAcceptableOrUnknown(
              data['operator_id']!, _operatorIdMeta));
    } else if (isInserting) {
      context.missing(_operatorIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(_ratingMeta,
          rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));
    } else if (isInserting) {
      context.missing(_ratingMeta);
    }
    if (data.containsKey('strengths')) {
      context.handle(_strengthsMeta,
          strengths.isAcceptableOrUnknown(data['strengths']!, _strengthsMeta));
    } else if (isInserting) {
      context.missing(_strengthsMeta);
    }
    if (data.containsKey('improvements')) {
      context.handle(
          _improvementsMeta,
          improvements.isAcceptableOrUnknown(
              data['improvements']!, _improvementsMeta));
    } else if (isInserting) {
      context.missing(_improvementsMeta);
    }
    if (data.containsKey('recommend_rating')) {
      context.handle(
          _recommendRatingMeta,
          recommendRating.isAcceptableOrUnknown(
              data['recommend_rating']!, _recommendRatingMeta));
    } else if (isInserting) {
      context.missing(_recommendRatingMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('source_other')) {
      context.handle(
          _sourceOtherMeta,
          sourceOther.isAcceptableOrUnknown(
              data['source_other']!, _sourceOtherMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Survey map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Survey(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      operatorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operator_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      rating: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rating'])!,
      strengths: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}strengths'])!,
      improvements: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}improvements'])!,
      recommendRating: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}recommend_rating'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      sourceOther: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_other']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $SurveysTable createAlias(String alias) {
    return $SurveysTable(attachedDatabase, alias);
  }
}

class Survey extends DataClass implements Insertable<Survey> {
  final String id;
  final String operatorId;
  final DateTime createdAt;
  final int rating;
  final String strengths;
  final String improvements;
  final int recommendRating;
  final String source;
  final String? sourceOther;
  final String? notes;
  final String syncStatus;
  const Survey(
      {required this.id,
      required this.operatorId,
      required this.createdAt,
      required this.rating,
      required this.strengths,
      required this.improvements,
      required this.recommendRating,
      required this.source,
      this.sourceOther,
      this.notes,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['operator_id'] = Variable<String>(operatorId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['rating'] = Variable<int>(rating);
    map['strengths'] = Variable<String>(strengths);
    map['improvements'] = Variable<String>(improvements);
    map['recommend_rating'] = Variable<int>(recommendRating);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || sourceOther != null) {
      map['source_other'] = Variable<String>(sourceOther);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  SurveysCompanion toCompanion(bool nullToAbsent) {
    return SurveysCompanion(
      id: Value(id),
      operatorId: Value(operatorId),
      createdAt: Value(createdAt),
      rating: Value(rating),
      strengths: Value(strengths),
      improvements: Value(improvements),
      recommendRating: Value(recommendRating),
      source: Value(source),
      sourceOther: sourceOther == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceOther),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      syncStatus: Value(syncStatus),
    );
  }

  factory Survey.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Survey(
      id: serializer.fromJson<String>(json['id']),
      operatorId: serializer.fromJson<String>(json['operatorId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      rating: serializer.fromJson<int>(json['rating']),
      strengths: serializer.fromJson<String>(json['strengths']),
      improvements: serializer.fromJson<String>(json['improvements']),
      recommendRating: serializer.fromJson<int>(json['recommendRating']),
      source: serializer.fromJson<String>(json['source']),
      sourceOther: serializer.fromJson<String?>(json['sourceOther']),
      notes: serializer.fromJson<String?>(json['notes']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'operatorId': serializer.toJson<String>(operatorId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'rating': serializer.toJson<int>(rating),
      'strengths': serializer.toJson<String>(strengths),
      'improvements': serializer.toJson<String>(improvements),
      'recommendRating': serializer.toJson<int>(recommendRating),
      'source': serializer.toJson<String>(source),
      'sourceOther': serializer.toJson<String?>(sourceOther),
      'notes': serializer.toJson<String?>(notes),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Survey copyWith(
          {String? id,
          String? operatorId,
          DateTime? createdAt,
          int? rating,
          String? strengths,
          String? improvements,
          int? recommendRating,
          String? source,
          Value<String?> sourceOther = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          String? syncStatus}) =>
      Survey(
        id: id ?? this.id,
        operatorId: operatorId ?? this.operatorId,
        createdAt: createdAt ?? this.createdAt,
        rating: rating ?? this.rating,
        strengths: strengths ?? this.strengths,
        improvements: improvements ?? this.improvements,
        recommendRating: recommendRating ?? this.recommendRating,
        source: source ?? this.source,
        sourceOther: sourceOther.present ? sourceOther.value : this.sourceOther,
        notes: notes.present ? notes.value : this.notes,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  Survey copyWithCompanion(SurveysCompanion data) {
    return Survey(
      id: data.id.present ? data.id.value : this.id,
      operatorId:
          data.operatorId.present ? data.operatorId.value : this.operatorId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      rating: data.rating.present ? data.rating.value : this.rating,
      strengths: data.strengths.present ? data.strengths.value : this.strengths,
      improvements: data.improvements.present
          ? data.improvements.value
          : this.improvements,
      recommendRating: data.recommendRating.present
          ? data.recommendRating.value
          : this.recommendRating,
      source: data.source.present ? data.source.value : this.source,
      sourceOther:
          data.sourceOther.present ? data.sourceOther.value : this.sourceOther,
      notes: data.notes.present ? data.notes.value : this.notes,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Survey(')
          ..write('id: $id, ')
          ..write('operatorId: $operatorId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rating: $rating, ')
          ..write('strengths: $strengths, ')
          ..write('improvements: $improvements, ')
          ..write('recommendRating: $recommendRating, ')
          ..write('source: $source, ')
          ..write('sourceOther: $sourceOther, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, operatorId, createdAt, rating, strengths,
      improvements, recommendRating, source, sourceOther, notes, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Survey &&
          other.id == this.id &&
          other.operatorId == this.operatorId &&
          other.createdAt == this.createdAt &&
          other.rating == this.rating &&
          other.strengths == this.strengths &&
          other.improvements == this.improvements &&
          other.recommendRating == this.recommendRating &&
          other.source == this.source &&
          other.sourceOther == this.sourceOther &&
          other.notes == this.notes &&
          other.syncStatus == this.syncStatus);
}

class SurveysCompanion extends UpdateCompanion<Survey> {
  final Value<String> id;
  final Value<String> operatorId;
  final Value<DateTime> createdAt;
  final Value<int> rating;
  final Value<String> strengths;
  final Value<String> improvements;
  final Value<int> recommendRating;
  final Value<String> source;
  final Value<String?> sourceOther;
  final Value<String?> notes;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const SurveysCompanion({
    this.id = const Value.absent(),
    this.operatorId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rating = const Value.absent(),
    this.strengths = const Value.absent(),
    this.improvements = const Value.absent(),
    this.recommendRating = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceOther = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SurveysCompanion.insert({
    required String id,
    required String operatorId,
    required DateTime createdAt,
    required int rating,
    required String strengths,
    required String improvements,
    required int recommendRating,
    required String source,
    this.sourceOther = const Value.absent(),
    this.notes = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        operatorId = Value(operatorId),
        createdAt = Value(createdAt),
        rating = Value(rating),
        strengths = Value(strengths),
        improvements = Value(improvements),
        recommendRating = Value(recommendRating),
        source = Value(source);
  static Insertable<Survey> custom({
    Expression<String>? id,
    Expression<String>? operatorId,
    Expression<DateTime>? createdAt,
    Expression<int>? rating,
    Expression<String>? strengths,
    Expression<String>? improvements,
    Expression<int>? recommendRating,
    Expression<String>? source,
    Expression<String>? sourceOther,
    Expression<String>? notes,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operatorId != null) 'operator_id': operatorId,
      if (createdAt != null) 'created_at': createdAt,
      if (rating != null) 'rating': rating,
      if (strengths != null) 'strengths': strengths,
      if (improvements != null) 'improvements': improvements,
      if (recommendRating != null) 'recommend_rating': recommendRating,
      if (source != null) 'source': source,
      if (sourceOther != null) 'source_other': sourceOther,
      if (notes != null) 'notes': notes,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SurveysCompanion copyWith(
      {Value<String>? id,
      Value<String>? operatorId,
      Value<DateTime>? createdAt,
      Value<int>? rating,
      Value<String>? strengths,
      Value<String>? improvements,
      Value<int>? recommendRating,
      Value<String>? source,
      Value<String?>? sourceOther,
      Value<String?>? notes,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return SurveysCompanion(
      id: id ?? this.id,
      operatorId: operatorId ?? this.operatorId,
      createdAt: createdAt ?? this.createdAt,
      rating: rating ?? this.rating,
      strengths: strengths ?? this.strengths,
      improvements: improvements ?? this.improvements,
      recommendRating: recommendRating ?? this.recommendRating,
      source: source ?? this.source,
      sourceOther: sourceOther ?? this.sourceOther,
      notes: notes ?? this.notes,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (operatorId.present) {
      map['operator_id'] = Variable<String>(operatorId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (strengths.present) {
      map['strengths'] = Variable<String>(strengths.value);
    }
    if (improvements.present) {
      map['improvements'] = Variable<String>(improvements.value);
    }
    if (recommendRating.present) {
      map['recommend_rating'] = Variable<int>(recommendRating.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sourceOther.present) {
      map['source_other'] = Variable<String>(sourceOther.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SurveysCompanion(')
          ..write('id: $id, ')
          ..write('operatorId: $operatorId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rating: $rating, ')
          ..write('strengths: $strengths, ')
          ..write('improvements: $improvements, ')
          ..write('recommendRating: $recommendRating, ')
          ..write('source: $source, ')
          ..write('sourceOther: $sourceOther, ')
          ..write('notes: $notes, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GlobalSettingsTable extends GlobalSettings
    with TableInfo<$GlobalSettingsTable, GlobalSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GlobalSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _gpsAccuracyThresholdMeta =
      const VerificationMeta('gpsAccuracyThreshold');
  @override
  late final GeneratedColumn<int> gpsAccuracyThreshold = GeneratedColumn<int>(
      'gps_accuracy_threshold', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(50));
  static const VerificationMeta _entryBufferSecondsMeta =
      const VerificationMeta('entryBufferSeconds');
  @override
  late final GeneratedColumn<int> entryBufferSeconds = GeneratedColumn<int>(
      'entry_buffer_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(4));
  static const VerificationMeta _exitBufferSecondsMeta =
      const VerificationMeta('exitBufferSeconds');
  @override
  late final GeneratedColumn<int> exitBufferSeconds = GeneratedColumn<int>(
      'exit_buffer_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(45));
  static const VerificationMeta _hysteresisMarginMeta =
      const VerificationMeta('hysteresisMargin');
  @override
  late final GeneratedColumn<int> hysteresisMargin = GeneratedColumn<int>(
      'hysteresis_margin', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(10));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        gpsAccuracyThreshold,
        entryBufferSeconds,
        exitBufferSeconds,
        hysteresisMargin
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'global_settings';
  @override
  VerificationContext validateIntegrity(Insertable<GlobalSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('gps_accuracy_threshold')) {
      context.handle(
          _gpsAccuracyThresholdMeta,
          gpsAccuracyThreshold.isAcceptableOrUnknown(
              data['gps_accuracy_threshold']!, _gpsAccuracyThresholdMeta));
    }
    if (data.containsKey('entry_buffer_seconds')) {
      context.handle(
          _entryBufferSecondsMeta,
          entryBufferSeconds.isAcceptableOrUnknown(
              data['entry_buffer_seconds']!, _entryBufferSecondsMeta));
    }
    if (data.containsKey('exit_buffer_seconds')) {
      context.handle(
          _exitBufferSecondsMeta,
          exitBufferSeconds.isAcceptableOrUnknown(
              data['exit_buffer_seconds']!, _exitBufferSecondsMeta));
    }
    if (data.containsKey('hysteresis_margin')) {
      context.handle(
          _hysteresisMarginMeta,
          hysteresisMargin.isAcceptableOrUnknown(
              data['hysteresis_margin']!, _hysteresisMarginMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GlobalSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GlobalSetting(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      gpsAccuracyThreshold: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}gps_accuracy_threshold'])!,
      entryBufferSeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}entry_buffer_seconds'])!,
      exitBufferSeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}exit_buffer_seconds'])!,
      hysteresisMargin: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}hysteresis_margin'])!,
    );
  }

  @override
  $GlobalSettingsTable createAlias(String alias) {
    return $GlobalSettingsTable(attachedDatabase, alias);
  }
}

class GlobalSetting extends DataClass implements Insertable<GlobalSetting> {
  final int id;
  final int gpsAccuracyThreshold;
  final int entryBufferSeconds;
  final int exitBufferSeconds;
  final int hysteresisMargin;
  const GlobalSetting(
      {required this.id,
      required this.gpsAccuracyThreshold,
      required this.entryBufferSeconds,
      required this.exitBufferSeconds,
      required this.hysteresisMargin});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['gps_accuracy_threshold'] = Variable<int>(gpsAccuracyThreshold);
    map['entry_buffer_seconds'] = Variable<int>(entryBufferSeconds);
    map['exit_buffer_seconds'] = Variable<int>(exitBufferSeconds);
    map['hysteresis_margin'] = Variable<int>(hysteresisMargin);
    return map;
  }

  GlobalSettingsCompanion toCompanion(bool nullToAbsent) {
    return GlobalSettingsCompanion(
      id: Value(id),
      gpsAccuracyThreshold: Value(gpsAccuracyThreshold),
      entryBufferSeconds: Value(entryBufferSeconds),
      exitBufferSeconds: Value(exitBufferSeconds),
      hysteresisMargin: Value(hysteresisMargin),
    );
  }

  factory GlobalSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GlobalSetting(
      id: serializer.fromJson<int>(json['id']),
      gpsAccuracyThreshold:
          serializer.fromJson<int>(json['gpsAccuracyThreshold']),
      entryBufferSeconds: serializer.fromJson<int>(json['entryBufferSeconds']),
      exitBufferSeconds: serializer.fromJson<int>(json['exitBufferSeconds']),
      hysteresisMargin: serializer.fromJson<int>(json['hysteresisMargin']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'gpsAccuracyThreshold': serializer.toJson<int>(gpsAccuracyThreshold),
      'entryBufferSeconds': serializer.toJson<int>(entryBufferSeconds),
      'exitBufferSeconds': serializer.toJson<int>(exitBufferSeconds),
      'hysteresisMargin': serializer.toJson<int>(hysteresisMargin),
    };
  }

  GlobalSetting copyWith(
          {int? id,
          int? gpsAccuracyThreshold,
          int? entryBufferSeconds,
          int? exitBufferSeconds,
          int? hysteresisMargin}) =>
      GlobalSetting(
        id: id ?? this.id,
        gpsAccuracyThreshold: gpsAccuracyThreshold ?? this.gpsAccuracyThreshold,
        entryBufferSeconds: entryBufferSeconds ?? this.entryBufferSeconds,
        exitBufferSeconds: exitBufferSeconds ?? this.exitBufferSeconds,
        hysteresisMargin: hysteresisMargin ?? this.hysteresisMargin,
      );
  GlobalSetting copyWithCompanion(GlobalSettingsCompanion data) {
    return GlobalSetting(
      id: data.id.present ? data.id.value : this.id,
      gpsAccuracyThreshold: data.gpsAccuracyThreshold.present
          ? data.gpsAccuracyThreshold.value
          : this.gpsAccuracyThreshold,
      entryBufferSeconds: data.entryBufferSeconds.present
          ? data.entryBufferSeconds.value
          : this.entryBufferSeconds,
      exitBufferSeconds: data.exitBufferSeconds.present
          ? data.exitBufferSeconds.value
          : this.exitBufferSeconds,
      hysteresisMargin: data.hysteresisMargin.present
          ? data.hysteresisMargin.value
          : this.hysteresisMargin,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GlobalSetting(')
          ..write('id: $id, ')
          ..write('gpsAccuracyThreshold: $gpsAccuracyThreshold, ')
          ..write('entryBufferSeconds: $entryBufferSeconds, ')
          ..write('exitBufferSeconds: $exitBufferSeconds, ')
          ..write('hysteresisMargin: $hysteresisMargin')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, gpsAccuracyThreshold, entryBufferSeconds,
      exitBufferSeconds, hysteresisMargin);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GlobalSetting &&
          other.id == this.id &&
          other.gpsAccuracyThreshold == this.gpsAccuracyThreshold &&
          other.entryBufferSeconds == this.entryBufferSeconds &&
          other.exitBufferSeconds == this.exitBufferSeconds &&
          other.hysteresisMargin == this.hysteresisMargin);
}

class GlobalSettingsCompanion extends UpdateCompanion<GlobalSetting> {
  final Value<int> id;
  final Value<int> gpsAccuracyThreshold;
  final Value<int> entryBufferSeconds;
  final Value<int> exitBufferSeconds;
  final Value<int> hysteresisMargin;
  const GlobalSettingsCompanion({
    this.id = const Value.absent(),
    this.gpsAccuracyThreshold = const Value.absent(),
    this.entryBufferSeconds = const Value.absent(),
    this.exitBufferSeconds = const Value.absent(),
    this.hysteresisMargin = const Value.absent(),
  });
  GlobalSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.gpsAccuracyThreshold = const Value.absent(),
    this.entryBufferSeconds = const Value.absent(),
    this.exitBufferSeconds = const Value.absent(),
    this.hysteresisMargin = const Value.absent(),
  });
  static Insertable<GlobalSetting> custom({
    Expression<int>? id,
    Expression<int>? gpsAccuracyThreshold,
    Expression<int>? entryBufferSeconds,
    Expression<int>? exitBufferSeconds,
    Expression<int>? hysteresisMargin,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gpsAccuracyThreshold != null)
        'gps_accuracy_threshold': gpsAccuracyThreshold,
      if (entryBufferSeconds != null)
        'entry_buffer_seconds': entryBufferSeconds,
      if (exitBufferSeconds != null) 'exit_buffer_seconds': exitBufferSeconds,
      if (hysteresisMargin != null) 'hysteresis_margin': hysteresisMargin,
    });
  }

  GlobalSettingsCompanion copyWith(
      {Value<int>? id,
      Value<int>? gpsAccuracyThreshold,
      Value<int>? entryBufferSeconds,
      Value<int>? exitBufferSeconds,
      Value<int>? hysteresisMargin}) {
    return GlobalSettingsCompanion(
      id: id ?? this.id,
      gpsAccuracyThreshold: gpsAccuracyThreshold ?? this.gpsAccuracyThreshold,
      entryBufferSeconds: entryBufferSeconds ?? this.entryBufferSeconds,
      exitBufferSeconds: exitBufferSeconds ?? this.exitBufferSeconds,
      hysteresisMargin: hysteresisMargin ?? this.hysteresisMargin,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (gpsAccuracyThreshold.present) {
      map['gps_accuracy_threshold'] = Variable<int>(gpsAccuracyThreshold.value);
    }
    if (entryBufferSeconds.present) {
      map['entry_buffer_seconds'] = Variable<int>(entryBufferSeconds.value);
    }
    if (exitBufferSeconds.present) {
      map['exit_buffer_seconds'] = Variable<int>(exitBufferSeconds.value);
    }
    if (hysteresisMargin.present) {
      map['hysteresis_margin'] = Variable<int>(hysteresisMargin.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GlobalSettingsCompanion(')
          ..write('id: $id, ')
          ..write('gpsAccuracyThreshold: $gpsAccuracyThreshold, ')
          ..write('entryBufferSeconds: $entryBufferSeconds, ')
          ..write('exitBufferSeconds: $exitBufferSeconds, ')
          ..write('hysteresisMargin: $hysteresisMargin')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $AttractionsTable attractions = $AttractionsTable(this);
  late final $MeasurementsTable measurements = $MeasurementsTable(this);
  late final $SurveysTable surveys = $SurveysTable(this);
  late final $GlobalSettingsTable globalSettings = $GlobalSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [users, attractions, measurements, surveys, globalSettings];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  required String username,
  required String passwordHash,
  required String pinHash,
  Value<String> role,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String> username,
  Value<String> passwordHash,
  Value<String> pinHash,
  Value<String> role,
  Value<int> rowid,
});

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, User> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MeasurementsTable, List<Measurement>>
      _measurementsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.measurements,
              aliasName: 'users__id__measurements__operator_id');

  $$MeasurementsTableProcessedTableManager get measurementsRefs {
    final manager = $$MeasurementsTableTableManager($_db, $_db.measurements)
        .filter((f) => f.operatorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_measurementsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pinHash => $composableBuilder(
      column: $table.pinHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  Expression<bool> measurementsRefs(
      Expression<bool> Function($$MeasurementsTableFilterComposer f) f) {
    final $$MeasurementsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.measurements,
        getReferencedColumn: (t) => t.operatorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MeasurementsTableFilterComposer(
              $db: $db,
              $table: $db.measurements,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pinHash => $composableBuilder(
      column: $table.pinHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash, builder: (column) => column);

  GeneratedColumn<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  Expression<T> measurementsRefs<T extends Object>(
      Expression<T> Function($$MeasurementsTableAnnotationComposer a) f) {
    final $$MeasurementsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.measurements,
        getReferencedColumn: (t) => t.operatorId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MeasurementsTableAnnotationComposer(
              $db: $db,
              $table: $db.measurements,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, $$UsersTableReferences),
    User,
    PrefetchHooks Function({bool measurementsRefs})> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> username = const Value.absent(),
            Value<String> passwordHash = const Value.absent(),
            Value<String> pinHash = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            username: username,
            passwordHash: passwordHash,
            pinHash: pinHash,
            role: role,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String username,
            required String passwordHash,
            required String pinHash,
            Value<String> role = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            username: username,
            passwordHash: passwordHash,
            pinHash: pinHash,
            role: role,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$UsersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({measurementsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (measurementsRefs) db.measurements],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (measurementsRefs)
                    await $_getPrefetchedData<User, $UsersTable, Measurement>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._measurementsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0)
                                .measurementsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.operatorId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, $$UsersTableReferences),
    User,
    PrefetchHooks Function({bool measurementsRefs})>;
typedef $$AttractionsTableCreateCompanionBuilder = AttractionsCompanion
    Function({
  required String id,
  required String name,
  required double latitude,
  required double longitude,
  required double radius,
  Value<bool> isActive,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$AttractionsTableUpdateCompanionBuilder = AttractionsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<double> latitude,
  Value<double> longitude,
  Value<double> radius,
  Value<bool> isActive,
  Value<String> syncStatus,
  Value<int> rowid,
});

final class $$AttractionsTableReferences
    extends BaseReferences<_$AppDatabase, $AttractionsTable, Attraction> {
  $$AttractionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MeasurementsTable, List<Measurement>>
      _measurementsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.measurements,
              aliasName: 'attractions__id__measurements__attraction_id');

  $$MeasurementsTableProcessedTableManager get measurementsRefs {
    final manager = $$MeasurementsTableTableManager($_db, $_db.measurements)
        .filter(
            (f) => f.attractionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_measurementsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AttractionsTableFilterComposer
    extends Composer<_$AppDatabase, $AttractionsTable> {
  $$AttractionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get radius => $composableBuilder(
      column: $table.radius, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  Expression<bool> measurementsRefs(
      Expression<bool> Function($$MeasurementsTableFilterComposer f) f) {
    final $$MeasurementsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.measurements,
        getReferencedColumn: (t) => t.attractionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MeasurementsTableFilterComposer(
              $db: $db,
              $table: $db.measurements,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AttractionsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttractionsTable> {
  $$AttractionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get radius => $composableBuilder(
      column: $table.radius, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$AttractionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttractionsTable> {
  $$AttractionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get radius =>
      $composableBuilder(column: $table.radius, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  Expression<T> measurementsRefs<T extends Object>(
      Expression<T> Function($$MeasurementsTableAnnotationComposer a) f) {
    final $$MeasurementsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.measurements,
        getReferencedColumn: (t) => t.attractionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MeasurementsTableAnnotationComposer(
              $db: $db,
              $table: $db.measurements,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AttractionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AttractionsTable,
    Attraction,
    $$AttractionsTableFilterComposer,
    $$AttractionsTableOrderingComposer,
    $$AttractionsTableAnnotationComposer,
    $$AttractionsTableCreateCompanionBuilder,
    $$AttractionsTableUpdateCompanionBuilder,
    (Attraction, $$AttractionsTableReferences),
    Attraction,
    PrefetchHooks Function({bool measurementsRefs})> {
  $$AttractionsTableTableManager(_$AppDatabase db, $AttractionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttractionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttractionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttractionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> latitude = const Value.absent(),
            Value<double> longitude = const Value.absent(),
            Value<double> radius = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AttractionsCompanion(
            id: id,
            name: name,
            latitude: latitude,
            longitude: longitude,
            radius: radius,
            isActive: isActive,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required double latitude,
            required double longitude,
            required double radius,
            Value<bool> isActive = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AttractionsCompanion.insert(
            id: id,
            name: name,
            latitude: latitude,
            longitude: longitude,
            radius: radius,
            isActive: isActive,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AttractionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({measurementsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (measurementsRefs) db.measurements],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (measurementsRefs)
                    await $_getPrefetchedData<Attraction, $AttractionsTable,
                            Measurement>(
                        currentTable: table,
                        referencedTable: $$AttractionsTableReferences
                            ._measurementsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AttractionsTableReferences(db, table, p0)
                                .measurementsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.attractionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AttractionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AttractionsTable,
    Attraction,
    $$AttractionsTableFilterComposer,
    $$AttractionsTableOrderingComposer,
    $$AttractionsTableAnnotationComposer,
    $$AttractionsTableCreateCompanionBuilder,
    $$AttractionsTableUpdateCompanionBuilder,
    (Attraction, $$AttractionsTableReferences),
    Attraction,
    PrefetchHooks Function({bool measurementsRefs})>;
typedef $$MeasurementsTableCreateCompanionBuilder = MeasurementsCompanion
    Function({
  required String id,
  required String operatorId,
  required String attractionId,
  required DateTime startTime,
  Value<DateTime?> stopTime,
  Value<int?> totalDurationSeconds,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$MeasurementsTableUpdateCompanionBuilder = MeasurementsCompanion
    Function({
  Value<String> id,
  Value<String> operatorId,
  Value<String> attractionId,
  Value<DateTime> startTime,
  Value<DateTime?> stopTime,
  Value<int?> totalDurationSeconds,
  Value<String> syncStatus,
  Value<int> rowid,
});

final class $$MeasurementsTableReferences
    extends BaseReferences<_$AppDatabase, $MeasurementsTable, Measurement> {
  $$MeasurementsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _operatorIdTable(_$AppDatabase db) =>
      db.users.createAlias('measurements__operator_id__users__id');

  $$UsersTableProcessedTableManager get operatorId {
    final $_column = $_itemColumn<String>('operator_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_operatorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AttractionsTable _attractionIdTable(_$AppDatabase db) =>
      db.attractions
          .createAlias('measurements__attraction_id__attractions__id');

  $$AttractionsTableProcessedTableManager get attractionId {
    final $_column = $_itemColumn<String>('attraction_id')!;

    final manager = $$AttractionsTableTableManager($_db, $_db.attractions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_attractionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MeasurementsTableFilterComposer
    extends Composer<_$AppDatabase, $MeasurementsTable> {
  $$MeasurementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get stopTime => $composableBuilder(
      column: $table.stopTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalDurationSeconds => $composableBuilder(
      column: $table.totalDurationSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get operatorId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.operatorId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AttractionsTableFilterComposer get attractionId {
    final $$AttractionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.attractionId,
        referencedTable: $db.attractions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttractionsTableFilterComposer(
              $db: $db,
              $table: $db.attractions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MeasurementsTableOrderingComposer
    extends Composer<_$AppDatabase, $MeasurementsTable> {
  $$MeasurementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get stopTime => $composableBuilder(
      column: $table.stopTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalDurationSeconds => $composableBuilder(
      column: $table.totalDurationSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get operatorId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.operatorId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AttractionsTableOrderingComposer get attractionId {
    final $$AttractionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.attractionId,
        referencedTable: $db.attractions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttractionsTableOrderingComposer(
              $db: $db,
              $table: $db.attractions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MeasurementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeasurementsTable> {
  $$MeasurementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get stopTime =>
      $composableBuilder(column: $table.stopTime, builder: (column) => column);

  GeneratedColumn<int> get totalDurationSeconds => $composableBuilder(
      column: $table.totalDurationSeconds, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  $$UsersTableAnnotationComposer get operatorId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.operatorId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AttractionsTableAnnotationComposer get attractionId {
    final $$AttractionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.attractionId,
        referencedTable: $db.attractions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AttractionsTableAnnotationComposer(
              $db: $db,
              $table: $db.attractions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MeasurementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MeasurementsTable,
    Measurement,
    $$MeasurementsTableFilterComposer,
    $$MeasurementsTableOrderingComposer,
    $$MeasurementsTableAnnotationComposer,
    $$MeasurementsTableCreateCompanionBuilder,
    $$MeasurementsTableUpdateCompanionBuilder,
    (Measurement, $$MeasurementsTableReferences),
    Measurement,
    PrefetchHooks Function({bool operatorId, bool attractionId})> {
  $$MeasurementsTableTableManager(_$AppDatabase db, $MeasurementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeasurementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeasurementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeasurementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> operatorId = const Value.absent(),
            Value<String> attractionId = const Value.absent(),
            Value<DateTime> startTime = const Value.absent(),
            Value<DateTime?> stopTime = const Value.absent(),
            Value<int?> totalDurationSeconds = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MeasurementsCompanion(
            id: id,
            operatorId: operatorId,
            attractionId: attractionId,
            startTime: startTime,
            stopTime: stopTime,
            totalDurationSeconds: totalDurationSeconds,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String operatorId,
            required String attractionId,
            required DateTime startTime,
            Value<DateTime?> stopTime = const Value.absent(),
            Value<int?> totalDurationSeconds = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MeasurementsCompanion.insert(
            id: id,
            operatorId: operatorId,
            attractionId: attractionId,
            startTime: startTime,
            stopTime: stopTime,
            totalDurationSeconds: totalDurationSeconds,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MeasurementsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({operatorId = false, attractionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (operatorId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.operatorId,
                    referencedTable:
                        $$MeasurementsTableReferences._operatorIdTable(db),
                    referencedColumn:
                        $$MeasurementsTableReferences._operatorIdTable(db).id,
                  ) as T;
                }
                if (attractionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.attractionId,
                    referencedTable:
                        $$MeasurementsTableReferences._attractionIdTable(db),
                    referencedColumn:
                        $$MeasurementsTableReferences._attractionIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$MeasurementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MeasurementsTable,
    Measurement,
    $$MeasurementsTableFilterComposer,
    $$MeasurementsTableOrderingComposer,
    $$MeasurementsTableAnnotationComposer,
    $$MeasurementsTableCreateCompanionBuilder,
    $$MeasurementsTableUpdateCompanionBuilder,
    (Measurement, $$MeasurementsTableReferences),
    Measurement,
    PrefetchHooks Function({bool operatorId, bool attractionId})>;
typedef $$SurveysTableCreateCompanionBuilder = SurveysCompanion Function({
  required String id,
  required String operatorId,
  required DateTime createdAt,
  required int rating,
  required String strengths,
  required String improvements,
  required int recommendRating,
  required String source,
  Value<String?> sourceOther,
  Value<String?> notes,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$SurveysTableUpdateCompanionBuilder = SurveysCompanion Function({
  Value<String> id,
  Value<String> operatorId,
  Value<DateTime> createdAt,
  Value<int> rating,
  Value<String> strengths,
  Value<String> improvements,
  Value<int> recommendRating,
  Value<String> source,
  Value<String?> sourceOther,
  Value<String?> notes,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$SurveysTableFilterComposer
    extends Composer<_$AppDatabase, $SurveysTable> {
  $$SurveysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operatorId => $composableBuilder(
      column: $table.operatorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get strengths => $composableBuilder(
      column: $table.strengths, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get improvements => $composableBuilder(
      column: $table.improvements, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recommendRating => $composableBuilder(
      column: $table.recommendRating,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceOther => $composableBuilder(
      column: $table.sourceOther, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$SurveysTableOrderingComposer
    extends Composer<_$AppDatabase, $SurveysTable> {
  $$SurveysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operatorId => $composableBuilder(
      column: $table.operatorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get strengths => $composableBuilder(
      column: $table.strengths, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get improvements => $composableBuilder(
      column: $table.improvements,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recommendRating => $composableBuilder(
      column: $table.recommendRating,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceOther => $composableBuilder(
      column: $table.sourceOther, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$SurveysTableAnnotationComposer
    extends Composer<_$AppDatabase, $SurveysTable> {
  $$SurveysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operatorId => $composableBuilder(
      column: $table.operatorId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get strengths =>
      $composableBuilder(column: $table.strengths, builder: (column) => column);

  GeneratedColumn<String> get improvements => $composableBuilder(
      column: $table.improvements, builder: (column) => column);

  GeneratedColumn<int> get recommendRating => $composableBuilder(
      column: $table.recommendRating, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get sourceOther => $composableBuilder(
      column: $table.sourceOther, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$SurveysTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SurveysTable,
    Survey,
    $$SurveysTableFilterComposer,
    $$SurveysTableOrderingComposer,
    $$SurveysTableAnnotationComposer,
    $$SurveysTableCreateCompanionBuilder,
    $$SurveysTableUpdateCompanionBuilder,
    (Survey, BaseReferences<_$AppDatabase, $SurveysTable, Survey>),
    Survey,
    PrefetchHooks Function()> {
  $$SurveysTableTableManager(_$AppDatabase db, $SurveysTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SurveysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SurveysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SurveysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> operatorId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rating = const Value.absent(),
            Value<String> strengths = const Value.absent(),
            Value<String> improvements = const Value.absent(),
            Value<int> recommendRating = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String?> sourceOther = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SurveysCompanion(
            id: id,
            operatorId: operatorId,
            createdAt: createdAt,
            rating: rating,
            strengths: strengths,
            improvements: improvements,
            recommendRating: recommendRating,
            source: source,
            sourceOther: sourceOther,
            notes: notes,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String operatorId,
            required DateTime createdAt,
            required int rating,
            required String strengths,
            required String improvements,
            required int recommendRating,
            required String source,
            Value<String?> sourceOther = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SurveysCompanion.insert(
            id: id,
            operatorId: operatorId,
            createdAt: createdAt,
            rating: rating,
            strengths: strengths,
            improvements: improvements,
            recommendRating: recommendRating,
            source: source,
            sourceOther: sourceOther,
            notes: notes,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SurveysTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SurveysTable,
    Survey,
    $$SurveysTableFilterComposer,
    $$SurveysTableOrderingComposer,
    $$SurveysTableAnnotationComposer,
    $$SurveysTableCreateCompanionBuilder,
    $$SurveysTableUpdateCompanionBuilder,
    (Survey, BaseReferences<_$AppDatabase, $SurveysTable, Survey>),
    Survey,
    PrefetchHooks Function()>;
typedef $$GlobalSettingsTableCreateCompanionBuilder = GlobalSettingsCompanion
    Function({
  Value<int> id,
  Value<int> gpsAccuracyThreshold,
  Value<int> entryBufferSeconds,
  Value<int> exitBufferSeconds,
  Value<int> hysteresisMargin,
});
typedef $$GlobalSettingsTableUpdateCompanionBuilder = GlobalSettingsCompanion
    Function({
  Value<int> id,
  Value<int> gpsAccuracyThreshold,
  Value<int> entryBufferSeconds,
  Value<int> exitBufferSeconds,
  Value<int> hysteresisMargin,
});

class $$GlobalSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $GlobalSettingsTable> {
  $$GlobalSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gpsAccuracyThreshold => $composableBuilder(
      column: $table.gpsAccuracyThreshold,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get entryBufferSeconds => $composableBuilder(
      column: $table.entryBufferSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get exitBufferSeconds => $composableBuilder(
      column: $table.exitBufferSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hysteresisMargin => $composableBuilder(
      column: $table.hysteresisMargin,
      builder: (column) => ColumnFilters(column));
}

class $$GlobalSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $GlobalSettingsTable> {
  $$GlobalSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gpsAccuracyThreshold => $composableBuilder(
      column: $table.gpsAccuracyThreshold,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get entryBufferSeconds => $composableBuilder(
      column: $table.entryBufferSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get exitBufferSeconds => $composableBuilder(
      column: $table.exitBufferSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hysteresisMargin => $composableBuilder(
      column: $table.hysteresisMargin,
      builder: (column) => ColumnOrderings(column));
}

class $$GlobalSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GlobalSettingsTable> {
  $$GlobalSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get gpsAccuracyThreshold => $composableBuilder(
      column: $table.gpsAccuracyThreshold, builder: (column) => column);

  GeneratedColumn<int> get entryBufferSeconds => $composableBuilder(
      column: $table.entryBufferSeconds, builder: (column) => column);

  GeneratedColumn<int> get exitBufferSeconds => $composableBuilder(
      column: $table.exitBufferSeconds, builder: (column) => column);

  GeneratedColumn<int> get hysteresisMargin => $composableBuilder(
      column: $table.hysteresisMargin, builder: (column) => column);
}

class $$GlobalSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GlobalSettingsTable,
    GlobalSetting,
    $$GlobalSettingsTableFilterComposer,
    $$GlobalSettingsTableOrderingComposer,
    $$GlobalSettingsTableAnnotationComposer,
    $$GlobalSettingsTableCreateCompanionBuilder,
    $$GlobalSettingsTableUpdateCompanionBuilder,
    (
      GlobalSetting,
      BaseReferences<_$AppDatabase, $GlobalSettingsTable, GlobalSetting>
    ),
    GlobalSetting,
    PrefetchHooks Function()> {
  $$GlobalSettingsTableTableManager(
      _$AppDatabase db, $GlobalSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GlobalSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GlobalSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GlobalSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> gpsAccuracyThreshold = const Value.absent(),
            Value<int> entryBufferSeconds = const Value.absent(),
            Value<int> exitBufferSeconds = const Value.absent(),
            Value<int> hysteresisMargin = const Value.absent(),
          }) =>
              GlobalSettingsCompanion(
            id: id,
            gpsAccuracyThreshold: gpsAccuracyThreshold,
            entryBufferSeconds: entryBufferSeconds,
            exitBufferSeconds: exitBufferSeconds,
            hysteresisMargin: hysteresisMargin,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> gpsAccuracyThreshold = const Value.absent(),
            Value<int> entryBufferSeconds = const Value.absent(),
            Value<int> exitBufferSeconds = const Value.absent(),
            Value<int> hysteresisMargin = const Value.absent(),
          }) =>
              GlobalSettingsCompanion.insert(
            id: id,
            gpsAccuracyThreshold: gpsAccuracyThreshold,
            entryBufferSeconds: entryBufferSeconds,
            exitBufferSeconds: exitBufferSeconds,
            hysteresisMargin: hysteresisMargin,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GlobalSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GlobalSettingsTable,
    GlobalSetting,
    $$GlobalSettingsTableFilterComposer,
    $$GlobalSettingsTableOrderingComposer,
    $$GlobalSettingsTableAnnotationComposer,
    $$GlobalSettingsTableCreateCompanionBuilder,
    $$GlobalSettingsTableUpdateCompanionBuilder,
    (
      GlobalSetting,
      BaseReferences<_$AppDatabase, $GlobalSettingsTable, GlobalSetting>
    ),
    GlobalSetting,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$AttractionsTableTableManager get attractions =>
      $$AttractionsTableTableManager(_db, _db.attractions);
  $$MeasurementsTableTableManager get measurements =>
      $$MeasurementsTableTableManager(_db, _db.measurements);
  $$SurveysTableTableManager get surveys =>
      $$SurveysTableTableManager(_db, _db.surveys);
  $$GlobalSettingsTableTableManager get globalSettings =>
      $$GlobalSettingsTableTableManager(_db, _db.globalSettings);
}
