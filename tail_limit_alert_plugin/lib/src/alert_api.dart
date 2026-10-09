import 'alert_models.dart';

/// 插件平台通道接口（窄接口设计：仅 6 个方法）。
///
/// 三端原生实现（Android Kotlin / iOS Swift / OHOS ArkTS）只需实现本接口：
/// 1. [getCapabilities]   能力探测
/// 2. [requestPermission] 请求通知/闹钟等前置授权
/// 3. [schedule]          排程一条提醒（原生层持久化，杀进程仍触发）
/// 4. [cancel]            取消排程
/// 5. [showNow]           立即弹出强提醒（应用内即时演示/手动触发）
/// 6. [speakNow]          立即 TTS 播报
///
/// 本文件不引入 Flutter 依赖，便于纯 Dart 单元测试；
/// MethodChannel 实现见 alert_channel.dart。
abstract class AlertApi {
  Future<AlertCapabilities> getCapabilities();

  /// 请求全部前置授权（通知、精确闹钟、勿扰旁路、时效性通知）。
  /// 返回是否全部就绪；未就绪项由 UI 权限引导页逐项处理。
  Future<bool> requestPermission();

  Future<ScheduleResult> schedule(AlertPayload payload);

  Future<void> cancel(String alertId);

  Future<void> showNow(AlertPayload payload);

  Future<void> speakNow(String text);
}
