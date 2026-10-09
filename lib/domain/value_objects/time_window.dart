/// 限行时段值对象：以"当日分钟数"表达，纯 Dart 无 Flutter 依赖。
class TimeWindow {
  const TimeWindow({required this.startMinutes, required this.endMinutes});

  /// 从 "HH:mm-HH:mm" 解析，支持 "7:30-20:00"。
  static TimeWindow? tryParse(String raw) {
    final parts = raw.trim().split('-');
    if (parts.length != 2) return null;
    final start = _parseClock(parts[0]);
    final end = _parseClock(parts[1]);
    if (start == null || end == null) return null;
    if (end <= start) return null;
    return TimeWindow(startMinutes: start, endMinutes: end);
  }

  static int? _parseClock(String s) {
    final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(s.trim());
    if (m == null) return null;
    final h = int.parse(m.group(1)!);
    final min = int.parse(m.group(2)!);
    if (h > 24 || min > 59) return null;
    return h * 60 + min;
  }

  /// 当日起始分钟数（7:30 → 450）。
  final int startMinutes;

  /// 当日结束分钟数（20:00 → 1200）。
  final int endMinutes;

  bool get isAllDay => startMinutes <= 0 && endMinutes >= 24 * 60;

  /// 展示文本 "7:30-20:00"。
  String get displayText =>
      '${_clock(startMinutes)}-${_clock(endMinutes)}';

  static String _clock(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '$h:${m.toString().padLeft(2, '0')}';
  }

  /// 该时刻（当日分钟数）是否处于窗口内（含端点）。
  bool contains(int minutesOfDay) =>
      minutesOfDay >= startMinutes && minutesOfDay <= endMinutes;

  @override
  bool operator ==(Object other) =>
      other is TimeWindow &&
      other.startMinutes == startMinutes &&
      other.endMinutes == endMinutes;

  @override
  int get hashCode => Object.hash(startMinutes, endMinutes);

  @override
  String toString() => displayText;
}

/// 全天时段常量。
const TimeWindow kAllDayWindow =
    TimeWindow(startMinutes: 0, endMinutes: 24 * 60);
