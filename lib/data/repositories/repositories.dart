import '../../data/datasources/local/app_database.dart';
import '../../data/datasources/local/daos/city_dao.dart';
import '../../data/datasources/local/daos/setting_dao.dart';
import '../../data/datasources/local/daos/vehicle_dao.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/reminder_config.dart';
import '../../domain/entities/scheduled_reminder.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/city_repository.dart';
import '../../domain/repositories/restriction_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/vehicle_limit_source.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../../domain/services/local_rotation_engine.dart';
import 'restriction_repository_impl.dart';

/// 车辆仓库实现。
class VehicleRepositoryImpl implements VehicleRepository {
  VehicleRepositoryImpl(this._dao);

  final VehicleDao _dao;

  @override
  Stream<List<Vehicle>> watchVehicles() => _dao.watchAll();

  @override
  Future<List<Vehicle>> getAll() => _dao.getAll();

  @override
  Future<Vehicle> add(Vehicle vehicle) async {
    final existing = await _dao.getAll();
    final shouldBeDefault = existing.isEmpty || vehicle.isDefault;
    var v = vehicle.copyWith(createdAt: vehicle.createdAt ?? DateTime.now());
    if (shouldBeDefault) v = v.copyWith(isDefault: true);
    await _dao.upsert(v);
    if (shouldBeDefault) await _dao.setDefault(v.id);
    return v;
  }

  @override
  Future<void> update(Vehicle vehicle) => _dao.upsert(vehicle);

  @override
  Future<void> delete(String vehicleId) => _dao.deleteById(vehicleId);

  @override
  Future<void> setDefault(String vehicleId) => _dao.setDefault(vehicleId);

  @override
  Future<Vehicle?> findByPlate(String plate) => _dao.findByPlate(plate);
}

/// 城市仓库实现。
class CityRepositoryImpl implements CityRepository {
  CityRepositoryImpl({
    required CityDao dao,
    required VehicleLimitSource source,
  })  : _dao = dao,
        _source = source;

  final CityDao _dao;
  final VehicleLimitSource _source;

  @override
  Stream<List<City>> watchMyCities() => _dao.watchMyCities();

  @override
  Future<List<City>> getMyCities() => _dao.getMyCities();

  @override
  Future<void> addMyCity(City city) => _dao.addMyCity(city);

  @override
  Future<void> removeMyCity(String cityId) => _dao.removeMyCity(cityId);

  @override
  Future<List<City>> searchAvailableCities(String query) async {
    // 缓存为空时先拉取数据源城市列表
    final cached = await _dao.searchCitiesCache('');
    if (cached.isEmpty) {
      try {
        final cities = await _source.getSupportedCities();
        await _dao.upsertCitiesCache(cities);
      } on SourceException {
        await _dao
            .upsertCitiesCache(const LocalRotationEngine().supportedCities());
      }
    }
    return _dao.searchCitiesCache(query);
  }

  @override
  Future<City?> getCity(String cityId) => _dao.getCity(cityId);

  @override
  Stream<bool> watchOnboardingCompleted() => _dao.watchOnboardingCompleted();

  @override
  Future<void> markOnboardingCompleted() => _dao.markOnboardingCompleted();
}

/// 设置/提醒配置仓库实现。
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._dao);

  final SettingDao _dao;

  @override
  Future<ReminderConfig> getConfig(String cityId) => _dao.getConfig(cityId);

  @override
  Stream<ReminderConfig> watchConfig(String cityId) => _dao.watchConfig(cityId);

  @override
  Future<void> saveConfig(ReminderConfig config) => _dao.saveConfig(config);

  @override
  Future<List<ScheduledReminder>> getScheduledReminders() =>
      _dao.getScheduledReminders();

  @override
  Stream<List<ScheduledReminder>> watchScheduledReminders() =>
      _dao.watchScheduledReminders();

  @override
  Future<void> upsertScheduled(List<ScheduledReminder> reminders) =>
      _dao.upsertScheduled(reminders);

  @override
  Future<void> deleteScheduled(List<String> ids) => _dao.deleteScheduled(ids);

  @override
  Future<void> clearScheduled() => _dao.clearScheduled();
}

/// 便捷构造（DI 层使用）。
class Repositories {
  const Repositories._();

  static VehicleRepository vehicle(AppDatabase db) =>
      VehicleRepositoryImpl(db.vehicleDao);

  static CityRepository city(AppDatabase db, VehicleLimitSource source) =>
      CityRepositoryImpl(dao: db.cityDao, source: source);

  static RestrictionRepository restriction(AppDatabase db) =>
      RestrictionRepositoryImpl(db.restrictionDao);

  static SettingsRepository settings(AppDatabase db) =>
      SettingsRepositoryImpl(db.settingDao);
}
