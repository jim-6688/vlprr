import 'package:flutter_test/flutter_test.dart';
import 'package:tail_limit/domain/entities/restriction_day.dart';
import 'package:tail_limit/domain/entities/restriction_verdict.dart';
import 'package:tail_limit/domain/entities/vehicle.dart';
import 'package:tail_limit/domain/services/restriction_evaluator.dart';
import 'package:tail_limit/domain/value_objects/restriction_type.dart';
import 'package:tail_limit/domain/value_objects/time_window.dart';

void main() {
  const evaluator = RestrictionEvaluator();

  RestrictionDay day({
    Set<int> tails = const {4, 9},
    bool isRestricted = true,
    bool nevExempt = true,
    bool nonLocalOnly = false,
    String abbr = '京',
    TailDigitRule rule = TailDigitRule.lastDigit,
    List<TimeWindow> windows = const [
      TimeWindow(startMinutes: 480, endMinutes: 1200)
    ],
  }) =>
      RestrictionDay(
        cityId: '110000',
        cityName: '北京',
        date: DateTime(2026, 10, 9),
        isRestrictedDay: isRestricted,
        restrictedTails: tails,
        timeWindows: windows,
        exemptsNewEnergy: nevExempt,
        appliesToNonLocalOnly: nonLocalOnly,
        cityProvinceAbbr: abbr,
        tailDigitRule: rule,
        source: 'mock',
        fetchedAt: DateTime(2026, 10, 9),
      );

  Vehicle vehicle(String plate, {String city = '110000'}) => Vehicle(
        id: 'v-$plate',
        plate: plate,
        boundCityId: city,
      );

  group('RestrictionEvaluator 优先级', () {
    test('周末/无措施日不限行，即使尾号命中', () {
      final v = evaluator.evaluate(
        vehicle: vehicle('京A12344'),
        day: day(isRestricted: false),
      );
      expect(v.kind, VerdictKind.notRestricted);
      expect(v.reasonText, VerdictText.noMeasure);
    });

    test('新能源豁免优先于尾号命中', () {
      final v = evaluator.evaluate(
        vehicle: vehicle('京AD12344'),
        day: day(),
      );
      expect(v.kind, VerdictKind.exemptNewEnergy);
    });

    test('新能源但政策不豁免时按尾号判定', () {
      final v = evaluator.evaluate(
        vehicle: vehicle('京AD12344'),
        day: day(nevExempt: false),
      );
      expect(v.kind, VerdictKind.restricted);
    });

    test('尾号命中判定受限', () {
      final v = evaluator.evaluate(
        vehicle: vehicle('京A88884'),
        day: day(),
      );
      expect(v.kind, VerdictKind.restricted);
      expect(v.windows.length, 1);
    });

    test('尾号未命中判定不限行', () {
      final v = evaluator.evaluate(
        vehicle: vehicle('京A12345'),
        day: day(),
      );
      expect(v.kind, VerdictKind.notRestricted);
      expect(v.reasonText, VerdictText.notRestricted);
    });

    test('末位字母牌按北京规则取前一位数字判定', () {
      final v = evaluator.evaluate(
        vehicle: vehicle('京A1234A'),
        day: day(rule: TailDigitRule.digitBeforeTrailingLetter),
      );
      // 前一位数字为 4，命中限行
      expect(v.kind, VerdictKind.restricted);
    });

    test('外牌区域限行：本地牌豁免', () {
      final v = evaluator.evaluate(
        vehicle: vehicle('沪A12345', city: '310000'),
        day: day(nonLocalOnly: true, abbr: '沪'),
      );
      expect(v.kind, VerdictKind.exemptLocalPlate);
    });

    test('外牌区域限行：非本地牌受限', () {
      final v = evaluator.evaluate(
        vehicle: vehicle('浙A12345', city: '310000'),
        day: day(nonLocalOnly: true, abbr: '沪'),
      );
      expect(v.kind, VerdictKind.restricted);
    });
  });

  group('evaluateAll', () {
    test('只判定绑定该城市的车辆', () {
      final verdicts = evaluator.evaluateAll(
        vehicles: [
          vehicle('京A88884'),
          vehicle('京A12345'),
          vehicle('沪A12345', city: '310000'),
        ],
        day: day(),
      );
      expect(verdicts.length, 2);
      expect(verdicts.first.isRestricted, isTrue);
    });
  });
}
