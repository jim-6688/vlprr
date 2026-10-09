/// 强提醒插件的数据模型与能力描述。
library;

/// 提醒阶段类型。
enum AlertKind { preview, strong }

/// 平台能力探测结果。
///
/// 强提醒手段在不同平台/设备上能力不同，UI 与提醒网关依据本能力
/// 做降级处理（例如 iOS 无全屏意图、部分 Android ROM 禁精确闹钟）。
class AlertCapabilities {
  const AlertCapabilities({
    required this.exactAlarmSupported,
    required this.fullScreenIntentSupported,
    required this.ttsSupported,
    required this.bypassDndSupported,
    required this.timeSensitiveSupported,
    required this.platformName,
  });

  /// Android：SCHEDULE_EXACT_ALARM 精确闹钟是否可用。
  final bool exactAlarmSupported;

  /// Android：FULL_SCREEN_INTENT 是否可用。
  final bool fullScreenIntentSupported;

  /// TTS 语音播报是否可用。
  final bool ttsSupported;

  /// 是否支持绕过勿扰模式（Android ACCESS_NOTIFICATION_POLICY）。
  final bool bypassDndSupported;

  /// iOS 15+ 时效性通知（timeSensitive）是否可用。
  final bool timeSensitiveSupported;

  /// 平台标识：android / ios / ohos。
  final String platformName;

  Map<String, Object?> toMap() => <String, Object?>{
        'exactAlarmSupported': exactAlarmSupported,
        'fullScreenIntentSupported': fullScreenIntentSupported,
        'ttsSupported': ttsSupported,
        'bypassDndSupported': bypassDndSupported,
        'timeSensitiveSupported': timeSensitiveSupported,
        'platformName': platformName,
      };

  factory AlertCapabilities.fromMap(Map<Object?, Object?> map) =>
      AlertCapabilities(
        exactAlarmSupported: map['exactAlarmSupported'] == true,
        fullScreenIntentSupported: map['fullScreenIntentSupported'] == true,
        ttsSupported: map['ttsSupported'] == true,
        bypassDndSupported: map['bypassDndSupported'] == true,
        timeSensitiveSupported: map['timeSensitiveSupported'] == true,
        platformName: map['platformName'] as String? ?? 'unknown',
      );

  static const AlertCapabilities unknown = AlertCapabilities(
    exactAlarmSupported: false,
    fullScreenIntentSupported: false,
    ttsSupported: false,
    bypassDndSupported: false,
    timeSensitiveSupported: false,
    platformName: 'unknown',
  );

  @override
  String toString() =>
      'AlertCapabilities($platformName exact=$exactAlarmSupported '
      'fullscreen=$fullScreenIntentSupported tts=$ttsSupported '
      'dnd=$bypassDndSupported timeSensitive=$timeSensitiveSupported)';
}

/// 一条待排程提醒的完整载荷。
///
/// 设计原则：**离线自足** —— 触发时原生层直接使用本载荷展示/播报，
/// 不依赖网络与应用进程存活。
class AlertPayload {
  const AlertPayload({
    required this.id,
    required this.kind,
    required this.fireAt,
    required this.title,
    required this.body,
    required this.voiceText,
    this.cityId = '',
    this.cityName = '',
    this.dateIso = '',
    this.plateText = '',
    this.tailsText = '',
    this.timeWindowText = '',
    this.areaText = '',
  });

  /// 确定性 ID（由 Planner 依据 city|date|kind|vehicle 哈希生成）。
  final String id;

  final AlertKind kind;

  /// 触发时刻（本地时间）。
  final DateTime fireAt;

  /// 通知标题，如"今日限行提醒"。
  final String title;

  /// 通知正文，如"京A12345 今日限行 4 和 9（7:00-20:00），请注意出行安排"。
  final String body;

  /// TTS 播报文本（可含标点控制停顿）。
  final String voiceText;

  final String cityId;
  final String cityName;

  /// 限行日期 yyyy-MM-dd。
  final String dateIso;

  /// 车牌展示文本。
  final String plateText;

  /// 限行尾号展示，如"4 和 9"。
  final String tailsText;

  /// 限行时段展示，如"7:00-20:00"。
  final String timeWindowText;

  /// 限行区域展示。
  final String areaText;

  Map<String, Object?> toMap() => <String, Object?>{
        'id': id,
        'kind': kind == AlertKind.preview ? 'preview' : 'strong',
        'fireAt': fireAt.millisecondsSinceEpoch,
        'title': title,
        'body': body,
        'voiceText': voiceText,
        'cityId': cityId,
        'cityName': cityName,
        'dateIso': dateIso,
        'plateText': plateText,
        'tailsText': tailsText,
        'timeWindowText': timeWindowText,
        'areaText': areaText,
      };

  factory AlertPayload.fromMap(Map<Object?, Object?> map) => AlertPayload(
        id: map['id'] as String? ?? '',
        kind: map['kind'] == 'strong' ? AlertKind.strong : AlertKind.preview,
        fireAt:
            DateTime.fromMillisecondsSinceEpoch(map['fireAt'] as int? ?? 0),
        title: map['title'] as String? ?? '',
        body: map['body'] as String? ?? '',
        voiceText: map['voiceText'] as String? ?? '',
        cityId: map['cityId'] as String? ?? '',
        cityName: map['cityName'] as String? ?? '',
        dateIso: map['dateIso'] as String? ?? '',
        plateText: map['plateText'] as String? ?? '',
        tailsText: map['tailsText'] as String? ?? '',
        timeWindowText: map['timeWindowText'] as String? ?? '',
        areaText: map['areaText'] as String? ?? '',
      );

  @override
  String toString() =>
      'AlertPayload($id ${kind.name} @$fireAt "$title" / "$body")';
}

/// 排程操作结果。
class ScheduleResult {
  const ScheduleResult({required this.accepted, this.reason});

  final bool accepted;
  final String? reason;

  @override
  String toString() => accepted ? 'accepted' : 'rejected($reason)';
}
