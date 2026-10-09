# Android 端构建指南（含车机 AAOS）

> TailLimit 的 Android 支持覆盖**手机**与**车机（Android Automotive OS）**两种形态。

---

## 一、环境要求

| 项目 | 版本要求 |
|---|---|
| JDK | 17（Android Gradle Plugin 8.x 强制要求） |
| Android SDK | compileSdk 34 / minSdk 21 |
| Android Gradle Plugin | 8.1+ |
| Kotlin | 1.9+ |

工程已由 `flutter create` 生成，无需额外配置。

---

## 二、构建与运行

### 手机

```bash
# 调试运行
flutter run -d <device-id>

# 发布构建（App Bundle，用于上架）
flutter build appbundle --release

# 发布构建（APK，用于直装）
flutter build apk --release --split-per-abi
```

产物：
- `build/app/outputs/bundle/release/app-release.aab`
- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

### 接入真实数据源

默认使用内置规则引擎（开箱即跑）。接入第三方实时数据：

```bash
flutter build apk --release \
  --dart-define=LIMIT_SOURCE=apispace \
  --dart-define=LIMIT_API_KEY=你的key \
  --dart-define=LIMIT_SYNC_DAYS=14
```

| dart-define | 取值 | 说明 |
|---|---|---|
| `LIMIT_SOURCE` | `mock` / `apispace` / `jisu` | 数据源类型 |
| `LIMIT_API_KEY` | 字符串 | API Key（为空自动降级 mock） |
| `LIMIT_SYNC_DAYS` | 整数，默认 14 | 同步天数 |
| `LIMIT_APISPACE_BASEURL` | URL | APISpace 基地址（一般不需改） |
| `LIMIT_JISU_BASEURL` | URL | 极速数据基地址（一般不需改） |

---

## 三、强提醒能力

Android 端的强提醒由 `tail_limit_alert_plugin` 提供，能力如下：

| 手段 | 实现 | 需要权限 |
|---|---|---|
| 准点触发 | `AlarmManager.setExactAndAllowWhileIdle` | `SCHEDULE_EXACT_ALARM`（Android 12+） |
| 全屏强提醒 | `setFullScreenIntent` + `IMPORTANCE_HIGH` 渠道 | `USE_FULL_SCREEN_INTENT` |
| 语音播报 | `TextToSpeech`（`Locale.SIMPLIFIED_CHINESE`，语速 0.95） | — |
| 绕过勿扰 | 渠道 + 系统勿扰访问权限 | `ACCESS_NOTIFICATION_POLICY` |
| 开机重建 | `BootReceiver` 监听 `BOOT_COMPLETED` | `RECEIVE_BOOT_COMPLETED` |
| 熄屏唤醒 | `PARTIAL_WAKE_LOCK` | `WAKE_LOCK` |
| 震动 | 通知渠道 + `VIBRATE` | `VIBRATE` |

权限已在插件 `AndroidManifest.xml` 中声明，由 Manifest 合并自动注入宿主应用。

### Android 14+ 的精确闹钟降级

Android 14 起 `SCHEDULE_EXACT_ALARM` **默认不授予**，应用需引导用户手动开启：

1. 应用内调用 `requestPermission()`（会跳转系统设置页）
2. 用户路径：`设置 → 应用 → TailLimit → 闹钟和提醒 → 允许`

未授权时，插件自动降级为 `setAndAllowWhileIdle`（**非精确**），
触发时间可能偏移数分钟至数十分钟。UI 层通过 `getCapabilities()`
返回的 `exactAlarmSupported` 字段提示用户。

### Android 15+ 的全屏意图限制

Android 15 起 `USE_FULL_SCREEN_INTENT` 对**非通话/闹钟类**应用默认关闭，
需引导用户开启：`设置 → 应用 → TailLimit → 全屏通知`。

---

## 四、车机（Android Automotive OS）

### 两种车机形态

| 形态 | 说明 | Flutter 支持 |
|---|---|---|
| **AAOS**（车机原生系统） | 车机自带 Android 系统，可安装 APK | ✅ 直接支持，UI 全自绘 |
| **Android Auto**（手机投屏） | 手机投屏到车机屏幕 | ⚠️ 需 Car App Library 模板 |
| **CarPlay** | iOS 投屏 | ⚠️ 需 Apple 模板（且审核严格） |

**TailLimit 当前支持 AAOS 直装**。Android Auto 投屏模式需要额外的
Car App Library 模板实现（见下文），不在 MVP 范围内。

### AAOS 侧载安装

AAOS 车机通常不开放应用商店，需侧载：

```bash
# 1. 车机开启开发者模式（连续点击"版本号"7 次）
# 2. 车机开启 ADB 调试
# 3. 通过 USB 或 Wi-Fi 连接
adb devices

# 4. 安装 APK
adb install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk

# 5. 验证安装
adb shell pm list packages | grep taillimit
```

### 在 AAOS 模拟器上调试

```bash
# 使用 Android Studio 的 Automotive 系统镜像创建 AVD
# 目标 API 33+，选择 "Automotive" 类别
flutter devices           # 应能看到 automotive 设备
flutter run -d <avd-id>
```

### AAOS 适配要点

应用层已自动处理（`FormFactor.isCar`）：

| 项 | 手机 | 车机（≥840dp） |
|---|---|---|
| 布局 | 单栏 + 底部导航 | 双栏 + 左侧 200px 导航栏 |
| 触控目标 | 48dp | **76dp**（驾驶中易触达） |
| 字号 | 标准 | 标题 30sp / 正文 18sp（驾驶中易读） |
| 动效 | 标准 | 简短、无复杂转场（减少分心） |

AAOS 的驾驶分心限制（`CarUxRestrictions`）由系统强制，Flutter 自绘 UI
不受模板限制，但仍建议驾驶中**只读不写**。

### 声明为车载应用（可选）

若希望出现在车机应用列表中，在 `android/app/src/main/AndroidManifest.xml`
的 `<application>` 内添加：

```xml
<meta-data
    android:name="com.android.automotive.CAR_APP"
    android:value="true" />
```

并在 `<manifest>` 中声明：

```xml
<uses-feature
    android:name="android.hardware.type.automotive"
    android:required="false" />
```

> `required="false"` 保证同一 APK 也能安装到手机。

### Android Auto 投屏（未实现）

如需支持 Android Auto，需要：

1. 在 `pubspec.yaml` 添加 `android_auto` 相关插件
2. 使用 **Car App Library**（`androidx.car.app`）实现 `CarAppService`
3. 在 Manifest 中声明 `androidx.car.app.CarAppService` 与 `category.CAR_APP`
4. 提交 Google 审核（Android Auto 应用需官方批准）

由于 Car App Library 使用**原生模板渲染**（非 Flutter 自绘），
UI 需用原生代码重写，成本较高。建议作为 v1.1 的独立迭代。

---

## 五、权限引导清单

应用内"设置 → 权限与能力"页会逐项展示状态。用户需手动开启的项：

| 权限 | 系统路径 | 不开启的后果 |
|---|---|---|
| 通知 | 设置 → 应用 → TailLimit → 通知 | 完全无法提醒 |
| 精确闹钟 | 设置 → 应用 → TailLimit → 闹钟和提醒 | 触发延迟数分钟~数十分钟 |
| 全屏通知 | 设置 → 应用 → TailLimit → 全屏通知 | 锁屏时只响铃不亮屏 |
| 勿扰访问 | 设置 → 通知 → 勿扰 → 允许以下应用 | 勿扰模式下静音 |
| 电池优化白名单 | 设置 → 电池 → 不受限制 | 后台被清理后排程丢失 |

### 厂商差异

国产 ROM 对后台管理更严格，需额外引导：

- **小米/红米**：设置 → 应用 → TailLimit → 省电策略 → 无限制 + 自启动
- **华为/荣耀**：设置 → 应用 → 应用启动管理 → 手动管理（允许自启动/关联启动/后台活动）
- **OPPO/一加**：设置 → 电池 → 应用耗电管理 → 允许后台运行
- **vivo/iQOO**：设置 → 电池 → 后台耗电管理 → 允许后台高耗电
- **三星**：设置 → 电池 → 后台使用限制 → 从不休眠的应用

---

## 六、常见问题

### Q1: 到点不提醒

按顺序检查：
1. 通知权限是否开启
2. 精确闹钟权限是否开启
3. 电池优化是否已加入白名单
4. 系统"自启动"是否允许
5. 在应用内"设置 → 待触发提醒"确认提醒确实已排程

### Q2: `INSTALL_FAILED_UPDATE_INCOMPATIBLE`

签名冲突。先卸载：

```bash
adb uninstall com.taillimit.tail_limit
```

### Q3: 构建报 "Unsupported class file major version"

JDK 版本不对，需 JDK 17：

```bash
flutter config --jdk-dir=/path/to/jdk17
```

### Q4: 车机上字体过小 / 布局错乱

应用已按 840dp 阈值切换形态。若车机屏幕 DPI 异常导致判定失败，
可在系统设置中调整"显示大小"后重启应用。
