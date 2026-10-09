import 'package:flutter/services.dart';

import 'alert_api.dart';
import 'alert_models.dart';

/// MethodChannel 实现的平台通道。
class AlertChannel implements AlertApi {
  AlertChannel({String? channelName})
      : _channel = MethodChannel(channelName ?? AlertChannel.defaultChannelName);

  static const String defaultChannelName = 'com.taillimit.alert/channel';

  final MethodChannel _channel;

  @override
  Future<AlertCapabilities> getCapabilities() async {
    final map = await _channel.invokeMethod<Object?>('getCapabilities');
    if (map is Map) {
      return AlertCapabilities.fromMap(map.cast<Object?, Object?>());
    }
    return AlertCapabilities.unknown;
  }

  @override
  Future<bool> requestPermission() async =>
      await _channel.invokeMethod<bool>('requestPermission') ?? false;

  @override
  Future<ScheduleResult> schedule(AlertPayload payload) async {
    final map = await _channel
        .invokeMethod<Object?>('schedule', payload.toMap());
    if (map is Map) {
      final m = map.cast<Object?, Object?>();
      return ScheduleResult(
        accepted: m['accepted'] == true,
        reason: m['reason'] as String?,
      );
    }
    return const ScheduleResult(accepted: false, reason: 'bad channel reply');
  }

  @override
  Future<void> cancel(String alertId) =>
      _channel.invokeMethod<void>('cancel', <String, Object?>{'id': alertId});

  @override
  Future<void> showNow(AlertPayload payload) =>
      _channel.invokeMethod<void>('showNow', payload.toMap());

  @override
  Future<void> speakNow(String text) =>
      _channel.invokeMethod<void>('speakNow', <String, Object?>{'text': text});
}
