import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../domain/entities/city.dart';
import '../../../domain/entities/reminder_config.dart';
import '../../../domain/entities/restriction_day.dart';
import '../../../domain/entities/vehicle.dart';
import '../../../domain/usecases/get_today_status.dart';

/// 今日状态视图模型。
class TodayStatusView {
  const TodayStatusView({
    required this.city,
    required this.today,
    required this.tomorrow,
    required this.vehicleStatuses,
    required this.dataSource,
    required this.fetchedAt,
    required this.isEstimated,
  });

  final City? city;
  final RestrictionDay? today;
  final RestrictionDay? tomorrow;
  final List<VehicleDayStatus> vehicleStatuses;

  /// 数据来源标识：apispace / jisu / mock / cache。
  final String dataSource;

  final DateTime? fetchedAt;

  /// 是否为估算数据（本地规则引擎产出）。
  final bool isEstimated;

  /// 是否有任一车辆今日受限。
  bool get hasRestrictedVehicle =>
      vehicleStatuses.any((s) => s.isRestricted);

  /// 主展示车辆（默认车优先）。
  Vehicle? get primaryVehicle =>
      vehicleStatuses.isEmpty ? null : vehicleStatuses.first.vehicle;

  /// 无车辆绑定。
  bool get hasNoVehicle => vehicleStatuses.isEmpty;

  /// 数据缺失。
  bool get hasNoData => today == null;

  /// 数据是否可能过期（超过 12 小时未更新）。
  bool get isStale {
    final t = fetchedAt;
    if (t == null) return true;
    return DateTime.now().difference(t).inHours >= 12;
  }
}

/// 今日限行状态（核心页面数据源）。
final todayStatusProvider = FutureProvider<TodayStatusView>((ref) async {
  final city = ref.watch(currentCityProvider);
  final vehicles = ref.watch(vehiclesProvider).valueOrNull ?? const <Vehicle>[];
  final source = ref.watch(limitSourceProvider);

  if (city == null) {
    return const TodayStatusView(
      city: null,
      today: null,
      tomorrow: null,
      vehicleStatuses: [],
      dataSource: '',
      fetchedAt: null,
      isEstimated: false,
    );
  }

  // 走数据源（含缓存优先 + 回退链）
  final now = DateTime.now();
  final from = DateTime(now.year, now.month, now.day);
  List<RestrictionDay> days;
  try {
    days = await source.fetchUpcoming(city, from, 2);
  } catch (_) {
    days = const [];
  }

  final today = days.isNotEmpty ? days[0] : null;
  final tomorrow = days.length > 1 ? days[1] : null;

  const usecase = GetTodayStatus();
  final statuses = usecase.compute(
    vehicles: vehicles,
    city: city,
    day: today,
    now: now,
  );

  return TodayStatusView(
    city: city,
    today: today,
    tomorrow: tomorrow,
    vehicleStatuses: statuses,
    dataSource: today?.source ?? '',
    fetchedAt: today?.fetchedAt,
    isEstimated: (today?.source ?? '') == 'mock',
  );
});

/// 某城市未来 N 天的限行日历数据。
final calendarProvider =
    FutureProvider.family<List<RestrictionDay>, String>((ref, cityId) async {
  final cities = ref.watch(myCitiesProvider).valueOrNull ?? const <City>[];
  final city = cities.firstWhere(
    (c) => c.id == cityId,
    orElse: () => const City(id: '', name: ''),
  );
  if (city.id.isEmpty) return const [];

  final source = ref.watch(limitSourceProvider);
  final now = DateTime.now();
  final from = DateTime(now.year, now.month, 1);
  try {
    return await source.fetchUpcoming(city, from, 42);
  } catch (_) {
    return const [];
  }
});

/// 某城市提醒配置。
final cityConfigProvider =
    FutureProvider.family<ReminderConfig, String>((ref, cityId) async {
  return ref.watch(settingsRepositoryProvider).getConfig(cityId);
});
