import '../entities/noise.dart';
import '../entities/radio_station.dart';

/// 广播播放网关。
///
/// 抽象出来是为了让领域层不依赖 just_audio——播放实现属于基础设施细节。
abstract class RadioGateway {
  /// 当前正在播放的频道；未播放时为 null。
  RadioStation? get current;

  /// 播放状态。
  RadioPlaybackState get state;

  /// 播放指定频道。调用前应先 [stop]。
  Future<void> play(RadioStation station);

  /// 暂停。
  Future<void> pause();

  /// 继续播放。
  Future<void> resume();

  /// 停止并释放资源。
  Future<void> stop();

  /// 监听播放状态变化。
  Stream<RadioPlaybackState> get stateStream;
}

/// 广播播放状态。
enum RadioPlaybackState {
  /// 空闲，未加载任何频道。
  idle,

  /// 正在连接流。
  connecting,

  /// 正在缓冲。
  buffering,

  /// 正在播放。
  playing,

  /// 已暂停。
  paused,

  /// 播放出错。
  error,
}

/// 白噪音播放网关。
abstract class NoiseGateway {
  /// 当前播放的音效类型；未播放时为 null。
  NoiseKind? get current;

  /// 是否正在播放。
  bool get isPlaying;

  /// 开始播放指定音效。
  Future<void> play(NoiseKind kind);

  /// 暂停。
  Future<void> pause();

  /// 继续。
  Future<void> resume();

  /// 停止并释放资源。
  Future<void> stop();

  /// 设置音量（0.0–1.0）。
  Future<void> setVolume(double volume);

  /// 播放状态变化通知。
  Stream<bool> get playingStream;

  /// 当前音量。
  double get volume;
}

/// 白噪音偏好设置。
///
/// [lastKind] 用于恢复上次选择，[volume] 为上次音量。
abstract class NoiseRepository {
  /// 上次播放的音效类型。
  NoiseKind? get lastKind;

  /// 上次使用的定时器预设。
  SleepTimerPreset get lastTimerPreset;

  /// 上次音量。
  double get volume;

  Future<void> saveLastKind(NoiseKind kind);

  Future<void> saveTimerPreset(SleepTimerPreset preset);

  Future<void> saveVolume(double volume);
}

/// 广播偏好设置。
abstract class RadioRepository {
  /// 上次收听的频道 id。
  String? get lastStationId;

  /// 上次收听对应的频道实体。
  ///
  /// 频道目录更新后，旧的 id 可能已失效，此时返回 null 而非抛异常。
  RadioStation? get lastStation;

  /// 上次音量。
  double get volume;

  Future<void> saveLastStation(String stationId);

  Future<void> saveVolume(double volume);
}
