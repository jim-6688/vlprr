import 'package:drift/drift.dart';

import '../../../../domain/entities/reminder_config.dart';
import '../../../../domain/entities/scheduled_reminder.dart';
import '../../../models/mappers.dart';
import '../app_database.dart';
import '../tables.dart';

part 'setting_dao.g.dart';

/// 提醒配置与排程事实源的数据访问对象。
@DriftAccessor(tables: [ReminderConfigRows, ScheduledRemindersTable])
class SettingDao extends DatabaseAccessor<AppDatabase> with _$SettingDaoMixin {
  SettingDao(super.db);

  // —— 提醒配置 ——

  Future<ReminderConfig> getConfig(String cityId) async {
    // 城市维度优先，回退全局默认
    var row = await (select(reminderConfigRows)
          ..where((t) => t.cityId.equals(cityId)))
        .getSingleOrNull();
    row ??= await (select(reminderConfigRows)
          ..where((t) => t.cityId.equals(ReminderConfig.defaultKey)))
        .getSingleOrNull();
    if (row == null) {
      return cityId == ReminderConfig.defaultKey
          ? kDefaultReminderConfig
          : kDefaultReminderConfig.copyWith(cityId: cityId);
    }
    return _configFromRow(row, cityId);
  }

  Future<Map<String, ReminderConfig>> getAllConfigs() async {
    final rows = await select(reminderConfigRows).get();
    return {for (final r in rows) r.cityId: _configFromRow(r, r.cityId)};
  }

  Stream<ReminderConfig> watchConfig(String cityId) {
    return select(reminderConfigRows).watch().map((rows) {
      for (final r in rows) {
        if (r.cityId == cityId) return _configFromRow(r, cityId);
      }
      for (final r in rows) {
        if (r.cityId == ReminderConfig.defaultKey) {
          return _configFromRow(r, cityId);
        }
      }
      return kDefaultReminderConfig.copyWith(cityId: cityId);
    });
  }

  Future<void> saveConfig(ReminderConfig config) async {
    await into(reminderConfigRows).insertOnConflictUpdate(
      ReminderConfigRowsCompanion.insert(
        cityId: config.cityId,
        previewEnabled: Value(config.previewEnabled),
        previewMinutesOfDay: Value(config.previewMinutesOfDay),
        strongEnabled: Value(config.strongEnabled),
        strongLeadMinutes: Value(config.strongLeadMinutes),
        strongFallbackMinutesOfDay: Value(config.strongFallbackMinutesOfDay),
        voiceEnabled: Value(config.voiceEnabled),
        fullScreenEnabled: Value(config.fullScreenEnabled),
        bypassDndEnabled: Value(config.bypassDndEnabled),
      ),
    );
  }

  // —— 排程事实源 ——

  Future<List<ScheduledReminder>> getScheduledReminders() async {
    final rows = await (select(scheduledRemindersTable)
          ..orderBy([(t) => OrderingTerm.asc(t.fireAt)]))
        .get();
    return rows.map(_reminderFromRow).toList();
  }

  Stream<List<ScheduledReminder>> watchScheduledReminders() {
    return (select(scheduledRemindersTable)
          ..orderBy([(t) => OrderingTerm.asc(t.fireAt)]))
        .watch()
        .map((rows) => rows.map(_reminderFromRow).toList());
  }

  Future<void> upsertScheduled(List<ScheduledReminder> reminders) async {
    await batch((b) {
      for (final r in reminders) {
        b.insert(
          scheduledRemindersTable,
          ScheduledRemindersTableCompanion.insert(
            id: r.id,
            kindName: Mappers.kindToName(r.kind),
            fireAt: r.fireAt,
            cityId: r.cityId,
            dateIso: Mappers.dateToIso(r.date),
            vehicleId: r.vehicleId,
            title: r.title,
            body: r.body,
            voiceText: Value(r.voiceText),
            tailsText: Value(r.tailsText),
            timeWindowText: Value(r.timeWindowText),
            areaText: Value(r.areaText),
            cityName: Value(r.cityName),
            plateText: Value(r.plateText),
          ),
          onConflict: DoUpdate((_) => ScheduledRemindersTableCompanion(
                kindName: Value(Mappers.kindToName(r.kind)),
                fireAt: Value(r.fireAt),
                title: Value(r.title),
                body: Value(r.body),
                voiceText: Value(r.voiceText),
                tailsText: Value(r.tailsText),
                timeWindowText: Value(r.timeWindowText),
                areaText: Value(r.areaText),
                cityName: Value(r.cityName),
                plateText: Value(r.plateText),
              )),
        );
      }
    });
  }

  Future<void> deleteScheduled(List<String> ids) async {
    if (ids.isEmpty) return;
    await (delete(scheduledRemindersTable)..where((t) => t.id.isIn(ids))).go();
  }

  Future<void> clearScheduled() async {
    await delete(scheduledRemindersTable).go();
  }

  // —— 行 → 实体 ——

  ReminderConfig _configFromRow(ReminderConfigRow row, String cityId) =>
      ReminderConfig(
        cityId: cityId,
        previewEnabled: row.previewEnabled,
        previewMinutesOfDay: row.previewMinutesOfDay,
        strongEnabled: row.strongEnabled,
        strongLeadMinutes: row.strongLeadMinutes,
        strongFallbackMinutesOfDay: row.strongFallbackMinutesOfDay,
        voiceEnabled: row.voiceEnabled,
        fullScreenEnabled: row.fullScreenEnabled,
        bypassDndEnabled: row.bypassDndEnabled,
      );

  ScheduledReminder _reminderFromRow(ScheduledRemindersTableData row) =>
      ScheduledReminder(
        id: row.id,
        kind: Mappers.kindFromName(row.kindName),
        fireAt: row.fireAt,
        cityId: row.cityId,
        date: Mappers.isoToDate(row.dateIso),
        vehicleId: row.vehicleId,
        title: row.title,
        body: row.body,
        voiceText: row.voiceText,
        tailsText: row.tailsText,
        timeWindowText: row.timeWindowText,
        areaText: row.areaText,
        cityName: row.cityName,
        plateText: row.plateText,
      );
}
