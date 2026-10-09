import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/radio_station.dart';
import '../../../domain/repositories/media_gateways.dart';

/// 播放失败异常。
class RadioPlaybackException implements Exception {
  const RadioPlaybackException(this.station, this.reason);

  final RadioStation station;

  /// 面向用户的中文失败原因。
  final String reason;

  @override
  String toString() => 'RadioPlaybackException(${station.name}: $reason)';
}

/// 播放状态快照。
@immutable
class RadioPlaybackSnapshot {
  const RadioPlaybackSnapshot({
    this.station,
    this.state = RadioPlaybackState.idle,
    this.errorReason,
  });

  /// 当前频道。
  final RadioStation? station;

  /// 播放状态。
  final RadioPlaybackState state;

  /// 失败原因，仅 [RadioPlaybackState.error] 时非空。
  final String? errorReason;

  /// 是否正在播放。
  bool get isPlaying => state == RadioPlaybackState.playing;

  RadioPlaybackSnapshot copyWith({
    RadioStation? station,
    RadioPlaybackState? state,
    String? errorReason,
    bool clearError = false,
  }) {
    return RadioPlaybackSnapshot(
      station: station ?? this.station,
      state: state ?? this.state,
      errorReason: clearError ? null : (errorReason ?? this.errorReason),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is RadioPlaybackSnapshot &&
      other.station?.id == station?.id &&
      other.state == state &&
      other.errorReason == errorReason;

  @override
  int get hashCode => Object.hash(station?.id, state, errorReason);
}

/// 广播播放控制器。
///
/// 播放后端通过 [radioGatewayProvider] 注入。真实实现需要 `just_audio`，
/// 在无法联网安装依赖的环境下会退化为 [_SimulatedRadioGateway]，
/// 它完整实现了状态机但不发出真实声音——界面逻辑与交互均可正常验证。
class RadioPlaybackController extends StateNotifier<RadioPlaybackSnapshot> {
  RadioPlaybackController(this._gateway) : super(const RadioPlaybackSnapshot()) {
    _sub = _gateway.stateStream.listen(_onGatewayState);
  }

  final RadioGateway _gateway;
  late final StreamSubscription<RadioPlaybackState> _sub;

  void _onGatewayState(RadioPlaybackState next) {
    if (!mounted) return;
    // 网关只回报状态，不回报频道，因此只更新 state 字段
    state = state.copyWith(
      state: next,
      clearError: next != RadioPlaybackState.error,
    );
  }

  Future<void> play(RadioStation station) async {
    state = state.copyWith(
      station: station,
      state: RadioPlaybackState.connecting,
      clearError: true,
    );
    try {
      await _gateway.play(station);
    } on RadioPlaybackException catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        state: RadioPlaybackState.error,
        errorReason: e.reason,
      );
      rethrow;
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        state: RadioPlaybackState.error,
        errorReason: '未知错误',
      );
      rethrow;
    }
  }

  Future<void> pause() => _gateway.pause();

  Future<void> resume() => _gateway.resume();

  Future<void> toggle() async {
    switch (state.state) {
      case RadioPlaybackState.playing:
        await pause();
      case RadioPlaybackState.paused:
        await resume();
      case RadioPlaybackState.idle:
      case RadioPlaybackState.connecting:
      case RadioPlaybackState.buffering:
      case RadioPlaybackState.error:
        final RadioStation? station = state.station;
        if (station != null) await play(station);
    }
  }

  Future<void> stop() async {
    await _gateway.stop();
    if (mounted) state = const RadioPlaybackSnapshot();
  }

  @override
  void dispose() {
    _sub.cancel();
    _gateway.stop();
    super.dispose();
  }
}

/// 模拟网关：不发真实声音，但完整实现播放状态机。
///
/// 用于两种场景：
/// 1. 无网络 / 无法安装音频依赖时的降级路径；
/// 2. 单元测试中注入可控的播放行为。
class SimulatedRadioGateway implements RadioGateway {
  SimulatedRadioGateway({this.connectLatency = const Duration(milliseconds: 600)});

  /// 模拟连接耗时。
  final Duration connectLatency;

  final StreamController<RadioPlaybackState> _controller =
      StreamController<RadioPlaybackState>.broadcast();

  RadioStation? _current;
  RadioPlaybackState _state = RadioPlaybackState.idle;

  /// 下一次 [play] 是否应失败（供测试注入失败路径）。
  bool failNextPlay = false;

  @override
  RadioStation? get current => _current;

  @override
  RadioPlaybackState get state => _state;

  @override
  Stream<RadioPlaybackState> get stateStream => _controller.stream;

  void _emit(RadioPlaybackState next) {
    _state = next;
    if (!_controller.isClosed) _controller.add(next);
  }

  @override
  Future<void> play(RadioStation station) async {
    await stop();
    _current = station;

    if (failNextPlay) {
      failNextPlay = false;
      _emit(RadioPlaybackState.error);
      throw RadioPlaybackException(station, '网络不可用');
    }

    _emit(RadioPlaybackState.connecting);
    await Future<void>.delayed(connectLatency);
    if (_current != station) return; // 期间被新的 play 取代
    _emit(RadioPlaybackState.playing);
  }

  @override
  Future<void> pause() async {
    if (_current == null) return;
    _emit(RadioPlaybackState.paused);
  }

  @override
  Future<void> resume() async {
    if (_current == null) return;
    _emit(RadioPlaybackState.playing);
  }

  @override
  Future<void> stop() async {
    if (_state == RadioPlaybackState.idle) return;
    _current = null;
    _emit(RadioPlaybackState.idle);
  }

  Future<void> dispose() => _controller.close();
}

// ==================================================================
//  Providers
// ==================================================================

/// 播放网关。
///
/// 覆盖此 provider 即可注入真实音频后端或测试替身。
final radioGatewayProvider = Provider<RadioGateway>((ref) {
  final gateway = SimulatedRadioGateway();
  ref.onDispose(gateway.dispose);
  return gateway;
});

/// 广播播放状态。
final radioPlaybackProvider =
    StateNotifierProvider<RadioPlaybackController, RadioPlaybackSnapshot>(
  (ref) => RadioPlaybackController(ref.watch(radioGatewayProvider)),
);
