import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tail_limit/data/datasources/local/app_database.dart';
import 'package:tail_limit/data/repositories/repositories.dart';
import 'package:tail_limit/domain/entities/city.dart';
import 'package:tail_limit/domain/entities/reminder_config.dart';
import 'package:tail_limit/domain/entities/restriction_day.dart';
import 'package:tail_limit/domain/entities/vehicle.dart';
import 'package:tail_limit/domain/repositories/vehicle_limit_source.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('VehicleRepository', () {
    test('添加车辆并自动设为默认（首辆车）', () async {
      final repo = Repositories.vehicle(db);
      final v = await repo.add(const Vehicle(
        id: 'v1',
        plate: '京A12345',
        boundCityId: '110000',
      ));

      expect(v.isDefault, isTrue);
      final all = await repo.getAll();
      expect(all.length, 1);
      expect(all.first.plate, '京A12345');
    });

    test('第二辆车不自动设默认', () async {
      final repo = Repositories.vehicle(db);
      await repo.add(const Vehicle(
          id: 'v1', plate: '京A12345', boundCityId: '110000'));
      final v2 = await repo.add(const Vehicle(
          id: 'v2', plate: '沪B23456', boundCityId: '310000'));

      expect(v2.isDefault, isFalse);
      final all = await repo.getAll();
      expect(all.where((v) => v.isDefault).length, 1);
    });

    test('切换默认车时互斥', () async {
      final repo = Repositories.vehicle(db);
      await repo.add(const Vehicle(
          id: 'v1', plate: '京A12345', boundCityId: '110000'));
      await repo.add(const Vehicle(
          id: 'v2', plate: '京A23456', boundCityId: '110000'));

      await repo.setDefault('v2');
      final all = await repo.getAll();
      final defaults = all.where((v) => v.isDefault).toList();
      expect(defaults.length, 1);
      expect(defaults.first.id, 'v2');
    });

    test('按车牌查询', () async {
      final repo = Repositories.vehicle(db);
      await repo.add(const Vehicle(
          id: 'v1', plate: '京A12345', boundCityId: '110000'));
      expect((await repo.findByPlate('京A12345'))?.id, 'v1');
      expect(await repo.findByPlate('不存在'), isNull);
    });

    test('删除车辆', () async {
      final repo = Repositories.vehicle(db);
      await repo.add(const Vehicle(
          id: 'v1', plate: '京A12345', boundCityId: '110000'));
      await repo.delete('v1');
      expect(await repo.getAll(), isEmpty);
    });
  });

  group('CityRepository', () {
    test('添加与移除我的城市', () async {
      final repo = Repositories.city(db, _NullSource());
      await repo.addMyCity(const City(
          id: '110000', name: '北京', provinceAbbr: '京'));
      expect((await repo.getMyCities()).length, 1);

      await repo.removeMyCity('110000');
      expect(await repo.getMyCities(), isEmpty);
    });

    test('重复添加城市不产生重复记录', () async {
      final repo = Repositories.city(db, _NullSource());
      await repo.addMyCity(const City(id: '110000', name: '北京'));
      await repo.addMyCity(const City(id: '110000', name: '北京'));
      expect((await repo.getMyCities()).length, 1);
    });

    test('引导完成状态持久化', () async {
      final repo = Repositories.city(db, _NullSource());
      expect(await repo.watchOnboardingCompleted().first, isFalse);
      await repo.markOnboardingCompleted();
      expect(await repo.watchOnboardingCompleted().first, isTrue);
    });
  });

  group('SettingsRepository', () {
    test('无配置时返回全局默认', () async {
      final repo = Repositories.settings(db);
      final config = await repo.getConfig('110000');
      expect(config.previewEnabled, isTrue);
      expect(config.strongEnabled, isTrue);
      expect(config.strongLeadMinutes, 10);
      expect(config.previewMinutesOfDay, 21 * 60);
    });

    test('保存城市配置后按城市维度读取', () async {
      final repo = Repositories.settings(db);
      await repo.saveConfig(
        kDefaultReminderConfig.copyWith(
          cityId: '110000',
          strongLeadMinutes: 30,
          voiceEnabled: false,
        ),
      );

      final beijing = await repo.getConfig('110000');
      expect(beijing.strongLeadMinutes, 30);
      expect(beijing.voiceEnabled, isFalse);

      // 其他城市仍用默认
      final shanghai = await repo.getConfig('310000');
      expect(shanghai.strongLeadMinutes, 10);
    });
  });
}

/// 测试用空数据源。
class _NullSource implements VehicleLimitSource {
  @override
  String get sourceId => 'test';

  @override
  bool get isEstimated => true;

  @override
  Future<List<City>> getSupportedCities() async => const [];

  @override
  Future<List<RestrictionDay>> fetchUpcoming(
    City city,
    DateTime from,
    int days,
  ) async =>
      const [];
}
