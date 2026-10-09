import '../../../domain/entities/city.dart';
import '../../../domain/entities/restriction_day.dart';
import '../../../domain/repositories/vehicle_limit_source.dart';
import '../local/daos/restriction_dao.dart';

/// 缓存优先 + 多级回退的数据源装饰器。
///
/// 查询顺序（[fetchUpcoming]）：
///   1. drift 缓存命中且未过期 → 直接返回（标记 source='cache'）
///   2. 主数据源（API）请求成功 → 写透缓存并返回
///   3. 主数据源失败 → 返回过期缓存（若存在）
///   4. 再失败 → 委托兜底数据源（本地规则引擎，标注估算）
///
/// 设计目标：**离线可用 + 数据诚实**。每层结果都携带来源标记，
/// UI 层据此展示"数据来源 + 更新时间"徽章。
class CachedSource implements VehicleLimitSource {
  CachedSource({
    required this.primary,
    required this.fallback,
    required this.restrictionDao,
    this.cacheValidDuration = const Duration(hours: 12),
  });

  /// 主数据源（API，如 ApispaceSource）。
  final VehicleLimitSource primary;

  /// 兜底数据源（MockSource 本地规则引擎）。
  final VehicleLimitSource fallback;

  final RestrictionDao restrictionDao;

  /// 缓存有效时长。
  final Duration cacheValidDuration;

  @override
  String get sourceId => primary.sourceId;

  @override
  bool get isEstimated => primary.isEstimated;

  @override
  Future<List<City>> getSupportedCities() async {
    try {
      return await primary.getSupportedCities();
    } on SourceException {
      return fallback.getSupportedCities();
    }
  }

  @override
  Future<List<RestrictionDay>> fetchUpcoming(
    City city,
    DateTime from,
    int days,
  ) async {
    // 1. 缓存优先
    final cached = await restrictionDao.getRange(city.id, from, days);
    if (cached.length >= days && _allFresh(cached)) {
      return cached.map(_markAsCache).toList();
    }

    // 2. 主数据源
    try {
      final fresh = await primary.fetchUpcoming(city, from, days);
      await restrictionDao.upsertDays(fresh);
      return fresh;
    } on SourceException {
      // 3. 过期缓存兜底
      if (cached.isNotEmpty) {
        return cached.map(_markAsCache).toList();
      }
      // 4. 本地规则引擎兜底
      final estimated = await fallback.fetchUpcoming(city, from, days);
      await restrictionDao.upsertDays(estimated);
      return estimated;
    }
  }

  bool _allFresh(List<RestrictionDay> days) {
    final now = DateTime.now();
    for (final d in days) {
      final exp = d.expiresAt;
      if (exp == null || exp.isBefore(now)) return false;
    }
    return true;
  }

  /// 命中缓存的快照统一标记来源为 cache（保留原始来源至 ruleText 语义）。
  RestrictionDay _markAsCache(RestrictionDay d) =>
      d.source == 'cache' ? d : d.copyWith(source: 'cache');

  /// 判断某城市某日数据是否已过期（供 UI 展示"数据可能过期"提示）。
  bool isExpired(RestrictionDay? day) {
    if (day == null) return true;
    final exp = day.expiresAt;
    return exp == null || exp.isBefore(DateTime.now());
  }
}
