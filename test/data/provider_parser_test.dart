import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tail_limit/data/datasources/remote/provider_parser.dart';
import 'package:tail_limit/domain/entities/city.dart';
import 'package:tail_limit/domain/value_objects/restriction_type.dart';

/// 真实供应商响应样本（fixture）。
/// 结构依据 APISpace / 极速数据官方文档返回示例。
const String apispaceCityFixture = '''
{
  "status": 0,
  "msg": "ok",
  "result": [
    {"areacode": "110000", "cityname": "北京市", "province": "北京市"},
    {"areacode": "510100", "cityname": "成都市", "province": "四川省"},
    {"areacode": "310000", "cityname": "上海市", "province": "上海市"}
  ]
}
''';

const String apispaceDayFixture = '''
{
  "status": 0,
  "msg": "ok",
  "result": {
    "city": "beijing",
    "cityname": "北京",
    "date": "2026-10-12",
    "week": "星期一",
    "time": ["07:00-20:00"],
    "area": "五环路（不含）以内道路",
    "summary": "对进入限行区域的客车实行尾号限行，新能源车不限行",
    "numberrule": "最后一位数字",
    "number": "3和8"
  }
}
''';

const String jisuCityFixture = '''
{
  "status": 0,
  "msg": "ok",
  "result": [
    {"city": "beijing", "cityname": "北京"},
    {"city": "chengdu", "cityname": "成都"},
    {"city": "hangzhou", "cityname": "杭州"}
  ]
}
''';

const String jisuDayFixture = '''
{
  "status": 0,
  "msg": "ok",
  "result": {
    "city": "hangzhou",
    "cityname": "杭州",
    "date": "2026-10-13",
    "week": "星期二",
    "time": ["07:00-09:00", "16:30-18:30"],
    "area": "错峰限行区域",
    "summary": "本市号牌尾号限行，外地号牌全部限行",
    "numberrule": "最后一位数字",
    "number": "2和8"
  }
}
''';

const String nonLocalOnlyFixture = '''
{
  "status": 0,
  "result": {
    "city": "shanghai",
    "cityname": "上海",
    "date": "2026-10-13",
    "week": "星期二",
    "time": ["07:00-20:00"],
    "area": "内环内地面道路",
    "summary": "工作日禁止悬挂外省市号牌小客车通行",
    "number": ""
  }
}
''';

void main() {
  group('APISpace 解析', () {
    test('城市列表解析（去"市"后缀 + 省份简称推导）', () {
      final json = jsonDecode(apispaceCityFixture) as Map<String, Object?>;
      final cities = ProviderParser.parseApispaceCities(json);

      expect(cities.length, 3);
      expect(cities[0].id, '110000');
      expect(cities[0].name, '北京');
      expect(cities[0].provinceAbbr, '京');
      expect(cities[1].name, '成都');
      expect(cities[1].provinceAbbr, '川');
    });

    test('单日限行解析（尾号 + 时段 + 区域 + 新能源豁免）', () {
      final json = jsonDecode(apispaceDayFixture) as Map<String, Object?>;
      final day = ProviderParser.parseApispaceDay(
        json,
        const City(id: '110000', name: '北京', provinceAbbr: '京'),
        DateTime(2026, 10, 12),
      );

      expect(day, isNotNull);
      expect(day!.isRestrictedDay, isTrue);
      expect(day.restrictedTails, {3, 8});
      expect(day.timeWindows.length, 1);
      expect(day.timeWindows.first.displayText, '7:00-20:00');
      expect(day.areaText, contains('五环路'));
      expect(day.exemptsNewEnergy, isTrue);
      expect(day.source, 'apispace');
      expect(day.type, RestrictionType.tailRotationByWeekday);
      expect(day.tailsText, '3 和 8');
    });

    test('外牌区域限行识别（尾号为空 + 含"外省市"）', () {
      final json = jsonDecode(nonLocalOnlyFixture) as Map<String, Object?>;
      final day = ProviderParser.parseApispaceDay(
        json,
        const City(id: '310000', name: '上海', provinceAbbr: '沪'),
        DateTime(2026, 10, 13),
      );

      expect(day!.appliesToNonLocalOnly, isTrue);
      expect(day.type, RestrictionType.areaBanForNonLocal);
      expect(day.restrictedTails, isEmpty);
    });
  });

  group('极速数据解析', () {
    test('城市列表解析', () {
      final json = jsonDecode(jisuCityFixture) as Map<String, Object?>;
      final cities = ProviderParser.parseJisuCities(json);
      expect(cities.length, 3);
      expect(cities[0].name, '北京');
      expect(cities[2].name, '杭州');
    });

    test('单日多时段解析（杭州错峰）', () {
      final json = jsonDecode(jisuDayFixture) as Map<String, Object?>;
      final day = ProviderParser.parseJisuDay(
        json,
        const City(id: '330100', name: '杭州', provinceAbbr: '浙'),
        DateTime(2026, 10, 13),
      );

      expect(day!.restrictedTails, {2, 8});
      expect(day.timeWindows.length, 2);
      expect(day.timeWindows[0].displayText, '7:00-9:00');
      expect(day.timeWindows[1].displayText, '16:30-18:30');
      expect(day.source, 'jisu');
    });

    test('按星期递推扩展多日', () {
      final json = jsonDecode(jisuDayFixture) as Map<String, Object?>;
      final seed = ProviderParser.parseJisuDay(
        json,
        const City(id: '330100', name: '杭州'),
        DateTime(2026, 10, 12), // 周一
      )!;

      final days = ProviderParser.expandByWeekdayRotation(seed, 7);
      expect(days.length, 7);
      // 工作日保持限行尾号
      expect(days[0].restrictedTails, {2, 8});
      // 周末不限行
      expect(days[5].isRestrictedDay, isFalse);
      expect(days[5].restrictedTails, isEmpty);
      // 递推标注
      expect(days[1].ruleText, contains('递推'));
    });
  });

  group('尾号文本解析边界', () {
    test('多种分隔符', () {
      expect(parseTails('4和9'), {4, 9});
      expect(parseTails('4 和 9'), {4, 9});
      expect(parseTails('4,9'), {4, 9});
      expect(parseTails('4、9'), {4, 9});
      expect(parseTails('4/9'), {4, 9});
    });

    test('单双号', () {
      expect(parseTails('单号'), {1, 3, 5, 7, 9});
      expect(parseTails('双号'), {0, 2, 4, 6, 8});
    });

    test('空值与占位符', () {
      expect(parseTails(''), isEmpty);
      expect(parseTails('-'), isEmpty);
    });
  });

  group('类型推断', () {
    test('有尾号 → 尾号轮换', () {
      expect(
        inferType(tails: {1, 2}, nonLocalOnly: false),
        RestrictionType.tailRotationByWeekday,
      );
    });

    test('无尾号且仅外牌 → 区域限行', () {
      expect(
        inferType(tails: {}, nonLocalOnly: true),
        RestrictionType.areaBanForNonLocal,
      );
    });
  });
}
