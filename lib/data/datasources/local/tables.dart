import 'package:drift/drift.dart';

/// 车辆表。
class VehicleRows extends Table {
  TextColumn get id => text()();
  TextColumn get plate => text()();
  TextColumn get nickname => text().withDefault(const Constant(''))();
  TextColumn get boundCityId => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 我的城市（关注城市）表。
class MyCityRows extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get province => text().withDefault(const Constant(''))();
  TextColumn get provinceAbbr => text().withDefault(const Constant(''))();
  BoolColumn get hasRestriction => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// 数据源城市覆盖缓存。
class CityCacheRows extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get province => text().withDefault(const Constant(''))();
  TextColumn get provinceAbbr => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

/// 限行日快照表（核心缓存表，主键 cityId + date）。
///
/// 类名加 Rows 后缀，避免 drift 生成的数据行类 `RestrictionDayRowsData`
/// 与领域实体 `RestrictionDay` 重名。
class RestrictionDayRows extends Table {
  TextColumn get cityId => text()();
  TextColumn get cityName => text().withDefault(const Constant(''))();
  /// yyyy-MM-dd
  TextColumn get dateIso => text()();

  BoolColumn get isRestrictedDay =>
      boolean().withDefault(const Constant(false))();
  /// 逗号分隔的尾号，如 "4,9"
  TextColumn get restrictedTails => text().withDefault(const Constant(''))();
  /// JSON: [{"start":450,"end":1200}]
  TextColumn get timeWindowsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get areaText => text().withDefault(const Constant(''))();
  TextColumn get ruleText => text().withDefault(const Constant(''))();
  TextColumn get typeName => text().withDefault(const Constant('tailRotationByWeekday'))();
  BoolColumn get appliesToNonLocalOnly =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get exemptsNewEnergy =>
      boolean().withDefault(const Constant(false))();
  TextColumn get tailDigitRuleName => text().withDefault(const Constant('lastDigit'))();
  TextColumn get cityProvinceAbbr => text().withDefault(const Constant(''))();
  TextColumn get source => text().withDefault(const Constant('mock'))();
  DateTimeColumn get fetchedAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {cityId, dateIso};
}

/// 提醒配置表（cityId 维度，'default' 为全局默认）。
class ReminderConfigRows extends Table {
  TextColumn get cityId => text()();
  BoolColumn get previewEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get previewMinutesOfDay =>
      integer().withDefault(const Constant(1260))();
  BoolColumn get strongEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get strongLeadMinutes => integer().withDefault(const Constant(10))();
  IntColumn get strongFallbackMinutesOfDay =>
      integer().withDefault(const Constant(420))();
  BoolColumn get voiceEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get fullScreenEnabled =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get bypassDndEnabled => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {cityId};
}

/// 已排程提醒表（排程事实源）。
class ScheduledRemindersTable extends Table {
  TextColumn get id => text()();
  TextColumn get kindName => text()();
  DateTimeColumn get fireAt => dateTime()();
  TextColumn get cityId => text()();
  TextColumn get dateIso => text()();
  TextColumn get vehicleId => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get voiceText => text().withDefault(const Constant(''))();
  TextColumn get tailsText => text().withDefault(const Constant(''))();
  TextColumn get timeWindowText => text().withDefault(const Constant(''))();
  TextColumn get areaText => text().withDefault(const Constant(''))();
  TextColumn get cityName => text().withDefault(const Constant(''))();
  TextColumn get plateText => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

/// 应用级键值设置表。
class AppSettingRows extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
