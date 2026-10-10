/// 白噪音 / 环境音实体与睡眠定时器。
library;

import 'dart:math' as math;

/// 白噪音类型。
///
/// [waveform] 决定合成算法，[defaultDurationSeconds] 是首次播放的默认时长。
///
/// 分为两类：
/// - **合成音**（[isSynthesized] 为 true）：实时生成，体积为零、可无缝循环；
/// - **实录音**（为 false）：内置真实录音，自然度更高，但需要打包资源。
///
/// 已切换为实录的音色保留同名合成算法作为降级路径——资源缺失时
/// 仍能发声，不至于让整个页面哑掉。
enum NoiseKind {
  /// 白噪音——全频段等功率，最"亮"，掩盖力最强。
  white('白噪音', 'wi', 1800),

  /// 粉噪音——低频更强，接近自然界背景声。
  pink('粉噪音', 'pi', 1800),

  /// 棕噪音——低频主导，接近远处的瀑布/风声。
  brown('棕噪音', 'br', 1800),

  /// 雨声——滤波白噪 + 低通，最常用于助眠。
  rain('雨声', 'ra', 2700),

  /// 海浪——实录海岸浪涛。录音本身首尾波形连续，循环无接缝。
  waves('海浪', 'wa', 2700),

  /// 篝火——实录柴火燃烧。已做 4秒等功率交叉淡化，循环无接缝。
  campfire('篝火', 'ca', 2700),

  /// 夜风——带通噪声 + 缓慢漂移的中心频率。
  wind('夜风', 'wi', 2700),

  /// 咖啡馆——带通噪声 + 人声频段起伏（400–900Hz）。
  cafe('咖啡馆', 'ca', 3600);

  const NoiseKind(this.label, this.iconId, this.defaultDurationSeconds);

  /// 中文名。
  final String label;

  /// 图标标识，映射到 [TaillimitIcons] 的扩展名。
  final String iconId;

  /// 默认播放时长（秒）。
  final int defaultDurationSeconds;

  /// 是否为纯合成音（无采样素材）。
  bool get isSynthesized => switch (this) {
        NoiseKind.waves || NoiseKind.campfire => false,
        _ => true,
      };

  /// 内置音频资源路径；[isSynthesized] 为 true 时为 null。
  ///
  /// 统一走 Flutter 的 `AssetManifest` 加载，路径以 `assets/` 开头。
  String? get assetPath => switch (this) {
        NoiseKind.waves => 'assets/audio/ocean_waves.ogg',
        NoiseKind.campfire => 'assets/audio/campfire.ogg',
        _ => null,
      };

  /// 音源来源说明，用于「关于」页展示与署名。
  ///
  /// 实录音必须可追溯到作者与许可，这是内置音频的合规底线。
  AudioCredit? get credit => switch (this) {
        NoiseKind.waves => const AudioCredit(
            title: '海岸浪涛',
            author: 'Buk，挂载于 Blanket 音频集',
            source: 'https://freesound.org/sounds/1313451/',
            license: 'CC BY 4.0',
            licenseUrl: 'https://creativecommons.org/licenses/by/4.0/',
          ),
        NoiseKind.campfire => const AudioCredit(
            title: '篝火燃烧',
            author: 'Goodkoalas，挂载于 Blanket 音频集',
            source: 'https://freesound.org/sounds/3846183/',
            license: 'CC BY 4.0',
            licenseUrl: 'https://creativecommons.org/licenses/by/4.0/',
          ),
        _ => null,
      };
}

/// 单条内置音源的署名信息。
class AudioCredit {
  const AudioCredit({
    required this.title,
    required this.author,
    required this.source,
    required this.license,
    required this.licenseUrl,
  });

  /// 曲目标题。
  final String title;

  /// 作者/ 表演者。
  final String author;

  /// 原始来源链接。
  final String source;

  /// 许可标识（如 CC BY 4.0）。
  final String license;

  /// 许可全文链接。
  final String licenseUrl;

  /// 是否需要署名（CC BY / CC BY-SA 需署名，CC0 / 公有领域不需）。
  ///
  /// 需要署名的音源必须在应用内提供展示位置，不能只放在源码注释里。
  bool get requiresAttribution => license.contains('BY');
}

/// 睡眠定时器的可选时长。
enum SleepTimerPreset {
  /// 不定时，播放到用户手动停止。
  off('不定时', 0),

  /// 15 分钟。
  minutes15('15 分钟', 15 * 60),

  /// 30 分钟。
  minutes30('30 分钟', 30 * 60),

  /// 45 分钟。
  minutes45('45 分钟', 45 * 60),

  /// 1 小时。
  hour1('1 小时', 60 * 60),

  /// 2 小时。
  hours2('2 小时', 2 * 60 * 60);

  const SleepTimerPreset(this.label, this.seconds);

  /// 中文标签。
  final String label;

  /// 秒数，[off] 为 0。
  final int seconds;

  /// 是否为不定时。
  bool get isOff => seconds == 0;
}

/// 睡眠定时器。
///
/// 记录**结束时刻**而非倒计时秒数——这样 App 进入后台或进程被挂起时，
/// 依据系统时钟仍能算出准确剩余时间，不会因为后台节流而漂移。
class SleepTimer {
  const SleepTimer({
    required this.endsAt,
    required this.fadeOutSeconds,
    required this.totalSeconds,
  });

  /// 播放结束的时刻（本地时间）。
  ///
  /// 为 null 表示**不定时**（[SleepTimer.none]）——这是合法状态而非异常，
  /// 因此类型必须可空。
  final DateTime? endsAt;

  /// 总时长（秒）。
  ///
  /// 保留它而非每次从预设反推，是为了让进度条能显示真实占比——
  /// 只知道 endsAt 无法算出"已播/总长"。
  final int totalSeconds;

  /// 最后渐弱的时长（秒）。
  ///
  /// 在结束前这段时间内音量线性降到 0，避免"啪"地一声切断。
  final int fadeOutSeconds;

  /// 不定时（无结束时刻）。
  static const SleepTimer none = SleepTimer._raw(null, 0, 0);
  const SleepTimer._raw(this.endsAt, this.fadeOutSeconds, this.totalSeconds);

  /// 从预设时长创建定时器，以 [start] 为起点。
  factory SleepTimer.fromPreset(
    SleepTimerPreset preset, {
    DateTime? start,
    int fadeOutSeconds = 20,
  }) {
    if (preset.isOff) return none;
    final DateTime from = start ?? DateTime.now();
    return SleepTimer(
      endsAt: from.add(Duration(seconds: preset.seconds)),
      totalSeconds: preset.seconds,
      fadeOutSeconds: fadeOutSeconds,
    );
  }

  /// 剩余时长。
  ///
  /// [at] 参数便于测试注入固定时钟。
  Duration remaining([DateTime? at]) {
    if (isOff) return Duration.zero;
    final DateTime now = at ?? DateTime.now();
    final Duration left = endsAt!.difference(now);
    return left.isNegative ? Duration.zero : left;
  }

  /// 是否为不定时。
  bool get isOff => endsAt == null;

  /// 是否已到期。
  bool isExpired([DateTime? at]) => !isOff && remaining(at) == Duration.zero;

  /// 已流逝比例（0.0–1.0），用于进度条。
  double progress([DateTime? at]) {
    if (isOff || totalSeconds <= 0) return 0.0;
    final int elapsed = totalSeconds - remaining(at).inSeconds;
    return (elapsed / totalSeconds).clamp(0.0, 1.0);
  }

  /// 当前音量系数（0.0–1.0）。
  ///
  /// 进入渐弱区间后线性下降，其余时间为 1.0。
  double volumeFactor([DateTime? at]) {
    if (isExpired(at)) return 0.0;
    if (isOff || fadeOutSeconds <= 0) return 1.0;

    final DateTime now = at ?? DateTime.now();
    final DateTime fadeStart =
        endsAt!.subtract(Duration(seconds: fadeOutSeconds));
    if (now.isBefore(fadeStart)) return 1.0;

    final int total = endsAt!.difference(fadeStart).inSeconds;
    if (total <= 0) return 1.0;
    final int elapsed = now.difference(fadeStart).inSeconds;
    final double ratio = 1.0 - (elapsed / total);
    return ratio.clamp(0.0, 1.0);
  }

  /// 是否处于渐弱阶段。
  bool isFading([DateTime? at]) =>
      !isOff && !isExpired(at) && volumeFactor(at) < 1.0;

  @override
  bool operator ==(Object other) =>
      other is SleepTimer &&
      other.endsAt == endsAt &&
      other.totalSeconds == totalSeconds &&
      other.fadeOutSeconds == fadeOutSeconds;

  @override
  int get hashCode => Object.hash(endsAt, totalSeconds, fadeOutSeconds);

  @override
  String toString() =>
      isOff
          ? 'SleepTimer(off)'
          : 'SleepTimer(endsAt: $endsAt, total: ${totalSeconds}s, '
                'fade: ${fadeOutSeconds}s)';
}

/// 音频合成参数。
///
/// 白噪音类音效用 Voss-McCartney 或简单滤波从随机数生成，
/// 无需任何音频素材文件。
class NoiseSynthesisSpec {
  const NoiseSynthesisSpec({
    required this.kind,
    required this.sampleRate,
    this.gain = 0.32,
    this.seed,
  });

  final NoiseKind kind;

  /// 采样率（Hz）。44100 是各平台通用值。
  final double sampleRate;

  /// 输出增益，控制在 0.3 附近以避免长时间聆听的听觉疲劳。
  final double gain;

  /// 随机种子，用于可复现的测试。
  final int? seed;

  /// 生成单声道样本。
  ///
  /// 返回 `sampleRate * durationSeconds` 个值域在 [-1, 1] 的浮点样本。
  /// 不同 [NoiseKind] 使用不同的滤波算法产生不同的频谱特征。
  static List<double> generate({
    required NoiseKind kind,
    double sampleRate = 44100,
    double durationSeconds = 2.0,
    double gain = 0.32,
    int? seed,
  }) {
    final int count = (sampleRate * durationSeconds).round();
    if (count <= 0) return const <double>[];

    final math.Random rng = seed == null
        ? math.Random()
        : math.Random(seed);
    final List<double> out = List<double>.filled(count, 0);

    switch (kind) {
      // 全频段等功率
      case NoiseKind.white:
        for (int i = 0; i < count; i++) {
          out[i] = (rng.nextDouble() * 2.0 - 1.0) * gain;
        }

      // 低频加权（-3dB/oct），Paul Kellet 三极点滤波近似
      case NoiseKind.pink:
      case NoiseKind.cafe:
      case NoiseKind.wind:
        double b0 = 0;
        double b1 = 0;
        double b2 = 0;
        for (int i = 0; i < count; i++) {
          final double w = rng.nextDouble() * 2.0 - 1.0;
          b0 = 0.99765 * b0 + w * 0.0990460;
          b1 = 0.96300 * b1 + w * 0.2965164;
          b2 = 0.57000 * b2 + w * 1.0526913;
          out[i] = (b0 + b1 + b2 + w * 0.1848) * gain * 0.32;
        }

      // 强低频（-6dB/oct），两级低通
      case NoiseKind.brown:
      case NoiseKind.campfire:
        double y1 = 0;
        double y2 = 0;
        for (int i = 0; i < count; i++) {
          final double w = rng.nextDouble() * 2.0 - 1.0;
          y1 = y1 * 0.997 + w * 0.029;
          y2 = y2 * 0.985 + y1 * 0.0329;
          out[i] = y2 * gain * 2.4;
        }

      // 雨声：粉噪 + 低通压制高频
      case NoiseKind.rain:
        double lp = 0;
        for (int i = 0; i < count; i++) {
          final double w = rng.nextDouble() * 2.0 - 1.0;
          lp = lp * 0.86 + w * 0.14;
          out[i] = lp * gain * 1.5;
        }

      // 海浪：粉噪 + 0.09Hz 包络调幅
      case NoiseKind.waves:
        double y1 = 0;
        double y2 = 0;
        for (int i = 0; i < count; i++) {
          final double w = rng.nextDouble() * 2.0 - 1.0;
          y1 = y1 * 0.997 + w * 0.029;
          y2 = y2 * 0.985 + y1 * 0.0329;
          final double t = i / sampleRate;
          // 双频叠加的涌浪包络，制造"涨—退"的呼吸感
          final double envelope =
              0.55 +
              0.30 * math.sin(2 * math.pi * 0.09 * t) +
              0.15 * math.sin(2 * math.pi * 0.031 * t + 1.1);
          out[i] = y2 * envelope * gain * 3.0;
        }
    }

    // 软限幅，防止滤波叠加后削波产生爆音
    for (int i = 0; i < count; i++) {
      final double v = out[i].clamp(-1.0, 1.0);
      out[i] = v - (v * v * v) / 3.0;
    }
    return out;
  }
}
