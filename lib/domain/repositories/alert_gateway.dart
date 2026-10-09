import '../entities/scheduled_reminder.dart';

/// 强提醒网关端口：领域层与平台原生能力（插件）的隔离层。
///
/// data 层实现（AlertGatewayImpl）负责：
/// - 调用 tail_limit_alert_plugin 三端原生
/// - ScheduledReminder → AlertPayload 转换
/// - 能力探测与降级日志
abstract class AlertGateway {
  /// 平台能力探测。
  Future<AlertCapabilitiesInfo> capabilities();

  /// 请求前置授权（通知/精确闹钟/时效性通知）。
  Future<bool> requestPermission();

  /// 应用提醒计划：排程新增、取消失效。
  Future<void> applyPlan({
    required List<ScheduledReminder> toSchedule,
    required List<String> toCancel,
  });

  /// 立即弹出强提醒（应用内演示）。
  Future<void> showNow(ScheduledReminder reminder);

  /// 立即 TTS 播报。
  Future<void> speakNow(String text);
}

/// 平台能力信息（对插件模型的领域封装）。
class AlertCapabilitiesInfo {
  const AlertCapabilitiesInfo({
    required this.platformName,
    required this.exactAlarmSupported,
    required this.fullScreenIntentSupported,
    required this.ttsSupported,
    required this.bypassDndSupported,
    required this.timeSensitiveSupported,
  });

  final String platformName;
  final bool exactAlarmSupported;
  final bool fullScreenIntentSupported;
  final bool ttsSupported;
  final bool bypassDndSupported;
  final bool timeSensitiveSupported;

  /// 当前平台是否支持强提醒的核心手段（全屏/时效性/系统代理）。
  bool get hasStrongAlertPath =>
      fullScreenIntentSupported || timeSensitiveSupported;

  @override
  String toString() => 'AlertCapabilitiesInfo($platformName)';
}
