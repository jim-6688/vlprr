# 鸿蒙端（HarmonyOS / OpenHarmony）构建指南

> TailLimit 的鸿蒙支持依赖 **Flutter-OH**（OpenHarmony SIG 维护的 Flutter 分支）。
> 官方 Flutter SDK 不含 `ohos` 平台目录，必须切换到 Flutter-OH 才能生成鸿蒙工程。

---

## 一、为什么需要单独的 SDK

| 项目 | 官方 Flutter | Flutter-OH |
|---|---|---|
| 支持平台 | android / ios / web / windows / macos / linux | **增加 ohos** |
| 维护方 | Google | OpenHarmony SIG（TPC） |
| 仓库 | github.com/flutter/flutter | atomgit.com/openharmony-tpc/flutter_flutter |
| 版本节奏 | 主版本领先 | 滞后 1~2 个 stable 版本（当前 3.35.x 已可商用） |

本项目的 Dart 代码（`lib/domain`、`lib/data`、`lib/presentation`）**完全复用**，
只有原生插件层需要为鸿蒙补一份 ArkTS 实现——这正是采用六边形架构的原因。

---

## 二、环境准备

### 1. 安装 Flutter-OH

```bash
git clone -b 3.35.x https://atomgit.com/openharmony-tpc/flutter_flutter.git ~/flutter_ohos
export PATH=~/flutter_ohos/bin:$PATH

# 验证：输出中应包含 ohos
flutter create --help | grep ohos
```

### 2. 安装 DevEco Studio 与 HarmonyOS SDK

- DevEco Studio 4.1 或更高版本
- HarmonyOS SDK **API 11+**（在 DevEco 的 SDK Manager 中安装）
- 配置环境变量：

```bash
export DEVECO_SDK_HOME=/path/to/DevEco-Studio/sdk
export OHOS_SDK_HOME=$DEVECO_SDK_HOME
export PATH=$DEVECO_SDK_HOME/../tools/hvigor/bin:$PATH
```

### 3. 一键检查环境

```bash
./tool/bootstrap_ohos.sh --check
```

脚本会验证：
- `flutter` 是否支持 `ohos` 子命令
- `DEVECO_SDK_HOME` / `OHOS_SDK_HOME` 是否已配置

---

## 三、生成鸿蒙工程

```bash
./tool/bootstrap_ohos.sh
```

等价于：

```bash
flutter pub get
flutter create --platforms=ohos --org com.taillimit --project-name tail_limit .
```

生成后目录结构：

```
ohos/
├── entry/                      # 主模块（含 EntryAbility）
│   └── src/main/
│       ├── module.json5        # ⚠️ 需手动合并权限声明
│       ├── ets/entryability/   # 应用入口 Ability
│       └── resources/          # 资源（含 string.json 权限文案）
├── oh-package.json5            # 鸿蒙依赖清单
├── build-profile.json5         # 构建配置
└── hvigorfile.ts               # 构建脚本
```

---

## 四、合并权限声明（必做）

Flutter-OH 插件**无法**为宿主工程声明权限，必须手动合并。

打开 `ohos/entry/src/main/module.json5`，在 `module` 节点下添加：

```json5
{
  "module": {
    // ... 已有配置
    "requestPermissions": [
      {
        "name": "ohos.permission.NOTIFICATION_CONTROLLER",
        "reason": "$string:reason_notification",
        "usedScene": { "abilities": ["EntryAbility"], "when": "inuse" }
      },
      {
        "name": "ohos.permission.PUBLISH_AGENT_REMINDER",
        "reason": "$string:reason_agent_reminder",
        "usedScene": { "abilities": ["EntryAbility"], "when": "always" }
      },
      {
        "name": "ohos.permission.KEEP_BACKGROUND_RUNNING",
        "reason": "$string:reason_background",
        "usedScene": { "abilities": ["EntryAbility"], "when": "always" }
      },
      {
        "name": "ohos.permission.INTERNET",
        "reason": "$string:reason_internet",
        "usedScene": { "abilities": ["EntryAbility"], "when": "inuse" }
      }
    ]
  }
}
```

完整模板见 `tail_limit_alert_plugin/ohos/module.json5.permissions.template`。

### 权限用途说明

| 权限 | 用途 | 不授予的后果 |
|---|---|---|
| `NOTIFICATION_CONTROLLER` | 发送提醒通知 | 完全无法提醒 |
| `PUBLISH_AGENT_REMINDER` | 系统代理提醒（**强提醒核心**） | 应用被杀死后提醒失效 |
| `KEEP_BACKGROUND_RUNNING` | 保持排程有效 | 后台被清理后排程可能丢失 |
| `INTERNET` | 拉取限行数据 | 只能使用内置规则引擎 |

### 补充 string.json

在 `ohos/entry/src/main/resources/base/element/string.json` 中添加：

```json
{
  "string": [
    { "name": "reason_notification", "value": "用于发送限号提醒通知" },
    { "name": "reason_agent_reminder", "value": "用于在限号当日准点触发强提醒" },
    { "name": "reason_background", "value": "用于在后台保持提醒排程有效" },
    { "name": "reason_internet", "value": "用于从交管数据服务获取实时限号信息" }
  ]
}
```

---

## 五、鸿蒙强提醒实现原理

TailLimit 在鸿蒙端使用 **系统代理提醒**（`reminderAgentManager`），而非自建通知。

### 为什么用代理提醒

| 方案 | 应用存活 | 设备重启后 | 准点性 | 能否全屏 |
|---|---|---|---|---|
| 自建定时器 + 通知 | ❌ 依赖进程 | ❌ 失效 | ⚠️ 受省电限制 | ❌ |
| **系统代理提醒** | ✅ 系统托管 | ✅ 系统重建 | ✅ 系统保证 | ✅ `maxScreenWantAgent` |

### 关键参数映射

| 需求 | 鸿蒙实现 |
|---|---|
| 准点触发 | `ReminderType.REMINDER_TYPE_ALARM` + `hour`/`minute` |
| 全屏强提醒 | `maxScreenWantAgent`（拉起源页并点亮屏幕） |
| 响铃 | `ringDuration: 30`（强提醒）/ `5`（普通） |
| 震动 | `slotType: SOCIAL_COMMUNICATION` + 渠道 `vibrationEnabled` |
| 绕过勿扰 | 通知渠道 `bypassDnd: true` |
| 语音播报 | `@ohos.ai.tts`（触发时朗读车牌与尾号） |
| 稍后提醒 | `snoozeTimes: 1` + `timeInterval: 5` |
| 点击操作 | `actionButton`（"知道了"） |

实现代码：`tail_limit_alert_plugin/ohos/src/main/ets/components/alert/AgentReminderHelper.ets`

### 确定性 ID

Dart 侧生成的字符串 ID 通过 **FNV-1a 32 位哈希** 转为鸿蒙所需的数值 `reminderId`，
保证同一提醒跨进程、跨重启得到相同 ID，从而实现幂等排程。

---

## 六、构建与运行

### 开发调试

```bash
# 连接鸿蒙设备（或在 DevEco Studio 中启动模拟器）
hdc list targets

flutter run -d <device-id>
```

### 发布构建

```bash
flutter build hap --release
```

产物：`ohos/entry/build/default/outputs/default/entry-default-signed.hap`

### 签名配置

首次构建需在 DevEco Studio 中配置签名：

1. 用 DevEco Studio 打开 `ohos/` 目录
2. `File → Project Structure → Signing Configs`
3. 勾选 `Automatically generate signature`
4. 登录华为开发者账号完成自动签名

---

## 七、车机形态

鸿蒙车机（HarmonyOS for Car）与手机共用同一套 ArkTS 代码。

在 `ohos/entry/src/main/module.json5` 中确认 `deviceTypes` 包含 `"car"`：

```json5
{
  "module": {
    "deviceTypes": ["default", "tablet", "car"]
  }
}
```

### UI 自动适配

应用层通过逻辑宽度判定形态（`FormFactor.isCar`，阈值 840dp）：

- **≥ 840dp（车机）**：双栏布局 + 左侧 200px 导航栏 + 触控目标放大到 76dp
- **< 840dp（手机）**：单栏 + 底部导航栏

无需为车机单独维护代码分支，同一份 Flutter UI 自动切换。

---

## 八、常见问题

### Q1: `flutter create --platforms=ohos` 报错 "Invalid platform"

使用的是官方 Flutter SDK。切换到 Flutter-OH：

```bash
export PATH=~/flutter_ohos/bin:$PATH
which flutter   # 应指向 flutter_ohos/bin/flutter
```

### Q2: hvigor 同步失败，找不到 HarmonyOS SDK

```bash
export DEVECO_SDK_HOME=/path/to/DevEco-Studio/sdk
```

devEco Studio 中的 SDK 路径可在 `Settings → SDK` 查看。

### Q3: 应用被杀死后提醒不触发

检查 `PUBLISH_AGENT_REMINDER` 权限是否已授予，以及使用的是
`reminderAgentManager` 而非 `notificationManager`。

`getCapabilities` 返回的 `agentReminderSupported` 字段可用于运行时判定。

### Q4: 语音不播报

鸿蒙 TTS 需要设备已安装中文语音包。若引擎创建失败（`TtsSpeaker.ensureEngine`
返回 null），应用会静默跳过播报，不影响通知本身。

### Q5: 权限被拒后如何重新申请

调用 `requestPermission` 只会弹一次系统授权框。若用户已拒绝，
需引导用户前往 `设置 → 应用 → TailLimit → 权限` 手动开启。

---

## 九、端能力对照总表

| 能力 | Android | iOS | 鸿蒙 |
|---|---|---|---|
| 准点触发 | `AlarmManager.setExactAndAllowWhileIdle` | `UNCalendarNotificationTrigger` | `reminderAgentManager` |
| 全屏强提醒 | `setFullScreenIntent` | ❌ 不支持 | `maxScreenWantAgent` |
| 突破专注/勿扰 | 通知渠道 + `ACCESS_NOTIFICATION_POLICY` | `.timeSensitive` | 渠道 `bypassDnd` |
| 语音播报 | `TextToSpeech` | `AVSpeechSynthesizer` | `@ohos.ai.tts` |
| 开机重建 | `BootReceiver` | 系统自动保留 | 系统托管 |
| 待触发上限 | ~500（WorkManager 建议值） | **64**（系统硬限） | ~100 |
| 权限申请 | 通知 + 精确闹钟 + 全屏意图 | 通知（时效性需用户授权） | 通知 + 代理提醒 |

> **iOS 的 64 条硬限制**由 `ReminderPlanner(maxPending: 60)` 在领域层统一处理，
> 超出的提醒按"日期近 + 强提醒优先"截断，保证最重要的提醒不丢失。
