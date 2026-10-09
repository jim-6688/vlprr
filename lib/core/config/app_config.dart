import '../../data/datasources/remote/source_factory.dart';

/// 应用运行时配置（通过 `--dart-define` 注入，不落库不入版本控制）。
///
/// 用法：
/// ```
/// # 默认：本地规则引擎（开箱即跑，无需 Key）
/// flutter run
///
/// # 接入真实数据源
/// flutter run \
///   --dart-define=LIMIT_SOURCE=apispace \
///   --dart-define=LIMIT_API_KEY=你的key
/// ```
class AppConfig {
  const AppConfig({
    required this.sourceKind,
    required this.apiKey,
    required this.apispaceBaseUrl,
    required this.jisuBaseUrl,
    required this.syncDays,
    required this.strongAlertExperimentEnabled,
  });

  /// 数据源类型：mock / apispace / jisu。
  final LimitSourceKind sourceKind;

  /// 第三方 API Key（空则自动降级 mock）。
  final String apiKey;

  final String apispaceBaseUrl;
  final String jisuBaseUrl;

  /// 同步天数（默认 14 天，覆盖尾号轮换周期内的日常变更）。
  final int syncDays;

  /// 是否启用强提醒实验特性（如绕过勿扰引导）。
  final bool strongAlertExperimentEnabled;

  /// 从编译期环境变量构建。
  factory AppConfig.fromDartDefines() => AppConfig(
        sourceKind: SourceFactory.parseKind(
          const String.fromEnvironment('LIMIT_SOURCE', defaultValue: 'mock'),
        ),
        apiKey: const String.fromEnvironment('LIMIT_API_KEY', defaultValue: ''),
        apispaceBaseUrl: const String.fromEnvironment(
          'LIMIT_APISPACE_BASEURL',
          defaultValue: 'https://eolink.o.apispace.com',
        ),
        jisuBaseUrl: const String.fromEnvironment(
          'LIMIT_JISU_BASEURL',
          defaultValue: 'https://api.jisuapi.com',
        ),
        syncDays: const int.fromEnvironment('LIMIT_SYNC_DAYS', defaultValue: 14),
        strongAlertExperimentEnabled: const bool.fromEnvironment(
          'LIMIT_ENABLE_EXPERIMENT',
          defaultValue: false,
        ),
      );

  /// 测试/开发默认配置。
  static const AppConfig dev = AppConfig(
    sourceKind: LimitSourceKind.mock,
    apiKey: '',
    apispaceBaseUrl: 'https://eolink.o.apispace.com',
    jisuBaseUrl: 'https://api.jisuapi.com',
    syncDays: 14,
    strongAlertExperimentEnabled: false,
  );

  /// 数据源是否降级为估算模式。
  bool get isEstimatedMode =>
      sourceKind == LimitSourceKind.mock || apiKey.isEmpty;

  @override
  String toString() =>
      'AppConfig(source=${sourceKind.name} estimated=$isEstimatedMode days=$syncDays)';
}
