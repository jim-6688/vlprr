import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/app_database.dart';
import '../../data/datasources/remote/source_factory.dart';
import '../../data/datasources/system/alert_gateway_impl.dart';
import '../../data/repositories/repositories.dart';
import '../../data/repositories/restriction_repository_impl.dart';
import '../../domain/entities/reminder_config.dart';
import '../../domain/entities/scheduled_reminder.dart';
import '../../domain/repositories/alert_gateway.dart';
import '../../domain/repositories/city_repository.dart';
import '../../domain/repositories/restriction_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/vehicle_limit_source.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../../domain/services/reminder_planner.dart';
import '../../domain/usecases/apply_reminder_plan.dart';
import '../../domain/usecases/sync_restrictions.dart';
import '../config/app_config.dart';

/// ——————————————————————————————————————————————
/// 基础设施层
/// ——————————————————————————————————————————————

/// 应用配置（启动时 override 注入）。
final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.dev);

/// 本地数据库。
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// 限行数据源（主源 + 兜底 + 缓存装饰器）。
final limitSourceProvider = Provider<VehicleLimitSource>((ref) {
  final config = ref.watch(appConfigProvider);
  final db = ref.watch(databaseProvider);
  return SourceFactory.build(
    kind: config.sourceKind,
    apiKey: config.apiKey,
    database: db,
    apispaceBaseUrl: config.apispaceBaseUrl,
    jisuBaseUrl: config.jisuBaseUrl,
  );
});

/// 强提醒网关（三端原生插件）。
final alertGatewayProvider = Provider<AlertGateway>((ref) => AlertGatewayImpl());

/// ——————————————————————————————————————————————
/// 仓库层
/// ——————————————————————————————————————————————

final vehicleRepositoryProvider = Provider<VehicleRepository>(
  (ref) => Repositories.vehicle(ref.watch(databaseProvider)),
);

final cityRepositoryProvider = Provider<CityRepository>(
  (ref) => Repositories.city(
    ref.watch(databaseProvider),
    ref.watch(limitSourceProvider),
  ),
);

final restrictionRepositoryProvider = Provider<RestrictionRepository>(
  (ref) => RestrictionRepositoryImpl(
    ref.watch(databaseProvider).restrictionDao,
  ),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => Repositories.settings(ref.watch(databaseProvider)),
);

/// ——————————————————————————————————————————————
/// 用例层
/// ——————————————————————————————————————————————

final syncRestrictionsProvider = Provider<SyncRestrictions>(
  (ref) => SyncRestrictions(
    source: ref.watch(limitSourceProvider),
    restrictionRepository: ref.watch(restrictionRepositoryProvider),
    cityRepository: ref.watch(cityRepositoryProvider),
  ),
);

final applyReminderPlanProvider = Provider<ApplyReminderPlan>(
  (ref) => ApplyReminderPlan(
    settingsRepository: ref.watch(settingsRepositoryProvider),
    alertGateway: ref.watch(alertGatewayProvider),
    planner: const ReminderPlanner(),
  ),
);

/// ——————————————————————————————————————————————
/// 数据流
/// ——————————————————————————————————————————————

/// 我的城市列表。
final myCitiesProvider = StreamProvider((ref) {
  return ref.watch(cityRepositoryProvider).watchMyCities();
});

/// 当前城市（我的城市列表第一个）。
final currentCityProvider = Provider((ref) {
  final cities = ref.watch(myCitiesProvider).valueOrNull ?? const [];
  return cities.isEmpty ? null : cities.first;
});

/// 车辆列表。
final vehiclesProvider = StreamProvider((ref) {
  return ref.watch(vehicleRepositoryProvider).watchVehicles();
});

/// 全部提醒配置（cityId → config）。
final allConfigsProvider = FutureProvider<Map<String, ReminderConfig>>((ref) async {
  final dao = ref.watch(databaseProvider).settingDao;
  return dao.getAllConfigs();
});

/// 全局默认提醒配置。
final defaultConfigProvider = FutureProvider<ReminderConfig>((ref) async {
  return ref.watch(settingsRepositoryProvider).getConfig(ReminderConfig.defaultKey);
});

/// 已排程提醒列表。
final scheduledRemindersProvider = StreamProvider<List<ScheduledReminder>>((ref) {
  return ref.watch(settingsRepositoryProvider).watchScheduledReminders();
});

/// 引导是否完成。
final onboardingCompletedProvider = StreamProvider<bool>((ref) {
  return ref.watch(cityRepositoryProvider).watchOnboardingCompleted();
});

/// 平台强提醒能力。
final alertCapabilitiesProvider = FutureProvider((ref) async {
  return ref.watch(alertGatewayProvider).capabilities();
});

/// 上次同步时间。
final lastSyncProvider = FutureProvider<DateTime?>((ref) {
  return ref.watch(restrictionRepositoryProvider).lastSyncAt();
});
