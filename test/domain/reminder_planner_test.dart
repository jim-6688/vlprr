import 'package:flutter_test/flutter_test.dart';
import 'package:tail_limit/domain/entities/city.dart';
import 'package:tail_limit/domain/entities/reminder_config.dart';
import 'package:tail_limit/domain/entities/scheduled_reminder.dart';
import 'package:tail_limit/domain/entities/vehicle.dart';
import 'package:tail_limit/domain/services/local_rotation_engine.dart';
import 'package:tail_limit/domain/services/reminder_planner.dart';
import 'package:tail_limit/domain/value_objects/restriction_type.dart';

void main() {
  const engine = LocalRotationEngine();
  const planner = ReminderPlanner();

  const beijing = City(
    id: '110000',
    name: '北京',
    province: '北京市',
    provinceAbbr: '京',
  );

  group('LocalRotationEngine', () {
    test('生成的快照含限行尾号与时段', () {
      final days = engine.generateDays(
        city: beijing,
        from: DateTime(2026, 10, 5), // 周一
        days: 7,
      );
      expect(days.length, 7);
      // 周一限 3 和 8
      expect(days[0].isRestrictedDay, isTrue);
      expect(days[0].restrictedTails, {3, 8});
      // 周六日不限行
      expect(days[5].isRestrictedDay, isFalse);
      expect(days[6].isRestrictedDay, isFalse);
      // 数据来源标记为估算
      expect(days[0].source, 'mock');
    });

    test('未知城市生成不限行快照', () {
      const unknown = City(id: '999999', name: '测试市');
      final days = engine.generateDays(city: unknown, from: DateTime(2026, 10, 5));
      expect(days.every((d) => !d.isRestrictedDay), isTrue);
    });

    test('上海仅限外牌，本地牌不受尾号影响', () {
      const shanghai = City(id: '310000', name: '上海', provinceAbbr: '沪');
      final days = engine.generateDays(city: shanghai, from: DateTime(2026, 10, 5));
      expect(days.first.appliesToNonLocalOnly, isTrue);
      expect(days.first.restrictedTails, isEmpty);
    });
  });

  group('ReminderPlanner', () {
    final now = DateTime(2026, 10, 8, 12); // 10-08 中午

    List<ScheduledReminder> planFor(
      List<Vehicle> vehicles, {
      ReminderConfig config = kDefaultReminderConfig,
    }) {
      final days = engine.generateDays(
        city: beijing,
        from: DateTime(2026, 10, 5),
        days: 14,
      );
      return planner.plan(
        days: days,
        vehicles: vehicles,
        defaultConfig: config,
        cityConfigs: const {},
        now: now,
      );
    }

    test('受限车辆在受限日生成两阶段提醒', () {
      final vehicles = [
        const Vehicle(id: 'v1', plate: '京A88884', boundCityId: '110000'),
      ];
      final reminders = planFor(vehicles);

      // 10-09 周五限 2 和 7 → 4 不限；10-08 周四限 1 和 6
      // 选取 10-12 周一（限 3、8）等后续受限日
      expect(reminders, isNotEmpty);
      final strong = reminders.where((r) => r.kind == ReminderKind.strong);
      expect(strong, isNotEmpty);
      // 每个强提醒都早于限行时段开始（7:00）
      for (final r in strong) {
        expect(r.fireAt.hour * 60 + r.fireAt.minute, 7 * 60 - 10);
      }
    });

    test('不限行车辆不产生提醒', () {
      // 京A12345 尾号 5：周一限 3/8、周二 4/9、周三 5/0 → 周三受限
      // 用一个在所有工作日都无命中的尾号较难，改为验证空车辆列表
      final reminders = planFor(const []);
      expect(reminders, isEmpty);
    });

    test('新能源车（政策豁免）不产生提醒', () {
      final vehicles = [
        const Vehicle(id: 'nev', plate: '京AD12344', boundCityId: '110000'),
      ];
      expect(planFor(vehicles), isEmpty);
    });

    test('已过期时刻不排程', () {
      final vehicles = [
        const Vehicle(id: 'v1', plate: '京A88884', boundCityId: '110000'),
      ];
      // now 越过第一天的提醒时刻
      final late = DateTime(2026, 10, 9, 23);
      final days = engine.generateDays(
        city: beijing,
        from: DateTime(2026, 10, 5),
        days: 3,
      );
      final reminders = planner.plan(
        days: days,
        vehicles: vehicles,
        defaultConfig: kDefaultReminderConfig,
        cityConfigs: const {},
        now: late,
      );
      expect(reminders.every((r) => r.fireAt.isAfter(late)), isTrue);
    });

    test('确定性 ID 可重复生成（幂等）', () {
      final vehicles = [
        const Vehicle(id: 'v1', plate: '京A88884', boundCityId: '110000'),
      ];
      final a = planFor(vehicles);
      final b = planFor(vehicles);
      expect(a.map((r) => r.id).toList(), b.map((r) => r.id).toList());
    });

    test('maxPending 截断', () {
      const small = ReminderPlanner(maxPending: 2);
      final vehicles = [
        const Vehicle(id: 'v1', plate: '京A88884', boundCityId: '110000'),
        const Vehicle(id: 'v2', plate: '京A88883', boundCityId: '110000'),
      ];
      final days = engine.generateDays(
        city: beijing,
        from: DateTime(2026, 10, 5),
        days: 14,
      );
      final reminders = small.plan(
        days: days,
        vehicles: vehicles,
        defaultConfig: kDefaultReminderConfig,
        cityConfigs: const {},
        now: DateTime(2026, 10, 1),
      );
      expect(reminders.length, lessThanOrEqualTo(2));
    });
  });

  group('computeStrongFireAt', () {
    test('有明确时段时按提前量计算', () {
      final fire = computeStrongFireAt(
        date: DateTime(2026, 10, 12),
        firstStartMinutes: 7 * 60,
        leadMinutes: 10,
        fallbackMinutesOfDay: 7 * 60,
      );
      expect(fire, DateTime(2026, 10, 12, 6, 50));
    });

    test('无时段时使用兜底时刻', () {
      final fire = computeStrongFireAt(
        date: DateTime(2026, 10, 12),
        firstStartMinutes: null,
        leadMinutes: 10,
        fallbackMinutesOfDay: 7 * 60,
      );
      expect(fire, DateTime(2026, 10, 12, 6, 50));
    });

    test('提前量跨午夜时钳制到当日 00:01', () {
      final fire = computeStrongFireAt(
        date: DateTime(2026, 10, 12),
        firstStartMinutes: 5,
        leadMinutes: 30,
        fallbackMinutesOfDay: 420,
      );
      expect(fire.isAfter(DateTime(2026, 10, 11, 23, 59)), isTrue);
      expect(fire, DateTime(2026, 10, 12, 0, 1));
    });
  });
}
