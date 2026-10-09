import '../entities/city.dart';
import '../entities/restriction_day.dart';
import '../entities/restriction_policy.dart';
import '../value_objects/restriction_type.dart';
import '../value_objects/time_window.dart';

/// 本地尾号轮换规则引擎：Mock 数据源的底层。
///
/// 内置主要限行城市的政策常量表，按星期生成未来 N 天的 RestrictionDay 快照。
///
/// ⚠️ 数据诚实性：本地引擎产出为**估算数据**（source='mock'），
/// 轮换周期映射可能滞后于官方调整；UI 必须展示来源徽章。
/// MVP 不内置法定节假日调休表：周末一律按不限行处理。
class LocalRotationEngine {
  const LocalRotationEngine();

  /// 内置城市政策表。
  static const Map<String, RestrictionPolicy> policies = {
    // 北京：尾号轮换，末位字母按前一位数字，新能源豁免
    '110000': RestrictionPolicy(
      cityId: '110000',
      cityName: '北京',
      type: RestrictionType.tailRotationByWeekday,
      weekdayTails: {1: {3, 8}, 2: {4, 9}, 3: {5, 0}, 4: {1, 6}, 5: {2, 7}},
      timeWindows: [TimeWindow(startMinutes: 7 * 60, endMinutes: 20 * 60)],
      areaText: '五环路（不含）以内道路',
      ruleText: '工作日 7:00-20:00 尾号轮换限行，新能源号牌不限行',
      exemptions: {Exemption.newEnergy},
      tailDigitRule: TailDigitRule.digitBeforeTrailingLetter,
      cityProvinceAbbr: '京',
    ),
    // 天津：与北京同周期轮换
    '120000': RestrictionPolicy(
      cityId: '120000',
      cityName: '天津',
      type: RestrictionType.tailRotationByWeekday,
      weekdayTails: {1: {3, 8}, 2: {4, 9}, 3: {5, 0}, 4: {1, 6}, 5: {2, 7}},
      timeWindows: [TimeWindow(startMinutes: 7 * 60, endMinutes: 19 * 60)],
      areaText: '外环线（不含）以内道路',
      ruleText: '工作日 7:00-19:00 尾号轮换限行，新能源号牌不限行',
      exemptions: {Exemption.newEnergy},
      cityProvinceAbbr: '津',
    ),
    // 成都
    '510100': RestrictionPolicy(
      cityId: '510100',
      cityName: '成都',
      type: RestrictionType.tailRotationByWeekday,
      weekdayTails: {1: {1, 6}, 2: {2, 7}, 3: {3, 8}, 4: {4, 9}, 5: {5, 0}},
      timeWindows: [TimeWindow(startMinutes: 7 * 60 + 30, endMinutes: 20 * 60)],
      areaText: '四环路（成都绕城高速，不含）以内区域道路',
      ruleText: '工作日 7:30-20:00 尾号轮换限行，新能源车不限行',
      exemptions: {Exemption.newEnergy},
      cityProvinceAbbr: '川',
    ),
    // 杭州：本地牌错峰限行
    '330100': RestrictionPolicy(
      cityId: '330100',
      cityName: '杭州',
      type: RestrictionType.tailRotationByWeekday,
      weekdayTails: {1: {1, 9}, 2: {2, 8}, 3: {3, 7}, 4: {4, 6}, 5: {5, 0}},
      timeWindows: [
        TimeWindow(startMinutes: 7 * 60, endMinutes: 9 * 60),
        TimeWindow(startMinutes: 16 * 60 + 30, endMinutes: 18 * 60 + 30),
      ],
      areaText: '错峰限行区域（留祥路—石祥路—石桥路—秋涛路等围合区域及高架）',
      ruleText: '工作日早 7:00-9:00、晚 16:30-18:30 错峰限行',
      exemptions: {Exemption.newEnergy},
      cityProvinceAbbr: '浙',
    ),
    // 西安
    '610100': RestrictionPolicy(
      cityId: '610100',
      cityName: '西安',
      type: RestrictionType.tailRotationByWeekday,
      weekdayTails: {1: {1, 6}, 2: {2, 7}, 3: {3, 8}, 4: {4, 9}, 5: {5, 0}},
      timeWindows: [TimeWindow(startMinutes: 7 * 60, endMinutes: 20 * 60)],
      areaText: '以绕城高速以内区域为目标区域（含穿城高速）',
      ruleText: '工作日 7:00-20:00 尾号轮换限行，新能源车不限行',
      exemptions: {Exemption.newEnergy},
      cityProvinceAbbr: '陕',
    ),
    // 郑州
    '410100': RestrictionPolicy(
      cityId: '410100',
      cityName: '郑州',
      type: RestrictionType.tailRotationByWeekday,
      weekdayTails: {1: {1, 6}, 2: {2, 7}, 3: {3, 8}, 4: {4, 9}, 5: {5, 0}},
      timeWindows: [TimeWindow(startMinutes: 7 * 60, endMinutes: 21 * 60)],
      areaText: '三环以内区域道路',
      ruleText: '工作日 7:00-21:00 尾号轮换限行，新能源车不限行',
      exemptions: {Exemption.newEnergy},
      cityProvinceAbbr: '豫',
    ),
    // 上海：外牌区域限行（本地牌不限）
    '310000': RestrictionPolicy(
      cityId: '310000',
      cityName: '上海',
      type: RestrictionType.areaBanForNonLocal,
      weekdayTails: {},
      timeWindows: [TimeWindow(startMinutes: 7 * 60, endMinutes: 20 * 60)],
      areaText: '内环内地面道路及部分高架（工作日）',
      ruleText: '工作日 7:00-20:00 禁止悬挂外省市号牌小客车通行',
      appliesToNonLocalOnly: true,
      cityProvinceAbbr: '沪',
    ),
    // 深圳：非深牌高峰限行
    '440300': RestrictionPolicy(
      cityId: '440300',
      cityName: '深圳',
      type: RestrictionType.areaBanForNonLocal,
      weekdayTails: {},
      timeWindows: [
        TimeWindow(startMinutes: 7 * 60, endMinutes: 9 * 60),
        TimeWindow(startMinutes: 17 * 60 + 30, endMinutes: 19 * 60 + 30),
      ],
      areaText: '全市道路（部分高速及口岸路线除外）',
      ruleText: '工作日早晚高峰（7:00-9:00、17:30-19:30）限制非深圳号牌',
      appliesToNonLocalOnly: true,
      cityProvinceAbbr: '粤',
    ),
    // 石家庄
    '130100': RestrictionPolicy(
      cityId: '130100',
      cityName: '石家庄',
      type: RestrictionType.tailRotationByWeekday,
      weekdayTails: {1: {2, 7}, 2: {3, 8}, 3: {4, 9}, 4: {5, 0}, 5: {1, 6}},
      timeWindows: [TimeWindow(startMinutes: 7 * 60, endMinutes: 19 * 60)],
      areaText: '三环路（含）以内道路',
      ruleText: '工作日 7:00-19:00 尾号轮换限行',
      exemptions: {Exemption.newEnergy},
      cityProvinceAbbr: '冀',
    ),
    // 太原
    '140100': RestrictionPolicy(
      cityId: '140100',
      cityName: '太原',
      type: RestrictionType.tailRotationByWeekday,
      weekdayTails: {1: {1, 6}, 2: {2, 7}, 3: {3, 8}, 4: {4, 9}, 5: {5, 0}},
      timeWindows: [TimeWindow(startMinutes: 7 * 60, endMinutes: 20 * 60)],
      areaText: '东环高速以西、西环高速以东等围合区域',
      ruleText: '工作日 7:00-20:00 尾号轮换限行',
      exemptions: {Exemption.newEnergy},
      cityProvinceAbbr: '晋',
    ),
    // 兰州
    '620100': RestrictionPolicy(
      cityId: '620100',
      cityName: '兰州',
      type: RestrictionType.tailRotationByWeekday,
      weekdayTails: {1: {1, 6}, 2: {2, 7}, 3: {3, 8}, 4: {4, 9}, 5: {5, 0}},
      timeWindows: [TimeWindow(startMinutes: 7 * 60 + 30, endMinutes: 19 * 60 + 30)],
      areaText: '城关区、七里河区部分区域',
      ruleText: '工作日 7:30-19:30 尾号轮换限行',
      exemptions: {Exemption.newEnergy},
      cityProvinceAbbr: '甘',
    ),
  };

  /// 政策存在但当前不执行轮换限行的城市（展示说明）。
  static const Map<String, String> noMeasureNotes = {
    '440100': '广州实行"开四停四"管理，规则复杂，请以官方通告为准',
    '420100': '武汉长江大桥/江汉桥实行单双号通行，请以交管发布为准',
    '220100': '长春当前无限行措施',
    '230100': '哈尔滨当前无限行措施',
    '360100': '南昌当前无限行措施',
    '520100': '贵阳当前无限行措施',
  };

  /// 获取城市政策（不存在返回 null）。
  RestrictionPolicy? getPolicy(String cityId) => policies[cityId];

  /// 生成 [from] 起 [days] 天的快照列表。
  List<RestrictionDay> generateDays({
    required City city,
    required DateTime from,
    int days = 14,
  }) {
    final policy = policies[city.id];
    if (policy == null) {
      return List.generate(days, (i) {
        final date = _day(from).add(Duration(days: i));
        return RestrictionDay(
          cityId: city.id,
          cityName: city.name,
          date: date,
          isRestrictedDay: false,
          ruleText: noMeasureNotes[city.id] ?? '暂无该城市限行数据（估算）',
          source: 'mock',
          fetchedAt: DateTime.now(),
        );
      });
    }

    return List.generate(days, (i) {
      final date = _day(from).add(Duration(days: i));
      final weekday = date.weekday; // 1=Mon .. 7=Sun
      final tails = policy.weekdayTails[weekday] ?? const <int>{};
      final isWeekend = weekday == DateTime.saturday || weekday == DateTime.sunday;

      return RestrictionDay(
        cityId: city.id,
        cityName: city.name,
        date: date,
        isRestrictedDay: tails.isNotEmpty && !isWeekend,
        restrictedTails: isWeekend ? const <int>{} : tails,
        timeWindows: policy.timeWindows,
        areaText: policy.areaText,
        ruleText: isWeekend ? '周末不限行（估算）' : policy.ruleText,
        type: policy.type,
        appliesToNonLocalOnly: policy.appliesToNonLocalOnly,
        exemptsNewEnergy: policy.exemptsNewEnergy,
        tailDigitRule: policy.tailDigitRule,
        cityProvinceAbbr: policy.cityProvinceAbbr,
        source: 'mock',
        fetchedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      );
    });
  }

  /// 数据源支持的城市列表。
  List<City> supportedCities() => kKnownRestrictionCities;

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);
}
