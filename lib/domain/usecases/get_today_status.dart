import '../entities/city.dart';
import '../entities/restriction_day.dart';
import '../entities/restriction_verdict.dart';
import '../entities/vehicle.dart';
import '../services/restriction_evaluator.dart';

/// 今日限行状态用例：车辆 × 城市当日快照 → 判定视图。
///
/// Stream 组合在 presentation 层 provider 完成；本用例提供纯计算。
class GetTodayStatus {
  const GetTodayStatus();

  /// 计算某城市当日所有绑定车辆的判定结果。
  List<VehicleDayStatus> compute({
    required List<Vehicle> vehicles,
    required City city,
    RestrictionDay? day,
    DateTime? now,
    RestrictionEvaluator evaluator = const RestrictionEvaluator(),
  }) {
    final today = _day(now ?? DateTime.now());
    final active = vehicles
        .where((v) => v.boundCityId == city.id && v.isActive)
        .toList()
      ..sort((a, b) {
        if (a.isDefault != b.isDefault) return a.isDefault ? -1 : 1;
        return 0;
      });

    return active.map((v) {
      if (day == null || !_sameDay(day.date, today)) {
        return VehicleDayStatus(
          vehicle: v,
          verdict: RestrictionVerdict(
            vehicleId: v.id,
            plate: v.plate,
            cityId: city.id,
            date: today,
            kind: VerdictKind.notRestricted,
            reasonText: '暂无限行数据，请刷新',
          ),
          day: null,
        );
      }
      return VehicleDayStatus(
        vehicle: v,
        verdict: evaluator.evaluate(vehicle: v, day: day),
        day: day,
      );
    }).toList();
  }

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// 单车当日状态视图。
class VehicleDayStatus {
  const VehicleDayStatus({
    required this.vehicle,
    required this.verdict,
    required this.day,
  });

  final Vehicle vehicle;
  final RestrictionVerdict verdict;

  /// 当日快照（数据缺失时为 null）。
  final RestrictionDay? day;

  bool get isRestricted => verdict.isRestricted;
}
