import '../value_objects/restriction_type.dart';
import '../value_objects/time_window.dart';

/// 限行政策实体：城市维度的完整规则描述。
///
/// 由数据源（API/Mock）产出，用于本地规则引擎生成 [RestrictionDay] 快照。
class RestrictionPolicy {
  const RestrictionPolicy({
    required this.cityId,
    required this.cityName,
    required this.type,
    required this.weekdayTails,
    this.timeWindows = const [],
    this.areaText = '',
    this.ruleText = '',
    this.exemptions = const {},
    this.appliesToNonLocalOnly = false,
    this.tailDigitRule = TailDigitRule.lastDigit,
    this.effectiveFrom,
    this.effectiveUntil,
    this.cityProvinceAbbr = '',
  });

  /// 城市行政区码（如 110000 北京）。
  final String cityId;

  final String cityName;

  final RestrictionType type;

  /// 星期 → 限行尾号集合。weekday 取 DateTime.monday(1)..sunday(7)。
  /// 例：{1: {3,8}, 2: {4,9}, ...} 为北京某轮换周期。
  final Map<int, Set<int>> weekdayTails;

  /// 限行时段（空 = 全天）。
  final List<TimeWindow> timeWindows;

  /// 限行区域描述文本。
  final String areaText;

  /// 规则原文说明（展示用）。
  final String ruleText;

  /// 豁免类型集合（新能源豁免是政策属性）。
  final Set<Exemption> exemptions;

  /// 是否仅针对非本地号牌（上海外牌、深圳非深牌等）。
  final bool appliesToNonLocalOnly;

  /// 尾号提取规则。
  final TailDigitRule tailDigitRule;

  /// 轮换周期起止（尾号轮换城市会定期调换星期-尾号映射）。
  final DateTime? effectiveFrom;
  final DateTime? effectiveUntil;

  /// 城市所属省份简称（本地牌判定）。
  final String cityProvinceAbbr;

  /// 该政策在 [date] 是否生效（轮换周期判定）。
  bool isEffectiveOn(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    if (effectiveFrom != null && d.isBefore(_day(effectiveFrom!))) return false;
    if (effectiveUntil != null && d.isAfter(_day(effectiveUntil!))) return false;
    return true;
  }

  /// 该政策是否豁免新能源车。
  bool get exemptsNewEnergy =>
      exemptions.contains(Exemption.newEnergy) ||
      exemptions.contains(Exemption.localNewEnergy);

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  RestrictionPolicy copyWith({
    String? cityId,
    String? cityName,
    RestrictionType? type,
    Map<int, Set<int>>? weekdayTails,
    List<TimeWindow>? timeWindows,
    String? areaText,
    String? ruleText,
    Set<Exemption>? exemptions,
    bool? appliesToNonLocalOnly,
    TailDigitRule? tailDigitRule,
    DateTime? effectiveFrom,
    DateTime? effectiveUntil,
    String? cityProvinceAbbr,
  }) =>
      RestrictionPolicy(
        cityId: cityId ?? this.cityId,
        cityName: cityName ?? this.cityName,
        type: type ?? this.type,
        weekdayTails: weekdayTails ?? this.weekdayTails,
        timeWindows: timeWindows ?? this.timeWindows,
        areaText: areaText ?? this.areaText,
        ruleText: ruleText ?? this.ruleText,
        exemptions: exemptions ?? this.exemptions,
        appliesToNonLocalOnly:
            appliesToNonLocalOnly ?? this.appliesToNonLocalOnly,
        tailDigitRule: tailDigitRule ?? this.tailDigitRule,
        effectiveFrom: effectiveFrom ?? this.effectiveFrom,
        effectiveUntil: effectiveUntil ?? this.effectiveUntil,
        cityProvinceAbbr: cityProvinceAbbr ?? this.cityProvinceAbbr,
      );
}
