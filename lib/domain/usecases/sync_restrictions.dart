import '../entities/city.dart';
import '../repositories/city_repository.dart';
import '../repositories/restriction_repository.dart';
import '../repositories/vehicle_limit_source.dart';

/// 同步限行数据用例：拉取所有关注城市未来 N 天数据并落库。
class SyncRestrictions {
  SyncRestrictions({
    required this.source,
    required this.restrictionRepository,
    required this.cityRepository,
  });

  final VehicleLimitSource source;
  final RestrictionRepository restrictionRepository;
  final CityRepository cityRepository;

  /// 返回同步的天数；单城市失败不影响其他城市（部分成功语义）。
  Future<SyncResult> call({
    int days = 14,
    List<City>? onlyCities,
  }) async {
    final cities = onlyCities ?? await cityRepository.getMyCities();
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, now.day);

    var synced = 0;
    final failed = <String>[];

    for (final city in cities) {
      try {
        final fetched = await source.fetchUpcoming(city, from, days);
        await restrictionRepository.upsertDays(fetched);
        synced += fetched.length;
      } on SourceException {
        failed.add(city.id);
      } catch (_) {
        failed.add(city.id);
      }
    }

    if (failed.length < cities.length) {
      await restrictionRepository.markSynced(DateTime.now());
    }

    return SyncResult(
      dayCount: synced,
      cityCount: cities.length,
      failedCityIds: failed,
      completedAt: DateTime.now(),
    );
  }
}

class SyncResult {
  const SyncResult({
    required this.dayCount,
    required this.cityCount,
    required this.failedCityIds,
    required this.completedAt,
  });

  final int dayCount;
  final int cityCount;
  final List<String> failedCityIds;
  final DateTime completedAt;

  bool get allSuccess => failedCityIds.isEmpty;

  @override
  String toString() =>
      'SyncResult($dayCount days, failed=${failedCityIds.length})';
}
