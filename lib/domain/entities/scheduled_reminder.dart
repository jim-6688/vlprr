import '../value_objects/restriction_type.dart' show ReminderKind;

/// 已排程的提醒实体（排程事实源的领域表示）。
///
/// 确定性 ID = hash(cityId|dateIso|kind|vehicleId)，保证同一条提醒
/// 重复计算不重复排程，且 diff 更新可精确匹配。
class ScheduledReminder {
  const ScheduledReminder({
    required this.id,
    required this.kind,
    required this.fireAt,
    required this.cityId,
    required this.date,
    required this.vehicleId,
    required this.title,
    required this.body,
    this.voiceText = '',
    this.tailsText = '',
    this.timeWindowText = '',
    this.areaText = '',
    this.cityName = '',
    this.plateText = '',
  });

  /// 确定性 ID（16 位十六进制）。
  final String id;

  final ReminderKind kind;

  /// 触发时刻（本地时间）。
  final DateTime fireAt;

  final String cityId;
  final DateTime date;
  final String vehicleId;

  /// 离线自足的展示与播报内容。
  final String title;
  final String body;
  final String voiceText;
  final String tailsText;
  final String timeWindowText;
  final String areaText;
  final String cityName;
  final String plateText;

  /// 生成确定性 ID。
  static String deterministicId({
    required String cityId,
    required DateTime date,
    required ReminderKind kind,
    required String vehicleId,
  }) {
    final dateIso =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    final raw = '$cityId|$dateIso|${kind.name}|$vehicleId';
    return raw.hashCode.toUnsigned(31).toRadixString(16).padLeft(8, '0') +
        raw.length.toRadixString(16).padLeft(4, '0');
  }

  @override
  String toString() =>
      'ScheduledReminder($id ${kind.name} @$fireAt $plateText@$cityName)';
}

/// 根据配置解析强提醒触发时刻。
///
/// - 有限行时段：取最早窗口开始时刻减去 leadMinutes
/// - 无时段（全天/未知）：取 fallbackMinutesOfDay
DateTime computeStrongFireAt({
  required DateTime date,
  int? firstStartMinutes,
  required int leadMinutes,
  required int fallbackMinutesOfDay,
}) {
  final d = DateTime(date.year, date.month, date.day);
  final base = firstStartMinutes ?? fallbackMinutesOfDay;
  final fire = d.add(Duration(minutes: base - leadMinutes));
  // 若提前量跨过午夜（如 0 点开始的限行 - 10 分钟），钳制到当日零点后。
  if (!fire.isAfter(d.subtract(const Duration(minutes: 1)))) {
    return d.add(const Duration(minutes: 1));
  }
  return fire;
}
