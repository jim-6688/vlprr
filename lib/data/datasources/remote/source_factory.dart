import '../../../domain/repositories/vehicle_limit_source.dart';
import '../local/app_database.dart';
import 'apispace_source.dart';
import 'cached_source.dart';
import 'mock_source.dart';

/// 数据源类型。
enum LimitSourceKind { mock, apispace, jisu }

/// 数据源工厂：按配置装配「主源 + 兜底源 + 缓存装饰器」。
class SourceFactory {
  const SourceFactory._();

  static LimitSourceKind parseKind(String raw) {
    switch (raw.toLowerCase()) {
      case 'apispace':
        return LimitSourceKind.apispace;
      case 'jisu':
        return LimitSourceKind.jisu;
      default:
        return LimitSourceKind.mock;
    }
  }

  /// 构建数据源。
  ///
  /// - [kind] 为 mock 时直接返回本地规则引擎
  /// - API Key 为空时自动降级为 mock（保证开箱可跑）
  static VehicleLimitSource build({
    required LimitSourceKind kind,
    required String apiKey,
    required AppDatabase database,
    String apispaceBaseUrl = 'https://eolink.o.apispace.com',
    String jisuBaseUrl = 'https://api.jisuapi.com',
  }) {
    final fallback = MockSource();

    if (kind == LimitSourceKind.mock || apiKey.isEmpty) {
      return fallback;
    }

    final VehicleLimitSource primary;
    switch (kind) {
      case LimitSourceKind.apispace:
        primary = ApispaceSource(apiKey: apiKey, baseUrl: apispaceBaseUrl);
      case LimitSourceKind.jisu:
        primary = JisuSource(apiKey: apiKey, baseUrl: jisuBaseUrl);
      case LimitSourceKind.mock:
        return fallback;
    }

    return CachedSource(
      primary: primary,
      fallback: fallback,
      restrictionDao: database.restrictionDao,
    );
  }
}
