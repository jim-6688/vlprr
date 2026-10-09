import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/noise.dart';
import '../../../domain/repositories/media_gateways.dart';

/// 噪音播放异常。
class NoisePlaybackException implements Exception {
  const NoisePlaybackException(this.kind, this.reason);

  final NoiseKind kind;
  final String reason;

  @override
  String toString() => 'NoisePlaybackException(${kind.label}: $reason)';
}

/// 白噪音播放状态快照。
@immutable
class NoisePlaybackSnapshot {
  const NoisePlaybackSnapshot({
    this.kind,
    this.timer,
    this.isPlaying = false,
    this.volume = 0.5,
    this.remaining = Duration.zero,
    this.errorReason,
  });

  /// 当前音效。
  final NoiseKind? kind;

  /// 定时器，null 表示未设置定时。
  final SleepTimer? timer;

  /// 是否正在播放。
  final bool isPlaying;

  /// 音量（0.0–1.0）。
  final double volume;

  /// 定时器剩余时长。[isPlaying] 为 true 时有效。
  final Duration remaining;

  final String? errorReason;

  /// 是否设定了定时。
  bool get hasTimer => timer != null && !timer!.isOff;

  /// 剩余分钟数（向上取整），用于界面显示。
  int get remainingMinutes => (remaining.inSeconds / 60).ceil();

  /// 剩余秒数，60 分钟以上显示"HH:MM:SS"。
  String get remainingLabel {
    if (!hasTimer) return '';
    if (!isPlaying) return '已暂停';
    if (remaining.inSeconds >= 3600) {
      final int h = remaining.inHours;
      final int m = remaining.inMinutes.remainder(60);
      final int s = remaining.inSeconds.remainder(60);
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '$remainingMinutes 分钟';
  }

  NoisePlaybackSnapshot copyWith({
    NoiseKind? kind,
    SleepTimer? timer,
    bool? isPlaying,
    double? volume,
    Duration? remaining,
    String? errorReason,
    bool clearError = false,
    bool clearTimer = false,
  }) {
    return NoisePlaybackSnapshot(
      kind: kind ?? this.kind,
      timer: clearTimer ? null : (timer ?? this.timer),
      isPlaying: isPlaying ?? this.isPlaying,
      volume: volume ?? this.volume,
      remaining: remaining ?? this.remaining,
      errorReason: clearError ? null : (errorReason ?? this.errorReason),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is NoisePlaybackSnapshot &&
      other.kind == kind &&
      other.timer == timer &&
      other.isPlaying == isPlaying &&
      other.volume == volume &&
      other.remaining == remaining &&
      other.errorReason == errorReason;

  @override
  int get hashCode =>
      Object.hash(kind, timer, isPlaying, volume, remaining, errorReason);
}

/// 白噪音播放控制器。
///
/// 定时器采用**每秒 tick** 驱动，而非 `Future.delayed(endsAt)`一次性等待——
/// 后者在 App 被系统挂起后计时会失准，逐秒 tick 配合 [SleepTimer.endsAt]
/// 可在恢复时立即校正。
class NoisePlaybackController extends StateNotifier<NoisePlaybackSnapshot> {
  NoisePlaybackController(this._gateway) : super(const NoisePlaybackSnapshot());

  final NoiseGateway _gateway;
  Timer? _ticker;

  /// 注入时钟，便于测试。
  @visibleForTesting
  DateTime Function() now = DateTime.now;

  Future<void> play(NoiseKind kind) async {
    // 未设定定时时，按音效的推荐时长自动起一个（雨/海浪等长音30–45 分钟，
    // 纯噪音音 30 分钟）。用户随后可随时改。
    final SleepTimer fallback = SleepTimer.fromPreset(
      kind.defaultDurationSeconds >= 3600
          ? SleepTimerPreset.minutes45
          : SleepTimerPreset.minutes30,
      start: now(),
      fadeOutSeconds: 20,
    );

    state = state.copyWith(
      kind: kind,
      isPlaying: true,
      clearError: true,
      timer: state.timer ?? fallback,
    );
    _syncRemaining();
    _startTicker();
    try {
      await _gateway.play(kind);
    } on NoisePlaybackException catch (e) {
      if (!mounted) return;
      state = state.copyWith(isPlaying: false, errorReason: e.reason);
      _stopTicker();
      rethrow;
    }
  }

  Future<void> toggle() async {
    if (state.kind == null) return;
    if (state.isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  Future<void> pause() async {
    await _gateway.pause();
    if (!mounted) return;
    state = state.copyWith(isPlaying: false);
    _stopTicker();
  }

  Future<void> resume() async {
    final kind = state.kind;
    if (kind == null) return;
    // 定时已到期则不再恢复，改为重新开始
    if (state.hasTimer && state.timer!.isExpired(now())) {
      await play(kind);
      return;
    }
    state = state.copyWith(isPlaying: true, clearError: true);
    _syncRemaining();
    _startTicker();
    await _gateway.resume();
  }

  Future<void> stop() async {
    _stopTicker();
    await _gateway.stop();
    if (!mounted) return;
    state = state.copyWith(isPlaying: false, clearTimer: true, remaining: Duration.zero);
  }

  Future<void> setVolume(double value) async {
    final double clamped = value.clamp(0.0, 1.0);
    state = state.copyWith(volume: clamped);
    await _gateway.setVolume(clamped);
  }

  /// 应用定时预设。传入 [SleepTimerPreset.off] 即取消定时。
  Future<void> setTimerPreset(SleepTimerPreset preset) async {
    if (preset.isOff) {
      state = state.copyWith(clearTimer: true, remaining: Duration.zero);
      return;
    }
    final SleepTimer timer = SleepTimer.fromPreset(preset, start: now());
    state = state.copyWith(timer: timer);
    _syncRemaining();
    if (state.isPlaying) _startTicker();
  }

  void _syncRemaining() {
    final timer = state.timer;
    if (timer == null || timer.isOff) {
      if (mounted) state = state.copyWith(remaining: Duration.zero);
      return;
    }
    if (mounted) {
      state = state.copyWith(remaining: timer.remaining(now()));
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  /// 定时器每拍的处理：同步剩余、按渐弱曲线调音量、到期则停止。
  ///
  /// 抽成方法而非写在 [Timer.periodic] 回调里，是为了让测试能用注入的
  /// 假时钟直接驱动这一拍，不必真的等 1 秒。
  void _onTick() {
    if (!mounted) return;
    final timer = state.timer;
    if (timer == null || timer.isOff) {
      _stopTicker();
      return;
    }
    final DateTime current = now();
    _syncRemaining();

    // 渐弱阶段同步调整音量
    final double factor = timer.volumeFactor(current);
    state = state.copyWith(volume: factor);

    if (timer.isExpired(current)) {
      _stopTicker();
      _gateway.stop();
      state = state.copyWith(
        isPlaying: false,
        remaining: Duration.zero,
        clearTimer: true,
      );
    }
  }

  /// 测试专用：立即执行一拍定时器逻辑。
  @visibleForTesting
  void debugTick() => _onTick();

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void dispose() {
    _stopTicker();
    _gateway.stop();
    super.dispose();
  }
}

/// 模拟网关：完整实现控制接口，不发出真实声音。
class SimulatedNoiseGateway implements NoiseGateway {
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  NoiseKind? _current;
  bool _playing = false;
  double _volume = 0.5;

  /// 下一次 [play] 是否应失败。
  bool failNextPlay = false;

  @override
  NoiseKind? get current => _current;

  @override
  bool get isPlaying => _playing;

  @override
  double get volume => _volume;

  @override
  Stream<bool> get playingStream => _controller.stream;

  @override
  Future<void> play(NoiseKind kind) async {
    if (failNextPlay) {
      failNextPlay = false;
      throw NoisePlaybackException(kind, '音频引擎不可用');
    }
    _current = kind;
    _playing = true;
    if (!_controller.isClosed) _controller.add(true);
  }

  @override
  Future<void> pause() async {
    _playing = false;
    if (!_controller.isClosed) _controller.add(false);
  }

  @override
  Future<void> resume() async {
    if (_current == null) return;
    _playing = true;
    if (!_controller.isClosed) _controller.add(true);
  }

  @override
  Future<void> stop() async {
    _current = null;
    _playing = false;
    if (!_controller.isClosed) _controller.add(false);
  }

  @override
  Future<void> setVolume(double value) async => _volume = value.clamp(0.0, 1.0);

  Future<void> dispose() => _controller.close();
}

// ==================================================================
//  Providers
// ==================================================================

/// 噪音播放网关。覆盖此 provider 注入真实音频后端。
final noiseGatewayProvider = Provider<NoiseGateway>((ref) {
  final gateway = SimulatedNoiseGateway();
  ref.onDispose(gateway.dispose);
  return gateway;
});

/// 白噪音播放状态。
final noisePlaybackProvider =
    StateNotifierProvider<NoisePlaybackController, NoisePlaybackSnapshot>(
  (ref) => NoisePlaybackController(ref.watch(noiseGatewayProvider)),
);
