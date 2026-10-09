import '../entities/city.dart';

/// 城市仓库抽象：我的城市（关注城市）管理。
abstract class CityRepository {
  /// 监听"我的城市"列表（第一个为当前城市）。
  Stream<List<City>> watchMyCities();

  Future<List<City>> getMyCities();

  Future<void> addMyCity(City city);

  Future<void> removeMyCity(String cityId);

  /// 搜索数据源覆盖的城市列表（65 个限行城市）。
  Future<List<City>> searchAvailableCities(String query);

  Future<City?> getCity(String cityId);

  /// 是否已完成首次引导（选过城市）。
  Stream<bool> watchOnboardingCompleted();

  Future<void> markOnboardingCompleted();
}
