import '../entities/city.dart';
import '../entities/restriction_day.dart';

/// 限行数据源端口（六边形架构 Port）。
///
/// data 层提供三类实现：
/// - ApispaceSource / JisuSource：第三方聚合 API（对应"从交管部门获取"的数据通道）
/// - MockSource：本地规则引擎兜底
/// - CachedSource：装饰器（缓存优先 + 回退链）
abstract class VehicleLimitSource {
  /// 数据源标识：apispace / jisu / mock。
  String get sourceId;

  /// 是否为估算数据（UI 展示来源徽章）。
  bool get isEstimated;

  /// 数据源支持的城市覆盖列表。
  Future<List<City>> getSupportedCities();

  /// 拉取 [city] 从 [from] 起 [days] 天的限行快照。
  Future<List<RestrictionDay>> fetchUpcoming(
    City city,
    DateTime from,
    int days,
  );
}

/// 数据源异常。
class SourceException implements Exception {
  const SourceException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'SourceException: $message${cause != null ? ' ($cause)' : ''}';
}
