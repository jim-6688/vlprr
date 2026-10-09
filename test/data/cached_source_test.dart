import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tail_limit/data/datasources/local/app_database.dart';
import 'package:tail_limit/data/datasources/remote/cached_source.dart';
import 'package:tail_limit/data/datasources/remote/mock_source.dart';
import 'package:tail_limit/domain/entities/city.dart';
import 'package:tail_limit/domain/entities/restriction_day.dart';
import 'package:tail_limit/domain/repositories/vehicle_limit_source.dart';

/// 可控失败的主数据源（模拟 API 故障/配额耗尽）。
class _FlakySource implements VehicleLimitSource {
  _FlakySource({required this.fail});

  bool fail;
  int callCount = 0;

  @override
  String get sourceId => 'flaky';

  @override
  bool get isEstimated => false;

  @override
  Future<List<City>> getSupportedCities() async {
    if (fail) throw const SourceException('模拟城市列表故障');
    return const [City(id: '110000', name: '北京')];
  }

  @override
  Future<List<RestrictionDay>> fetchUpcoming(
    City city,
    DateTime from,
    int days,
  ) async {
    callCount++;
    if (fail) throw const SourceException('模拟 API 故障');
    return List.generate(days, (i) {
      final date = DateTime(from.year, from.month, from.day)
          .add(Duration(days: i));
      return RestrictionDay(
        cityId: city.id,
        cityName: city.name,
        date: date,
        isRestrictedDay: true,
        restrictedTails: const {1, 6},
        source: 'flaky',
        fetchedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 12)),
      );
    });
  }
}

void main() {
  late AppDatabase db;
  const beijing = City(id: '110000', name: '北京', provinceAbbr: '京');

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  CachedSource build(_FlakySource primary) => CachedSource(
        primary: primary,
        fallback: MockSource(),
        restrictionDao: db.restrictionDao,
      );

  group('回退链', () {
    test('主源成功时返回主源数据并写透缓存', () async {
      final primary = _FlakySource(fail: false);
      final source = build(primary);

      final days = await source.fetchUpcoming(beijing, DateTime(2026, 10, 12), 7);
      expect(days.length, 7);
      expect(days.first.source, 'flaky');

      // 已写入缓存
      final cached = await db.restrictionDao.getRange('110000', DateTime(2026, 10, 12), 7);
      expect(cached.length, 7);
    });

    test('缓存命中时不再请求主源', () async {
      final primary = _FlakySource(fail: false);
      final source = build(primary);

      await source.fetchUpcoming(beijing, DateTime(2026, 10, 12), 7);
      final callsAfterFirst = primary.callCount;

      final again = await source.fetchUpcoming(beijing, DateTime(2026, 10, 12), 7);
      expect(primary.callCount, callsAfterFirst, reason: '第二次应命中缓存');
      expect(again.first.source, 'cache');
    });

    test('主源失败时回退到本地规则引擎（估算数据）', () async {
      final primary = _FlakySource(fail: true);
      final source = build(primary);

      final days = await source.fetchUpcoming(beijing, DateTime(2026, 10, 12), 5);
      expect(days.length, 5);
      // 本地引擎产出标注 mock
      expect(days.first.source, 'mock');
      expect(days.first.isRestrictedDay, isTrue);
    });

    test('主源失败但有未过期缓存时优先用缓存', () async {
      // 先用成功源填充缓存
      final ok = _FlakySource(fail: false);
      await build(ok).fetchUpcoming(beijing, DateTime(2026, 10, 12), 7);

      // 再切换到故障源
      final bad = _FlakySource(fail: true);
      final days = await build(bad).fetchUpcoming(beijing, DateTime(2026, 10, 12), 7);

      expect(days.first.source, 'cache');
    });

    test('缓存不足天数时重新拉取', () async {
      final primary = _FlakySource(fail: false);
      final source = build(primary);

      await source.fetchUpcoming(beijing, DateTime(2026, 10, 12), 3);
      final callsAfterFirst = primary.callCount;

      // 请求 7 天，缓存只有 3 天 → 应重新请求
      await source.fetchUpcoming(beijing, DateTime(2026, 10, 12), 7);
      expect(primary.callCount, greaterThan(callsAfterFirst));
    });
  });

  group('数据源可用性', () {
    test('Mock 源城市列表包含主要限行城市', () async {
      final cities = await MockSource().getSupportedCities();
      expect(cities.any((c) => c.name == '北京'), isTrue);
      expect(cities.any((c) => c.name == '成都'), isTrue);
      expect(cities.any((c) => c.name == '上海'), isTrue);
    });

    test('Mock 源标注为估算数据', () {
      expect(MockSource().isEstimated, isTrue);
    });
  });
}
