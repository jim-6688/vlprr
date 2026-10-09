/// TailLimit 强提醒插件门面。
///
/// 用法：
/// ```dart
/// final alert = TailLimitAlert();
/// final caps = await alert.getCapabilities();
/// await alert.schedule(AlertPayload(...));
/// ```
library;

import 'src/alert_api.dart';
import 'src/alert_channel.dart';
import 'src/alert_models.dart';

export 'src/alert_api.dart';
export 'src/alert_channel.dart';
export 'src/alert_models.dart';

class TailLimitAlert implements AlertApi {
  TailLimitAlert({AlertApi? api}) : _api = api ?? AlertChannel();

  final AlertApi _api;

  @override
  Future<AlertCapabilities> getCapabilities() => _api.getCapabilities();

  @override
  Future<bool> requestPermission() => _api.requestPermission();

  @override
  Future<ScheduleResult> schedule(AlertPayload payload) => _api.schedule(payload);

  @override
  Future<void> cancel(String alertId) => _api.cancel(alertId);

  @override
  Future<void> showNow(AlertPayload payload) => _api.showNow(payload);

  @override
  Future<void> speakNow(String text) => _api.speakNow(text);
}
