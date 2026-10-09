// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VehicleRowsTable extends VehicleRows
    with TableInfo<$VehicleRowsTable, VehicleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehicleRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _plateMeta = const VerificationMeta('plate');
  @override
  late final GeneratedColumn<String> plate = GeneratedColumn<String>(
      'plate', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nicknameMeta =
      const VerificationMeta('nickname');
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
      'nickname', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _boundCityIdMeta =
      const VerificationMeta('boundCityId');
  @override
  late final GeneratedColumn<String> boundCityId = GeneratedColumn<String>(
      'bound_city_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, plate, nickname, boundCityId, isActive, isDefault, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicle_rows';
  @override
  VerificationContext validateIntegrity(Insertable<VehicleRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plate')) {
      context.handle(
          _plateMeta, plate.isAcceptableOrUnknown(data['plate']!, _plateMeta));
    } else if (isInserting) {
      context.missing(_plateMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(_nicknameMeta,
          nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta));
    }
    if (data.containsKey('bound_city_id')) {
      context.handle(
          _boundCityIdMeta,
          boundCityId.isAcceptableOrUnknown(
              data['bound_city_id']!, _boundCityIdMeta));
    } else if (isInserting) {
      context.missing(_boundCityIdMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VehicleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VehicleRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      plate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plate'])!,
      nickname: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nickname'])!,
      boundCityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bound_city_id'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
    );
  }

  @override
  $VehicleRowsTable createAlias(String alias) {
    return $VehicleRowsTable(attachedDatabase, alias);
  }
}

class VehicleRow extends DataClass implements Insertable<VehicleRow> {
  final String id;
  final String plate;
  final String nickname;
  final String boundCityId;
  final bool isActive;
  final bool isDefault;
  final DateTime? createdAt;
  const VehicleRow(
      {required this.id,
      required this.plate,
      required this.nickname,
      required this.boundCityId,
      required this.isActive,
      required this.isDefault,
      this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plate'] = Variable<String>(plate);
    map['nickname'] = Variable<String>(nickname);
    map['bound_city_id'] = Variable<String>(boundCityId);
    map['is_active'] = Variable<bool>(isActive);
    map['is_default'] = Variable<bool>(isDefault);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  VehicleRowsCompanion toCompanion(bool nullToAbsent) {
    return VehicleRowsCompanion(
      id: Value(id),
      plate: Value(plate),
      nickname: Value(nickname),
      boundCityId: Value(boundCityId),
      isActive: Value(isActive),
      isDefault: Value(isDefault),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory VehicleRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VehicleRow(
      id: serializer.fromJson<String>(json['id']),
      plate: serializer.fromJson<String>(json['plate']),
      nickname: serializer.fromJson<String>(json['nickname']),
      boundCityId: serializer.fromJson<String>(json['boundCityId']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'plate': serializer.toJson<String>(plate),
      'nickname': serializer.toJson<String>(nickname),
      'boundCityId': serializer.toJson<String>(boundCityId),
      'isActive': serializer.toJson<bool>(isActive),
      'isDefault': serializer.toJson<bool>(isDefault),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  VehicleRow copyWith(
          {String? id,
          String? plate,
          String? nickname,
          String? boundCityId,
          bool? isActive,
          bool? isDefault,
          Value<DateTime?> createdAt = const Value.absent()}) =>
      VehicleRow(
        id: id ?? this.id,
        plate: plate ?? this.plate,
        nickname: nickname ?? this.nickname,
        boundCityId: boundCityId ?? this.boundCityId,
        isActive: isActive ?? this.isActive,
        isDefault: isDefault ?? this.isDefault,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
      );
  VehicleRow copyWithCompanion(VehicleRowsCompanion data) {
    return VehicleRow(
      id: data.id.present ? data.id.value : this.id,
      plate: data.plate.present ? data.plate.value : this.plate,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      boundCityId:
          data.boundCityId.present ? data.boundCityId.value : this.boundCityId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VehicleRow(')
          ..write('id: $id, ')
          ..write('plate: $plate, ')
          ..write('nickname: $nickname, ')
          ..write('boundCityId: $boundCityId, ')
          ..write('isActive: $isActive, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, plate, nickname, boundCityId, isActive, isDefault, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VehicleRow &&
          other.id == this.id &&
          other.plate == this.plate &&
          other.nickname == this.nickname &&
          other.boundCityId == this.boundCityId &&
          other.isActive == this.isActive &&
          other.isDefault == this.isDefault &&
          other.createdAt == this.createdAt);
}

class VehicleRowsCompanion extends UpdateCompanion<VehicleRow> {
  final Value<String> id;
  final Value<String> plate;
  final Value<String> nickname;
  final Value<String> boundCityId;
  final Value<bool> isActive;
  final Value<bool> isDefault;
  final Value<DateTime?> createdAt;
  final Value<int> rowid;
  const VehicleRowsCompanion({
    this.id = const Value.absent(),
    this.plate = const Value.absent(),
    this.nickname = const Value.absent(),
    this.boundCityId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VehicleRowsCompanion.insert({
    required String id,
    required String plate,
    this.nickname = const Value.absent(),
    required String boundCityId,
    this.isActive = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        plate = Value(plate),
        boundCityId = Value(boundCityId);
  static Insertable<VehicleRow> custom({
    Expression<String>? id,
    Expression<String>? plate,
    Expression<String>? nickname,
    Expression<String>? boundCityId,
    Expression<bool>? isActive,
    Expression<bool>? isDefault,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (plate != null) 'plate': plate,
      if (nickname != null) 'nickname': nickname,
      if (boundCityId != null) 'bound_city_id': boundCityId,
      if (isActive != null) 'is_active': isActive,
      if (isDefault != null) 'is_default': isDefault,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VehicleRowsCompanion copyWith(
      {Value<String>? id,
      Value<String>? plate,
      Value<String>? nickname,
      Value<String>? boundCityId,
      Value<bool>? isActive,
      Value<bool>? isDefault,
      Value<DateTime?>? createdAt,
      Value<int>? rowid}) {
    return VehicleRowsCompanion(
      id: id ?? this.id,
      plate: plate ?? this.plate,
      nickname: nickname ?? this.nickname,
      boundCityId: boundCityId ?? this.boundCityId,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (plate.present) {
      map['plate'] = Variable<String>(plate.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (boundCityId.present) {
      map['bound_city_id'] = Variable<String>(boundCityId.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehicleRowsCompanion(')
          ..write('id: $id, ')
          ..write('plate: $plate, ')
          ..write('nickname: $nickname, ')
          ..write('boundCityId: $boundCityId, ')
          ..write('isActive: $isActive, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MyCityRowsTable extends MyCityRows
    with TableInfo<$MyCityRowsTable, MyCityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MyCityRowsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _provinceMeta =
      const VerificationMeta('province');
  @override
  late final GeneratedColumn<String> province = GeneratedColumn<String>(
      'province', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _provinceAbbrMeta =
      const VerificationMeta('provinceAbbr');
  @override
  late final GeneratedColumn<String> provinceAbbr = GeneratedColumn<String>(
      'province_abbr', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _hasRestrictionMeta =
      const VerificationMeta('hasRestriction');
  @override
  late final GeneratedColumn<bool> hasRestriction = GeneratedColumn<bool>(
      'has_restriction', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_restriction" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, province, provinceAbbr, hasRestriction, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'my_city_rows';
  @override
  VerificationContext validateIntegrity(Insertable<MyCityRow> instance,
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
    if (data.containsKey('province')) {
      context.handle(_provinceMeta,
          province.isAcceptableOrUnknown(data['province']!, _provinceMeta));
    }
    if (data.containsKey('province_abbr')) {
      context.handle(
          _provinceAbbrMeta,
          provinceAbbr.isAcceptableOrUnknown(
              data['province_abbr']!, _provinceAbbrMeta));
    }
    if (data.containsKey('has_restriction')) {
      context.handle(
          _hasRestrictionMeta,
          hasRestriction.isAcceptableOrUnknown(
              data['has_restriction']!, _hasRestrictionMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MyCityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MyCityRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      province: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}province'])!,
      provinceAbbr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}province_abbr'])!,
      hasRestriction: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}has_restriction'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $MyCityRowsTable createAlias(String alias) {
    return $MyCityRowsTable(attachedDatabase, alias);
  }
}

class MyCityRow extends DataClass implements Insertable<MyCityRow> {
  final String id;
  final String name;
  final String province;
  final String provinceAbbr;
  final bool hasRestriction;
  final int sortOrder;
  const MyCityRow(
      {required this.id,
      required this.name,
      required this.province,
      required this.provinceAbbr,
      required this.hasRestriction,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['province'] = Variable<String>(province);
    map['province_abbr'] = Variable<String>(provinceAbbr);
    map['has_restriction'] = Variable<bool>(hasRestriction);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  MyCityRowsCompanion toCompanion(bool nullToAbsent) {
    return MyCityRowsCompanion(
      id: Value(id),
      name: Value(name),
      province: Value(province),
      provinceAbbr: Value(provinceAbbr),
      hasRestriction: Value(hasRestriction),
      sortOrder: Value(sortOrder),
    );
  }

  factory MyCityRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MyCityRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      province: serializer.fromJson<String>(json['province']),
      provinceAbbr: serializer.fromJson<String>(json['provinceAbbr']),
      hasRestriction: serializer.fromJson<bool>(json['hasRestriction']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'province': serializer.toJson<String>(province),
      'provinceAbbr': serializer.toJson<String>(provinceAbbr),
      'hasRestriction': serializer.toJson<bool>(hasRestriction),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  MyCityRow copyWith(
          {String? id,
          String? name,
          String? province,
          String? provinceAbbr,
          bool? hasRestriction,
          int? sortOrder}) =>
      MyCityRow(
        id: id ?? this.id,
        name: name ?? this.name,
        province: province ?? this.province,
        provinceAbbr: provinceAbbr ?? this.provinceAbbr,
        hasRestriction: hasRestriction ?? this.hasRestriction,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  MyCityRow copyWithCompanion(MyCityRowsCompanion data) {
    return MyCityRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      province: data.province.present ? data.province.value : this.province,
      provinceAbbr: data.provinceAbbr.present
          ? data.provinceAbbr.value
          : this.provinceAbbr,
      hasRestriction: data.hasRestriction.present
          ? data.hasRestriction.value
          : this.hasRestriction,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MyCityRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('province: $province, ')
          ..write('provinceAbbr: $provinceAbbr, ')
          ..write('hasRestriction: $hasRestriction, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, province, provinceAbbr, hasRestriction, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MyCityRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.province == this.province &&
          other.provinceAbbr == this.provinceAbbr &&
          other.hasRestriction == this.hasRestriction &&
          other.sortOrder == this.sortOrder);
}

class MyCityRowsCompanion extends UpdateCompanion<MyCityRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> province;
  final Value<String> provinceAbbr;
  final Value<bool> hasRestriction;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const MyCityRowsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.province = const Value.absent(),
    this.provinceAbbr = const Value.absent(),
    this.hasRestriction = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MyCityRowsCompanion.insert({
    required String id,
    required String name,
    this.province = const Value.absent(),
    this.provinceAbbr = const Value.absent(),
    this.hasRestriction = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<MyCityRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? province,
    Expression<String>? provinceAbbr,
    Expression<bool>? hasRestriction,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (province != null) 'province': province,
      if (provinceAbbr != null) 'province_abbr': provinceAbbr,
      if (hasRestriction != null) 'has_restriction': hasRestriction,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MyCityRowsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? province,
      Value<String>? provinceAbbr,
      Value<bool>? hasRestriction,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return MyCityRowsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      province: province ?? this.province,
      provinceAbbr: provinceAbbr ?? this.provinceAbbr,
      hasRestriction: hasRestriction ?? this.hasRestriction,
      sortOrder: sortOrder ?? this.sortOrder,
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
    if (province.present) {
      map['province'] = Variable<String>(province.value);
    }
    if (provinceAbbr.present) {
      map['province_abbr'] = Variable<String>(provinceAbbr.value);
    }
    if (hasRestriction.present) {
      map['has_restriction'] = Variable<bool>(hasRestriction.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MyCityRowsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('province: $province, ')
          ..write('provinceAbbr: $provinceAbbr, ')
          ..write('hasRestriction: $hasRestriction, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CityCacheRowsTable extends CityCacheRows
    with TableInfo<$CityCacheRowsTable, CityCacheRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CityCacheRowsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _provinceMeta =
      const VerificationMeta('province');
  @override
  late final GeneratedColumn<String> province = GeneratedColumn<String>(
      'province', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _provinceAbbrMeta =
      const VerificationMeta('provinceAbbr');
  @override
  late final GeneratedColumn<String> provinceAbbr = GeneratedColumn<String>(
      'province_abbr', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [id, name, province, provinceAbbr];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'city_cache_rows';
  @override
  VerificationContext validateIntegrity(Insertable<CityCacheRow> instance,
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
    if (data.containsKey('province')) {
      context.handle(_provinceMeta,
          province.isAcceptableOrUnknown(data['province']!, _provinceMeta));
    }
    if (data.containsKey('province_abbr')) {
      context.handle(
          _provinceAbbrMeta,
          provinceAbbr.isAcceptableOrUnknown(
              data['province_abbr']!, _provinceAbbrMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CityCacheRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CityCacheRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      province: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}province'])!,
      provinceAbbr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}province_abbr'])!,
    );
  }

  @override
  $CityCacheRowsTable createAlias(String alias) {
    return $CityCacheRowsTable(attachedDatabase, alias);
  }
}

class CityCacheRow extends DataClass implements Insertable<CityCacheRow> {
  final String id;
  final String name;
  final String province;
  final String provinceAbbr;
  const CityCacheRow(
      {required this.id,
      required this.name,
      required this.province,
      required this.provinceAbbr});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['province'] = Variable<String>(province);
    map['province_abbr'] = Variable<String>(provinceAbbr);
    return map;
  }

  CityCacheRowsCompanion toCompanion(bool nullToAbsent) {
    return CityCacheRowsCompanion(
      id: Value(id),
      name: Value(name),
      province: Value(province),
      provinceAbbr: Value(provinceAbbr),
    );
  }

  factory CityCacheRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CityCacheRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      province: serializer.fromJson<String>(json['province']),
      provinceAbbr: serializer.fromJson<String>(json['provinceAbbr']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'province': serializer.toJson<String>(province),
      'provinceAbbr': serializer.toJson<String>(provinceAbbr),
    };
  }

  CityCacheRow copyWith(
          {String? id, String? name, String? province, String? provinceAbbr}) =>
      CityCacheRow(
        id: id ?? this.id,
        name: name ?? this.name,
        province: province ?? this.province,
        provinceAbbr: provinceAbbr ?? this.provinceAbbr,
      );
  CityCacheRow copyWithCompanion(CityCacheRowsCompanion data) {
    return CityCacheRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      province: data.province.present ? data.province.value : this.province,
      provinceAbbr: data.provinceAbbr.present
          ? data.provinceAbbr.value
          : this.provinceAbbr,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CityCacheRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('province: $province, ')
          ..write('provinceAbbr: $provinceAbbr')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, province, provinceAbbr);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CityCacheRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.province == this.province &&
          other.provinceAbbr == this.provinceAbbr);
}

class CityCacheRowsCompanion extends UpdateCompanion<CityCacheRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> province;
  final Value<String> provinceAbbr;
  final Value<int> rowid;
  const CityCacheRowsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.province = const Value.absent(),
    this.provinceAbbr = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CityCacheRowsCompanion.insert({
    required String id,
    required String name,
    this.province = const Value.absent(),
    this.provinceAbbr = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<CityCacheRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? province,
    Expression<String>? provinceAbbr,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (province != null) 'province': province,
      if (provinceAbbr != null) 'province_abbr': provinceAbbr,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CityCacheRowsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? province,
      Value<String>? provinceAbbr,
      Value<int>? rowid}) {
    return CityCacheRowsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      province: province ?? this.province,
      provinceAbbr: provinceAbbr ?? this.provinceAbbr,
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
    if (province.present) {
      map['province'] = Variable<String>(province.value);
    }
    if (provinceAbbr.present) {
      map['province_abbr'] = Variable<String>(provinceAbbr.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CityCacheRowsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('province: $province, ')
          ..write('provinceAbbr: $provinceAbbr, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RestrictionDayRowsTable extends RestrictionDayRows
    with TableInfo<$RestrictionDayRowsTable, RestrictionDayRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RestrictionDayRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cityIdMeta = const VerificationMeta('cityId');
  @override
  late final GeneratedColumn<String> cityId = GeneratedColumn<String>(
      'city_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cityNameMeta =
      const VerificationMeta('cityName');
  @override
  late final GeneratedColumn<String> cityName = GeneratedColumn<String>(
      'city_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _dateIsoMeta =
      const VerificationMeta('dateIso');
  @override
  late final GeneratedColumn<String> dateIso = GeneratedColumn<String>(
      'date_iso', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isRestrictedDayMeta =
      const VerificationMeta('isRestrictedDay');
  @override
  late final GeneratedColumn<bool> isRestrictedDay = GeneratedColumn<bool>(
      'is_restricted_day', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_restricted_day" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _restrictedTailsMeta =
      const VerificationMeta('restrictedTails');
  @override
  late final GeneratedColumn<String> restrictedTails = GeneratedColumn<String>(
      'restricted_tails', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _timeWindowsJsonMeta =
      const VerificationMeta('timeWindowsJson');
  @override
  late final GeneratedColumn<String> timeWindowsJson = GeneratedColumn<String>(
      'time_windows_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _areaTextMeta =
      const VerificationMeta('areaText');
  @override
  late final GeneratedColumn<String> areaText = GeneratedColumn<String>(
      'area_text', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _ruleTextMeta =
      const VerificationMeta('ruleText');
  @override
  late final GeneratedColumn<String> ruleText = GeneratedColumn<String>(
      'rule_text', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _typeNameMeta =
      const VerificationMeta('typeName');
  @override
  late final GeneratedColumn<String> typeName = GeneratedColumn<String>(
      'type_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('tailRotationByWeekday'));
  static const VerificationMeta _appliesToNonLocalOnlyMeta =
      const VerificationMeta('appliesToNonLocalOnly');
  @override
  late final GeneratedColumn<bool> appliesToNonLocalOnly =
      GeneratedColumn<bool>('applies_to_non_local_only', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("applies_to_non_local_only" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _exemptsNewEnergyMeta =
      const VerificationMeta('exemptsNewEnergy');
  @override
  late final GeneratedColumn<bool> exemptsNewEnergy = GeneratedColumn<bool>(
      'exempts_new_energy', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("exempts_new_energy" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _tailDigitRuleNameMeta =
      const VerificationMeta('tailDigitRuleName');
  @override
  late final GeneratedColumn<String> tailDigitRuleName =
      GeneratedColumn<String>('tail_digit_rule_name', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('lastDigit'));
  static const VerificationMeta _cityProvinceAbbrMeta =
      const VerificationMeta('cityProvinceAbbr');
  @override
  late final GeneratedColumn<String> cityProvinceAbbr = GeneratedColumn<String>(
      'city_province_abbr', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('mock'));
  static const VerificationMeta _fetchedAtMeta =
      const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
      'fetched_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _expiresAtMeta =
      const VerificationMeta('expiresAt');
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
      'expires_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        cityId,
        cityName,
        dateIso,
        isRestrictedDay,
        restrictedTails,
        timeWindowsJson,
        areaText,
        ruleText,
        typeName,
        appliesToNonLocalOnly,
        exemptsNewEnergy,
        tailDigitRuleName,
        cityProvinceAbbr,
        source,
        fetchedAt,
        expiresAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'restriction_day_rows';
  @override
  VerificationContext validateIntegrity(Insertable<RestrictionDayRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('city_id')) {
      context.handle(_cityIdMeta,
          cityId.isAcceptableOrUnknown(data['city_id']!, _cityIdMeta));
    } else if (isInserting) {
      context.missing(_cityIdMeta);
    }
    if (data.containsKey('city_name')) {
      context.handle(_cityNameMeta,
          cityName.isAcceptableOrUnknown(data['city_name']!, _cityNameMeta));
    }
    if (data.containsKey('date_iso')) {
      context.handle(_dateIsoMeta,
          dateIso.isAcceptableOrUnknown(data['date_iso']!, _dateIsoMeta));
    } else if (isInserting) {
      context.missing(_dateIsoMeta);
    }
    if (data.containsKey('is_restricted_day')) {
      context.handle(
          _isRestrictedDayMeta,
          isRestrictedDay.isAcceptableOrUnknown(
              data['is_restricted_day']!, _isRestrictedDayMeta));
    }
    if (data.containsKey('restricted_tails')) {
      context.handle(
          _restrictedTailsMeta,
          restrictedTails.isAcceptableOrUnknown(
              data['restricted_tails']!, _restrictedTailsMeta));
    }
    if (data.containsKey('time_windows_json')) {
      context.handle(
          _timeWindowsJsonMeta,
          timeWindowsJson.isAcceptableOrUnknown(
              data['time_windows_json']!, _timeWindowsJsonMeta));
    }
    if (data.containsKey('area_text')) {
      context.handle(_areaTextMeta,
          areaText.isAcceptableOrUnknown(data['area_text']!, _areaTextMeta));
    }
    if (data.containsKey('rule_text')) {
      context.handle(_ruleTextMeta,
          ruleText.isAcceptableOrUnknown(data['rule_text']!, _ruleTextMeta));
    }
    if (data.containsKey('type_name')) {
      context.handle(_typeNameMeta,
          typeName.isAcceptableOrUnknown(data['type_name']!, _typeNameMeta));
    }
    if (data.containsKey('applies_to_non_local_only')) {
      context.handle(
          _appliesToNonLocalOnlyMeta,
          appliesToNonLocalOnly.isAcceptableOrUnknown(
              data['applies_to_non_local_only']!, _appliesToNonLocalOnlyMeta));
    }
    if (data.containsKey('exempts_new_energy')) {
      context.handle(
          _exemptsNewEnergyMeta,
          exemptsNewEnergy.isAcceptableOrUnknown(
              data['exempts_new_energy']!, _exemptsNewEnergyMeta));
    }
    if (data.containsKey('tail_digit_rule_name')) {
      context.handle(
          _tailDigitRuleNameMeta,
          tailDigitRuleName.isAcceptableOrUnknown(
              data['tail_digit_rule_name']!, _tailDigitRuleNameMeta));
    }
    if (data.containsKey('city_province_abbr')) {
      context.handle(
          _cityProvinceAbbrMeta,
          cityProvinceAbbr.isAcceptableOrUnknown(
              data['city_province_abbr']!, _cityProvinceAbbrMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('fetched_at')) {
      context.handle(_fetchedAtMeta,
          fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta));
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(_expiresAtMeta,
          expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cityId, dateIso};
  @override
  RestrictionDayRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RestrictionDayRow(
      cityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}city_id'])!,
      cityName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}city_name'])!,
      dateIso: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_iso'])!,
      isRestrictedDay: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_restricted_day'])!,
      restrictedTails: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}restricted_tails'])!,
      timeWindowsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}time_windows_json'])!,
      areaText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}area_text'])!,
      ruleText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rule_text'])!,
      typeName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type_name'])!,
      appliesToNonLocalOnly: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}applies_to_non_local_only'])!,
      exemptsNewEnergy: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}exempts_new_energy'])!,
      tailDigitRuleName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}tail_digit_rule_name'])!,
      cityProvinceAbbr: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}city_province_abbr'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      fetchedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fetched_at'])!,
      expiresAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expires_at']),
    );
  }

  @override
  $RestrictionDayRowsTable createAlias(String alias) {
    return $RestrictionDayRowsTable(attachedDatabase, alias);
  }
}

class RestrictionDayRow extends DataClass
    implements Insertable<RestrictionDayRow> {
  final String cityId;
  final String cityName;

  /// yyyy-MM-dd
  final String dateIso;
  final bool isRestrictedDay;

  /// 逗号分隔的尾号，如 "4,9"
  final String restrictedTails;

  /// JSON: [{"start":450,"end":1200}]
  final String timeWindowsJson;
  final String areaText;
  final String ruleText;
  final String typeName;
  final bool appliesToNonLocalOnly;
  final bool exemptsNewEnergy;
  final String tailDigitRuleName;
  final String cityProvinceAbbr;
  final String source;
  final DateTime fetchedAt;
  final DateTime? expiresAt;
  const RestrictionDayRow(
      {required this.cityId,
      required this.cityName,
      required this.dateIso,
      required this.isRestrictedDay,
      required this.restrictedTails,
      required this.timeWindowsJson,
      required this.areaText,
      required this.ruleText,
      required this.typeName,
      required this.appliesToNonLocalOnly,
      required this.exemptsNewEnergy,
      required this.tailDigitRuleName,
      required this.cityProvinceAbbr,
      required this.source,
      required this.fetchedAt,
      this.expiresAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['city_id'] = Variable<String>(cityId);
    map['city_name'] = Variable<String>(cityName);
    map['date_iso'] = Variable<String>(dateIso);
    map['is_restricted_day'] = Variable<bool>(isRestrictedDay);
    map['restricted_tails'] = Variable<String>(restrictedTails);
    map['time_windows_json'] = Variable<String>(timeWindowsJson);
    map['area_text'] = Variable<String>(areaText);
    map['rule_text'] = Variable<String>(ruleText);
    map['type_name'] = Variable<String>(typeName);
    map['applies_to_non_local_only'] = Variable<bool>(appliesToNonLocalOnly);
    map['exempts_new_energy'] = Variable<bool>(exemptsNewEnergy);
    map['tail_digit_rule_name'] = Variable<String>(tailDigitRuleName);
    map['city_province_abbr'] = Variable<String>(cityProvinceAbbr);
    map['source'] = Variable<String>(source);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    return map;
  }

  RestrictionDayRowsCompanion toCompanion(bool nullToAbsent) {
    return RestrictionDayRowsCompanion(
      cityId: Value(cityId),
      cityName: Value(cityName),
      dateIso: Value(dateIso),
      isRestrictedDay: Value(isRestrictedDay),
      restrictedTails: Value(restrictedTails),
      timeWindowsJson: Value(timeWindowsJson),
      areaText: Value(areaText),
      ruleText: Value(ruleText),
      typeName: Value(typeName),
      appliesToNonLocalOnly: Value(appliesToNonLocalOnly),
      exemptsNewEnergy: Value(exemptsNewEnergy),
      tailDigitRuleName: Value(tailDigitRuleName),
      cityProvinceAbbr: Value(cityProvinceAbbr),
      source: Value(source),
      fetchedAt: Value(fetchedAt),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
    );
  }

  factory RestrictionDayRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RestrictionDayRow(
      cityId: serializer.fromJson<String>(json['cityId']),
      cityName: serializer.fromJson<String>(json['cityName']),
      dateIso: serializer.fromJson<String>(json['dateIso']),
      isRestrictedDay: serializer.fromJson<bool>(json['isRestrictedDay']),
      restrictedTails: serializer.fromJson<String>(json['restrictedTails']),
      timeWindowsJson: serializer.fromJson<String>(json['timeWindowsJson']),
      areaText: serializer.fromJson<String>(json['areaText']),
      ruleText: serializer.fromJson<String>(json['ruleText']),
      typeName: serializer.fromJson<String>(json['typeName']),
      appliesToNonLocalOnly:
          serializer.fromJson<bool>(json['appliesToNonLocalOnly']),
      exemptsNewEnergy: serializer.fromJson<bool>(json['exemptsNewEnergy']),
      tailDigitRuleName: serializer.fromJson<String>(json['tailDigitRuleName']),
      cityProvinceAbbr: serializer.fromJson<String>(json['cityProvinceAbbr']),
      source: serializer.fromJson<String>(json['source']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cityId': serializer.toJson<String>(cityId),
      'cityName': serializer.toJson<String>(cityName),
      'dateIso': serializer.toJson<String>(dateIso),
      'isRestrictedDay': serializer.toJson<bool>(isRestrictedDay),
      'restrictedTails': serializer.toJson<String>(restrictedTails),
      'timeWindowsJson': serializer.toJson<String>(timeWindowsJson),
      'areaText': serializer.toJson<String>(areaText),
      'ruleText': serializer.toJson<String>(ruleText),
      'typeName': serializer.toJson<String>(typeName),
      'appliesToNonLocalOnly': serializer.toJson<bool>(appliesToNonLocalOnly),
      'exemptsNewEnergy': serializer.toJson<bool>(exemptsNewEnergy),
      'tailDigitRuleName': serializer.toJson<String>(tailDigitRuleName),
      'cityProvinceAbbr': serializer.toJson<String>(cityProvinceAbbr),
      'source': serializer.toJson<String>(source),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
    };
  }

  RestrictionDayRow copyWith(
          {String? cityId,
          String? cityName,
          String? dateIso,
          bool? isRestrictedDay,
          String? restrictedTails,
          String? timeWindowsJson,
          String? areaText,
          String? ruleText,
          String? typeName,
          bool? appliesToNonLocalOnly,
          bool? exemptsNewEnergy,
          String? tailDigitRuleName,
          String? cityProvinceAbbr,
          String? source,
          DateTime? fetchedAt,
          Value<DateTime?> expiresAt = const Value.absent()}) =>
      RestrictionDayRow(
        cityId: cityId ?? this.cityId,
        cityName: cityName ?? this.cityName,
        dateIso: dateIso ?? this.dateIso,
        isRestrictedDay: isRestrictedDay ?? this.isRestrictedDay,
        restrictedTails: restrictedTails ?? this.restrictedTails,
        timeWindowsJson: timeWindowsJson ?? this.timeWindowsJson,
        areaText: areaText ?? this.areaText,
        ruleText: ruleText ?? this.ruleText,
        typeName: typeName ?? this.typeName,
        appliesToNonLocalOnly:
            appliesToNonLocalOnly ?? this.appliesToNonLocalOnly,
        exemptsNewEnergy: exemptsNewEnergy ?? this.exemptsNewEnergy,
        tailDigitRuleName: tailDigitRuleName ?? this.tailDigitRuleName,
        cityProvinceAbbr: cityProvinceAbbr ?? this.cityProvinceAbbr,
        source: source ?? this.source,
        fetchedAt: fetchedAt ?? this.fetchedAt,
        expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
      );
  RestrictionDayRow copyWithCompanion(RestrictionDayRowsCompanion data) {
    return RestrictionDayRow(
      cityId: data.cityId.present ? data.cityId.value : this.cityId,
      cityName: data.cityName.present ? data.cityName.value : this.cityName,
      dateIso: data.dateIso.present ? data.dateIso.value : this.dateIso,
      isRestrictedDay: data.isRestrictedDay.present
          ? data.isRestrictedDay.value
          : this.isRestrictedDay,
      restrictedTails: data.restrictedTails.present
          ? data.restrictedTails.value
          : this.restrictedTails,
      timeWindowsJson: data.timeWindowsJson.present
          ? data.timeWindowsJson.value
          : this.timeWindowsJson,
      areaText: data.areaText.present ? data.areaText.value : this.areaText,
      ruleText: data.ruleText.present ? data.ruleText.value : this.ruleText,
      typeName: data.typeName.present ? data.typeName.value : this.typeName,
      appliesToNonLocalOnly: data.appliesToNonLocalOnly.present
          ? data.appliesToNonLocalOnly.value
          : this.appliesToNonLocalOnly,
      exemptsNewEnergy: data.exemptsNewEnergy.present
          ? data.exemptsNewEnergy.value
          : this.exemptsNewEnergy,
      tailDigitRuleName: data.tailDigitRuleName.present
          ? data.tailDigitRuleName.value
          : this.tailDigitRuleName,
      cityProvinceAbbr: data.cityProvinceAbbr.present
          ? data.cityProvinceAbbr.value
          : this.cityProvinceAbbr,
      source: data.source.present ? data.source.value : this.source,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RestrictionDayRow(')
          ..write('cityId: $cityId, ')
          ..write('cityName: $cityName, ')
          ..write('dateIso: $dateIso, ')
          ..write('isRestrictedDay: $isRestrictedDay, ')
          ..write('restrictedTails: $restrictedTails, ')
          ..write('timeWindowsJson: $timeWindowsJson, ')
          ..write('areaText: $areaText, ')
          ..write('ruleText: $ruleText, ')
          ..write('typeName: $typeName, ')
          ..write('appliesToNonLocalOnly: $appliesToNonLocalOnly, ')
          ..write('exemptsNewEnergy: $exemptsNewEnergy, ')
          ..write('tailDigitRuleName: $tailDigitRuleName, ')
          ..write('cityProvinceAbbr: $cityProvinceAbbr, ')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      cityId,
      cityName,
      dateIso,
      isRestrictedDay,
      restrictedTails,
      timeWindowsJson,
      areaText,
      ruleText,
      typeName,
      appliesToNonLocalOnly,
      exemptsNewEnergy,
      tailDigitRuleName,
      cityProvinceAbbr,
      source,
      fetchedAt,
      expiresAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RestrictionDayRow &&
          other.cityId == this.cityId &&
          other.cityName == this.cityName &&
          other.dateIso == this.dateIso &&
          other.isRestrictedDay == this.isRestrictedDay &&
          other.restrictedTails == this.restrictedTails &&
          other.timeWindowsJson == this.timeWindowsJson &&
          other.areaText == this.areaText &&
          other.ruleText == this.ruleText &&
          other.typeName == this.typeName &&
          other.appliesToNonLocalOnly == this.appliesToNonLocalOnly &&
          other.exemptsNewEnergy == this.exemptsNewEnergy &&
          other.tailDigitRuleName == this.tailDigitRuleName &&
          other.cityProvinceAbbr == this.cityProvinceAbbr &&
          other.source == this.source &&
          other.fetchedAt == this.fetchedAt &&
          other.expiresAt == this.expiresAt);
}

class RestrictionDayRowsCompanion extends UpdateCompanion<RestrictionDayRow> {
  final Value<String> cityId;
  final Value<String> cityName;
  final Value<String> dateIso;
  final Value<bool> isRestrictedDay;
  final Value<String> restrictedTails;
  final Value<String> timeWindowsJson;
  final Value<String> areaText;
  final Value<String> ruleText;
  final Value<String> typeName;
  final Value<bool> appliesToNonLocalOnly;
  final Value<bool> exemptsNewEnergy;
  final Value<String> tailDigitRuleName;
  final Value<String> cityProvinceAbbr;
  final Value<String> source;
  final Value<DateTime> fetchedAt;
  final Value<DateTime?> expiresAt;
  final Value<int> rowid;
  const RestrictionDayRowsCompanion({
    this.cityId = const Value.absent(),
    this.cityName = const Value.absent(),
    this.dateIso = const Value.absent(),
    this.isRestrictedDay = const Value.absent(),
    this.restrictedTails = const Value.absent(),
    this.timeWindowsJson = const Value.absent(),
    this.areaText = const Value.absent(),
    this.ruleText = const Value.absent(),
    this.typeName = const Value.absent(),
    this.appliesToNonLocalOnly = const Value.absent(),
    this.exemptsNewEnergy = const Value.absent(),
    this.tailDigitRuleName = const Value.absent(),
    this.cityProvinceAbbr = const Value.absent(),
    this.source = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RestrictionDayRowsCompanion.insert({
    required String cityId,
    this.cityName = const Value.absent(),
    required String dateIso,
    this.isRestrictedDay = const Value.absent(),
    this.restrictedTails = const Value.absent(),
    this.timeWindowsJson = const Value.absent(),
    this.areaText = const Value.absent(),
    this.ruleText = const Value.absent(),
    this.typeName = const Value.absent(),
    this.appliesToNonLocalOnly = const Value.absent(),
    this.exemptsNewEnergy = const Value.absent(),
    this.tailDigitRuleName = const Value.absent(),
    this.cityProvinceAbbr = const Value.absent(),
    this.source = const Value.absent(),
    required DateTime fetchedAt,
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : cityId = Value(cityId),
        dateIso = Value(dateIso),
        fetchedAt = Value(fetchedAt);
  static Insertable<RestrictionDayRow> custom({
    Expression<String>? cityId,
    Expression<String>? cityName,
    Expression<String>? dateIso,
    Expression<bool>? isRestrictedDay,
    Expression<String>? restrictedTails,
    Expression<String>? timeWindowsJson,
    Expression<String>? areaText,
    Expression<String>? ruleText,
    Expression<String>? typeName,
    Expression<bool>? appliesToNonLocalOnly,
    Expression<bool>? exemptsNewEnergy,
    Expression<String>? tailDigitRuleName,
    Expression<String>? cityProvinceAbbr,
    Expression<String>? source,
    Expression<DateTime>? fetchedAt,
    Expression<DateTime>? expiresAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cityId != null) 'city_id': cityId,
      if (cityName != null) 'city_name': cityName,
      if (dateIso != null) 'date_iso': dateIso,
      if (isRestrictedDay != null) 'is_restricted_day': isRestrictedDay,
      if (restrictedTails != null) 'restricted_tails': restrictedTails,
      if (timeWindowsJson != null) 'time_windows_json': timeWindowsJson,
      if (areaText != null) 'area_text': areaText,
      if (ruleText != null) 'rule_text': ruleText,
      if (typeName != null) 'type_name': typeName,
      if (appliesToNonLocalOnly != null)
        'applies_to_non_local_only': appliesToNonLocalOnly,
      if (exemptsNewEnergy != null) 'exempts_new_energy': exemptsNewEnergy,
      if (tailDigitRuleName != null) 'tail_digit_rule_name': tailDigitRuleName,
      if (cityProvinceAbbr != null) 'city_province_abbr': cityProvinceAbbr,
      if (source != null) 'source': source,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RestrictionDayRowsCompanion copyWith(
      {Value<String>? cityId,
      Value<String>? cityName,
      Value<String>? dateIso,
      Value<bool>? isRestrictedDay,
      Value<String>? restrictedTails,
      Value<String>? timeWindowsJson,
      Value<String>? areaText,
      Value<String>? ruleText,
      Value<String>? typeName,
      Value<bool>? appliesToNonLocalOnly,
      Value<bool>? exemptsNewEnergy,
      Value<String>? tailDigitRuleName,
      Value<String>? cityProvinceAbbr,
      Value<String>? source,
      Value<DateTime>? fetchedAt,
      Value<DateTime?>? expiresAt,
      Value<int>? rowid}) {
    return RestrictionDayRowsCompanion(
      cityId: cityId ?? this.cityId,
      cityName: cityName ?? this.cityName,
      dateIso: dateIso ?? this.dateIso,
      isRestrictedDay: isRestrictedDay ?? this.isRestrictedDay,
      restrictedTails: restrictedTails ?? this.restrictedTails,
      timeWindowsJson: timeWindowsJson ?? this.timeWindowsJson,
      areaText: areaText ?? this.areaText,
      ruleText: ruleText ?? this.ruleText,
      typeName: typeName ?? this.typeName,
      appliesToNonLocalOnly:
          appliesToNonLocalOnly ?? this.appliesToNonLocalOnly,
      exemptsNewEnergy: exemptsNewEnergy ?? this.exemptsNewEnergy,
      tailDigitRuleName: tailDigitRuleName ?? this.tailDigitRuleName,
      cityProvinceAbbr: cityProvinceAbbr ?? this.cityProvinceAbbr,
      source: source ?? this.source,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cityId.present) {
      map['city_id'] = Variable<String>(cityId.value);
    }
    if (cityName.present) {
      map['city_name'] = Variable<String>(cityName.value);
    }
    if (dateIso.present) {
      map['date_iso'] = Variable<String>(dateIso.value);
    }
    if (isRestrictedDay.present) {
      map['is_restricted_day'] = Variable<bool>(isRestrictedDay.value);
    }
    if (restrictedTails.present) {
      map['restricted_tails'] = Variable<String>(restrictedTails.value);
    }
    if (timeWindowsJson.present) {
      map['time_windows_json'] = Variable<String>(timeWindowsJson.value);
    }
    if (areaText.present) {
      map['area_text'] = Variable<String>(areaText.value);
    }
    if (ruleText.present) {
      map['rule_text'] = Variable<String>(ruleText.value);
    }
    if (typeName.present) {
      map['type_name'] = Variable<String>(typeName.value);
    }
    if (appliesToNonLocalOnly.present) {
      map['applies_to_non_local_only'] =
          Variable<bool>(appliesToNonLocalOnly.value);
    }
    if (exemptsNewEnergy.present) {
      map['exempts_new_energy'] = Variable<bool>(exemptsNewEnergy.value);
    }
    if (tailDigitRuleName.present) {
      map['tail_digit_rule_name'] = Variable<String>(tailDigitRuleName.value);
    }
    if (cityProvinceAbbr.present) {
      map['city_province_abbr'] = Variable<String>(cityProvinceAbbr.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RestrictionDayRowsCompanion(')
          ..write('cityId: $cityId, ')
          ..write('cityName: $cityName, ')
          ..write('dateIso: $dateIso, ')
          ..write('isRestrictedDay: $isRestrictedDay, ')
          ..write('restrictedTails: $restrictedTails, ')
          ..write('timeWindowsJson: $timeWindowsJson, ')
          ..write('areaText: $areaText, ')
          ..write('ruleText: $ruleText, ')
          ..write('typeName: $typeName, ')
          ..write('appliesToNonLocalOnly: $appliesToNonLocalOnly, ')
          ..write('exemptsNewEnergy: $exemptsNewEnergy, ')
          ..write('tailDigitRuleName: $tailDigitRuleName, ')
          ..write('cityProvinceAbbr: $cityProvinceAbbr, ')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReminderConfigRowsTable extends ReminderConfigRows
    with TableInfo<$ReminderConfigRowsTable, ReminderConfigRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderConfigRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cityIdMeta = const VerificationMeta('cityId');
  @override
  late final GeneratedColumn<String> cityId = GeneratedColumn<String>(
      'city_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _previewEnabledMeta =
      const VerificationMeta('previewEnabled');
  @override
  late final GeneratedColumn<bool> previewEnabled = GeneratedColumn<bool>(
      'preview_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("preview_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _previewMinutesOfDayMeta =
      const VerificationMeta('previewMinutesOfDay');
  @override
  late final GeneratedColumn<int> previewMinutesOfDay = GeneratedColumn<int>(
      'preview_minutes_of_day', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1260));
  static const VerificationMeta _strongEnabledMeta =
      const VerificationMeta('strongEnabled');
  @override
  late final GeneratedColumn<bool> strongEnabled = GeneratedColumn<bool>(
      'strong_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("strong_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _strongLeadMinutesMeta =
      const VerificationMeta('strongLeadMinutes');
  @override
  late final GeneratedColumn<int> strongLeadMinutes = GeneratedColumn<int>(
      'strong_lead_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(10));
  static const VerificationMeta _strongFallbackMinutesOfDayMeta =
      const VerificationMeta('strongFallbackMinutesOfDay');
  @override
  late final GeneratedColumn<int> strongFallbackMinutesOfDay =
      GeneratedColumn<int>('strong_fallback_minutes_of_day', aliasedName, false,
          type: DriftSqlType.int,
          requiredDuringInsert: false,
          defaultValue: const Constant(420));
  static const VerificationMeta _voiceEnabledMeta =
      const VerificationMeta('voiceEnabled');
  @override
  late final GeneratedColumn<bool> voiceEnabled = GeneratedColumn<bool>(
      'voice_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("voice_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _fullScreenEnabledMeta =
      const VerificationMeta('fullScreenEnabled');
  @override
  late final GeneratedColumn<bool> fullScreenEnabled = GeneratedColumn<bool>(
      'full_screen_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("full_screen_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _bypassDndEnabledMeta =
      const VerificationMeta('bypassDndEnabled');
  @override
  late final GeneratedColumn<bool> bypassDndEnabled = GeneratedColumn<bool>(
      'bypass_dnd_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("bypass_dnd_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        cityId,
        previewEnabled,
        previewMinutesOfDay,
        strongEnabled,
        strongLeadMinutes,
        strongFallbackMinutesOfDay,
        voiceEnabled,
        fullScreenEnabled,
        bypassDndEnabled
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_config_rows';
  @override
  VerificationContext validateIntegrity(Insertable<ReminderConfigRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('city_id')) {
      context.handle(_cityIdMeta,
          cityId.isAcceptableOrUnknown(data['city_id']!, _cityIdMeta));
    } else if (isInserting) {
      context.missing(_cityIdMeta);
    }
    if (data.containsKey('preview_enabled')) {
      context.handle(
          _previewEnabledMeta,
          previewEnabled.isAcceptableOrUnknown(
              data['preview_enabled']!, _previewEnabledMeta));
    }
    if (data.containsKey('preview_minutes_of_day')) {
      context.handle(
          _previewMinutesOfDayMeta,
          previewMinutesOfDay.isAcceptableOrUnknown(
              data['preview_minutes_of_day']!, _previewMinutesOfDayMeta));
    }
    if (data.containsKey('strong_enabled')) {
      context.handle(
          _strongEnabledMeta,
          strongEnabled.isAcceptableOrUnknown(
              data['strong_enabled']!, _strongEnabledMeta));
    }
    if (data.containsKey('strong_lead_minutes')) {
      context.handle(
          _strongLeadMinutesMeta,
          strongLeadMinutes.isAcceptableOrUnknown(
              data['strong_lead_minutes']!, _strongLeadMinutesMeta));
    }
    if (data.containsKey('strong_fallback_minutes_of_day')) {
      context.handle(
          _strongFallbackMinutesOfDayMeta,
          strongFallbackMinutesOfDay.isAcceptableOrUnknown(
              data['strong_fallback_minutes_of_day']!,
              _strongFallbackMinutesOfDayMeta));
    }
    if (data.containsKey('voice_enabled')) {
      context.handle(
          _voiceEnabledMeta,
          voiceEnabled.isAcceptableOrUnknown(
              data['voice_enabled']!, _voiceEnabledMeta));
    }
    if (data.containsKey('full_screen_enabled')) {
      context.handle(
          _fullScreenEnabledMeta,
          fullScreenEnabled.isAcceptableOrUnknown(
              data['full_screen_enabled']!, _fullScreenEnabledMeta));
    }
    if (data.containsKey('bypass_dnd_enabled')) {
      context.handle(
          _bypassDndEnabledMeta,
          bypassDndEnabled.isAcceptableOrUnknown(
              data['bypass_dnd_enabled']!, _bypassDndEnabledMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cityId};
  @override
  ReminderConfigRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderConfigRow(
      cityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}city_id'])!,
      previewEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}preview_enabled'])!,
      previewMinutesOfDay: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}preview_minutes_of_day'])!,
      strongEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}strong_enabled'])!,
      strongLeadMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}strong_lead_minutes'])!,
      strongFallbackMinutesOfDay: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}strong_fallback_minutes_of_day'])!,
      voiceEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}voice_enabled'])!,
      fullScreenEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}full_screen_enabled'])!,
      bypassDndEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}bypass_dnd_enabled'])!,
    );
  }

  @override
  $ReminderConfigRowsTable createAlias(String alias) {
    return $ReminderConfigRowsTable(attachedDatabase, alias);
  }
}

class ReminderConfigRow extends DataClass
    implements Insertable<ReminderConfigRow> {
  final String cityId;
  final bool previewEnabled;
  final int previewMinutesOfDay;
  final bool strongEnabled;
  final int strongLeadMinutes;
  final int strongFallbackMinutesOfDay;
  final bool voiceEnabled;
  final bool fullScreenEnabled;
  final bool bypassDndEnabled;
  const ReminderConfigRow(
      {required this.cityId,
      required this.previewEnabled,
      required this.previewMinutesOfDay,
      required this.strongEnabled,
      required this.strongLeadMinutes,
      required this.strongFallbackMinutesOfDay,
      required this.voiceEnabled,
      required this.fullScreenEnabled,
      required this.bypassDndEnabled});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['city_id'] = Variable<String>(cityId);
    map['preview_enabled'] = Variable<bool>(previewEnabled);
    map['preview_minutes_of_day'] = Variable<int>(previewMinutesOfDay);
    map['strong_enabled'] = Variable<bool>(strongEnabled);
    map['strong_lead_minutes'] = Variable<int>(strongLeadMinutes);
    map['strong_fallback_minutes_of_day'] =
        Variable<int>(strongFallbackMinutesOfDay);
    map['voice_enabled'] = Variable<bool>(voiceEnabled);
    map['full_screen_enabled'] = Variable<bool>(fullScreenEnabled);
    map['bypass_dnd_enabled'] = Variable<bool>(bypassDndEnabled);
    return map;
  }

  ReminderConfigRowsCompanion toCompanion(bool nullToAbsent) {
    return ReminderConfigRowsCompanion(
      cityId: Value(cityId),
      previewEnabled: Value(previewEnabled),
      previewMinutesOfDay: Value(previewMinutesOfDay),
      strongEnabled: Value(strongEnabled),
      strongLeadMinutes: Value(strongLeadMinutes),
      strongFallbackMinutesOfDay: Value(strongFallbackMinutesOfDay),
      voiceEnabled: Value(voiceEnabled),
      fullScreenEnabled: Value(fullScreenEnabled),
      bypassDndEnabled: Value(bypassDndEnabled),
    );
  }

  factory ReminderConfigRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderConfigRow(
      cityId: serializer.fromJson<String>(json['cityId']),
      previewEnabled: serializer.fromJson<bool>(json['previewEnabled']),
      previewMinutesOfDay:
          serializer.fromJson<int>(json['previewMinutesOfDay']),
      strongEnabled: serializer.fromJson<bool>(json['strongEnabled']),
      strongLeadMinutes: serializer.fromJson<int>(json['strongLeadMinutes']),
      strongFallbackMinutesOfDay:
          serializer.fromJson<int>(json['strongFallbackMinutesOfDay']),
      voiceEnabled: serializer.fromJson<bool>(json['voiceEnabled']),
      fullScreenEnabled: serializer.fromJson<bool>(json['fullScreenEnabled']),
      bypassDndEnabled: serializer.fromJson<bool>(json['bypassDndEnabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cityId': serializer.toJson<String>(cityId),
      'previewEnabled': serializer.toJson<bool>(previewEnabled),
      'previewMinutesOfDay': serializer.toJson<int>(previewMinutesOfDay),
      'strongEnabled': serializer.toJson<bool>(strongEnabled),
      'strongLeadMinutes': serializer.toJson<int>(strongLeadMinutes),
      'strongFallbackMinutesOfDay':
          serializer.toJson<int>(strongFallbackMinutesOfDay),
      'voiceEnabled': serializer.toJson<bool>(voiceEnabled),
      'fullScreenEnabled': serializer.toJson<bool>(fullScreenEnabled),
      'bypassDndEnabled': serializer.toJson<bool>(bypassDndEnabled),
    };
  }

  ReminderConfigRow copyWith(
          {String? cityId,
          bool? previewEnabled,
          int? previewMinutesOfDay,
          bool? strongEnabled,
          int? strongLeadMinutes,
          int? strongFallbackMinutesOfDay,
          bool? voiceEnabled,
          bool? fullScreenEnabled,
          bool? bypassDndEnabled}) =>
      ReminderConfigRow(
        cityId: cityId ?? this.cityId,
        previewEnabled: previewEnabled ?? this.previewEnabled,
        previewMinutesOfDay: previewMinutesOfDay ?? this.previewMinutesOfDay,
        strongEnabled: strongEnabled ?? this.strongEnabled,
        strongLeadMinutes: strongLeadMinutes ?? this.strongLeadMinutes,
        strongFallbackMinutesOfDay:
            strongFallbackMinutesOfDay ?? this.strongFallbackMinutesOfDay,
        voiceEnabled: voiceEnabled ?? this.voiceEnabled,
        fullScreenEnabled: fullScreenEnabled ?? this.fullScreenEnabled,
        bypassDndEnabled: bypassDndEnabled ?? this.bypassDndEnabled,
      );
  ReminderConfigRow copyWithCompanion(ReminderConfigRowsCompanion data) {
    return ReminderConfigRow(
      cityId: data.cityId.present ? data.cityId.value : this.cityId,
      previewEnabled: data.previewEnabled.present
          ? data.previewEnabled.value
          : this.previewEnabled,
      previewMinutesOfDay: data.previewMinutesOfDay.present
          ? data.previewMinutesOfDay.value
          : this.previewMinutesOfDay,
      strongEnabled: data.strongEnabled.present
          ? data.strongEnabled.value
          : this.strongEnabled,
      strongLeadMinutes: data.strongLeadMinutes.present
          ? data.strongLeadMinutes.value
          : this.strongLeadMinutes,
      strongFallbackMinutesOfDay: data.strongFallbackMinutesOfDay.present
          ? data.strongFallbackMinutesOfDay.value
          : this.strongFallbackMinutesOfDay,
      voiceEnabled: data.voiceEnabled.present
          ? data.voiceEnabled.value
          : this.voiceEnabled,
      fullScreenEnabled: data.fullScreenEnabled.present
          ? data.fullScreenEnabled.value
          : this.fullScreenEnabled,
      bypassDndEnabled: data.bypassDndEnabled.present
          ? data.bypassDndEnabled.value
          : this.bypassDndEnabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderConfigRow(')
          ..write('cityId: $cityId, ')
          ..write('previewEnabled: $previewEnabled, ')
          ..write('previewMinutesOfDay: $previewMinutesOfDay, ')
          ..write('strongEnabled: $strongEnabled, ')
          ..write('strongLeadMinutes: $strongLeadMinutes, ')
          ..write('strongFallbackMinutesOfDay: $strongFallbackMinutesOfDay, ')
          ..write('voiceEnabled: $voiceEnabled, ')
          ..write('fullScreenEnabled: $fullScreenEnabled, ')
          ..write('bypassDndEnabled: $bypassDndEnabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      cityId,
      previewEnabled,
      previewMinutesOfDay,
      strongEnabled,
      strongLeadMinutes,
      strongFallbackMinutesOfDay,
      voiceEnabled,
      fullScreenEnabled,
      bypassDndEnabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderConfigRow &&
          other.cityId == this.cityId &&
          other.previewEnabled == this.previewEnabled &&
          other.previewMinutesOfDay == this.previewMinutesOfDay &&
          other.strongEnabled == this.strongEnabled &&
          other.strongLeadMinutes == this.strongLeadMinutes &&
          other.strongFallbackMinutesOfDay == this.strongFallbackMinutesOfDay &&
          other.voiceEnabled == this.voiceEnabled &&
          other.fullScreenEnabled == this.fullScreenEnabled &&
          other.bypassDndEnabled == this.bypassDndEnabled);
}

class ReminderConfigRowsCompanion extends UpdateCompanion<ReminderConfigRow> {
  final Value<String> cityId;
  final Value<bool> previewEnabled;
  final Value<int> previewMinutesOfDay;
  final Value<bool> strongEnabled;
  final Value<int> strongLeadMinutes;
  final Value<int> strongFallbackMinutesOfDay;
  final Value<bool> voiceEnabled;
  final Value<bool> fullScreenEnabled;
  final Value<bool> bypassDndEnabled;
  final Value<int> rowid;
  const ReminderConfigRowsCompanion({
    this.cityId = const Value.absent(),
    this.previewEnabled = const Value.absent(),
    this.previewMinutesOfDay = const Value.absent(),
    this.strongEnabled = const Value.absent(),
    this.strongLeadMinutes = const Value.absent(),
    this.strongFallbackMinutesOfDay = const Value.absent(),
    this.voiceEnabled = const Value.absent(),
    this.fullScreenEnabled = const Value.absent(),
    this.bypassDndEnabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReminderConfigRowsCompanion.insert({
    required String cityId,
    this.previewEnabled = const Value.absent(),
    this.previewMinutesOfDay = const Value.absent(),
    this.strongEnabled = const Value.absent(),
    this.strongLeadMinutes = const Value.absent(),
    this.strongFallbackMinutesOfDay = const Value.absent(),
    this.voiceEnabled = const Value.absent(),
    this.fullScreenEnabled = const Value.absent(),
    this.bypassDndEnabled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : cityId = Value(cityId);
  static Insertable<ReminderConfigRow> custom({
    Expression<String>? cityId,
    Expression<bool>? previewEnabled,
    Expression<int>? previewMinutesOfDay,
    Expression<bool>? strongEnabled,
    Expression<int>? strongLeadMinutes,
    Expression<int>? strongFallbackMinutesOfDay,
    Expression<bool>? voiceEnabled,
    Expression<bool>? fullScreenEnabled,
    Expression<bool>? bypassDndEnabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cityId != null) 'city_id': cityId,
      if (previewEnabled != null) 'preview_enabled': previewEnabled,
      if (previewMinutesOfDay != null)
        'preview_minutes_of_day': previewMinutesOfDay,
      if (strongEnabled != null) 'strong_enabled': strongEnabled,
      if (strongLeadMinutes != null) 'strong_lead_minutes': strongLeadMinutes,
      if (strongFallbackMinutesOfDay != null)
        'strong_fallback_minutes_of_day': strongFallbackMinutesOfDay,
      if (voiceEnabled != null) 'voice_enabled': voiceEnabled,
      if (fullScreenEnabled != null) 'full_screen_enabled': fullScreenEnabled,
      if (bypassDndEnabled != null) 'bypass_dnd_enabled': bypassDndEnabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReminderConfigRowsCompanion copyWith(
      {Value<String>? cityId,
      Value<bool>? previewEnabled,
      Value<int>? previewMinutesOfDay,
      Value<bool>? strongEnabled,
      Value<int>? strongLeadMinutes,
      Value<int>? strongFallbackMinutesOfDay,
      Value<bool>? voiceEnabled,
      Value<bool>? fullScreenEnabled,
      Value<bool>? bypassDndEnabled,
      Value<int>? rowid}) {
    return ReminderConfigRowsCompanion(
      cityId: cityId ?? this.cityId,
      previewEnabled: previewEnabled ?? this.previewEnabled,
      previewMinutesOfDay: previewMinutesOfDay ?? this.previewMinutesOfDay,
      strongEnabled: strongEnabled ?? this.strongEnabled,
      strongLeadMinutes: strongLeadMinutes ?? this.strongLeadMinutes,
      strongFallbackMinutesOfDay:
          strongFallbackMinutesOfDay ?? this.strongFallbackMinutesOfDay,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      fullScreenEnabled: fullScreenEnabled ?? this.fullScreenEnabled,
      bypassDndEnabled: bypassDndEnabled ?? this.bypassDndEnabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cityId.present) {
      map['city_id'] = Variable<String>(cityId.value);
    }
    if (previewEnabled.present) {
      map['preview_enabled'] = Variable<bool>(previewEnabled.value);
    }
    if (previewMinutesOfDay.present) {
      map['preview_minutes_of_day'] = Variable<int>(previewMinutesOfDay.value);
    }
    if (strongEnabled.present) {
      map['strong_enabled'] = Variable<bool>(strongEnabled.value);
    }
    if (strongLeadMinutes.present) {
      map['strong_lead_minutes'] = Variable<int>(strongLeadMinutes.value);
    }
    if (strongFallbackMinutesOfDay.present) {
      map['strong_fallback_minutes_of_day'] =
          Variable<int>(strongFallbackMinutesOfDay.value);
    }
    if (voiceEnabled.present) {
      map['voice_enabled'] = Variable<bool>(voiceEnabled.value);
    }
    if (fullScreenEnabled.present) {
      map['full_screen_enabled'] = Variable<bool>(fullScreenEnabled.value);
    }
    if (bypassDndEnabled.present) {
      map['bypass_dnd_enabled'] = Variable<bool>(bypassDndEnabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderConfigRowsCompanion(')
          ..write('cityId: $cityId, ')
          ..write('previewEnabled: $previewEnabled, ')
          ..write('previewMinutesOfDay: $previewMinutesOfDay, ')
          ..write('strongEnabled: $strongEnabled, ')
          ..write('strongLeadMinutes: $strongLeadMinutes, ')
          ..write('strongFallbackMinutesOfDay: $strongFallbackMinutesOfDay, ')
          ..write('voiceEnabled: $voiceEnabled, ')
          ..write('fullScreenEnabled: $fullScreenEnabled, ')
          ..write('bypassDndEnabled: $bypassDndEnabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScheduledRemindersTableTable extends ScheduledRemindersTable
    with TableInfo<$ScheduledRemindersTableTable, ScheduledRemindersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduledRemindersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kindNameMeta =
      const VerificationMeta('kindName');
  @override
  late final GeneratedColumn<String> kindName = GeneratedColumn<String>(
      'kind_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fireAtMeta = const VerificationMeta('fireAt');
  @override
  late final GeneratedColumn<DateTime> fireAt = GeneratedColumn<DateTime>(
      'fire_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _cityIdMeta = const VerificationMeta('cityId');
  @override
  late final GeneratedColumn<String> cityId = GeneratedColumn<String>(
      'city_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateIsoMeta =
      const VerificationMeta('dateIso');
  @override
  late final GeneratedColumn<String> dateIso = GeneratedColumn<String>(
      'date_iso', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _vehicleIdMeta =
      const VerificationMeta('vehicleId');
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
      'vehicle_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _voiceTextMeta =
      const VerificationMeta('voiceText');
  @override
  late final GeneratedColumn<String> voiceText = GeneratedColumn<String>(
      'voice_text', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _tailsTextMeta =
      const VerificationMeta('tailsText');
  @override
  late final GeneratedColumn<String> tailsText = GeneratedColumn<String>(
      'tails_text', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _timeWindowTextMeta =
      const VerificationMeta('timeWindowText');
  @override
  late final GeneratedColumn<String> timeWindowText = GeneratedColumn<String>(
      'time_window_text', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _areaTextMeta =
      const VerificationMeta('areaText');
  @override
  late final GeneratedColumn<String> areaText = GeneratedColumn<String>(
      'area_text', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _cityNameMeta =
      const VerificationMeta('cityName');
  @override
  late final GeneratedColumn<String> cityName = GeneratedColumn<String>(
      'city_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _plateTextMeta =
      const VerificationMeta('plateText');
  @override
  late final GeneratedColumn<String> plateText = GeneratedColumn<String>(
      'plate_text', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        kindName,
        fireAt,
        cityId,
        dateIso,
        vehicleId,
        title,
        body,
        voiceText,
        tailsText,
        timeWindowText,
        areaText,
        cityName,
        plateText
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scheduled_reminders_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<ScheduledRemindersTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind_name')) {
      context.handle(_kindNameMeta,
          kindName.isAcceptableOrUnknown(data['kind_name']!, _kindNameMeta));
    } else if (isInserting) {
      context.missing(_kindNameMeta);
    }
    if (data.containsKey('fire_at')) {
      context.handle(_fireAtMeta,
          fireAt.isAcceptableOrUnknown(data['fire_at']!, _fireAtMeta));
    } else if (isInserting) {
      context.missing(_fireAtMeta);
    }
    if (data.containsKey('city_id')) {
      context.handle(_cityIdMeta,
          cityId.isAcceptableOrUnknown(data['city_id']!, _cityIdMeta));
    } else if (isInserting) {
      context.missing(_cityIdMeta);
    }
    if (data.containsKey('date_iso')) {
      context.handle(_dateIsoMeta,
          dateIso.isAcceptableOrUnknown(data['date_iso']!, _dateIsoMeta));
    } else if (isInserting) {
      context.missing(_dateIsoMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(_vehicleIdMeta,
          vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta));
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('voice_text')) {
      context.handle(_voiceTextMeta,
          voiceText.isAcceptableOrUnknown(data['voice_text']!, _voiceTextMeta));
    }
    if (data.containsKey('tails_text')) {
      context.handle(_tailsTextMeta,
          tailsText.isAcceptableOrUnknown(data['tails_text']!, _tailsTextMeta));
    }
    if (data.containsKey('time_window_text')) {
      context.handle(
          _timeWindowTextMeta,
          timeWindowText.isAcceptableOrUnknown(
              data['time_window_text']!, _timeWindowTextMeta));
    }
    if (data.containsKey('area_text')) {
      context.handle(_areaTextMeta,
          areaText.isAcceptableOrUnknown(data['area_text']!, _areaTextMeta));
    }
    if (data.containsKey('city_name')) {
      context.handle(_cityNameMeta,
          cityName.isAcceptableOrUnknown(data['city_name']!, _cityNameMeta));
    }
    if (data.containsKey('plate_text')) {
      context.handle(_plateTextMeta,
          plateText.isAcceptableOrUnknown(data['plate_text']!, _plateTextMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduledRemindersTableData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduledRemindersTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      kindName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind_name'])!,
      fireAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fire_at'])!,
      cityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}city_id'])!,
      dateIso: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_iso'])!,
      vehicleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vehicle_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      voiceText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}voice_text'])!,
      tailsText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tails_text'])!,
      timeWindowText: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}time_window_text'])!,
      areaText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}area_text'])!,
      cityName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}city_name'])!,
      plateText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plate_text'])!,
    );
  }

  @override
  $ScheduledRemindersTableTable createAlias(String alias) {
    return $ScheduledRemindersTableTable(attachedDatabase, alias);
  }
}

class ScheduledRemindersTableData extends DataClass
    implements Insertable<ScheduledRemindersTableData> {
  final String id;
  final String kindName;
  final DateTime fireAt;
  final String cityId;
  final String dateIso;
  final String vehicleId;
  final String title;
  final String body;
  final String voiceText;
  final String tailsText;
  final String timeWindowText;
  final String areaText;
  final String cityName;
  final String plateText;
  const ScheduledRemindersTableData(
      {required this.id,
      required this.kindName,
      required this.fireAt,
      required this.cityId,
      required this.dateIso,
      required this.vehicleId,
      required this.title,
      required this.body,
      required this.voiceText,
      required this.tailsText,
      required this.timeWindowText,
      required this.areaText,
      required this.cityName,
      required this.plateText});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind_name'] = Variable<String>(kindName);
    map['fire_at'] = Variable<DateTime>(fireAt);
    map['city_id'] = Variable<String>(cityId);
    map['date_iso'] = Variable<String>(dateIso);
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['voice_text'] = Variable<String>(voiceText);
    map['tails_text'] = Variable<String>(tailsText);
    map['time_window_text'] = Variable<String>(timeWindowText);
    map['area_text'] = Variable<String>(areaText);
    map['city_name'] = Variable<String>(cityName);
    map['plate_text'] = Variable<String>(plateText);
    return map;
  }

  ScheduledRemindersTableCompanion toCompanion(bool nullToAbsent) {
    return ScheduledRemindersTableCompanion(
      id: Value(id),
      kindName: Value(kindName),
      fireAt: Value(fireAt),
      cityId: Value(cityId),
      dateIso: Value(dateIso),
      vehicleId: Value(vehicleId),
      title: Value(title),
      body: Value(body),
      voiceText: Value(voiceText),
      tailsText: Value(tailsText),
      timeWindowText: Value(timeWindowText),
      areaText: Value(areaText),
      cityName: Value(cityName),
      plateText: Value(plateText),
    );
  }

  factory ScheduledRemindersTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduledRemindersTableData(
      id: serializer.fromJson<String>(json['id']),
      kindName: serializer.fromJson<String>(json['kindName']),
      fireAt: serializer.fromJson<DateTime>(json['fireAt']),
      cityId: serializer.fromJson<String>(json['cityId']),
      dateIso: serializer.fromJson<String>(json['dateIso']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      voiceText: serializer.fromJson<String>(json['voiceText']),
      tailsText: serializer.fromJson<String>(json['tailsText']),
      timeWindowText: serializer.fromJson<String>(json['timeWindowText']),
      areaText: serializer.fromJson<String>(json['areaText']),
      cityName: serializer.fromJson<String>(json['cityName']),
      plateText: serializer.fromJson<String>(json['plateText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kindName': serializer.toJson<String>(kindName),
      'fireAt': serializer.toJson<DateTime>(fireAt),
      'cityId': serializer.toJson<String>(cityId),
      'dateIso': serializer.toJson<String>(dateIso),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'voiceText': serializer.toJson<String>(voiceText),
      'tailsText': serializer.toJson<String>(tailsText),
      'timeWindowText': serializer.toJson<String>(timeWindowText),
      'areaText': serializer.toJson<String>(areaText),
      'cityName': serializer.toJson<String>(cityName),
      'plateText': serializer.toJson<String>(plateText),
    };
  }

  ScheduledRemindersTableData copyWith(
          {String? id,
          String? kindName,
          DateTime? fireAt,
          String? cityId,
          String? dateIso,
          String? vehicleId,
          String? title,
          String? body,
          String? voiceText,
          String? tailsText,
          String? timeWindowText,
          String? areaText,
          String? cityName,
          String? plateText}) =>
      ScheduledRemindersTableData(
        id: id ?? this.id,
        kindName: kindName ?? this.kindName,
        fireAt: fireAt ?? this.fireAt,
        cityId: cityId ?? this.cityId,
        dateIso: dateIso ?? this.dateIso,
        vehicleId: vehicleId ?? this.vehicleId,
        title: title ?? this.title,
        body: body ?? this.body,
        voiceText: voiceText ?? this.voiceText,
        tailsText: tailsText ?? this.tailsText,
        timeWindowText: timeWindowText ?? this.timeWindowText,
        areaText: areaText ?? this.areaText,
        cityName: cityName ?? this.cityName,
        plateText: plateText ?? this.plateText,
      );
  ScheduledRemindersTableData copyWithCompanion(
      ScheduledRemindersTableCompanion data) {
    return ScheduledRemindersTableData(
      id: data.id.present ? data.id.value : this.id,
      kindName: data.kindName.present ? data.kindName.value : this.kindName,
      fireAt: data.fireAt.present ? data.fireAt.value : this.fireAt,
      cityId: data.cityId.present ? data.cityId.value : this.cityId,
      dateIso: data.dateIso.present ? data.dateIso.value : this.dateIso,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      voiceText: data.voiceText.present ? data.voiceText.value : this.voiceText,
      tailsText: data.tailsText.present ? data.tailsText.value : this.tailsText,
      timeWindowText: data.timeWindowText.present
          ? data.timeWindowText.value
          : this.timeWindowText,
      areaText: data.areaText.present ? data.areaText.value : this.areaText,
      cityName: data.cityName.present ? data.cityName.value : this.cityName,
      plateText: data.plateText.present ? data.plateText.value : this.plateText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduledRemindersTableData(')
          ..write('id: $id, ')
          ..write('kindName: $kindName, ')
          ..write('fireAt: $fireAt, ')
          ..write('cityId: $cityId, ')
          ..write('dateIso: $dateIso, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('voiceText: $voiceText, ')
          ..write('tailsText: $tailsText, ')
          ..write('timeWindowText: $timeWindowText, ')
          ..write('areaText: $areaText, ')
          ..write('cityName: $cityName, ')
          ..write('plateText: $plateText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      kindName,
      fireAt,
      cityId,
      dateIso,
      vehicleId,
      title,
      body,
      voiceText,
      tailsText,
      timeWindowText,
      areaText,
      cityName,
      plateText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduledRemindersTableData &&
          other.id == this.id &&
          other.kindName == this.kindName &&
          other.fireAt == this.fireAt &&
          other.cityId == this.cityId &&
          other.dateIso == this.dateIso &&
          other.vehicleId == this.vehicleId &&
          other.title == this.title &&
          other.body == this.body &&
          other.voiceText == this.voiceText &&
          other.tailsText == this.tailsText &&
          other.timeWindowText == this.timeWindowText &&
          other.areaText == this.areaText &&
          other.cityName == this.cityName &&
          other.plateText == this.plateText);
}

class ScheduledRemindersTableCompanion
    extends UpdateCompanion<ScheduledRemindersTableData> {
  final Value<String> id;
  final Value<String> kindName;
  final Value<DateTime> fireAt;
  final Value<String> cityId;
  final Value<String> dateIso;
  final Value<String> vehicleId;
  final Value<String> title;
  final Value<String> body;
  final Value<String> voiceText;
  final Value<String> tailsText;
  final Value<String> timeWindowText;
  final Value<String> areaText;
  final Value<String> cityName;
  final Value<String> plateText;
  final Value<int> rowid;
  const ScheduledRemindersTableCompanion({
    this.id = const Value.absent(),
    this.kindName = const Value.absent(),
    this.fireAt = const Value.absent(),
    this.cityId = const Value.absent(),
    this.dateIso = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.voiceText = const Value.absent(),
    this.tailsText = const Value.absent(),
    this.timeWindowText = const Value.absent(),
    this.areaText = const Value.absent(),
    this.cityName = const Value.absent(),
    this.plateText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScheduledRemindersTableCompanion.insert({
    required String id,
    required String kindName,
    required DateTime fireAt,
    required String cityId,
    required String dateIso,
    required String vehicleId,
    required String title,
    required String body,
    this.voiceText = const Value.absent(),
    this.tailsText = const Value.absent(),
    this.timeWindowText = const Value.absent(),
    this.areaText = const Value.absent(),
    this.cityName = const Value.absent(),
    this.plateText = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        kindName = Value(kindName),
        fireAt = Value(fireAt),
        cityId = Value(cityId),
        dateIso = Value(dateIso),
        vehicleId = Value(vehicleId),
        title = Value(title),
        body = Value(body);
  static Insertable<ScheduledRemindersTableData> custom({
    Expression<String>? id,
    Expression<String>? kindName,
    Expression<DateTime>? fireAt,
    Expression<String>? cityId,
    Expression<String>? dateIso,
    Expression<String>? vehicleId,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? voiceText,
    Expression<String>? tailsText,
    Expression<String>? timeWindowText,
    Expression<String>? areaText,
    Expression<String>? cityName,
    Expression<String>? plateText,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kindName != null) 'kind_name': kindName,
      if (fireAt != null) 'fire_at': fireAt,
      if (cityId != null) 'city_id': cityId,
      if (dateIso != null) 'date_iso': dateIso,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (voiceText != null) 'voice_text': voiceText,
      if (tailsText != null) 'tails_text': tailsText,
      if (timeWindowText != null) 'time_window_text': timeWindowText,
      if (areaText != null) 'area_text': areaText,
      if (cityName != null) 'city_name': cityName,
      if (plateText != null) 'plate_text': plateText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScheduledRemindersTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? kindName,
      Value<DateTime>? fireAt,
      Value<String>? cityId,
      Value<String>? dateIso,
      Value<String>? vehicleId,
      Value<String>? title,
      Value<String>? body,
      Value<String>? voiceText,
      Value<String>? tailsText,
      Value<String>? timeWindowText,
      Value<String>? areaText,
      Value<String>? cityName,
      Value<String>? plateText,
      Value<int>? rowid}) {
    return ScheduledRemindersTableCompanion(
      id: id ?? this.id,
      kindName: kindName ?? this.kindName,
      fireAt: fireAt ?? this.fireAt,
      cityId: cityId ?? this.cityId,
      dateIso: dateIso ?? this.dateIso,
      vehicleId: vehicleId ?? this.vehicleId,
      title: title ?? this.title,
      body: body ?? this.body,
      voiceText: voiceText ?? this.voiceText,
      tailsText: tailsText ?? this.tailsText,
      timeWindowText: timeWindowText ?? this.timeWindowText,
      areaText: areaText ?? this.areaText,
      cityName: cityName ?? this.cityName,
      plateText: plateText ?? this.plateText,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kindName.present) {
      map['kind_name'] = Variable<String>(kindName.value);
    }
    if (fireAt.present) {
      map['fire_at'] = Variable<DateTime>(fireAt.value);
    }
    if (cityId.present) {
      map['city_id'] = Variable<String>(cityId.value);
    }
    if (dateIso.present) {
      map['date_iso'] = Variable<String>(dateIso.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (voiceText.present) {
      map['voice_text'] = Variable<String>(voiceText.value);
    }
    if (tailsText.present) {
      map['tails_text'] = Variable<String>(tailsText.value);
    }
    if (timeWindowText.present) {
      map['time_window_text'] = Variable<String>(timeWindowText.value);
    }
    if (areaText.present) {
      map['area_text'] = Variable<String>(areaText.value);
    }
    if (cityName.present) {
      map['city_name'] = Variable<String>(cityName.value);
    }
    if (plateText.present) {
      map['plate_text'] = Variable<String>(plateText.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduledRemindersTableCompanion(')
          ..write('id: $id, ')
          ..write('kindName: $kindName, ')
          ..write('fireAt: $fireAt, ')
          ..write('cityId: $cityId, ')
          ..write('dateIso: $dateIso, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('voiceText: $voiceText, ')
          ..write('tailsText: $tailsText, ')
          ..write('timeWindowText: $timeWindowText, ')
          ..write('areaText: $areaText, ')
          ..write('cityName: $cityName, ')
          ..write('plateText: $plateText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingRowsTable extends AppSettingRows
    with TableInfo<$AppSettingRowsTable, AppSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_setting_rows';
  @override
  VerificationContext validateIntegrity(Insertable<AppSettingRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingRow(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $AppSettingRowsTable createAlias(String alias) {
    return $AppSettingRowsTable(attachedDatabase, alias);
  }
}

class AppSettingRow extends DataClass implements Insertable<AppSettingRow> {
  final String key;
  final String value;
  const AppSettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingRowsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingRowsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory AppSettingRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSettingRow copyWith({String? key, String? value}) => AppSettingRow(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  AppSettingRow copyWithCompanion(AppSettingRowsCompanion data) {
    return AppSettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingRowsCompanion extends UpdateCompanion<AppSettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingRowsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingRowsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<AppSettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingRowsCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return AppSettingRowsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingRowsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VehicleRowsTable vehicleRows = $VehicleRowsTable(this);
  late final $MyCityRowsTable myCityRows = $MyCityRowsTable(this);
  late final $CityCacheRowsTable cityCacheRows = $CityCacheRowsTable(this);
  late final $RestrictionDayRowsTable restrictionDayRows =
      $RestrictionDayRowsTable(this);
  late final $ReminderConfigRowsTable reminderConfigRows =
      $ReminderConfigRowsTable(this);
  late final $ScheduledRemindersTableTable scheduledRemindersTable =
      $ScheduledRemindersTableTable(this);
  late final $AppSettingRowsTable appSettingRows = $AppSettingRowsTable(this);
  late final VehicleDao vehicleDao = VehicleDao(this as AppDatabase);
  late final CityDao cityDao = CityDao(this as AppDatabase);
  late final RestrictionDao restrictionDao =
      RestrictionDao(this as AppDatabase);
  late final SettingDao settingDao = SettingDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        vehicleRows,
        myCityRows,
        cityCacheRows,
        restrictionDayRows,
        reminderConfigRows,
        scheduledRemindersTable,
        appSettingRows
      ];
}

typedef $$VehicleRowsTableCreateCompanionBuilder = VehicleRowsCompanion
    Function({
  required String id,
  required String plate,
  Value<String> nickname,
  required String boundCityId,
  Value<bool> isActive,
  Value<bool> isDefault,
  Value<DateTime?> createdAt,
  Value<int> rowid,
});
typedef $$VehicleRowsTableUpdateCompanionBuilder = VehicleRowsCompanion
    Function({
  Value<String> id,
  Value<String> plate,
  Value<String> nickname,
  Value<String> boundCityId,
  Value<bool> isActive,
  Value<bool> isDefault,
  Value<DateTime?> createdAt,
  Value<int> rowid,
});

class $$VehicleRowsTableFilterComposer
    extends Composer<_$AppDatabase, $VehicleRowsTable> {
  $$VehicleRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get plate => $composableBuilder(
      column: $table.plate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nickname => $composableBuilder(
      column: $table.nickname, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get boundCityId => $composableBuilder(
      column: $table.boundCityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$VehicleRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $VehicleRowsTable> {
  $$VehicleRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get plate => $composableBuilder(
      column: $table.plate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nickname => $composableBuilder(
      column: $table.nickname, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get boundCityId => $composableBuilder(
      column: $table.boundCityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$VehicleRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehicleRowsTable> {
  $$VehicleRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get plate =>
      $composableBuilder(column: $table.plate, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get boundCityId => $composableBuilder(
      column: $table.boundCityId, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$VehicleRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VehicleRowsTable,
    VehicleRow,
    $$VehicleRowsTableFilterComposer,
    $$VehicleRowsTableOrderingComposer,
    $$VehicleRowsTableAnnotationComposer,
    $$VehicleRowsTableCreateCompanionBuilder,
    $$VehicleRowsTableUpdateCompanionBuilder,
    (VehicleRow, BaseReferences<_$AppDatabase, $VehicleRowsTable, VehicleRow>),
    VehicleRow,
    PrefetchHooks Function()> {
  $$VehicleRowsTableTableManager(_$AppDatabase db, $VehicleRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehicleRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehicleRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehicleRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> plate = const Value.absent(),
            Value<String> nickname = const Value.absent(),
            Value<String> boundCityId = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VehicleRowsCompanion(
            id: id,
            plate: plate,
            nickname: nickname,
            boundCityId: boundCityId,
            isActive: isActive,
            isDefault: isDefault,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String plate,
            Value<String> nickname = const Value.absent(),
            required String boundCityId,
            Value<bool> isActive = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VehicleRowsCompanion.insert(
            id: id,
            plate: plate,
            nickname: nickname,
            boundCityId: boundCityId,
            isActive: isActive,
            isDefault: isDefault,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$VehicleRowsTable, VehicleRow>(table),
                    BaseReferences<_$AppDatabase, $VehicleRowsTable,
                        VehicleRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$VehicleRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VehicleRowsTable,
    VehicleRow,
    $$VehicleRowsTableFilterComposer,
    $$VehicleRowsTableOrderingComposer,
    $$VehicleRowsTableAnnotationComposer,
    $$VehicleRowsTableCreateCompanionBuilder,
    $$VehicleRowsTableUpdateCompanionBuilder,
    (VehicleRow, BaseReferences<_$AppDatabase, $VehicleRowsTable, VehicleRow>),
    VehicleRow,
    PrefetchHooks Function()>;
typedef $$MyCityRowsTableCreateCompanionBuilder = MyCityRowsCompanion Function({
  required String id,
  required String name,
  Value<String> province,
  Value<String> provinceAbbr,
  Value<bool> hasRestriction,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$MyCityRowsTableUpdateCompanionBuilder = MyCityRowsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> province,
  Value<String> provinceAbbr,
  Value<bool> hasRestriction,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$MyCityRowsTableFilterComposer
    extends Composer<_$AppDatabase, $MyCityRowsTable> {
  $$MyCityRowsTableFilterComposer({
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

  ColumnFilters<String> get province => $composableBuilder(
      column: $table.province, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get provinceAbbr => $composableBuilder(
      column: $table.provinceAbbr, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasRestriction => $composableBuilder(
      column: $table.hasRestriction,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$MyCityRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $MyCityRowsTable> {
  $$MyCityRowsTableOrderingComposer({
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

  ColumnOrderings<String> get province => $composableBuilder(
      column: $table.province, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get provinceAbbr => $composableBuilder(
      column: $table.provinceAbbr,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasRestriction => $composableBuilder(
      column: $table.hasRestriction,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$MyCityRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MyCityRowsTable> {
  $$MyCityRowsTableAnnotationComposer({
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

  GeneratedColumn<String> get province =>
      $composableBuilder(column: $table.province, builder: (column) => column);

  GeneratedColumn<String> get provinceAbbr => $composableBuilder(
      column: $table.provinceAbbr, builder: (column) => column);

  GeneratedColumn<bool> get hasRestriction => $composableBuilder(
      column: $table.hasRestriction, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$MyCityRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MyCityRowsTable,
    MyCityRow,
    $$MyCityRowsTableFilterComposer,
    $$MyCityRowsTableOrderingComposer,
    $$MyCityRowsTableAnnotationComposer,
    $$MyCityRowsTableCreateCompanionBuilder,
    $$MyCityRowsTableUpdateCompanionBuilder,
    (MyCityRow, BaseReferences<_$AppDatabase, $MyCityRowsTable, MyCityRow>),
    MyCityRow,
    PrefetchHooks Function()> {
  $$MyCityRowsTableTableManager(_$AppDatabase db, $MyCityRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MyCityRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MyCityRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MyCityRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> province = const Value.absent(),
            Value<String> provinceAbbr = const Value.absent(),
            Value<bool> hasRestriction = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MyCityRowsCompanion(
            id: id,
            name: name,
            province: province,
            provinceAbbr: provinceAbbr,
            hasRestriction: hasRestriction,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String> province = const Value.absent(),
            Value<String> provinceAbbr = const Value.absent(),
            Value<bool> hasRestriction = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MyCityRowsCompanion.insert(
            id: id,
            name: name,
            province: province,
            provinceAbbr: provinceAbbr,
            hasRestriction: hasRestriction,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$MyCityRowsTable, MyCityRow>(table),
                    BaseReferences<_$AppDatabase, $MyCityRowsTable, MyCityRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MyCityRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MyCityRowsTable,
    MyCityRow,
    $$MyCityRowsTableFilterComposer,
    $$MyCityRowsTableOrderingComposer,
    $$MyCityRowsTableAnnotationComposer,
    $$MyCityRowsTableCreateCompanionBuilder,
    $$MyCityRowsTableUpdateCompanionBuilder,
    (MyCityRow, BaseReferences<_$AppDatabase, $MyCityRowsTable, MyCityRow>),
    MyCityRow,
    PrefetchHooks Function()>;
typedef $$CityCacheRowsTableCreateCompanionBuilder = CityCacheRowsCompanion
    Function({
  required String id,
  required String name,
  Value<String> province,
  Value<String> provinceAbbr,
  Value<int> rowid,
});
typedef $$CityCacheRowsTableUpdateCompanionBuilder = CityCacheRowsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> province,
  Value<String> provinceAbbr,
  Value<int> rowid,
});

class $$CityCacheRowsTableFilterComposer
    extends Composer<_$AppDatabase, $CityCacheRowsTable> {
  $$CityCacheRowsTableFilterComposer({
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

  ColumnFilters<String> get province => $composableBuilder(
      column: $table.province, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get provinceAbbr => $composableBuilder(
      column: $table.provinceAbbr, builder: (column) => ColumnFilters(column));
}

class $$CityCacheRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $CityCacheRowsTable> {
  $$CityCacheRowsTableOrderingComposer({
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

  ColumnOrderings<String> get province => $composableBuilder(
      column: $table.province, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get provinceAbbr => $composableBuilder(
      column: $table.provinceAbbr,
      builder: (column) => ColumnOrderings(column));
}

class $$CityCacheRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CityCacheRowsTable> {
  $$CityCacheRowsTableAnnotationComposer({
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

  GeneratedColumn<String> get province =>
      $composableBuilder(column: $table.province, builder: (column) => column);

  GeneratedColumn<String> get provinceAbbr => $composableBuilder(
      column: $table.provinceAbbr, builder: (column) => column);
}

class $$CityCacheRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CityCacheRowsTable,
    CityCacheRow,
    $$CityCacheRowsTableFilterComposer,
    $$CityCacheRowsTableOrderingComposer,
    $$CityCacheRowsTableAnnotationComposer,
    $$CityCacheRowsTableCreateCompanionBuilder,
    $$CityCacheRowsTableUpdateCompanionBuilder,
    (
      CityCacheRow,
      BaseReferences<_$AppDatabase, $CityCacheRowsTable, CityCacheRow>
    ),
    CityCacheRow,
    PrefetchHooks Function()> {
  $$CityCacheRowsTableTableManager(_$AppDatabase db, $CityCacheRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CityCacheRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CityCacheRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CityCacheRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> province = const Value.absent(),
            Value<String> provinceAbbr = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CityCacheRowsCompanion(
            id: id,
            name: name,
            province: province,
            provinceAbbr: provinceAbbr,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String> province = const Value.absent(),
            Value<String> provinceAbbr = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CityCacheRowsCompanion.insert(
            id: id,
            name: name,
            province: province,
            provinceAbbr: provinceAbbr,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CityCacheRowsTable, CityCacheRow>(table),
                    BaseReferences<_$AppDatabase, $CityCacheRowsTable,
                        CityCacheRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CityCacheRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CityCacheRowsTable,
    CityCacheRow,
    $$CityCacheRowsTableFilterComposer,
    $$CityCacheRowsTableOrderingComposer,
    $$CityCacheRowsTableAnnotationComposer,
    $$CityCacheRowsTableCreateCompanionBuilder,
    $$CityCacheRowsTableUpdateCompanionBuilder,
    (
      CityCacheRow,
      BaseReferences<_$AppDatabase, $CityCacheRowsTable, CityCacheRow>
    ),
    CityCacheRow,
    PrefetchHooks Function()>;
typedef $$RestrictionDayRowsTableCreateCompanionBuilder
    = RestrictionDayRowsCompanion Function({
  required String cityId,
  Value<String> cityName,
  required String dateIso,
  Value<bool> isRestrictedDay,
  Value<String> restrictedTails,
  Value<String> timeWindowsJson,
  Value<String> areaText,
  Value<String> ruleText,
  Value<String> typeName,
  Value<bool> appliesToNonLocalOnly,
  Value<bool> exemptsNewEnergy,
  Value<String> tailDigitRuleName,
  Value<String> cityProvinceAbbr,
  Value<String> source,
  required DateTime fetchedAt,
  Value<DateTime?> expiresAt,
  Value<int> rowid,
});
typedef $$RestrictionDayRowsTableUpdateCompanionBuilder
    = RestrictionDayRowsCompanion Function({
  Value<String> cityId,
  Value<String> cityName,
  Value<String> dateIso,
  Value<bool> isRestrictedDay,
  Value<String> restrictedTails,
  Value<String> timeWindowsJson,
  Value<String> areaText,
  Value<String> ruleText,
  Value<String> typeName,
  Value<bool> appliesToNonLocalOnly,
  Value<bool> exemptsNewEnergy,
  Value<String> tailDigitRuleName,
  Value<String> cityProvinceAbbr,
  Value<String> source,
  Value<DateTime> fetchedAt,
  Value<DateTime?> expiresAt,
  Value<int> rowid,
});

class $$RestrictionDayRowsTableFilterComposer
    extends Composer<_$AppDatabase, $RestrictionDayRowsTable> {
  $$RestrictionDayRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cityId => $composableBuilder(
      column: $table.cityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cityName => $composableBuilder(
      column: $table.cityName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateIso => $composableBuilder(
      column: $table.dateIso, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRestrictedDay => $composableBuilder(
      column: $table.isRestrictedDay,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get restrictedTails => $composableBuilder(
      column: $table.restrictedTails,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timeWindowsJson => $composableBuilder(
      column: $table.timeWindowsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get areaText => $composableBuilder(
      column: $table.areaText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ruleText => $composableBuilder(
      column: $table.ruleText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get typeName => $composableBuilder(
      column: $table.typeName, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get appliesToNonLocalOnly => $composableBuilder(
      column: $table.appliesToNonLocalOnly,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get exemptsNewEnergy => $composableBuilder(
      column: $table.exemptsNewEnergy,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tailDigitRuleName => $composableBuilder(
      column: $table.tailDigitRuleName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cityProvinceAbbr => $composableBuilder(
      column: $table.cityProvinceAbbr,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
      column: $table.fetchedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnFilters(column));
}

class $$RestrictionDayRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $RestrictionDayRowsTable> {
  $$RestrictionDayRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cityId => $composableBuilder(
      column: $table.cityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cityName => $composableBuilder(
      column: $table.cityName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateIso => $composableBuilder(
      column: $table.dateIso, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRestrictedDay => $composableBuilder(
      column: $table.isRestrictedDay,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get restrictedTails => $composableBuilder(
      column: $table.restrictedTails,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timeWindowsJson => $composableBuilder(
      column: $table.timeWindowsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get areaText => $composableBuilder(
      column: $table.areaText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ruleText => $composableBuilder(
      column: $table.ruleText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get typeName => $composableBuilder(
      column: $table.typeName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get appliesToNonLocalOnly => $composableBuilder(
      column: $table.appliesToNonLocalOnly,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get exemptsNewEnergy => $composableBuilder(
      column: $table.exemptsNewEnergy,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tailDigitRuleName => $composableBuilder(
      column: $table.tailDigitRuleName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cityProvinceAbbr => $composableBuilder(
      column: $table.cityProvinceAbbr,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
      column: $table.fetchedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnOrderings(column));
}

class $$RestrictionDayRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RestrictionDayRowsTable> {
  $$RestrictionDayRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cityId =>
      $composableBuilder(column: $table.cityId, builder: (column) => column);

  GeneratedColumn<String> get cityName =>
      $composableBuilder(column: $table.cityName, builder: (column) => column);

  GeneratedColumn<String> get dateIso =>
      $composableBuilder(column: $table.dateIso, builder: (column) => column);

  GeneratedColumn<bool> get isRestrictedDay => $composableBuilder(
      column: $table.isRestrictedDay, builder: (column) => column);

  GeneratedColumn<String> get restrictedTails => $composableBuilder(
      column: $table.restrictedTails, builder: (column) => column);

  GeneratedColumn<String> get timeWindowsJson => $composableBuilder(
      column: $table.timeWindowsJson, builder: (column) => column);

  GeneratedColumn<String> get areaText =>
      $composableBuilder(column: $table.areaText, builder: (column) => column);

  GeneratedColumn<String> get ruleText =>
      $composableBuilder(column: $table.ruleText, builder: (column) => column);

  GeneratedColumn<String> get typeName =>
      $composableBuilder(column: $table.typeName, builder: (column) => column);

  GeneratedColumn<bool> get appliesToNonLocalOnly => $composableBuilder(
      column: $table.appliesToNonLocalOnly, builder: (column) => column);

  GeneratedColumn<bool> get exemptsNewEnergy => $composableBuilder(
      column: $table.exemptsNewEnergy, builder: (column) => column);

  GeneratedColumn<String> get tailDigitRuleName => $composableBuilder(
      column: $table.tailDigitRuleName, builder: (column) => column);

  GeneratedColumn<String> get cityProvinceAbbr => $composableBuilder(
      column: $table.cityProvinceAbbr, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$RestrictionDayRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RestrictionDayRowsTable,
    RestrictionDayRow,
    $$RestrictionDayRowsTableFilterComposer,
    $$RestrictionDayRowsTableOrderingComposer,
    $$RestrictionDayRowsTableAnnotationComposer,
    $$RestrictionDayRowsTableCreateCompanionBuilder,
    $$RestrictionDayRowsTableUpdateCompanionBuilder,
    (
      RestrictionDayRow,
      BaseReferences<_$AppDatabase, $RestrictionDayRowsTable, RestrictionDayRow>
    ),
    RestrictionDayRow,
    PrefetchHooks Function()> {
  $$RestrictionDayRowsTableTableManager(
      _$AppDatabase db, $RestrictionDayRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RestrictionDayRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RestrictionDayRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RestrictionDayRowsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> cityId = const Value.absent(),
            Value<String> cityName = const Value.absent(),
            Value<String> dateIso = const Value.absent(),
            Value<bool> isRestrictedDay = const Value.absent(),
            Value<String> restrictedTails = const Value.absent(),
            Value<String> timeWindowsJson = const Value.absent(),
            Value<String> areaText = const Value.absent(),
            Value<String> ruleText = const Value.absent(),
            Value<String> typeName = const Value.absent(),
            Value<bool> appliesToNonLocalOnly = const Value.absent(),
            Value<bool> exemptsNewEnergy = const Value.absent(),
            Value<String> tailDigitRuleName = const Value.absent(),
            Value<String> cityProvinceAbbr = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<DateTime> fetchedAt = const Value.absent(),
            Value<DateTime?> expiresAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RestrictionDayRowsCompanion(
            cityId: cityId,
            cityName: cityName,
            dateIso: dateIso,
            isRestrictedDay: isRestrictedDay,
            restrictedTails: restrictedTails,
            timeWindowsJson: timeWindowsJson,
            areaText: areaText,
            ruleText: ruleText,
            typeName: typeName,
            appliesToNonLocalOnly: appliesToNonLocalOnly,
            exemptsNewEnergy: exemptsNewEnergy,
            tailDigitRuleName: tailDigitRuleName,
            cityProvinceAbbr: cityProvinceAbbr,
            source: source,
            fetchedAt: fetchedAt,
            expiresAt: expiresAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String cityId,
            Value<String> cityName = const Value.absent(),
            required String dateIso,
            Value<bool> isRestrictedDay = const Value.absent(),
            Value<String> restrictedTails = const Value.absent(),
            Value<String> timeWindowsJson = const Value.absent(),
            Value<String> areaText = const Value.absent(),
            Value<String> ruleText = const Value.absent(),
            Value<String> typeName = const Value.absent(),
            Value<bool> appliesToNonLocalOnly = const Value.absent(),
            Value<bool> exemptsNewEnergy = const Value.absent(),
            Value<String> tailDigitRuleName = const Value.absent(),
            Value<String> cityProvinceAbbr = const Value.absent(),
            Value<String> source = const Value.absent(),
            required DateTime fetchedAt,
            Value<DateTime?> expiresAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RestrictionDayRowsCompanion.insert(
            cityId: cityId,
            cityName: cityName,
            dateIso: dateIso,
            isRestrictedDay: isRestrictedDay,
            restrictedTails: restrictedTails,
            timeWindowsJson: timeWindowsJson,
            areaText: areaText,
            ruleText: ruleText,
            typeName: typeName,
            appliesToNonLocalOnly: appliesToNonLocalOnly,
            exemptsNewEnergy: exemptsNewEnergy,
            tailDigitRuleName: tailDigitRuleName,
            cityProvinceAbbr: cityProvinceAbbr,
            source: source,
            fetchedAt: fetchedAt,
            expiresAt: expiresAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$RestrictionDayRowsTable, RestrictionDayRow>(
                        table),
                    BaseReferences<_$AppDatabase, $RestrictionDayRowsTable,
                        RestrictionDayRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RestrictionDayRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RestrictionDayRowsTable,
    RestrictionDayRow,
    $$RestrictionDayRowsTableFilterComposer,
    $$RestrictionDayRowsTableOrderingComposer,
    $$RestrictionDayRowsTableAnnotationComposer,
    $$RestrictionDayRowsTableCreateCompanionBuilder,
    $$RestrictionDayRowsTableUpdateCompanionBuilder,
    (
      RestrictionDayRow,
      BaseReferences<_$AppDatabase, $RestrictionDayRowsTable, RestrictionDayRow>
    ),
    RestrictionDayRow,
    PrefetchHooks Function()>;
typedef $$ReminderConfigRowsTableCreateCompanionBuilder
    = ReminderConfigRowsCompanion Function({
  required String cityId,
  Value<bool> previewEnabled,
  Value<int> previewMinutesOfDay,
  Value<bool> strongEnabled,
  Value<int> strongLeadMinutes,
  Value<int> strongFallbackMinutesOfDay,
  Value<bool> voiceEnabled,
  Value<bool> fullScreenEnabled,
  Value<bool> bypassDndEnabled,
  Value<int> rowid,
});
typedef $$ReminderConfigRowsTableUpdateCompanionBuilder
    = ReminderConfigRowsCompanion Function({
  Value<String> cityId,
  Value<bool> previewEnabled,
  Value<int> previewMinutesOfDay,
  Value<bool> strongEnabled,
  Value<int> strongLeadMinutes,
  Value<int> strongFallbackMinutesOfDay,
  Value<bool> voiceEnabled,
  Value<bool> fullScreenEnabled,
  Value<bool> bypassDndEnabled,
  Value<int> rowid,
});

class $$ReminderConfigRowsTableFilterComposer
    extends Composer<_$AppDatabase, $ReminderConfigRowsTable> {
  $$ReminderConfigRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cityId => $composableBuilder(
      column: $table.cityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get previewEnabled => $composableBuilder(
      column: $table.previewEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get previewMinutesOfDay => $composableBuilder(
      column: $table.previewMinutesOfDay,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get strongEnabled => $composableBuilder(
      column: $table.strongEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get strongLeadMinutes => $composableBuilder(
      column: $table.strongLeadMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get strongFallbackMinutesOfDay => $composableBuilder(
      column: $table.strongFallbackMinutesOfDay,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get voiceEnabled => $composableBuilder(
      column: $table.voiceEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get fullScreenEnabled => $composableBuilder(
      column: $table.fullScreenEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get bypassDndEnabled => $composableBuilder(
      column: $table.bypassDndEnabled,
      builder: (column) => ColumnFilters(column));
}

class $$ReminderConfigRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReminderConfigRowsTable> {
  $$ReminderConfigRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cityId => $composableBuilder(
      column: $table.cityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get previewEnabled => $composableBuilder(
      column: $table.previewEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get previewMinutesOfDay => $composableBuilder(
      column: $table.previewMinutesOfDay,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get strongEnabled => $composableBuilder(
      column: $table.strongEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get strongLeadMinutes => $composableBuilder(
      column: $table.strongLeadMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get strongFallbackMinutesOfDay => $composableBuilder(
      column: $table.strongFallbackMinutesOfDay,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get voiceEnabled => $composableBuilder(
      column: $table.voiceEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get fullScreenEnabled => $composableBuilder(
      column: $table.fullScreenEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get bypassDndEnabled => $composableBuilder(
      column: $table.bypassDndEnabled,
      builder: (column) => ColumnOrderings(column));
}

class $$ReminderConfigRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReminderConfigRowsTable> {
  $$ReminderConfigRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cityId =>
      $composableBuilder(column: $table.cityId, builder: (column) => column);

  GeneratedColumn<bool> get previewEnabled => $composableBuilder(
      column: $table.previewEnabled, builder: (column) => column);

  GeneratedColumn<int> get previewMinutesOfDay => $composableBuilder(
      column: $table.previewMinutesOfDay, builder: (column) => column);

  GeneratedColumn<bool> get strongEnabled => $composableBuilder(
      column: $table.strongEnabled, builder: (column) => column);

  GeneratedColumn<int> get strongLeadMinutes => $composableBuilder(
      column: $table.strongLeadMinutes, builder: (column) => column);

  GeneratedColumn<int> get strongFallbackMinutesOfDay => $composableBuilder(
      column: $table.strongFallbackMinutesOfDay, builder: (column) => column);

  GeneratedColumn<bool> get voiceEnabled => $composableBuilder(
      column: $table.voiceEnabled, builder: (column) => column);

  GeneratedColumn<bool> get fullScreenEnabled => $composableBuilder(
      column: $table.fullScreenEnabled, builder: (column) => column);

  GeneratedColumn<bool> get bypassDndEnabled => $composableBuilder(
      column: $table.bypassDndEnabled, builder: (column) => column);
}

class $$ReminderConfigRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReminderConfigRowsTable,
    ReminderConfigRow,
    $$ReminderConfigRowsTableFilterComposer,
    $$ReminderConfigRowsTableOrderingComposer,
    $$ReminderConfigRowsTableAnnotationComposer,
    $$ReminderConfigRowsTableCreateCompanionBuilder,
    $$ReminderConfigRowsTableUpdateCompanionBuilder,
    (
      ReminderConfigRow,
      BaseReferences<_$AppDatabase, $ReminderConfigRowsTable, ReminderConfigRow>
    ),
    ReminderConfigRow,
    PrefetchHooks Function()> {
  $$ReminderConfigRowsTableTableManager(
      _$AppDatabase db, $ReminderConfigRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderConfigRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReminderConfigRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReminderConfigRowsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> cityId = const Value.absent(),
            Value<bool> previewEnabled = const Value.absent(),
            Value<int> previewMinutesOfDay = const Value.absent(),
            Value<bool> strongEnabled = const Value.absent(),
            Value<int> strongLeadMinutes = const Value.absent(),
            Value<int> strongFallbackMinutesOfDay = const Value.absent(),
            Value<bool> voiceEnabled = const Value.absent(),
            Value<bool> fullScreenEnabled = const Value.absent(),
            Value<bool> bypassDndEnabled = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReminderConfigRowsCompanion(
            cityId: cityId,
            previewEnabled: previewEnabled,
            previewMinutesOfDay: previewMinutesOfDay,
            strongEnabled: strongEnabled,
            strongLeadMinutes: strongLeadMinutes,
            strongFallbackMinutesOfDay: strongFallbackMinutesOfDay,
            voiceEnabled: voiceEnabled,
            fullScreenEnabled: fullScreenEnabled,
            bypassDndEnabled: bypassDndEnabled,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String cityId,
            Value<bool> previewEnabled = const Value.absent(),
            Value<int> previewMinutesOfDay = const Value.absent(),
            Value<bool> strongEnabled = const Value.absent(),
            Value<int> strongLeadMinutes = const Value.absent(),
            Value<int> strongFallbackMinutesOfDay = const Value.absent(),
            Value<bool> voiceEnabled = const Value.absent(),
            Value<bool> fullScreenEnabled = const Value.absent(),
            Value<bool> bypassDndEnabled = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReminderConfigRowsCompanion.insert(
            cityId: cityId,
            previewEnabled: previewEnabled,
            previewMinutesOfDay: previewMinutesOfDay,
            strongEnabled: strongEnabled,
            strongLeadMinutes: strongLeadMinutes,
            strongFallbackMinutesOfDay: strongFallbackMinutesOfDay,
            voiceEnabled: voiceEnabled,
            fullScreenEnabled: fullScreenEnabled,
            bypassDndEnabled: bypassDndEnabled,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ReminderConfigRowsTable, ReminderConfigRow>(
                        table),
                    BaseReferences<_$AppDatabase, $ReminderConfigRowsTable,
                        ReminderConfigRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReminderConfigRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReminderConfigRowsTable,
    ReminderConfigRow,
    $$ReminderConfigRowsTableFilterComposer,
    $$ReminderConfigRowsTableOrderingComposer,
    $$ReminderConfigRowsTableAnnotationComposer,
    $$ReminderConfigRowsTableCreateCompanionBuilder,
    $$ReminderConfigRowsTableUpdateCompanionBuilder,
    (
      ReminderConfigRow,
      BaseReferences<_$AppDatabase, $ReminderConfigRowsTable, ReminderConfigRow>
    ),
    ReminderConfigRow,
    PrefetchHooks Function()>;
typedef $$ScheduledRemindersTableTableCreateCompanionBuilder
    = ScheduledRemindersTableCompanion Function({
  required String id,
  required String kindName,
  required DateTime fireAt,
  required String cityId,
  required String dateIso,
  required String vehicleId,
  required String title,
  required String body,
  Value<String> voiceText,
  Value<String> tailsText,
  Value<String> timeWindowText,
  Value<String> areaText,
  Value<String> cityName,
  Value<String> plateText,
  Value<int> rowid,
});
typedef $$ScheduledRemindersTableTableUpdateCompanionBuilder
    = ScheduledRemindersTableCompanion Function({
  Value<String> id,
  Value<String> kindName,
  Value<DateTime> fireAt,
  Value<String> cityId,
  Value<String> dateIso,
  Value<String> vehicleId,
  Value<String> title,
  Value<String> body,
  Value<String> voiceText,
  Value<String> tailsText,
  Value<String> timeWindowText,
  Value<String> areaText,
  Value<String> cityName,
  Value<String> plateText,
  Value<int> rowid,
});

class $$ScheduledRemindersTableTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduledRemindersTableTable> {
  $$ScheduledRemindersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kindName => $composableBuilder(
      column: $table.kindName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fireAt => $composableBuilder(
      column: $table.fireAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cityId => $composableBuilder(
      column: $table.cityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateIso => $composableBuilder(
      column: $table.dateIso, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vehicleId => $composableBuilder(
      column: $table.vehicleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get voiceText => $composableBuilder(
      column: $table.voiceText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tailsText => $composableBuilder(
      column: $table.tailsText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timeWindowText => $composableBuilder(
      column: $table.timeWindowText,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get areaText => $composableBuilder(
      column: $table.areaText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cityName => $composableBuilder(
      column: $table.cityName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get plateText => $composableBuilder(
      column: $table.plateText, builder: (column) => ColumnFilters(column));
}

class $$ScheduledRemindersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduledRemindersTableTable> {
  $$ScheduledRemindersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kindName => $composableBuilder(
      column: $table.kindName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fireAt => $composableBuilder(
      column: $table.fireAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cityId => $composableBuilder(
      column: $table.cityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateIso => $composableBuilder(
      column: $table.dateIso, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vehicleId => $composableBuilder(
      column: $table.vehicleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get voiceText => $composableBuilder(
      column: $table.voiceText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tailsText => $composableBuilder(
      column: $table.tailsText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timeWindowText => $composableBuilder(
      column: $table.timeWindowText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get areaText => $composableBuilder(
      column: $table.areaText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cityName => $composableBuilder(
      column: $table.cityName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get plateText => $composableBuilder(
      column: $table.plateText, builder: (column) => ColumnOrderings(column));
}

class $$ScheduledRemindersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduledRemindersTableTable> {
  $$ScheduledRemindersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kindName =>
      $composableBuilder(column: $table.kindName, builder: (column) => column);

  GeneratedColumn<DateTime> get fireAt =>
      $composableBuilder(column: $table.fireAt, builder: (column) => column);

  GeneratedColumn<String> get cityId =>
      $composableBuilder(column: $table.cityId, builder: (column) => column);

  GeneratedColumn<String> get dateIso =>
      $composableBuilder(column: $table.dateIso, builder: (column) => column);

  GeneratedColumn<String> get vehicleId =>
      $composableBuilder(column: $table.vehicleId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get voiceText =>
      $composableBuilder(column: $table.voiceText, builder: (column) => column);

  GeneratedColumn<String> get tailsText =>
      $composableBuilder(column: $table.tailsText, builder: (column) => column);

  GeneratedColumn<String> get timeWindowText => $composableBuilder(
      column: $table.timeWindowText, builder: (column) => column);

  GeneratedColumn<String> get areaText =>
      $composableBuilder(column: $table.areaText, builder: (column) => column);

  GeneratedColumn<String> get cityName =>
      $composableBuilder(column: $table.cityName, builder: (column) => column);

  GeneratedColumn<String> get plateText =>
      $composableBuilder(column: $table.plateText, builder: (column) => column);
}

class $$ScheduledRemindersTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ScheduledRemindersTableTable,
    ScheduledRemindersTableData,
    $$ScheduledRemindersTableTableFilterComposer,
    $$ScheduledRemindersTableTableOrderingComposer,
    $$ScheduledRemindersTableTableAnnotationComposer,
    $$ScheduledRemindersTableTableCreateCompanionBuilder,
    $$ScheduledRemindersTableTableUpdateCompanionBuilder,
    (
      ScheduledRemindersTableData,
      BaseReferences<_$AppDatabase, $ScheduledRemindersTableTable,
          ScheduledRemindersTableData>
    ),
    ScheduledRemindersTableData,
    PrefetchHooks Function()> {
  $$ScheduledRemindersTableTableTableManager(
      _$AppDatabase db, $ScheduledRemindersTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduledRemindersTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduledRemindersTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduledRemindersTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> kindName = const Value.absent(),
            Value<DateTime> fireAt = const Value.absent(),
            Value<String> cityId = const Value.absent(),
            Value<String> dateIso = const Value.absent(),
            Value<String> vehicleId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<String> voiceText = const Value.absent(),
            Value<String> tailsText = const Value.absent(),
            Value<String> timeWindowText = const Value.absent(),
            Value<String> areaText = const Value.absent(),
            Value<String> cityName = const Value.absent(),
            Value<String> plateText = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ScheduledRemindersTableCompanion(
            id: id,
            kindName: kindName,
            fireAt: fireAt,
            cityId: cityId,
            dateIso: dateIso,
            vehicleId: vehicleId,
            title: title,
            body: body,
            voiceText: voiceText,
            tailsText: tailsText,
            timeWindowText: timeWindowText,
            areaText: areaText,
            cityName: cityName,
            plateText: plateText,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String kindName,
            required DateTime fireAt,
            required String cityId,
            required String dateIso,
            required String vehicleId,
            required String title,
            required String body,
            Value<String> voiceText = const Value.absent(),
            Value<String> tailsText = const Value.absent(),
            Value<String> timeWindowText = const Value.absent(),
            Value<String> areaText = const Value.absent(),
            Value<String> cityName = const Value.absent(),
            Value<String> plateText = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ScheduledRemindersTableCompanion.insert(
            id: id,
            kindName: kindName,
            fireAt: fireAt,
            cityId: cityId,
            dateIso: dateIso,
            vehicleId: vehicleId,
            title: title,
            body: body,
            voiceText: voiceText,
            tailsText: tailsText,
            timeWindowText: timeWindowText,
            areaText: areaText,
            cityName: cityName,
            plateText: plateText,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ScheduledRemindersTableTable,
                        ScheduledRemindersTableData>(table),
                    BaseReferences<_$AppDatabase, $ScheduledRemindersTableTable,
                        ScheduledRemindersTableData>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ScheduledRemindersTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ScheduledRemindersTableTable,
        ScheduledRemindersTableData,
        $$ScheduledRemindersTableTableFilterComposer,
        $$ScheduledRemindersTableTableOrderingComposer,
        $$ScheduledRemindersTableTableAnnotationComposer,
        $$ScheduledRemindersTableTableCreateCompanionBuilder,
        $$ScheduledRemindersTableTableUpdateCompanionBuilder,
        (
          ScheduledRemindersTableData,
          BaseReferences<_$AppDatabase, $ScheduledRemindersTableTable,
              ScheduledRemindersTableData>
        ),
        ScheduledRemindersTableData,
        PrefetchHooks Function()>;
typedef $$AppSettingRowsTableCreateCompanionBuilder = AppSettingRowsCompanion
    Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppSettingRowsTableUpdateCompanionBuilder = AppSettingRowsCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppSettingRowsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingRowsTable> {
  $$AppSettingRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$AppSettingRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingRowsTable> {
  $$AppSettingRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$AppSettingRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingRowsTable> {
  $$AppSettingRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppSettingRowsTable,
    AppSettingRow,
    $$AppSettingRowsTableFilterComposer,
    $$AppSettingRowsTableOrderingComposer,
    $$AppSettingRowsTableAnnotationComposer,
    $$AppSettingRowsTableCreateCompanionBuilder,
    $$AppSettingRowsTableUpdateCompanionBuilder,
    (
      AppSettingRow,
      BaseReferences<_$AppDatabase, $AppSettingRowsTable, AppSettingRow>
    ),
    AppSettingRow,
    PrefetchHooks Function()> {
  $$AppSettingRowsTableTableManager(
      _$AppDatabase db, $AppSettingRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingRowsCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingRowsCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$AppSettingRowsTable, AppSettingRow>(table),
                    BaseReferences<_$AppDatabase, $AppSettingRowsTable,
                        AppSettingRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppSettingRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppSettingRowsTable,
    AppSettingRow,
    $$AppSettingRowsTableFilterComposer,
    $$AppSettingRowsTableOrderingComposer,
    $$AppSettingRowsTableAnnotationComposer,
    $$AppSettingRowsTableCreateCompanionBuilder,
    $$AppSettingRowsTableUpdateCompanionBuilder,
    (
      AppSettingRow,
      BaseReferences<_$AppDatabase, $AppSettingRowsTable, AppSettingRow>
    ),
    AppSettingRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VehicleRowsTableTableManager get vehicleRows =>
      $$VehicleRowsTableTableManager(_db, _db.vehicleRows);
  $$MyCityRowsTableTableManager get myCityRows =>
      $$MyCityRowsTableTableManager(_db, _db.myCityRows);
  $$CityCacheRowsTableTableManager get cityCacheRows =>
      $$CityCacheRowsTableTableManager(_db, _db.cityCacheRows);
  $$RestrictionDayRowsTableTableManager get restrictionDayRows =>
      $$RestrictionDayRowsTableTableManager(_db, _db.restrictionDayRows);
  $$ReminderConfigRowsTableTableManager get reminderConfigRows =>
      $$ReminderConfigRowsTableTableManager(_db, _db.reminderConfigRows);
  $$ScheduledRemindersTableTableTableManager get scheduledRemindersTable =>
      $$ScheduledRemindersTableTableTableManager(
          _db, _db.scheduledRemindersTable);
  $$AppSettingRowsTableTableManager get appSettingRows =>
      $$AppSettingRowsTableTableManager(_db, _db.appSettingRows);
}
