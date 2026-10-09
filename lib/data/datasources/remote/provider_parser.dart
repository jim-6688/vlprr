import '../../../domain/entities/city.dart';
import '../../../domain/entities/restriction_day.dart';
import '../../../domain/value_objects/restriction_type.dart';
import '../../../domain/value_objects/time_window.dart';

/// 第三方数据源响应解析器（纯函数，便于用录制 fixture 离线单测）。
///
/// 各供应商返回结构差异较大，全部收敛在此文件，
/// 数据源实现只负责网络请求与错误转换。
class ProviderParser {
  const ProviderParser._();

  static String isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  // ==================== APISpace ====================

  /// APISpace 城市列表：
  /// {"status":0,"msg":"ok","result":[{"areacode":"110000","cityname":"北京",...}]}
  static List<City> parseApispaceCities(Map<String, Object?> json) {
    final result = json['result'];
    final list = _asList(result) ?? _asList(json['data']) ?? const [];
    return list
        .whereType<Map>()
        .map((e) {
          final m = e.cast<String, Object?>();
          final code = _str(m, ['areacode', 'areaCode', 'code', 'cityid']) ?? '';
          final name = _str(m, ['cityname', 'cityName', 'name', 'city']) ?? '';
          return City(
            id: code,
            name: _stripSuffix(name),
            province: _str(m, ['province', 'provincename']) ?? '',
            provinceAbbr: _abbrOf(name, _str(m, ['province', 'provincename'])),
          );
        })
        .where((c) => c.id.isNotEmpty && c.name.isNotEmpty)
        .toList();
  }

  /// APISpace 单日限行：
  /// {"status":0,"result":{"city":"beijing","cityname":"北京","date":"2026-08-22",
  ///  "week":"星期六","time":["07:00-20:00"],"area":"...","summary":"...","number":"4和6",
  ///  "numberrule":"最后一位数字"}}
  static RestrictionDay? parseApispaceDay(
    Map<String, Object?> json,
    City city,
    DateTime date,
  ) {
    final result = json['result'];
    final m = result is Map ? result.cast<String, Object?>() : json;

    final tails = _parseTails(_str(m, ['number', 'tailnumber', 'limitednumber']) ?? '');
    final windows = _parseWindows(m['time']);
    final areaText = _str(m, ['area', 'areatext', 'zone']) ?? '';
    final ruleText = _str(m, ['summary', 'rule', 'remark', 'ruletext']) ?? '';
    final ruleName = _str(m, ['numberrule', 'numrule']) ?? '';

    // 周末/法定节假日：API 返回 number 为空且无区域限行描述时视为不限行
    final isRestricted = tails.isNotEmpty;
    final nonLocalOnly = _inferNonLocalOnly(ruleText, areaText, tails);

    return RestrictionDay(
      cityId: city.id,
      cityName: city.name,
      date: DateTime(date.year, date.month, date.day),
      isRestrictedDay: isRestricted,
      restrictedTails: tails,
      timeWindows: windows,
      areaText: areaText,
      ruleText: ruleText.isEmpty ? '来自 APISpace 的限行数据' : ruleText,
      type: inferType(tails: tails, nonLocalOnly: nonLocalOnly),
      appliesToNonLocalOnly: nonLocalOnly,
      exemptsNewEnergy: _inferNevExempt(ruleText),
      tailDigitRule: _ruleFromText(ruleName),
      cityProvinceAbbr: city.provinceAbbr,
      source: 'apispace',
      fetchedAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 12)),
    );
  }

  // ==================== 极速数据 ====================

  /// 极速数据城市列表：
  /// {"status":0,"result":[{"city":"beijing","cityname":"北京"}]}
  static List<City> parseJisuCities(Map<String, Object?> json) {
    final list = _asList(json['result']) ?? _asList(json['data']) ?? const [];
    return list
        .whereType<Map>()
        .map((e) {
          final m = e.cast<String, Object?>();
          final name = _str(m, ['cityname', 'name', 'city']) ?? '';
          final code = _str(m, ['citycode', 'code', 'city']) ?? '';
          return City(
            id: code,
            name: _stripSuffix(name),
            province: _str(m, ['province']) ?? '',
            provinceAbbr: _abbrOf(name, _str(m, ['province'])),
          );
        })
        .where((c) => c.name.isNotEmpty)
        .toList();
  }

  /// 极速数据单日限行：
  /// {"status":0,"result":{"city":"beijing","cityname":"北京","date":"2026-08-22",
  ///  "week":"星期六","time":["07:00-20:00"],"area":"...","summary":"...","number":"4和6"}}
  static RestrictionDay? parseJisuDay(
    Map<String, Object?> json,
    City city,
    DateTime date,
  ) {
    final result = json['result'];
    if (result is! Map) return null;
    final m = result.cast<String, Object?>();

    final tails = _parseTails(_str(m, ['number', 'tailnumber']) ?? '');
    final windows = _parseWindows(m['time']);
    final areaText = _str(m, ['area', 'areatext']) ?? '';
    final ruleText = _str(m, ['summary', 'remark', 'rule']) ?? '';

    final nonLocalOnly = _inferNonLocalOnly(ruleText, areaText, tails);

    return RestrictionDay(
      cityId: city.id.isEmpty ? (_str(m, ['city']) ?? city.id) : city.id,
      cityName: city.name,
      date: DateTime(date.year, date.month, date.day),
      isRestrictedDay: tails.isNotEmpty,
      restrictedTails: tails,
      timeWindows: windows,
      areaText: areaText,
      ruleText: ruleText.isEmpty ? '来自极速数据的限行数据' : ruleText,
      type: inferType(tails: tails, nonLocalOnly: nonLocalOnly),
      appliesToNonLocalOnly: nonLocalOnly,
      exemptsNewEnergy: _inferNevExempt(ruleText),
      cityProvinceAbbr: city.provinceAbbr,
      source: 'jisu',
      fetchedAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 12)),
    );
  }

  /// 单日数据按"星期→尾号"轮换关系递推出后续 days 天。
  ///
  /// 依据：多数城市尾号轮换周期内，同一星期几的限行尾号固定不变。
  /// 产出标注为 estimated 语义（沿用来源标识 + 规则文本注明"递推"）。
  static List<RestrictionDay> expandByWeekdayRotation(
    RestrictionDay seed,
    int days,
  ) {
    final out = <RestrictionDay>[];
    for (var i = 0; i < days; i++) {
      final date = seed.date.add(Duration(days: i));
      final isWeekend =
          date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
      out.add(seed.copyWith(
        date: date,
        isRestrictedDay: isWeekend ? false : seed.isRestrictedDay,
        restrictedTails: isWeekend ? const <int>{} : seed.restrictedTails,
        ruleText: i == 0
            ? seed.ruleText
            : '${seed.ruleText}（按轮换周期递推）',
      ));
    }
    return out;
  }

  // ==================== 内部工具 ====================

  static List<dynamic>? _asList(Object? v) => v is List ? v : null;

  static String? _str(Map<String, Object?> m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
      if (v is num) return v.toString();
    }
    return null;
  }

  /// 解析尾号文本：支持 "4和6" / "4 和 9" / "4,6" / "4、6" / "单号" / "双号"。
  static Set<int> _parseTails(String raw) {
    final text = raw.trim();
    if (text.isEmpty || text == '-') return <int>{};
    if (text.contains('单号')) return {1, 3, 5, 7, 9};
    if (text.contains('双号')) return {0, 2, 4, 6, 8};

    final out = <int>{};
    for (final match in RegExp(r'\d').allMatches(text)) {
      final v = int.tryParse(match.group(0)!);
      if (v != null) out.add(v);
    }
    return out;
  }

  /// 解析时段：["07:00-20:00"] 或 "07:00-20:00" 或 ["07:00-09:00","16:30-18:30"]
  static List<TimeWindow> _parseWindows(Object? raw) {
    final out = <TimeWindow>[];
    if (raw is String) {
      final w = TimeWindow.tryParse(raw);
      if (w != null) out.add(w);
    } else if (raw is List) {
      for (final item in raw) {
        if (item is String) {
          final w = TimeWindow.tryParse(item);
          if (w != null) out.add(w);
        }
      }
    }
    return out;
  }

  /// 是否为"仅非本地号牌限行"（区域限行）。
  static bool _inferNonLocalOnly(
    String ruleText,
    String areaText,
    Set<int> tails,
  ) {
    if (tails.isNotEmpty) return false;
    final text = '$ruleText$areaText';
    return text.contains('外地') ||
        text.contains('外省市') ||
        text.contains('非本市') ||
        text.contains('非深圳') ||
        text.contains('外埠');
  }

  /// 是否豁免新能源。
  static bool _inferNevExempt(String ruleText) {
    if (ruleText.isEmpty) return true; // 大多数限行城市豁免新能源，保守取 true 需规则文本佐证
    return ruleText.contains('新能源') &&
        !ruleText.contains('新能源车除外不予豁免');
  }

  /// 尾号规则文本 → 尾号提取规则。
  static TailDigitRule _ruleFromText(String ruleName) {
    if (ruleName.contains('字母')) return TailDigitRule.digitBeforeTrailingLetter;
    if (ruleName.contains('最后一位数字')) return TailDigitRule.lastDigit;
    return TailDigitRule.lastDigit;
  }

  /// 省份简称推导（由城市名 / 省份名）。
  static String _abbrOf(String cityName, String? province) {
    const dict = {
      '北京': '京', '天津': '津', '上海': '沪', '重庆': '渝',
      '石家庄': '冀', '太原': '晋', '呼和浩特': '蒙', '沈阳': '辽',
      '长春': '吉', '哈尔滨': '黑', '南京': '苏', '杭州': '浙',
      '合肥': '皖', '福州': '闽', '南昌': '赣', '济南': '鲁',
      '郑州': '豫', '武汉': '鄂', '长沙': '湘', '广州': '粤',
      '深圳': '粤', '南宁': '桂', '海口': '琼', '成都': '川',
      '贵阳': '贵', '昆明': '云', '拉萨': '藏', '西安': '陕',
      '兰州': '甘', '西宁': '青', '银川': '宁', '乌鲁木齐': '新',
    };
    for (final entry in dict.entries) {
      if (cityName.contains(entry.key)) return entry.value;
    }
    if (province != null) {
      for (final entry in dict.entries) {
        if (province.contains(entry.key)) return entry.value;
      }
    }
    return '';
  }

  /// 去掉"市"后缀便于展示。
  static String _stripSuffix(String name) {
    var n = name.trim();
    if (n.endsWith('市') && n.length > 2) n = n.substring(0, n.length - 1);
    return n;
  }
}

/// 尾号文本解析（导出供数据源复用）。
Set<int> parseTails(String raw) {
  final text = raw.trim();
  if (text.isEmpty || text == '-') return <int>{};
  if (text.contains('单号')) return {1, 3, 5, 7, 9};
  if (text.contains('双号')) return {0, 2, 4, 6, 8};
  final out = <int>{};
  for (final match in RegExp(r'\d').allMatches(text)) {
    final v = int.tryParse(match.group(0)!);
    if (v != null) out.add(v);
  }
  return out;
}

/// 限行类型推断。
RestrictionType inferType({
  required Set<int> tails,
  required bool nonLocalOnly,
}) {
  if (nonLocalOnly && tails.isEmpty) return RestrictionType.areaBanForNonLocal;
  return RestrictionType.tailRotationByWeekday;
}
