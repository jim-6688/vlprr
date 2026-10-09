import '../entities/restriction_day.dart';
import '../entities/restriction_verdict.dart';
import '../entities/vehicle.dart';
import '../value_objects/tail_number.dart';

/// 限行判定领域服务（纯函数）。
///
/// 输入：RestrictionDay 快照 + Vehicle，输出 RestrictionVerdict。
/// 判定优先级：
/// 1. 当天无限行措施 → notRestricted
/// 2. 新能源且政策豁免 → exemptNewEnergy
/// 3. 仅外牌限行且是本地牌 → exemptLocalPlate
/// 4. 仅外牌限行且是外地牌 → restricted（区域禁行）
/// 5. 尾号轮换命中 → restricted
/// 6. 未命中 → notRestricted
class RestrictionEvaluator {
  const RestrictionEvaluator();

  RestrictionVerdict evaluate({
    required Vehicle vehicle,
    required RestrictionDay day,
    DateTime? now,
  }) {
    final date = DateTime(day.date.year, day.date.month, day.date.day);
    final base = RestrictionVerdict(
      vehicleId: vehicle.id,
      plate: vehicle.plate,
      cityId: day.cityId,
      date: date,
      kind: VerdictKind.notRestricted,
      tailsText: day.tailsText,
      areaText: day.areaText,
      windows: day.timeWindows,
    );

    // 1. 当天无措施
    if (!day.isRestrictedDay) {
      return base.copyWith(reasonText: VerdictText.noMeasure);
    }

    // 2. 新能源豁免（政策属性）
    if (vehicle.isNEV && day.exemptsNewEnergy) {
      return base.copyWith(
        kind: VerdictKind.exemptNewEnergy,
        reasonText: VerdictText.exemptNewEnergy,
      );
    }

    // 3/4. 非本地号牌区域限行
    if (day.appliesToNonLocalOnly) {
      final isLocal = isLocalPlate(vehicle.plate, day.cityProvinceAbbr);
      if (isLocal) {
        return base.copyWith(
          kind: VerdictKind.exemptLocalPlate,
          reasonText: VerdictText.localFree,
        );
      }
      return base.copyWith(
        kind: VerdictKind.restricted,
        reasonText: '外地号牌限行，${VerdictText.restricted}',
      );
    }

    // 5. 尾号轮换命中
    final tail = extractTailNumber(vehicle.plate, day.tailDigitRule);
    if (tail != null && day.restrictedTails.contains(tail.value)) {
      return base.copyWith(
        kind: VerdictKind.restricted,
        reasonText: '尾号 ${tail.value} 今日限行，${VerdictText.restricted}',
      );
    }

    // 6. 未命中
    return base.copyWith(reasonText: VerdictText.notRestricted);
  }

  /// 批量判定。
  List<RestrictionVerdict> evaluateAll({
    required List<Vehicle> vehicles,
    required RestrictionDay day,
    DateTime? now,
  }) =>
      vehicles
          .where((v) => v.boundCityId == day.cityId)
          .map((v) => evaluate(vehicle: v, day: day, now: now))
          .toList();
}
