import 'package:flutter/foundation.dart';
import 'package:tail_limit_alert_plugin/tail_limit_alert_plugin.dart';

import '../../../../domain/entities/scheduled_reminder.dart';
import '../../../../domain/repositories/alert_gateway.dart';
import '../../../../domain/value_objects/restriction_type.dart';

/// 强提醒网关实现：领域层 ↔ 三端原生插件。
///
/// 职责：
/// - ScheduledReminder → AlertPayload 转换（离线自足载荷）
/// - 能力探测与降级（平台不支持的手段自动跳过并记录）
/// - 排程去重由领域层 Planner/ApplyReminderPlan 保证，此处只做透传
class AlertGatewayImpl implements AlertGateway {
  AlertGatewayImpl({TailLimitAlert? alert})
      : _alert = alert ?? TailLimitAlert();

  final TailLimitAlert _alert;

  AlertCapabilitiesInfo? _cachedCaps;

  @override
  Future<AlertCapabilitiesInfo> capabilities() async {
    if (_cachedCaps != null) return _cachedCaps!;
    try {
      final caps = await _alert.getCapabilities();
      _cachedCaps = AlertCapabilitiesInfo(
        platformName: caps.platformName,
        exactAlarmSupported: caps.exactAlarmSupported,
        fullScreenIntentSupported: caps.fullScreenIntentSupported,
        ttsSupported: caps.ttsSupported,
        bypassDndSupported: caps.bypassDndSupported,
        timeSensitiveSupported: caps.timeSensitiveSupported,
      );
    } catch (e) {
      debugPrint('[AlertGateway] 能力探测失败，降级为无强提醒能力: $e');
      _cachedCaps = const AlertCapabilitiesInfo(
        platformName: 'unknown',
        exactAlarmSupported: false,
        fullScreenIntentSupported: false,
        ttsSupported: false,
        bypassDndSupported: false,
        timeSensitiveSupported: false,
      );
    }
    return _cachedCaps!;
  }

  @override
  Future<bool> requestPermission() async {
    try {
      return await _alert.requestPermission();
    } catch (e) {
      debugPrint('[AlertGateway] 授权请求失败: $e');
      return false;
    }
  }

  @override
  Future<void> applyPlan({
    required List<ScheduledReminder> toSchedule,
    required List<String> toCancel,
  }) async {
    for (final id in toCancel) {
      try {
        await _alert.cancel(id);
      } catch (e) {
        debugPrint('[AlertGateway] 取消失败 $id: $e');
      }
    }

    for (final reminder in toSchedule) {
      try {
        final result = await _alert.schedule(_toPayload(reminder));
        if (!result.accepted) {
          debugPrint('[AlertGateway] 排程被拒 ${reminder.id}: ${result.reason}');
        }
      } catch (e) {
        debugPrint('[AlertGateway] 排程失败 ${reminder.id}: $e');
      }
    }
  }

  @override
  Future<void> showNow(ScheduledReminder reminder) async {
    try {
      await _alert.showNow(_toPayload(reminder));
    } catch (e) {
      debugPrint('[AlertGateway] 立即展示失败: $e');
    }
  }

  @override
  Future<void> speakNow(String text) async {
    try {
      await _alert.speakNow(text);
    } catch (e) {
      debugPrint('[AlertGateway] 播报失败: $e');
    }
  }

  /// 领域实体 → 插件载荷（离线自足：触发时不依赖网络与 App 进程）。
  AlertPayload _toPayload(ScheduledReminder r) => AlertPayload(
        id: r.id,
        kind: r.kind == ReminderKind.strong
            ? AlertKind.strong
            : AlertKind.preview,
        fireAt: r.fireAt,
        title: r.title,
        body: r.body,
        voiceText: r.voiceText,
        cityId: r.cityId,
        cityName: r.cityName,
        dateIso: _isoDate(r.date),
        plateText: r.plateText,
        tailsText: r.tailsText,
        timeWindowText: r.timeWindowText,
        areaText: r.areaText,
      );

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
