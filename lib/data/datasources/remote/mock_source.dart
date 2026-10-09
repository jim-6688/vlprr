import '../../../domain/entities/city.dart';
import '../../../domain/entities/restriction_day.dart';
import '../../../domain/repositories/vehicle_limit_source.dart';
import '../../../domain/services/local_rotation_engine.dart';

/// 本地规则引擎数据源（兜底 + 默认数据源）。
///
/// 特点：
/// - 零依赖、离线可用、开箱即跑（`--dart-define=LIMIT_SOURCE=mock`）
/// - 数据为**估算**（[isEstimated] = true），UI 必须展示来源徽章
class MockSource implements VehicleLimitSource {
  MockSource({LocalRotationEngine? engine})
      : _engine = engine ?? const LocalRotationEngine();

  final LocalRotationEngine _engine;

  @override
  String get sourceId => 'mock';

  @override
  bool get isEstimated => true;

  @override
  Future<List<City>> getSupportedCities() async => _engine.supportedCities();

  @override
  Future<List<RestrictionDay>> fetchUpcoming(
    City city,
    DateTime from,
    int days,
  ) async =>
      _engine.generateDays(city: city, from: from, days: days);
}
