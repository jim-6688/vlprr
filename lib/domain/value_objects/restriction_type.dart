/// 限行措施类型。
///
/// 覆盖国内主流城市的限行政策形态：
/// - 尾号轮换（北京、天津、成都、西安、郑州等绝大多数城市）
/// - 非本地号牌区域限行（上海外牌、北京进京证、深圳非深牌高峰限行）
/// - 全号段禁行（特殊日单双号、重污染天气应急等，MVP 预留）
enum RestrictionType {
  /// 尾号轮换限行：按星期几轮换限行尾号（如"周一限 3 和 8"）。
  tailRotationByWeekday,

  /// 非本地号牌区域限行：本地牌不受限，外地牌在指定时段/区域禁行。
  areaBanForNonLocal,

  /// 全号段禁行 / 单双号等特殊措施（扩展位）。
  fullBan,
}

/// 车牌尾号提取规则。
///
/// 不同城市对"末位为字母"的处理存在差异，该规则作为政策属性随数据下发，
/// 不在代码中硬编码某个城市的行为：
/// - [lastDigit]：取车牌号中最后一位数字（默认，绝大多数城市）
/// - [digitBeforeTrailingLetter]：末位为字母时取字母前一位数字（如北京对字母尾牌的处理）
/// - [treatTrailingLetterAsZero]：末位为字母时按 0 处理（少数城市历史规则）
enum TailDigitRule {
  lastDigit,
  digitBeforeTrailingLetter,
  treatTrailingLetterAsZero,
}

/// 政策豁免类型。
enum Exemption {
  /// 新能源（绿牌）车辆豁免限行（政策属性，由城市决定，非全局硬编码）。
  newEnergy,

  /// 仅豁免本地新能源车。
  localNewEnergy,
}

/// 提醒阶段类型。
enum ReminderKind {
  /// T-1 前一日预告提醒（普通通知级）。
  preview,

  /// 限号当日强提醒（全屏通知 + 语音播报）。
  strong,
}
