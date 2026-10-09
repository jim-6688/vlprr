/// 提醒配置：全局默认 + 按城市覆盖。
class ReminderConfig {
  const ReminderConfig({
    required this.cityId,
    this.previewEnabled = true,
    this.previewMinutesOfDay = 21 * 60, // 默认前一日 21:00 预告
    this.strongEnabled = true,
    this.strongLeadMinutes = 10, // 限行时段开始前 10 分钟强提醒
    this.strongFallbackMinutesOfDay = 7 * 60, // 无明确时段时 07:00 强提醒
    this.voiceEnabled = true,
    this.fullScreenEnabled = true,
    this.bypassDndEnabled = false,
  });

  /// 城市维度配置键；全局默认用 'default'。
  static const String defaultKey = 'default';

  final String cityId;

  /// T-1 前一日预告提醒开关。
  final bool previewEnabled;

  /// 预告提醒时刻（当日分钟数，默认 21:00 = 1260）。
  final int previewMinutesOfDay;

  /// 限号当日强提醒开关。
  final bool strongEnabled;

  /// 强提醒提前分钟数（相对限行时段开始，默认 10 分钟）。
  final int strongLeadMinutes;

  /// 当天无限行时段数据时的强提醒时刻（默认 07:00 = 420）。
  final int strongFallbackMinutesOfDay;

  /// 语音播报（TTS）。
  final bool voiceEnabled;

  /// 全屏强提醒（Android 全屏意图）。
  final bool fullScreenEnabled;

  /// 尝试绕过勿扰模式（需系统授权，仅 Android）。
  final bool bypassDndEnabled;

  ReminderConfig copyWith({
    String? cityId,
    bool? previewEnabled,
    int? previewMinutesOfDay,
    bool? strongEnabled,
    int? strongLeadMinutes,
    int? strongFallbackMinutesOfDay,
    bool? voiceEnabled,
    bool? fullScreenEnabled,
    bool? bypassDndEnabled,
  }) =>
      ReminderConfig(
        cityId: cityId ?? this.cityId,
        previewEnabled: previewEnabled ?? this.previewEnabled,
        previewMinutesOfDay: previewMinutesOfDay ?? this.previewMinutesOfDay,
        strongEnabled: strongEnabled ?? this.strongEnabled,
        strongLeadMinutes: strongLeadMinutes ?? this.strongLeadMinutes,
        strongFallbackMinutesOfDay:
            strongFallbackMinutesOfDay ?? this.strongFallbackMinutesOfDay,
        voiceEnabled: voiceEnabled ?? this.voiceEnabled,
        fullScreenEnabled: fullScreenEnabled ?? this.fullScreenEnabled,
        bypassDndEnabled: bypassDndEnabled ?? this.bypassDndEnabled,
      );

  Map<String, Object?> toMap() => <String, Object?>{
        'cityId': cityId,
        'previewEnabled': previewEnabled,
        'previewMinutesOfDay': previewMinutesOfDay,
        'strongEnabled': strongEnabled,
        'strongLeadMinutes': strongLeadMinutes,
        'strongFallbackMinutesOfDay': strongFallbackMinutesOfDay,
        'voiceEnabled': voiceEnabled,
        'fullScreenEnabled': fullScreenEnabled,
        'bypassDndEnabled': bypassDndEnabled,
      };

  factory ReminderConfig.fromMap(Map<Object?, Object?> m) => ReminderConfig(
        cityId: m['cityId'] as String? ?? ReminderConfig.defaultKey,
        previewEnabled: m['previewEnabled'] != false,
        previewMinutesOfDay: m['previewMinutesOfDay'] as int? ?? 21 * 60,
        strongEnabled: m['strongEnabled'] != false,
        strongLeadMinutes: m['strongLeadMinutes'] as int? ?? 10,
        strongFallbackMinutesOfDay:
            m['strongFallbackMinutesOfDay'] as int? ?? 7 * 60,
        voiceEnabled: m['voiceEnabled'] != false,
        fullScreenEnabled: m['fullScreenEnabled'] != false,
        bypassDndEnabled: m['bypassDndEnabled'] == true,
      );

  @override
  String toString() => 'ReminderConfig($cityId)';
}

/// 全局默认配置。
const ReminderConfig kDefaultReminderConfig = ReminderConfig(
  cityId: ReminderConfig.defaultKey,
);
