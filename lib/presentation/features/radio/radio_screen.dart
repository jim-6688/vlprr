import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/radio_station.dart';
import '../../../domain/repositories/media_gateways.dart';
import '../../widgets/car_adaptive_scaffold.dart';
import '../radio/radio_provider.dart';

/// 广播页：国家免费广播频道列表 + 播放控制。
///
/// 频道均为中央广播电视总台（央广）公开直播流，无需登录、无广告插播。
class RadioScreen extends ConsumerWidget {
  const RadioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(radioPlaybackProvider);

    return CarAdaptiveScaffold(
      title: '广播',
      primary: ListView(
        padding: EdgeInsets.fromLTRB(
          FormFactor.pagePadding(context),
          AppSizes.gap8,
          FormFactor.pagePadding(context),
          AppSizes.gap24,
        ),
        children: [
          _NowPlaying(playback: playback),
          const SizedBox(height: AppSizes.gap24),
          for (final MapEntry<RadioCategory, List<RadioStation>> entry
              in RadioDirectory.grouped.entries) ...[
            _CategoryHeader(category: entry.key, count: entry.value.length),
            const SizedBox(height: AppSizes.gap12),
            for (final RadioStation station in entry.value) ...[
              _StationTile(
                station: station,
                playback: playback,
                onTap: () => _toggle(context, ref, station, playback),
              ),
              const SizedBox(height: AppSizes.gap8),
            ],
            const SizedBox(height: AppSizes.gap16),
          ],
          const _RadioNotice(),
        ],
      ),
      secondary: playback.state == RadioPlaybackState.playing ||
              playback.state == RadioPlaybackState.paused
          ? _StationDetail(station: playback.station!, playback: playback)
          : null,
    );
  }

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    RadioStation station,
    RadioPlaybackSnapshot playback,
  ) async {
    final notifier = ref.read(radioPlaybackProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);

    // 再次点击当前频道 = 暂停/继续
    if (playback.station?.id == station.id &&
        playback.state != RadioPlaybackState.error) {
      if (playback.state == RadioPlaybackState.playing) {
        await notifier.pause();
      } else {
        await notifier.resume();
      }
      return;
    }

    try {
      await notifier.play(station);
    } on RadioPlaybackException catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('${station.name} 暂时无法连接：${e.reason}'),
          action: SnackBarAction(label: '重试', onPressed: () => notifier.play(station)),
        ),
      );
    }
  }
}

/// 正在播放的横幅。未播放时显示引导提示。
class _NowPlaying extends ConsumerWidget {
  const _NowPlaying({required this.playback});

  final RadioPlaybackSnapshot playback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final station = playback.station;

    if (station == null) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.gap16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          border: Border.all(color: AppColors.outline),
        ),
        child: const Row(
          children: [
            IconDataWidget(name: TaillimitIcons.radio, size: 28),
            SizedBox(width: AppSizes.gap12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '选择频道收听',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppSizes.gap4),
                  Text(
                    '全部为央广公开直播流',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                  ),
                ],
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
          color: playback.state == RadioPlaybackState.error
              ? AppColors.estimated
              : AppColors.primary.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          _Equalizer(
            active: playback.state == RadioPlaybackState.playing,
            errored: playback.state == RadioPlaybackState.error,
          ),
          const SizedBox(width: AppSizes.gap12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.gap4),
                Text(
                  _statusLabel(playback.state),
                  style: TextStyle(
                    color: playback.state == RadioPlaybackState.error
                        ? AppColors.estimated
                        : AppColors.primaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => ref.read(radioPlaybackProvider.notifier).toggle(),
            icon: IconDataWidget(
              name: playback.state == RadioPlaybackState.playing
                  ? TaillimitIcons.pause
                  : TaillimitIcons.play,
              size: 28,
              color: AppColors.primary,
            ),
            iconSize: 28,
            tooltip: playback.state == RadioPlaybackState.playing ? '暂停' : '播放',
          ),
        ],
      ),
    );
  }

  static String _statusLabel(RadioPlaybackState state) {
    switch (state) {
      case RadioPlaybackState.idle:
        return '待播放';
      case RadioPlaybackState.connecting:
        return '连接中…';
      case RadioPlaybackState.buffering:
        return '缓冲中…';
      case RadioPlaybackState.playing:
        return '正在直播';
      case RadioPlaybackState.paused:
        return '已暂停';
      case RadioPlaybackState.error:
        return '连接失败';
    }
  }
}

/// 均衡器动画：播放时跳动的柱状图形，错误时静止。
class _Equalizer extends StatefulWidget {
  const _Equalizer({required this.active, required this.errored});

  final bool active;
  final bool errored;

  @override
  State<_Equalizer> createState() => _EqualizerState();
}

class _EqualizerState extends State<_Equalizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _controller.repeat();
  }

  @override
  void didUpdateWidget(_Equalizer old) {
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
    final color = widget.errored ? AppColors.estimated : AppColors.primary;
    return SizedBox(
      width: 28,
      height: 28,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _EqualizerPainter(
            phase: _controller.value,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _EqualizerPainter extends CustomPainter {
  _EqualizerPainter({required this.phase, required this.color});

  final double phase;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.6;

    const int bars = 4;
    final double slot = size.width / bars;
    for (int i = 0; i < bars; i++) {
      // 每根柱子的相位错开，形成波浪式起伏
      final double t = (phase + i * 0.22) % 1.0;
      final double h = 6 + 18 * _wave(t);
      final double x = slot * i + slot / 2;
      canvas.drawLine(
        Offset(x, (size.height - h) / 2),
        Offset(x, (size.height + h) / 2),
        paint,
      );
    }
  }

  /// 0→1→0 的平滑包络。
  static double _wave(double t) {
    final double v = 1 - (2 * t - 1).abs();
    return v * v;
  }

  @override
  bool shouldRepaint(_EqualizerPainter old) =>
      old.phase != phase || old.color != color;
}

/// 分类标题。
class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.category, required this.count});

  final RadioCategory category;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          category.label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: AppSizes.gap8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}

/// 频道行。
class _StationTile extends StatelessWidget {
  const _StationTile({
    required this.station,
    required this.playback,
    required this.onTap,
  });

  final RadioStation station;
  final RadioPlaybackSnapshot playback;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isCurrent = playback.station?.id == station.id;
    final bool isPlaying =
        isCurrent && playback.state == RadioPlaybackState.playing;
    final minHeight = FormFactor.touchTarget(context);

    return Material(
      color: isCurrent ? AppColors.primaryContainer : AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: minHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.gap16,
            vertical: AppSizes.gap12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(
              color: isCurrent ? AppColors.primary : AppColors.outline,
            ),
          ),
          child: Row(
            children: [
              IconDataWidget(
                name: isPlaying ? TaillimitIcons.pause : TaillimitIcons.play,
                size: 20,
                color: isCurrent ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSizes.gap12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            station.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: isCurrent
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.gap8),
                        Text(
                          station.frequency,
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                        if (station.isFallback) ...[
                          const SizedBox(width: AppSizes.gap8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.estimatedContainer,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Text(
                              '备用',
                              style: TextStyle(
                                color: AppColors.estimated,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSizes.gap4),
                    Text(
                      station.description,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 车机右侧详情栏。
class _StationDetail extends ConsumerWidget {
  const _StationDetail({required this.station, required this.playback});

  final RadioStation station;
  final RadioPlaybackSnapshot playback;

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
              const IconDataWidget(name: TaillimitIcons.radio, size: 32),
              const SizedBox(width: AppSizes.gap12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      station.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${station.frequency} · ${station.category.label}',
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.gap16),
          Text(
            station.description,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: AppSizes.gap24),
          FilledButton.icon(
            onPressed: () => ref.read(radioPlaybackProvider.notifier).toggle(),
            icon: IconDataWidget(
              name: playback.state == RadioPlaybackState.playing
                  ? TaillimitIcons.pause
                  : TaillimitIcons.play,
              size: 18,
              color: AppColors.onPrimary,
            ),
            label: Text(
              playback.state == RadioPlaybackState.playing ? '暂停' : '继续收听',
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, AppSizes.carTouchTarget),
            ),
          ),
        ],
      ),
    );
  }
}

/// 页面底部说明：数据来源与版权提示。
class _RadioNotice extends StatelessWidget {
  const _RadioNotice();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: AppSizes.gap8),
      child: Row(
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
              '直播流来自中央广播电视总台及中国国际广播电台公开接口，'
              '版权归原广播机构所有。本应用仅作收听入口，不存储、不转播音频内容。',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 11.5,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
