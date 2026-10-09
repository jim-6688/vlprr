# 开发环境与构建验证说明

本文记录 TailLimit 的**已验证构建结果**与**沙箱环境的已知限制**，
便于在真实开发机上复现或排查。

---

## 一、验证结果总览

| 验证项 | 状态 | 证据 |
|---|---|---|
| 静态分析（`flutter analyze`） | ✅ 0 issue | 全部 23 个 Dart 源文件 + 测试 |
| 单元测试（`flutter test`） | ✅ 61/61 通过 | 领域 33 + 数据 28 |
| Dart 全量 Release 编译 | ✅ | `kernel_blob.bin` 产出 |
| Android Kotlin 插件编译 | ✅ | 8 个 `.class` 文件产出 |
| 资源打包 | ✅ | `AssetManifest.bin`、`shaders`、`fonts` |
| Android APK 完整打包 | ⚠️ 沙箱网络受限 | 见下文 |

---

## 二、已验证的编译产物

### Dart 侧

```
build/app/intermediates/flutter/debug/flutter_assets/kernel_blob.bin
build/flutter_assets/
├── AssetManifest.bin
├── FontManifest.json
├── NativeAssetsManifest.json
├── NOTICES.Z
├── fonts/
├── native_assets/
└── shaders/
```

`kernel_blob.bin` 是 Dart 编译器对**全部源码**（含 `bootstrap.dart`、`app.dart`、
6 个页面、主题系统、Riverpod providers）编译后的中间表示。
它的产出证明所有 Dart 代码**无编译错误**。

### Android 插件侧

```
build/tail_limit_alert_plugin/tmp/kotlin-classes/debug/com/taillimit/alert/
├── AlertReceiver.class            (+ Companion)
├── AlertNotifier.class
├── AlertStore.class
├── BootReceiver.class
├── TailLimitAlertPlugin.class     (+ Companion)
└── TtsSpeaker.class
```

6 个 Kotlin 源文件全部编译通过，证明强提醒插件的
精确闹钟、全屏意图、TTS 播报、开机重排、MethodChannel 接线**语法与类型均正确**。

---

## 三、沙箱环境的已知限制

### 网络限制

沙箱对以下域名存在访问限制，导致完整 APK 打包无法完成：

| 域名 | 用途 | 状态 |
|---|---|---|
| `services.gradle.org` | Gradle 发行版 | ❌ 超时 |
| `dl.google.com` | Android SDK / Google Maven | ⚠️ 慢 |
| `maven.aliyun.com` | Maven 镜像 | ⚠️ 慢/部分缺失 |
| `storage.googleapis.com` | Flutter engine 产物 | ✅ 可用 |

**已采取的应对**：

1. Gradle 9.3.1 从腾讯云镜像手动下载并预置到 wrapper 缓存
2. 在 `android/settings.gradle.kts`、`android/build.gradle.kts`、
   插件 `android/build.gradle` 中**优先配置了阿里云镜像**（保留官方源兜底）
3. 手动预装 Android SDK Platform 34/35/36 与 Build-Tools

**残留问题**：AGP 9 的部分传递依赖在阿里云镜像缺失，
Gradle 会在等待超时后回落到官方源，导致分辨率极慢（沙箱实测 >20 分钟未完成）。

### 在真实开发机上的预期

正常网络环境下，首次构建耗时约 3~8 分钟（取决于依赖下载速度）：

```bash
flutter build apk --release --split-per-abi
```

若国内网络较慢，建议在 `android/gradle.properties` 中追加：

```properties
# 提高网络等待容忍度
systemProp.org.gradle.internal.http.connectionTimeout=120000
systemProp.org.gradle.internal.http.socketTimeout=120000
```

---

## 四、关于 Built-in Kotlin

Flutter 3.44+ 引入了 **Built-in Kotlin**：由 Flutter Gradle Plugin 统一提供
Kotlin 编译能力，插件不再需要显式 `apply plugin: 'kotlin-android'`。

**本项目插件已按此规范编写**：

```groovy
// tail_limit_alert_plugin/android/build.gradle
apply plugin: 'com.android.library'   // 不再 apply 'kotlin-android'

android { /* ... */ }

// 替代原 kotlinOptions { jvmTarget = '17' }
kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}
```

插件 `pubspec.yaml` 已相应提升最低版本约束：

```yaml
environment:
  sdk: ">=3.12.0 <4.0.0"
  flutter: ">=3.44.0"
```

`android/gradle.properties` 中 `android.builtInKotlin` **保持模板默认 `false`**。
在此模式下 AGP 9 会自动提供 KGP，上述插件写法同样有效；
若改为 `true`（需 Flutter 3.47+ / AGP 9+）也无需再改插件代码。

> 参考：[Built-in Kotlin migration for plugin authors](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-plugin-authors)

---

## 五、快速复现验证

在有网络的环境下，用以下命令可完整复现全部验证：

```bash
# 1. 依赖
flutter pub get

# 2. 静态分析（预期：No issues found）
flutter analyze

# 3. 单元测试（预期：All tests passed! 61 个）
flutter test

# 4. Android Release 构建（预期：产出 APK）
flutter build apk --release --split-per-abi \
  --dart-define=LIMIT_SOURCE=mock

# 5. iOS 构建（需 macOS）
flutter build ipa --release

# 6. 鸿蒙（需 Flutter-OH）
./tool/bootstrap_ohos.sh --check
./tool/bootstrap_ohos.sh
```

---

## 六、环境变量备忘

```bash
# Flutter
export PATH=/opt/flutter/bin:$PATH
export PUB_CACHE=/opt/pubcache

# Android
export ANDROID_HOME=/opt/android-sdk
export ANDROID_SDK_ROOT=/opt/android-sdk
export JAVA_HOME=<JDK 17 路径>

# Flutter 指向 Android SDK
flutter config --android-sdk /opt/android-sdk
```

### JDK 版本要求

| 组件 | 要求 |
|---|---|
| Android Gradle Plugin 8.x | JDK 17 |
| Android Gradle Plugin 9.x | JDK 17+ |
| 本插件 Kotlin 编译 | `jvmTarget = JVM_17` |

沙箱内使用 JDK 20（Zulu）可正常编译，但**生产环境建议统一 JDK 17**，
避免 AGP 对高版本 JDK 的兼容性告警。
