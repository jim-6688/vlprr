import 'package:drift/drift.dart';

import '../../../../domain/entities/restriction_day.dart';
import '../../../models/mappers.dart';
import '../app_database.dart';
import '../tables.dart';

part 'restriction_dao.g.dart';

/// 限行快照数据访问对象。
@DriftAccessor(tables: [RestrictionDayRows, AppSettingRows])
class RestrictionDao extends DatabaseAccessor<AppDatabase>
    with _$RestrictionDaoMixin {
  RestrictionDao(super.db);

  static const String lastSyncKey = 'last_sync_at';

  // —— 快照读写 ——

  Future<RestrictionDay?> getDay(String cityId, DateTime date) async {
    final iso = Mappers.dateToIso(date);
    final row = await (select(restrictionDayRows)
          ..where((t) => t.cityId.equals(cityId) & t.dateIso.equals(iso)))
        .getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  Stream<RestrictionDay?> watchDay(String cityId, DateTime date) {
    final iso = Mappers.dateToIso(date);
    return (select(restrictionDayRows)
          ..where((t) => t.cityId.equals(cityId) & t.dateIso.equals(iso)))
        .watchSingleOrNull()
        .map((row) => row == null ? null : _toEntity(row));
  }

  Future<List<RestrictionDay>> getRange(
    String cityId,
    DateTime start,
    int days,
  ) async {
    final fromIso = Mappers.dateToIso(start);
    final toIso = Mappers.dateToIso(start.add(Duration(days: days - 1)));
    final rows = await (select(restrictionDayRows)
          ..where((t) =>
              t.cityId.equals(cityId) &
              t.dateIso.isBiggerOrEqualValue(fromIso) &
              t.dateIso.isSmallerOrEqualValue(toIso))
          ..orderBy([(t) => OrderingTerm.asc(t.dateIso)]))
        .get();
    return rows.map(_toEntity).toList();
  }

  Future<void> upsertDays(List<RestrictionDay> days) async {
    await batch((b) {
      for (final d in days) {
        b.insert(
          restrictionDayRows,
          RestrictionDayRowsCompanion.insert(
            cityId: d.cityId,
            cityName: Value(d.cityName),
            dateIso: Mappers.dateToIso(d.date),
            isRestrictedDay: Value(d.isRestrictedDay),
            restrictedTails: Value(Mappers.tailsToCsv(d.restrictedTails)),
            timeWindowsJson: Value(Mappers.windowsToJson(d.timeWindows)),
            areaText: Value(d.areaText),
            ruleText: Value(d.ruleText),
            typeName: Value(Mappers.typeToName(d.type)),
            appliesToNonLocalOnly: Value(d.appliesToNonLocalOnly),
            exemptsNewEnergy: Value(d.exemptsNewEnergy),
            tailDigitRuleName: Value(Mappers.ruleToName(d.tailDigitRule)),
            cityProvinceAbbr: Value(d.cityProvinceAbbr),
            source: Value(d.source),
            fetchedAt: d.fetchedAt,
            expiresAt: Value(d.expiresAt),
          ),
          onConflict: DoUpdate((_) => RestrictionDayRowsCompanion(
                cityName: Value(d.cityName),
                isRestrictedDay: Value(d.isRestrictedDay),
                restrictedTails: Value(Mappers.tailsToCsv(d.restrictedTails)),
                timeWindowsJson: Value(Mappers.windowsToJson(d.timeWindows)),
                areaText: Value(d.areaText),
                ruleText: Value(d.ruleText),
                typeName: Value(Mappers.typeToName(d.type)),
                appliesToNonLocalOnly: Value(d.appliesToNonLocalOnly),
                exemptsNewEnergy: Value(d.exemptsNewEnergy),
                tailDigitRuleName: Value(Mappers.ruleToName(d.tailDigitRule)),
                cityProvinceAbbr: Value(d.cityProvinceAbbr),
                source: Value(d.source),
                fetchedAt: Value(d.fetchedAt),
                expiresAt: Value(d.expiresAt),
              )),
        );
      }
    });
  }

  /// 清理过期快照（保留最近 N 天）。
  Future<int> pruneOlderThan(DateTime before) {
    final iso = Mappers.dateToIso(before);
    return (delete(restrictionDayRows)
          ..where((t) => t.dateIso.isSmallerThanValue(iso)))
        .go();
  }

  // —— 同步时间 ——

  Future<DateTime?> lastSyncAt() async {
    final row = await (select(appSettingRows)
          ..where((t) => t.key.equals(lastSyncKey)))
        .getSingleOrNull();
    if (row == null) return null;
    final ms = int.tryParse(row.value);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> markSynced(DateTime at) async {
    await into(appSettingRows).insertOnConflictUpdate(
      AppSettingRowsCompanion.insert(
        key: lastSyncKey,
        value: at.millisecondsSinceEpoch.toString(),
      ),
    );
  }

  /// 数据库行 → 域实体。
  RestrictionDay _toEntity(RestrictionDayRow row) => RestrictionDay(
        cityId: row.cityId,
        cityName: row.cityName,
        date: Mappers.isoToDate(row.dateIso),
        isRestrictedDay: row.isRestrictedDay,
        restrictedTails: Mappers.tailsFromCsv(row.restrictedTails),
        timeWindows: Mappers.windowsFromJson(row.timeWindowsJson),
        areaText: row.areaText,
        ruleText: row.ruleText,
        type: Mappers.typeFromName(row.typeName),
        appliesToNonLocalOnly: row.appliesToNonLocalOnly,
        exemptsNewEnergy: row.exemptsNewEnergy,
        tailDigitRule: Mappers.ruleFromName(row.tailDigitRuleName),
        cityProvinceAbbr: row.cityProvinceAbbr,
        source: row.source,
        fetchedAt: row.fetchedAt,
        expiresAt: row.expiresAt,
      );
}


