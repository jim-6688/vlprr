import '../entities/reminder_config.dart';
import '../entities/restriction_day.dart';
import '../entities/restriction_verdict.dart';
import '../entities/scheduled_reminder.dart';
import '../entities/vehicle.dart';
import '../services/restriction_evaluator.dart';
import '../value_objects/restriction_type.dart';

/// 提醒规划领域服务（纯函数）。
///
/// 输入：未来 N 天的限行快照 + 车辆列表 + 配置 + 当前时刻。
/// 输出：应排程的提醒目标集合（与现有排程做 diff 后由用例层执行）。
///
/// 规则：
/// - 对每辆启用车辆在每个"受限日"生成两阶段提醒：
///   1. preview：前一日 previewMinutesOfDay 触发（"明天尾号 X 限行"）
///   2. strong：当日限行时段开始前 strongLeadMinutes 触发
/// - 已过期时刻（fireAt <= now）不排程
/// - 按 fireAt 升序截断至 [maxPending]（iOS pending 通知 64 条上限）
class ReminderPlanner {
  const ReminderPlanner({this.maxPending = 60});

  /// iOS 系统待推送通知上限 64，预留余量截断至 60。
  final int maxPending;

  List<ScheduledReminder> plan({
    required List<RestrictionDay> days,
    required List<Vehicle> vehicles,
    required ReminderConfig defaultConfig,
    required Map<String, ReminderConfig> cityConfigs,
    required DateTime now,
    RestrictionEvaluator evaluator = const RestrictionEvaluator(),
  }) {
    final result = <ScheduledReminder>[];

    for (final day in days) {
      final config = cityConfigs[day.cityId] ?? defaultConfig;
      final cityVehicles =
          vehicles.where((v) => v.boundCityId == day.cityId && v.isActive);

      for (final vehicle in cityVehicles) {
        final verdict = evaluator.evaluate(vehicle: vehicle, day: day);
        if (!verdict.isRestricted) continue;

        // —— 阶段一：T-1 前一日预告 ——
        if (config.previewEnabled) {
          final previewDay = day.date.subtract(const Duration(days: 1));
          final fireAt = _at(previewDay, config.previewMinutesOfDay);
          if (fireAt.isAfter(now)) {
            result.add(_build(
              kind: ReminderKind.preview,
              fireAt: fireAt,
              day: day,
              vehicle: vehicle,
              verdict: verdict,
              strong: false,
            ));
          }
        }

        // —— 阶段二：当日强提醒 ——
        if (config.strongEnabled) {
          final fireAt = computeStrongFireAt(
            date: day.date,
            firstStartMinutes: day.firstStartMinutes,
            leadMinutes: config.strongLeadMinutes,
            fallbackMinutesOfDay: config.strongFallbackMinutesOfDay,
          );
          if (fireAt.isAfter(now)) {
            result.add(_build(
              kind: ReminderKind.strong,
              fireAt: fireAt,
              day: day,
              vehicle: vehicle,
              verdict: verdict,
              strong: true,
            ));
          }
        }
      }
    }

    result.sort((a, b) => a.fireAt.compareTo(b.fireAt));
    return result.take(maxPending).toList();
  }

  ScheduledReminder _build({
    required ReminderKind kind,
    required DateTime fireAt,
    required RestrictionDay day,
    required Vehicle vehicle,
    required RestrictionVerdict verdict,
    required bool strong,
  }) {
    final when = kind == ReminderKind.preview ? '明日' : '今日';
    final title = strong ? '$when限行强提醒' : '$when限行预告';
    final body = strong
        ? '${vehicle.plate} $when限行（尾号 ${day.tailsText}，'
            '${day.timeWindowText}），请勿驶入限行区域'
        : '${vehicle.plate} 明日（${day.dateIso}）限行尾号 '
            '${day.tailsText}（${day.timeWindowText}）';
    final voiceText = strong
        ? '提醒，您绑定的车辆${vehicle.plate}，今日限行，'
            '限行尾号${_speakTails(day.tailsText)}，'
            '限行时间${day.timeWindowText}，请合理安排出行。'
        : '提醒，您的车辆${vehicle.plate}，明日限行尾号'
            '${_speakTails(day.tailsText)}，请提前安排出行。';

    return ScheduledReminder(
      id: ScheduledReminder.deterministicId(
        cityId: day.cityId,
        date: day.date,
        kind: kind,
        vehicleId: vehicle.id,
      ),
      kind: kind,
      fireAt: fireAt,
      cityId: day.cityId,
      date: day.date,
      vehicleId: vehicle.id,
      title: title,
      body: body,
      voiceText: voiceText,
      tailsText: day.tailsText,
      timeWindowText: day.timeWindowText,
      areaText: day.areaText,
      cityName: day.cityName,
      plateText: vehicle.plate,
    );
  }

  /// 尾号文本转 TTS 友好读法："4 和 9" → "4和9"（数字逐位自然读）。
  static String _speakTails(String tails) => tails.replaceAll(' ', '');

  static DateTime _at(DateTime day, int minutesOfDay) =>
      DateTime(day.year, day.month, day.day).add(Duration(minutes: minutesOfDay));
}
