import 'dart:convert';

import '../../domain/entities/city.dart';
import '../../domain/entities/reminder_config.dart';
import '../../domain/entities/restriction_day.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/value_objects/restriction_type.dart';
import '../../domain/value_objects/time_window.dart';

/// 域对象 ↔ 数据库行 / JSON 的映射工具。
class Mappers {
  const Mappers._();

  // —— 尾号集合 ——

  static String tailsToCsv(Set<int> tails) {
    final list = tails.toList()..sort();
    return list.join(',');
  }

  static Set<int> tailsFromCsv(String csv) {
    if (csv.trim().isEmpty) return <int>{};
    return csv
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .toSet();
  }

  // —— 时段 ——

  static String windowsToJson(List<TimeWindow> windows) {
    return jsonEncode(
      windows
          .map((w) => {'start': w.startMinutes, 'end': w.endMinutes})
          .toList(),
    );
  }

  static List<TimeWindow> windowsFromJson(String json) {
    if (json.trim().isEmpty) return const [];
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((e) {
            final m = e as Map<String, dynamic>;
            return TimeWindow(
              startMinutes: m['start'] as int? ?? 0,
              endMinutes: m['end'] as int? ?? 24 * 60,
            );
          })
          .toList();
    } catch (_) {
      return const [];
    }
  }

  // —— 枚举 ——

  static String typeToName(RestrictionType t) => t.name;

  static RestrictionType typeFromName(String name) => RestrictionType.values
      .firstWhere((e) => e.name == name, orElse: () => RestrictionType.tailRotationByWeekday);

  static String ruleToName(TailDigitRule r) => r.name;

  static TailDigitRule ruleFromName(String name) => TailDigitRule.values
      .firstWhere((e) => e.name == name, orElse: () => TailDigitRule.lastDigit);

  static String kindToName(ReminderKind k) => k.name;

  static ReminderKind kindFromName(String name) => ReminderKind.values
      .firstWhere((e) => e.name == name, orElse: () => ReminderKind.preview);

  // —— 日期 ——

  static String dateToIso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static DateTime isoToDate(String iso) {
    final parts = iso.split('-');
    if (parts.length != 3) return DateTime.now();
    return DateTime(
      int.tryParse(parts[0]) ?? 1970,
      int.tryParse(parts[1]) ?? 1,
      int.tryParse(parts[2]) ?? 1,
    );
  }

  // —— 城市 ——

  static City cityFromRow(String id, String name, String province, String abbr,
          {bool hasRestriction = true}) =>
      City(
        id: id,
        name: name,
        province: province,
        provinceAbbr: abbr,
        hasRestriction: hasRestriction,
      );

  // —— 车辆 ——

  static Map<String, Object?> vehicleToJson(Vehicle v) => {
        'id': v.id,
        'plate': v.plate,
        'nickname': v.nickname,
        'boundCityId': v.boundCityId,
        'isActive': v.isActive,
        'isDefault': v.isDefault,
        'createdAt': v.createdAt?.millisecondsSinceEpoch,
      };

  static Vehicle vehicleFromJson(Map<Object?, Object?> m) => Vehicle(
        id: m['id'] as String,
        plate: m['plate'] as String,
        nickname: m['nickname'] as String? ?? '',
        boundCityId: m['boundCityId'] as String? ?? '',
        isActive: m['isActive'] != false,
        isDefault: m['isDefault'] == true,
        createdAt: m['createdAt'] is int
            ? DateTime.fromMillisecondsSinceEpoch(m['createdAt'] as int)
            : null,
      );

  // —— 提醒配置 ——

  static ReminderConfig configFromJson(Map<Object?, Object?> m) =>
      ReminderConfig.fromMap(m);

  // —— 限行日 ——

  static Map<String, Object?> restrictionDayToColumnMap(RestrictionDay d) => {
        'cityId': d.cityId,
        'cityName': d.cityName,
        'dateIso': dateToIso(d.date),
        'isRestrictedDay': d.isRestrictedDay,
        'restrictedTails': tailsToCsv(d.restrictedTails),
        'timeWindowsJson': windowsToJson(d.timeWindows),
        'areaText': d.areaText,
        'ruleText': d.ruleText,
        'typeName': typeToName(d.type),
        'appliesToNonLocalOnly': d.appliesToNonLocalOnly,
        'exemptsNewEnergy': d.exemptsNewEnergy,
        'tailDigitRuleName': ruleToName(d.tailDigitRule),
        'cityProvinceAbbr': d.cityProvinceAbbr,
        'source': d.source,
        'fetchedAt': d.fetchedAt,
        'expiresAt': d.expiresAt,
      };
}
