# iOS 端构建指南

---

## 一、环境要求

| 项目 | 版本要求 |
|---|---|
| macOS | 13 Ventura 或更高 |
| Xcode | 15.0 或更高 |
| iOS Deployment Target | **15.0**（时效性通知要求） |
| CocoaPods | 1.14+ |
| Flutter | 3.47.7（官方 SDK 即可，无需 Flutter-OH） |

> ⚠️ **iOS 构建必须在 macOS 上进行**。Linux/Windows 无法编译 iOS 产物。

---

## 二、构建与运行

```bash
flutter pub get
cd ios && pod install && cd ..

# 调试运行
flutter run -d <ios-device-id>

# 发布构建
flutter build ipa --release
```

产物：`build/ios/ipa/tail_limit.ipa`

### 配置 Bundle ID 与签名

1. 用 Xcode 打开 `ios/Runner.xcworkspace`
2. `Runner → Signing & Capabilities`
3. 设置 Team 与 Bundle Identifier（如 `com.taillimit.tailLimit`）
4. 勾选 `Automatically manage signing`

---

## 三、强提醒能力

| 手段 | 实现 | 说明 |
|---|---|---|
| 准点触发 | `UNCalendarNotificationTrigger` | 系统级，应用被杀死仍生效 |
| 突破专注模式 | `UNNotificationInterruptionLevel.timeSensitive` | **iOS 15+**，关键 |
| 语音播报 | `AVSpeechSynthesizer`（中文，语速 0.95） | 应用内或后台播放 |
| 声音 | `UNNotificationSound.defaultCritical` ❌ / `default` ✅ | 见下文 |

### 时效性通知（Time Sensitive）

这是 iOS 端"强提醒"的核心。普通通知在**专注模式**下会被静默，
而 `timeSensitive` 级别的通知可以突破专注模式过滤，强制展示在锁屏。

前提：
1. iOS 15 或更高
2. 用户在 `设置 → 专注模式` 中开启"时效性通知"
3. 应用在 `Info.plist` 中声明 `NSUserNotificationsUsageDescription`

实现代码：`tail_limit_alert_plugin/ios/Classes/TailLimitAlertPlugin.swift`

```swift
if #available(iOS 15.0, *) {
    content.interruptionLevel = .timeSensitive
}
```

### 关于 Critical Alerts（紧急警报）

iOS 有一个比时效性通知更强的级别：**Critical Alerts**（可在静音模式下强制响铃）。

> **本项目不实现 Critical Alerts。**
>
> 原因：Apple 对 Critical Alerts 采用**逐应用审批制**，仅授予
> 健康、安全、公共安全类应用（如紧急医疗、家庭安防、灾害预警）。
> 车辆限号提醒属于生活便利类，**几乎不可能通过审批**。
>
> 若强行申请被拒，反而可能影响正常审核流程。因此 TailLimit 采用
> `timeSensitive` 作为 iOS 端强提醒的最强可用手段。

### 64 条待触发通知硬限制

iOS 系统对每个应用的**待触发本地通知上限为 64 条**，超出部分被系统静默丢弃。

本项目在**领域层**统一处理（`ReminderPlanner(maxPending: 60)`）：

```dart
// lib/domain/services/reminder_planner.dart
final targets = ... // 生成的提醒列表
if (targets.length > maxPending) {
  // 排序策略：日期近的优先 → 强提醒优先
  targets.sort(...);
  return targets.take(maxPending).toList();
}
```

留出 4 条余量，避免与系统其他通知冲突。

**容量测算**：假设绑定 2 辆车、关注 1 个城市、每车每周限行 1 天，
则每周产生 `2 × 1 × 2（预告+强提醒）= 4` 条，60 条可覆盖 **15 周**。
多车多城市场景下也不会触及上限。

---

## 四、车机（CarPlay）

### 现状

**CarPlay 当前未实现。** 原因：

1. CarPlay 要求应用属于特定类别（导航、音频、通讯、EV 充电、停车、快速点餐）
2. **限号提醒不在 Apple 允许的类别中**，无法通过审核
3. CarPlay 使用原生模板渲染，Flutter 无法直接绘制

### 可行的替代方案

| 方案 | 可行性 | 说明 |
|---|---|---|
| CarPlay 独立应用 | ❌ | 类别不符，审核必拒 |
| Apple Watch 应用 | ✅ | 手表震动提醒，适合"强提醒"场景 |
| 锁屏实时活动（Live Activity） | ✅ | iOS 16.1+，限行时段倒计时 |
| 快捷指令（Shortcuts）集成 | ✅ | 用户可自定义自动化 |

> **建议**：iOS 端不做车机适配，改为在 **Apple Watch** 上做镜像提醒。
> 手表贴身震动 + 抬腕即见，实际提醒效果优于车机屏幕。

---

## 五、后台限制与应对

| 限制 | 影响 | 应对 |
|---|---|---|
| 后台执行 30 秒上限 | 无法长时间后台运行 | 使用本地通知，不依赖后台进程 |
| 应用被杀死后不执行代码 | 排程无法动态调整 | `UNCalendarNotificationTrigger` 由系统托管 |
| 低电量模式 | 通知延迟 | 无法绕过，属系统行为 |
| 通知分组 | 多条提醒可能折叠 | 每条使用独立 `threadIdentifier` |

### 应用被杀死后的行为

iOS 与 Android 不同：**本地通知由系统托管，应用被杀死或设备重启后
依然会准时触发**。这是 iOS 端相对 Android 的优势（无需 `BootReceiver`）。

但代价是：应用无法在被杀死后**动态调整**已排程的通知。
因此本项目采取"**宁可多排，不可漏排**"策略：

1. 每次冷启动 / 数据同步后重排未来 60 条
2. 排程载荷**完全自足**（通知文案内联，触发时不读数据库）
3. 数据变更时按确定性 ID 覆盖旧排程

---

## 六、权限引导

iOS 通知授权只弹一次，被拒后需引导用户手动开启：

`设置 → 通知 → TailLimit → 允许通知`
（并单独开启"时效性通知"）

应用内"设置 → 权限与能力"页会展示当前状态。

### Info.plist 配置

需在 `ios/Runner/Info.plist` 中添加：

```xml
<key>NSUserNotificationsUsageDescription</key>
<string>用于在限号当日提醒你，避免违规出行</string>
```

---

## 七、常见问题

### Q1: `pod install` 失败

```bash
cd ios
rm -rf Pods Podfile.lock
pod repo update
pod install
```

### Q2: 通知不触发

检查顺序：
1. `设置 → 通知 → TailLimit → 允许通知` 是否开启
2. `设置 → 专注模式 → 时效性通知` 是否允许
3. 应用内"待触发提醒"确认已排程
4. 设备时间是否为自动（手动改时间会影响 `UNCalendarNotificationTrigger`）

### Q3: 时效性通知不生效

- 确认设备系统 **iOS 15+**
- 确认 `interruptionLevel` 已设置为 `.timeSensitive`
- 确认用户未关闭该应用的时效性通知开关

### Q4: 如何验证 64 条限制

```dart
final pending = await UNUserNotificationCenter.current()
    .getPendingNotificationRequests();
print('待触发通知数量：${pending.length}');
```

正常情况应 ≤ 60。

### Q5: 上架审核被拒理由 "缺少后台模式说明"

若声明了 `UIBackgroundModes`，需在 `Info.plist` 中说明用途。
本项目**不需要**任何后台模式（通知由系统托管），因此不要声明。

---

## 八、端能力对照

| 能力 | Android | iOS | 鸿蒙 |
|---|---|---|---|
| 准点触发 | `AlarmManager` | `UNCalendarNotificationTrigger` | `reminderAgentManager` |
| 全屏强提醒 | `setFullScreenIntent` | ❌ | `maxScreenWantAgent` |
| 突破专注/勿扰 | 通知渠道 + `ACCESS_NOTIFICATION_POLICY` | `.timeSensitive` | 渠道 `bypassDnd` |
| 语音播报 | `TextToSpeech` | `AVSpeechSynthesizer` | `@ohos.ai.tts` |
| 开机重建 | `BootReceiver` | 系统自动 | 系统托管 |
| 待触发上限 | ~500 | **64** | ~100 |
| 静音下强制响铃 | ✅（勿扰旁路） | ❌（需 Critical Alerts 特批） | ✅（渠道配置） |
| 车机 | AAOS ✅ / Auto ⚠️ | CarPlay ❌ | HarmonyOS Car ✅ |
