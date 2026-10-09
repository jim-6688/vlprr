# TailLimit 媒体功能交付说明

> 版本：v0.2.0 · 提交 `c17bd24` · 2026-10-09

## 一、本轮需求

底部导航调整为四栏：

| 栏位 | 功能 | 状态 |
|---|---|---|
| 1 | 今日 | 原有，限行主视图 |
| 2 | 广播 | **新增**，对接国家免费广播频道 |
| 3 | 白噪音 | **新增**，支持定时 |
| 4 | 设置 | 原有，新增「限行数据」入口组 |

原「限行日历 / 我的车牌 / 关注城市」三页不再占用一级导航，路由全部保留：

- 手机版：设置页 → 限行数据 → 三个入口
- 车机版：左侧 Rail 的「限行数据」分组直接平铺

这样处理的理由：这三个页面是「今日」的辅助视图（换个日期看看、看自己的车牌、查其他城市），一级入口位有限，而驾驶场景下高频操作只有「今天限不限」和「现在能上高速吗」。

## 二、广播

### 2.1 频道来源

全部为官方直播流，实测可用后才入库：

| 频道 | 地址 |
|---|---|
| 中国之声 | `https://ngcdn001.cnr.cn/live/zgzs/index.m3u8` |
| 经济之声 | `https://ngcdn001.cnr.cn/live/jjzs/index.m3u8` |
| 音乐之声 | `https://ngcdn001.cnr.cn/live/yyzs/index.m3u8` |
| 中华之声 | `https://ngcdn001.cnr.cn/live/zhzs/index.m3u8` |
| 文艺之声 | `https://ngcdn001.cnr.cn/live/wyzs/index.m3u8` |
| 环球资讯 | `http://sk.cri.cn/905.m3u8` |

**已剔除的失效源**（避免用户点了打不开）：

- `http://live.xmcdn.com/live/1065/64.m3u8` — 返回 JSON 错误「电台流获取失败」
- `https://ngcdn001.cnr.cn/live/gsglt/index.m3u8` — HTTP 404
- `http://sk.cri.cn/915.m3u8` — HTTP 404

### 2.2 状态机

`RadioPlaybackController` 六态流转：

```
idle → connecting → buffering → playing ⇄ paused
                ↓              ↓
              error ←──────────┘
```

失败后重播会清掉 `errorReason`，否则界面会一直挂错误条——这条已写成测试用例守着。

## 三、白噪音

### 3.1 音色

8 种**全部算法实时合成**，不打包任何音频素材，包体不增加：

| 类型 | 合成方式 |
|---|---|
| 白噪音 | 均匀随机 |
| 粉噪音 / 咖啡馆 / 夜风 | Paul Kellet 三极点滤波 |
| 棕噪音 / 篝火 | 两级低通 |
| 雨声 | 低通滤波 |
| 海浪 | 低频噪声 + 0.09 Hz / 0.031 Hz 双包络 |

末尾统一软限幅，避免削波爆音。

### 3.2 定时

`SleepTimer` 存的是**结束时刻**而不是剩余秒数：

```dart
final DateTime? endsAt;
final int totalSeconds;
final int fadeOutSeconds;
```

原因：iOS/Android 在后台会节流 Timer，如果按秒累加计数，切后台十分钟回来定时器会走慢好几分钟。存结束时刻则任何时候重新计算都准确。

六档预设：不定时 / 15 / 30 / 45 / 60 / 120 分钟。

**渐弱**：到期前 20 秒音量线性降到 0，避免「啪」地一声切断。

**兜底策略**：用户没手动设定时时，按音效推荐时长自动起一个（环境音 45 分钟、纯噪音 30 分钟），防止用户开着白噪音睡着后整夜播放。

## 四、测试

`139` 项全部通过，`flutter analyze` 零告警。

| 文件 | 覆盖 |
|---|---|
| `test/domain/media_test.dart` | 频道目录完整性、SleepTimer 全部方法、波形合成正确性（白噪音高频能量 > 棕噪音、海浪包络起伏、种子可复现） |
| `test/presentation/media_flow_test.dart` | 四栏导航结构、广播状态机六态、白噪音定时全链路（含到期渐弱到停止） |

本轮修掉的两个问题：

1. **渐弱断言时间点错误**（原测试代码有 bug，实现是对的）
   渐弱区间是 `[29:40, 30:00]`，测试取 `29:45` 只走过 5 秒，结果应为 0.75 而非 0.5。已改为每 5 秒采样一次验证整条线性曲线。

2. **定时器无法测试**
   把 `Timer.periodic` 的回调体抽成 `_onTick()`，配合可注入的 `now` 假时钟，测试直接驱动每一拍，不必真的等 15 分钟。

## 五、尚未完成

| 项 | 说明 |
|---|---|
| 真实音频输出 | 当前用 `SimulatedRadioGateway` / `SimulatedNoiseGateway`，只跑状态机不发声 |
| 后台播放与锁屏控制 | 需 `audio_service` |
| Android 音频焦点 | 需接 `AudioFocusRequest`，处理来电/导航播报打断 |
| iOS 后台音频 | 需配 `UIBackgroundModes: audio` |
| 鸿蒙音频播放 | 需 ArkTS 侧实现 |
| 偏好持久化 | 上次频道、音量、音效、定时预设均未落盘 |

### 接入真实后端的改动范围

只需覆盖两个 Provider，无需动 UI 和领域层：

```dart
// lib/presentation/features/radio/radio_provider.dart
final radioGatewayProvider = Provider<RadioGateway>((ref) => ...);

// lib/presentation/features/noise/noise_provider.dart
final noiseGatewayProvider = Provider<NoiseGateway>((ref) => ...);
```

`RadioGateway` / `NoiseGateway` 接口已按真实播放语义定义（`play/pause/resume/stop/setVolume` + 状态流），实现类直接替换即可。

### 建议的依赖选型

| 用途 | 选型 | 理由 |
|---|---|---|
| 广播 | `just_audio` | 原生支持 HLS/m3u8，三平台一致 |
| 白噪音 | `flutter_sound` 或自写 PCM 插件 | 需要实时写入 PCM 缓冲，`just_audio` 只能播文件，不适配算法合成 |
| 后台 | `audio_service` | 三平台统一的后台任务与媒体通知 |

**注意**：白噪音不能用 `just_audio`。它是算法逐样本生成的，需要能持续 push PCM 音频缓冲，这跟播文件的模型不同。