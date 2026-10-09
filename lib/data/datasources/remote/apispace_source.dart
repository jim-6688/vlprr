import 'package:dio/dio.dart';

import '../../../domain/entities/city.dart';
import '../../../domain/entities/restriction_day.dart';
import '../../../domain/repositories/vehicle_limit_source.dart';
import 'provider_parser.dart';

/// APISpace 尾号限行数据源。
///
/// 接口（需 API Key，[--dart-define=LIMIT_API_KEY=xxx] 注入）：
/// - 城市列表：GET /api/5345645/city
/// - 限行查询：GET /api/5345645/query?areacode={code}&date={yyyy-MM-dd}
///
/// 覆盖范围：65 个限行城市 / 800+ 区域（官方标注）。
/// 响应解析委托 [ProviderParser]，便于用录制 fixture 做离线单测。
class ApispaceSource implements VehicleLimitSource {
  ApispaceSource({
    required this.apiKey,
    Dio? dio,
    this.baseUrl = 'https://eolink.o.apispace.com',
    this.secondsTimeout = 10,
  }) : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  final String apiKey;
  final String baseUrl;
  final int secondsTimeout;
  final Dio _dio;

  @override
  String get sourceId => 'apispace';

  @override
  bool get isEstimated => false;

  Map<String, Object?> get _headers => {
        'X-APISpace-Token': apiKey,
        'Authorization-Type': 'apikey',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

  @override
  Future<List<City>> getSupportedCities() async {
    try {
      final resp = await _dio.get<Map<String, Object?>>(
        '$baseUrl/5345645/city',
        options: Options(headers: _headers),
      );
      final data = resp.data;
      if (data == null) throw const SourceException('空响应');
      return ProviderParser.parseApispaceCities(data);
    } on DioException catch (e) {
      throw SourceException('城市列表请求失败: ${e.message}', cause: e);
    }
  }

  @override
  Future<List<RestrictionDay>> fetchUpcoming(
    City city,
    DateTime from,
    int days,
  ) async {
    final out = <RestrictionDay>[];
    for (var i = 0; i < days; i++) {
      final date = DateTime(from.year, from.month, from.day)
          .add(Duration(days: i));
      try {
        final resp = await _dio.get<Map<String, Object?>>(
          '$baseUrl/5345645/query',
          queryParameters: {
            'areacode': city.id,
            'date': ProviderParser.isoDate(date),
          },
          options: Options(headers: _headers),
        );
        final data = resp.data;
        if (data == null) continue;
        final day = ProviderParser.parseApispaceDay(data, city, date);
        if (day != null) out.add(day);
      } on DioException catch (e) {
        // 单日失败不阻断整段拉取；若首日即失败则抛出以便触发回退链
        if (i == 0) {
          throw SourceException('限行查询失败: ${e.message}', cause: e);
        }
      }
    }
    if (out.isEmpty) {
      throw const SourceException('未获取到任何限行数据');
    }
    return out;
  }

  /// 供测试注入预置响应。
  static ApispaceSource forTesting({
    required String apiKey,
    required Dio dio,
    String baseUrl = 'https://eolink.o.apispace.com',
  }) =>
      ApispaceSource(apiKey: apiKey, dio: dio, baseUrl: baseUrl);
}

/// JISU（极速数据）尾号限行数据源。
///
/// 接口：GET https://api.jisuapi.com/vehiclelimit/query?appkey={key}&city={city}&date={date}
class JisuSource implements VehicleLimitSource {
  JisuSource({
    required this.apiKey,
    Dio? dio,
    this.baseUrl = 'https://api.jisuapi.com',
  }) : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  final String apiKey;
  final String baseUrl;
  final Dio _dio;

  @override
  String get sourceId => 'jisu';

  @override
  bool get isEstimated => false;

  @override
  Future<List<City>> getSupportedCities() async {
    try {
      final resp = await _dio.get<Map<String, Object?>>(
        '$baseUrl/vehiclelimit/city',
        queryParameters: {'appkey': apiKey},
      );
      final data = resp.data;
      if (data == null) throw const SourceException('空响应');
      return ProviderParser.parseJisuCities(data);
    } on DioException catch (e) {
      throw SourceException('城市列表请求失败: ${e.message}', cause: e);
    }
  }

  @override
  Future<List<RestrictionDay>> fetchUpcoming(
    City city,
    DateTime from,
    int days,
  ) async {
    // 极速数据按城市名查询（拼音/中文），此处用城市名
    try {
      final resp = await _dio.get<Map<String, Object?>>(
        '$baseUrl/vehiclelimit/query',
        queryParameters: {
          'appkey': apiKey,
          'city': city.name,
          'date': ProviderParser.isoDate(from),
        },
      );
      final data = resp.data;
      if (data == null) throw const SourceException('空响应');
      final first = ProviderParser.parseJisuDay(data, city, from);
      if (first == null) throw const SourceException('解析失败');
      // 极速数据单次返回单日；其余日期用规则递推（同轮换周期内尾号按星期固定）
      return ProviderParser.expandByWeekdayRotation(first, days);
    } on DioException catch (e) {
      throw SourceException('限行查询失败: ${e.message}', cause: e);
    }
  }
}
