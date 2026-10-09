import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/noise.dart';
import '../../widgets/car_adaptive_scaffold.dart';
import '../noise/noise_provider.dart';

/// 白噪音页：环境音库 + 睡眠定时器。
///
/// 全部音色由算法实时合成，**不打包任何音频素材**，
/// 因此安装包不增加体积，且可无缝循环。
class NoiseScreen extends ConsumerWidget {
  const NoiseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(noisePlaybackProvider);
    final controller = ref.read(noisePlaybackProvider.notifier);

    return CarAdaptiveScaffold(
      title: '白噪音',
      primary: ListView(
        padding: EdgeInsets.fromLTRB(
          FormFactor.pagePadding(context),
          AppSizes.gap8,
          FormFactor.pagePadding(context),
          AppSizes.gap24,
        ),
        children: [
          _NowPlayingBar(playback: playback, onToggle: controller.toggle),
          const SizedBox(height: AppSizes.gap24),
          _SectionLabel(text: '环境音', trailing: '${NoiseKind.values.length} 种'),
          const SizedBox(height: AppSizes.gap12),
          // 2 列网格而非竖向长列表——8种音色一屏可见，无需滚动
          LayoutBuilder(
            builder: (context, constraints) {
              final bool wide = constraints.maxWidth >= 560;
              final int columns = wide ? 4 : 2;
              const double gap = AppSizes.gap12;
              final double tileWidth =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final NoiseKind kind in NoiseKind.values)
                    SizedBox(
                      width: tileWidth,
                      height: wide ? 108 : 132,
                      child: _NoiseTile(
                        kind: kind,
                        selected: playback.kind == kind,
                        playing: playback.isPlaying &&
                            playback.kind == kind,
                        onTap: () => _onTap(context, ref, kind),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSizes.gap32),
          _SectionLabel(
            text: '定时',
            trailing: playback.hasTimer ? playback.remainingLabel : null,
          ),
          const SizedBox(height: AppSizes.gap12),
          _TimerPicker(
            selected: playback.timer,
            enabled: playback.kind != null,
            onChanged: (preset) => controller.setTimerPreset(preset),
          ),
          if (playback.hasTimer) ...[
            const SizedBox(height: AppSizes.gap16),
            _TimerProgress(
              timer: playback.timer!,
              remaining: playback.remaining,
              isPlaying: playback.isPlaying,
            ),
          ],
          const SizedBox(height: AppSizes.gap24),
          _VolumeControl(
            volume: playback.volume,
            enabled: playback.kind != null,
            onChanged: controller.setVolume,
          ),
          const SizedBox(height: AppSizes.gap24),
          const _NoiseNotice(),
        ],
      ),
      secondary: playback.kind == null
          ? null
          : _NoiseDetail(kind: playback.kind!, playback: playback),
    );
  }

  Future<void> _onTap(
    BuildContext context,
    WidgetRef ref,
    NoiseKind kind,
  ) async {
    final controller = ref.read(noisePlaybackProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);

    // 再次点击当前音色 = 停止（再次点击可从头开始）
    if (ref.read(noisePlaybackProvider).kind == kind) {
      if (ref.read(noisePlaybackProvider).isPlaying) {
        await controller.pause();
      } else {
        await controller.resume();
      }
      return;
    }

    try {
      await controller.play(kind);
    } on NoisePlaybackException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('${kind.label} 播放失败：${e.reason}')),
      );
    }
  }
}

/// 区块标题。
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, this.trailing});

  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: AppSizes.gap8),
        const Expanded(child: Divider(height: 1)),
        if (trailing != null) ...[
          const SizedBox(width: AppSizes.gap8),
          Text(
            trailing!,
            style: const TextStyle(
              color: AppColors.primaryText,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}

/// 顶部播放条。
class _NowPlayingBar extends StatelessWidget {
  const _NowPlayingBar({required this.playback, required this.onToggle});

  final NoisePlaybackSnapshot playback;
  final Future<void> Function() onToggle;

  @override
  Widget build(BuildContext context) {
    final kind = playback.kind;

    if (kind == null) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.gap16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          border: Border.all(color: AppColors.outline),
        ),
        child: const Row(
          children: [
            IconDataWidget(
              name: TaillimitIcons.noise,
              size: 28,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: AppSizes.gap12),
            Expanded(
              child: Text(
                '选择一种环境音开始',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.gap16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: playback.isPlaying
              ? AppColors.primary
              : AppColors.outline,
        ),
      ),
      child: Row(
        children: [
          _Waves(active: playback.isPlaying),
          const SizedBox(width: AppSizes.gap12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kind.label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.gap4),
                Text(
                  playback.isPlaying
                      ? (playback.hasTimer
                            ? '播放中 · ${playback.remainingLabel}后停止'
                            : '播放中 · 不定时')
                      : '已暂停',
                  style: TextStyle(
                    color: playback.isPlaying
                        ? AppColors.primaryText
                        : AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onToggle,
            icon: IconDataWidget(
              name: playback.isPlaying
                  ? TaillimitIcons.pause
                  : TaillimitIcons.play,
              size: 28,
              color: AppColors.primary,
            ),
            iconSize: 28,
            tooltip: playback.isPlaying ? '暂停' : '继续',
          ),
        ],
      ),
    );
  }
}

/// 播放时的声波动画。
class _Waves extends StatefulWidget {
  const _Waves({required this.active});

  final bool active;

  @override
  State<_Waves> createState() => _WavesState();
}

class _WavesState extends State<_Waves> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _controller.repeat();
  }

  @override
  void didUpdateWidget(_Waves old) {
    super.didUpdateWidget(old);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.active && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => CustomPaint(
          painter: _WavesPainter(
            phase: _controller.value,
            color: widget.active ? AppColors.primary : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}

class _WavesPainter extends CustomPainter {
  _WavesPainter({required this.phase, required this.color});

  final double phase;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final Offset center = Offset(size.width * 0.22, size.height / 2);

    // 声源点
    canvas.drawCircle(center, 2.4, paint..style = PaintingStyle.fill);
    paint.style = PaintingStyle.stroke;

    // 三道向外扩散的弧，半径随时间脉动
    for (int i = 0; i < 3; i++) {
      final double t = (phase + i / 3) % 1.0;
      final double r = 4 + t * 11;
      final double alpha = (1.0 - t) * 0.9;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        -0.85,
        1.7,
        false,
        paint..color = color.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(_WavesPainter old) =>
      old.phase != phase || old.color != color;
}

/// 音色卡片。
class _NoiseTile extends StatelessWidget {
  const _NoiseTile({
    required this.kind,
    required this.selected,
    required this.playing,
    required this.onTap,
  });

  final NoiseKind kind;
  final bool selected;
  final bool playing;
  final VoidCallback onTap;

  /// 音色的补充说明。
  static String _hintOf(NoiseKind kind) {
    switch (kind) {
      case NoiseKind.white:
        return '全频段 · 掩盖力强';
      case NoiseKind.pink:
        return '低频加权 · 自然感';
      case NoiseKind.brown:
        return '低频主导 · 接近瀑布';
      case NoiseKind.rain:
        return '低通滤波 · 助眠';
      case NoiseKind.waves:
        return '涌浪包络 · 0.09Hz';
      case NoiseKind.campfire:
        return '随机爆裂 · 夜晚';
      case NoiseKind.wind:
        return '带通漂移 · 通风口';
      case NoiseKind.cafe:
        return '人声频段 · 咖啡屋';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primaryContainer : AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSizes.gap12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.outline,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconDataWidget(
                    name: TaillimitIcons.noise,
                    size: 22,
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  const Spacer(),
                  if (playing)
                    const IconDataWidget(
                      name: TaillimitIcons.play,
                      size: 14,
                      color: AppColors.primary,
                    )
                  else if (selected)
                    const IconDataWidget(
                      name: TaillimitIcons.pause,
                      size: 14,
                      color: AppColors.primary,
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    kind.label,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _hintOf(kind),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 定时预设选择。
class _TimerPicker extends StatelessWidget {
  const _TimerPicker({
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  /// 当前定时器（用于反查预设）。
  final SleepTimer? selected;
  final bool enabled;
  final ValueChanged<SleepTimerPreset> onChanged;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Wrap(
        spacing: AppSizes.gap8,
        runSpacing: AppSizes.gap8,
        children: [
          for (final SleepTimerPreset preset in SleepTimerPreset.values)
            _TimerChip(
              preset: preset,
              // 通过时长反查是否选中：定时器记录的是结束时刻，
              // 需与各预设时长比对才能还原用户的选择
              selected: _isSelected(preset),
              onTap: enabled ? () => onChanged(preset) : null,
            ),
        ],
      ),
    );
  }

  bool _isSelected(SleepTimerPreset preset) {
    final timer = selected;
    if (timer == null || timer.isOff) return preset.isOff;
    if (preset.isOff) return false;
    // 直接比对总时长——SleepTimer 已记录 totalSeconds，无需从 endsAt 反推
    return timer.totalSeconds == preset.seconds;
  }
}

class _TimerChip extends StatelessWidget {
  const _TimerChip({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  final SleepTimerPreset preset;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.chipRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.chipRadius),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.gap16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.chipRadius),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.outline,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!preset.isOff) ...[
                IconDataWidget(
                  name: TaillimitIcons.timer,
                  size: 14,
                  color: selected
                      ? AppColors.onPrimary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                preset.label,
                style: TextStyle(
                  color: selected
                      ? AppColors.onPrimary
                      : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 定时进度条。
class _TimerProgress extends StatelessWidget {
  const _TimerProgress({
    required this.timer,
    required this.remaining,
    required this.isPlaying,
  });

  final SleepTimer timer;
  final Duration remaining;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    final double ratio = timer.progress();
    final bool fading = timer.isFading();
    final Color accent = fading ? AppColors.estimated : AppColors.primary;
    final int totalMinutes = (timer.totalSeconds / 60).round();
    final String label = remaining.inSeconds >= 3600
        ? '${remaining.inHours}:'
              '${remaining.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
              '${remaining.inSeconds.remainder(60).toString().padLeft(2, '0')}'
        : '${(remaining.inSeconds / 60).ceil()} 分钟';

    return Container(
      padding: const EdgeInsets.all(AppSizes.gap12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: fading ? AppColors.estimated : AppColors.outline,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconDataWidget(name: TaillimitIcons.timer, size: 16, color: accent),
              const SizedBox(width: AppSizes.gap8),
              Expanded(
                child: Text(
                  fading ? '正在渐弱…' : '剩余 $label',
                  style: TextStyle(color: accent, fontSize: 13),
                ),
              ),
              Text(
                '共 $totalMinutes 分钟',
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.gap12),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 3,
              backgroundColor: AppColors.surfaceElevated,
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
        ],
      ),
    );
  }
}

/// 音量控制。
class _VolumeControl extends StatelessWidget {
  const _VolumeControl({
    required this.volume,
    required this.enabled,
    required this.onChanged,
  });

  final double volume;
  final bool enabled;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Row(
        children: [
          const IconDataWidget(
            name: TaillimitIcons.noise,
            size: 16,
            color: AppColors.textTertiary,
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.surfaceElevated,
                thumbColor: AppColors.primary,
                trackHeight: 3,
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              ),
              child: Slider(
                value: volume,
                onChanged: enabled ? onChanged : null,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '${(volume * 100).round()}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 车机右侧详情。
class _NoiseDetail extends ConsumerWidget {
  const _NoiseDetail({required this.kind, required this.playback});

  final NoiseKind kind;
  final NoisePlaybackSnapshot playback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.gap24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const IconDataWidget(
                name: TaillimitIcons.noise,
                size: 32,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSizes.gap12),
              Text(
                kind.label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.gap16),
          const Text(
            '算法实时合成，无音频素材。无缝循环，不占用额外存储。',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: AppSizes.gap16),
          if (playback.hasTimer)
            Row(
              children: [
                const IconDataWidget(
                  name: TaillimitIcons.timer,
                  size: 16,
                  color: AppColors.primaryText,
                ),
                const SizedBox(width: AppSizes.gap8),
                Text(
                  playback.remainingLabel,
                  style: const TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSizes.gap24),
          FilledButton.icon(
            onPressed: () => ref.read(noisePlaybackProvider.notifier).toggle(),
            icon: IconDataWidget(
              name: playback.isPlaying
                  ? TaillimitIcons.pause
                  : TaillimitIcons.play,
              size: 18,
              color: AppColors.onPrimary,
            ),
            label: Text(playback.isPlaying ? '暂停' : '继续'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, AppSizes.carTouchTarget),
            ),
          ),
          const SizedBox(height: AppSizes.gap12),
          OutlinedButton.icon(
            onPressed: () => ref.read(noisePlaybackProvider.notifier).stop(),
            icon: const IconDataWidget(
              name: TaillimitIcons.stop,
              size: 18,
              color: AppColors.textSecondary,
            ),
            label: const Text('停止并清除定时'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.outline),
              minimumSize: const Size(0, AppSizes.carTouchTarget),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoiseNotice extends StatelessWidget {
  const _NoiseNotice();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconDataWidget(
          name: TaillimitIcons.cached,
          size: 14,
          color: AppColors.textTertiary,
        ),
        SizedBox(width: AppSizes.gap8),
        Expanded(
          child: Text(
            '长时间聆听建议音量不超过 60%。定时结束前 20 秒会渐弱至静音，'
            '避免突然的爆音惊扰。',
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11.5,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
