import '../value_objects/restriction_type.dart';
import '../value_objects/time_window.dart';

/// 限行日快照：某城市某天的限行措施（数据落库与 UI 消费的直接形态）。
///
/// 由数据源（API/Mock 规则引擎）产出；主键 (cityId, date)。
/// 设计为"自足快照"——判定与提醒不再需要回查政策详情。
class RestrictionDay {
  const RestrictionDay({
    required this.cityId,
    required this.date,
    required this.isRestrictedDay,
    this.restrictedTails = const {},
    this.timeWindows = const [],
    this.areaText = '',
    this.ruleText = '',
    this.type = RestrictionType.tailRotationByWeekday,
    this.appliesToNonLocalOnly = false,
    this.exemptsNewEnergy = false,
    this.tailDigitRule = TailDigitRule.lastDigit,
    this.cityProvinceAbbr = '',
    this.cityName = '',
    required this.source,
    required this.fetchedAt,
    this.expiresAt,
  });

  final String cityId;
  final String cityName;

  /// 归一化为本地零点的日期。
  final DateTime date;

  /// 当天是否执行限行措施（周末/节假日不限行为 false）。
  final bool isRestrictedDay;

  /// 当天限行的尾号集合。
  final Set<int> restrictedTails;

  /// 限行时段（空 = 全天）。
  final List<TimeWindow> timeWindows;

  /// 限行区域描述。
  final String areaText;

  /// 规则原文说明。
  final String ruleText;

  final RestrictionType type;

  /// 是否仅限非本地号牌。
  final bool appliesToNonLocalOnly;

  /// 新能源是否豁免（政策属性随快照下发）。
  final bool exemptsNewEnergy;

  final TailDigitRule tailDigitRule;

  final String cityProvinceAbbr;

  /// 数据来源标识：apispace / jisu / mock（估算）/ cache。
  final String source;

  final DateTime fetchedAt;

  /// 缓存过期时刻（回退链判定用）。
  final DateTime? expiresAt;

  /// 限行尾号展示，如"4 和 9"。
  String get tailsText {
    final sorted = restrictedTails.toList()..sort();
    return sorted.join(' 和 ');
  }

  /// 时段展示，如"7:00-20:00"；无时段（全天）返回"全天"。
  String get timeWindowText {
    if (timeWindows.isEmpty) return '全天';
    return timeWindows.map((w) => w.displayText).join('、');
  }

  /// 首个限行窗口开始分钟数（无窗口返回 null）。
  int? get firstStartMinutes =>
      timeWindows.isEmpty ? null : _minStart(timeWindows);

  static int _minStart(List<TimeWindow> ws) {
    var min = ws.first.startMinutes;
    for (final w in ws.skip(1)) {
      if (w.startMinutes < min) min = w.startMinutes;
    }
    return min;
  }

  /// ISO 日期 yyyy-MM-dd。
  String get dateIso =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  RestrictionDay copyWith({
    String? cityId,
    String? cityName,
    DateTime? date,
    bool? isRestrictedDay,
    Set<int>? restrictedTails,
    List<TimeWindow>? timeWindows,
    String? areaText,
    String? ruleText,
    RestrictionType? type,
    bool? appliesToNonLocalOnly,
    bool? exemptsNewEnergy,
    TailDigitRule? tailDigitRule,
    String? cityProvinceAbbr,
    String? source,
    DateTime? fetchedAt,
    DateTime? expiresAt,
  }) =>
      RestrictionDay(
        cityId: cityId ?? this.cityId,
        cityName: cityName ?? this.cityName,
        date: date ?? this.date,
        isRestrictedDay: isRestrictedDay ?? this.isRestrictedDay,
        restrictedTails: restrictedTails ?? this.restrictedTails,
        timeWindows: timeWindows ?? this.timeWindows,
        areaText: areaText ?? this.areaText,
        ruleText: ruleText ?? this.ruleText,
        type: type ?? this.type,
        appliesToNonLocalOnly: appliesToNonLocalOnly ?? this.appliesToNonLocalOnly,
        exemptsNewEnergy: exemptsNewEnergy ?? this.exemptsNewEnergy,
        tailDigitRule: tailDigitRule ?? this.tailDigitRule,
        cityProvinceAbbr: cityProvinceAbbr ?? this.cityProvinceAbbr,
        source: source ?? this.source,
        fetchedAt: fetchedAt ?? this.fetchedAt,
        expiresAt: expiresAt ?? this.expiresAt,
      );

  @override
  String toString() =>
      'RestrictionDay($cityId $dateIso restricted=$isRestrictedDay '
      'tails=$restrictedTails src=$source)';
}
