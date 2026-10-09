import '../value_objects/restriction_type.dart';

/// 车牌尾号值对象（0-9）。
class TailNumber {
  const TailNumber._(this.value) : assert(value >= 0 && value <= 9);

  final int value;

  static const List<TailNumber> all = [
    TailNumber._(0),
    TailNumber._(1),
    TailNumber._(2),
    TailNumber._(3),
    TailNumber._(4),
    TailNumber._(5),
    TailNumber._(6),
    TailNumber._(7),
    TailNumber._(8),
    TailNumber._(9),
  ];

  static TailNumber? tryFrom(int v) =>
      (v >= 0 && v <= 9) ? TailNumber._(v) : null;

  @override
  bool operator ==(Object other) =>
      other is TailNumber && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => '$value';
}

/// 从完整车牌号提取限行尾号。
///
/// 不同城市对"末位为字母"的处理不同，规则由政策下发（[rule]）：
/// - lastDigit：取最后一位数字（默认）
/// - digitBeforeTrailingLetter：末位为字母时取字母前一位数字（如北京）
/// - treatTrailingLetterAsZero：末位为字母时按 0 处理
TailNumber? extractTailNumber(String plate, TailDigitRule rule) {
  final normalized = _stripNonPlateChars(plate);
  if (normalized.length < 6) return null;

  final lastChar = normalized[normalized.length - 1];
  final lastIsDigit = _isDigit(lastChar);

  switch (rule) {
    case TailDigitRule.lastDigit:
      if (lastIsDigit) return TailNumber.tryFrom(int.parse(lastChar));
      // 无匹配数字规则时回退：向前找最后一位数字。
      return _lastDigitFallback(normalized);

    case TailDigitRule.digitBeforeTrailingLetter:
      if (lastIsDigit) return TailNumber.tryFrom(int.parse(lastChar));
      // 末位为字母：取前一位；若前一位也是字母（新能源牌），继续向前找数字。
      for (var i = normalized.length - 2; i >= 0; i--) {
        final c = normalized[i];
        if (_isDigit(c)) return TailNumber.tryFrom(int.parse(c));
      }
      return null;

    case TailDigitRule.treatTrailingLetterAsZero:
      if (lastIsDigit) return TailNumber.tryFrom(int.parse(lastChar));
      return const TailNumber._(0);
  }
}

/// 是否新能源号牌（绿牌）。
///
/// 判定规则（公安部 GA 36-2018 序号规范）：
/// - 小型新能源：省份+字母+6 位序号（总长 8），第 3 位（序号首位）为 D/F
/// - 大型新能源：总长 8，末位 D/F
bool isNewEnergyPlate(String plate) {
  final p = _stripNonPlateChars(plate);
  if (p.length < 7) return false;
  // 8 位号牌视为新能源候选，再校验 D/F 特征位。
  if (p.length == 8) {
    final body = p.substring(2);
    return body.startsWith('D') ||
        body.startsWith('F') ||
        body.endsWith('D') ||
        body.endsWith('F');
  }
  return false;
}

/// 判断是否本地号牌：省份简称与城市省份匹配。
/// [cityProvinceAbbr] 为城市所属省份简称（如京/沪/粤），空串表示无法判定。
bool isLocalPlate(String plate, String cityProvinceAbbr) {
  if (cityProvinceAbbr.isEmpty || plate.isEmpty) return false;
  return plate.trim().startsWith(cityProvinceAbbr);
}

bool _isDigit(String c) => RegExp(r'^\d$').hasMatch(c);

TailNumber? _lastDigitFallback(String s) {
  for (var i = s.length - 1; i >= 0; i--) {
    if (_isDigit(s[i])) return TailNumber.tryFrom(int.parse(s[i]));
  }
  return null;
}

String _stripNonPlateChars(String plate) {
  // 保留汉字（省份简称）与字母数字；去除点、空格、连接符等。
  return plate.replaceAll(RegExp(r'[^\u4e00-\u9fa5A-Za-z0-9]'), '').toUpperCase();
}
