# TailLimit · 车辆限号提醒

> 跨平台车辆限号提醒应用。支持 **Android / iOS / 鸿蒙**，覆盖 **手机版 / 车机版**，
> 在限号当日以**全屏 + 语音**的强提醒方式触达用户。
>
> v0.2.0 新增**广播**与**白噪音**两栏：广播直连中央广播电视总台官方直播流，
> 白噪音支持真实环境录音 + 算法合成双路线，带睡眠定时与渐弱。

---

## 目录

- [功能特性](#功能特性)
- [技术架构](#技术架构)
- [快速开始](#快速开始)
- [项目结构](#项目结构)
- [核心机制](#核心机制)
- [平台支持矩阵](#平台支持矩阵)
- [测试](#测试)
- [文档索引](#文档索引)
- [免责声明](#免责声明)

---

## 功能特性

### 已实现（v0.2.0）

**限行提醒（v0.1.0 起）**

| 功能 | 说明 |
|---|---|
| **多城市关注** | 同时关注多个城市，按各自政策独立判定 |
| **车牌绑定** | 蓝牌 / 绿牌自动识别，新能源绿牌多数城市豁免 |
| **今日状态** | 首页大字号展示"今日是否限行"+ 限行尾号 + 时段 + 区域 |
| **明日预告** | 首页底部条，提前一天知晓 |
| **月历视图** | 整月限行日历，点击查看某日详情 |
| **提醒配置** | 前一日预告时间、当日强提醒提前量、语音播报、全屏、勿扰旁路开关 |
| **强提醒** | 全屏通知 + 语音播报 + 精确闹钟，锁屏状态可点亮屏幕 |
| **数据源回退** | 实时 API → 缓存 → 内置规则引擎，四级回退，永不空白 |
| **数据诚实标注** | 明确区分"实时 / 缓存 / 估算"，不用估算冒充实时 |
| **三端原生插件** | Android（Kotlin）/ iOS（Swift）/ 鸿蒙（ArkTS）各一份强提醒实现 |
| **车机适配** | ≥840dp 自动切双栏 + 大触控目标，同一份 UI 代码 |

**广播与白噪音（v0.2.0 新增）**

| 功能 | 说明 |
|---|---|
| **四栏导航** | 今日 / 广播 / 白噪音 / 设置 |
| **官方广播** | 6 个实测可用官方直播源（总台 5 个 + CRI 环球资讯），失效源已剔除 |
| **实录音白噪音** | 海浪、篝火为真实录音，Opus 48kHz 立体声，合计 954 KB |
| **算法合成音** | 白/粉/棕噪音 + 雨声/夜风/咖啡馆，实时生成，零包体占用 |
| **睡眠定时** | 15/30/45/60/120 分钟六档，到期前 20 秒线性渐弱 |
| **结束时刻模型** | 存结束时刻而非倒计时，避免后台节流导致计时漂移 |

### 未实现（明确说明）

| 项 | 原因 |
|---|---|
| iOS Critical Alerts | Apple 逐应用特批，限号提醒类别不符，几乎不可通过 |
| Android Auto 投屏 | 需 Car App Library 原生模板重写，成本高，留待 v1.1 |
| CarPlay | Apple 允许的类别不含限号提醒，审核必拒 |
| 自建后端中转 | MVP 先直连第三方 API 验证产品，跑通后再加 |
| **真实音频播放** | 广播与白噪音当前为模拟网关（完整状态机，不发声），需接 `just_audio` + `audio_service` |
| **后台播放与锁屏控制** | 需 `audio_service`，含 Android 音频焦点、iOS 后台音频 |
| **应用内音源署名页** | 内置音源为 CC BY 4.0，合规要求在应用内可见地注明作者 —— **上架前必办** |

---

## 技术架构

采用**领域驱动 + 六边形架构**，三层严格分离：

```
┌───────────────────────────────────────────────────────────┐
│  presentation  （Flutter UI）                             │
│  Riverpod 状态管理 · GoRouter 路由 · 深空灰+香槟金主题     │
└──────────────────────────┬────────────────────────────────┘
                           │ 只依赖 domain 抽象
┌──────────────────────────▼────────────────────────────────┐
│  domain  （纯 Dart，零 Flutter 依赖）                     │
│  实体 · 值对象 · 领域服务 · 用例 · 仓库端口（abstract）    │
│  ▸ RestrictionEvaluator  判定优先级链                     │
│  ▸ ReminderPlanner       两阶段提醒规划 + 64 条截断        │
│  ▸ LocalRotationEngine   12 城内置规则                    │
└──────────────────────────▲────────────────────────────────┘
                           │ implements
┌──────────────────────────┴────────────────────────────────┐
│  data  （适配器实现）                                     │
│  drift/SQLite · Dio · 第三方 API · 平台插件网关            │
└───────────────────────────────────────────────────────────┘
```

### 技术选型

| 层 | 技术 | 选型理由 |
|---|---|---|
| 跨平台 | **Flutter 3.47.7** | 一套代码覆盖三端；与团队既有技术栈一致 |
| 状态管理 | Riverpod 2.6 | 编译期安全、可测试、无 context 依赖 |
| 路由 | GoRouter 14.6 | 声明式路由，支持重定向（首启引导） |
| 本地存储 | drift 2.22 | 类型安全 SQL、响应式 watch、便于测试 |
| 网络 | Dio 5.7 | 拦截器机制完善，异常类型清晰 |
| 鸿蒙 | Flutter-OH 3.35.x | OpenHarmony SIG 维护，已可商用 |

**为什么领域层零 Flutter 依赖？**
这样 `flutter test` 无需启动引擎即可测试全部业务规则，
且未来若要迁移到 KMP 或原生，领域逻辑可原样复用。

---

## 快速开始

### 前置条件

- Flutter **3.47.7**（官方 SDK 即可；鸿蒙需 Flutter-OH，见下文）
- Dart SDK ≥ 3.5.0

```bash
export PATH=/opt/flutter/bin:$PATH      # 或你的 Flutter 安装路径
export PUB_CACHE=/opt/pubcache
```

### 运行

```bash
flutter pub get

# 开箱即跑（使用内置规则引擎，无需任何 API Key）
flutter run

# 接入实时数据源
flutter run \
  --dart-define=LIMIT_SOURCE=apispace \
  --dart-define=LIMIT_API_KEY=你的key
```

### 构建

```bash
# Android（手机）
flutter build apk --release --split-per-abi

# Android（车机 AAOS）
flutter build apk --release --split-per-abi   # 同一 APK，侧载到车机

# iOS（需 macOS）
flutter build ipa --release

# 鸿蒙（需 Flutter-OH）
./tool/bootstrap_ohos.sh
flutter build hap --release
```

各平台详细步骤见 [文档索引](#文档索引)。

### 编译期配置

全部通过 `--dart-define` 注入，**不落库、不入版本控制**：

| 参数 | 取值 | 默认 | 说明 |
|---|---|---|---|
| `LIMIT_SOURCE` | `mock` / `apispace` / `jisu` | `mock` | 数据源类型 |
| `LIMIT_API_KEY` | 字符串 | 空 | API Key（空则自动降级 mock） |
| `LIMIT_SYNC_DAYS` | 整数 | `14` | 同步天数 |
| `LIMIT_APISPACE_BASEURL` | URL | 官方地址 | 可覆盖 |
| `LIMIT_JISU_BASEURL` | URL | 官方地址 | 可覆盖 |
| `LIMIT_ENABLE_EXPERIMENT` | bool | `false` | 实验特性开关 |

---

## 项目结构

```
tail_limit/
├── lib/
│   ├── main.dart                    # 入口（仅调用 bootstrap）
│   ├── bootstrap.dart               # 启动引导（DB 预热 + 后台同步，不阻塞首帧）
│   ├── app.dart                     # MaterialApp.router + 主题 + 中文本地化
│   │
│   ├── domain/                      # ◀ 纯 Dart，零 Flutter 依赖
│   │   ├── entities/                #   实体（11 个）
│   │   │   ├── city.dart
│   │   │   ├── vehicle.dart
│   │   │   ├── restriction_policy.dart
│   │   │   ├── restriction_day.dart      #   快照实体
│   │   │   ├── restriction_verdict.dart  #   判定结论
│   │   │   ├── reminder_config.dart
│   │   │   └── scheduled_reminder.dart   #   含 deterministicId
│   │   ├── value_objects/
│   │   │   ├── restriction_type.dart     #   4 个枚举
│   │   │   ├── time_window.dart
│   │   │   └── tail_number.dart          #   尾号提取 + 绿牌识别
│   │   ├── services/
│   │   │   ├── restriction_evaluator.dart  # 判定优先级链
│   │   │   ├── reminder_planner.dart       # 两阶段规划 + 截断
│   │   │   └── local_rotation_engine.dart  # 12 城内置规则
│   │   ├── repositories/            #   6 个端口抽象
│   │   └── usecases/                #   3 个用例
│   │
│   ├── data/                        # ◀ 适配器实现
│   │   ├── datasources/
│   │   │   ├── local/               #   drift 表 + DAO + 数据库
│   │   │   ├── remote/              #   API 源 + 解析器 + 回退装饰器 + 工厂
│   │   │   └── system/              #   平台插件网关实现
│   │   ├── models/mappers.dart      #   实体 ↔ 表行映射
│   │   └── repositories/            #   仓库实现
│   │
│   ├── presentation/
│   │   ├── features/
│   │   │   ├── onboarding/          #   三步引导
│   │   │   ├── shell/               #   外壳（底部导航 / 侧栏）
│   │   │   ├── home/                #   首页（今日状态 + 明日预告）
│   │   │   ├── calendar/            #   月历
│   │   │   ├── vehicles/            #   车辆列表 + 编辑
│   │   │   ├── cities/              #   城市管理
│   │   │   └── settings/            #   提醒设置 + 权限引导
│   │   └── widgets/                 #   通用组件（自适应脚手架等）
│   │
│   └── core/                        # ◀ 横切关注点
│       ├── config/app_config.dart   #   dart-define 配置
│       ├── di/providers.dart        #   全部 Riverpod Provider
│       ├── router/app_router.dart   #   路由表 + 首启重定向
│       ├── theme/                   #   色板 / 字体 / 尺寸 / ThemeData
│       ├── error/failures.dart      #   sealed Failure 体系
│       └── utils/plate_utils.dart   #   车牌规范化与校验
│
├── tail_limit_alert_plugin/         # ◀ 自研强提醒插件（三端）
│   ├── lib/                         #   Dart 门面（AlertApi 抽象 + MethodChannel）
│   ├── android/                     #   Kotlin：精确闹钟 + 全屏意图 + TTS + 开机重排
│   ├── ios/                         #   Swift：时效性通知 + AVSpeechSynthesizer
│   └── ohos/                        #   ArkTS：系统代理提醒 + @ohos.ai.tts
│
├── test/
│   ├── domain/                      #   33 个测试（判定规则 + 提醒规划）
│   └── data/                        #   28 个测试（仓库 + 解析器 + 回退链）
│
├── docs/
│   ├── build-android.md             #   Android + AAOS 车机
│   ├── build-ios.md                 #   iOS（含 64 条限制说明）
│   ├── build-ohos.md                #   鸿蒙（Flutter-OH）
│   └── api-providers.md             #   数据源接入指南
│
└── tool/
    └── bootstrap_ohos.sh            #   鸿蒙工程一键初始化
```

---

## 核心机制

### 1. 判定优先级链

`RestrictionEvaluator` 按固定顺序判定，**先命中先返回**：

```
① 无限行措施         → notRestricted
② 新能源绿牌豁免      → exemptNewEnergy
③ 外牌区域限行
   ├─ 本地牌          → exemptLocalPlate
   └─ 外地牌          → restricted
④ 尾号轮换命中        → restricted
⑤ 未命中             → notRestricted
```

顺序很重要：绿牌豁免必须早于尾号判定，否则绿牌会被错误判定为受限。

### 2. 两阶段提醒

```
T-1 日 21:00        前一日预告（普通通知）
       ↓
T 日 限行时段前 10 分钟   强提醒（全屏 + 语音 + 震动）
       ↓
   若无限行时段 → 兜底 07:00 强提醒
```

配置项：`previewMinutesOfDay=1260`（21:00）、`strongLeadMinutes=10`、
`strongFallbackMinutesOfDay=420`（07:00）。

### 3. 确定性提醒 ID

```dart
// domain/entities/scheduled_reminder.dart
String deterministicId() => '$cityId|$dateIso|${kind.name}|$vehicleId';
```

同样的输入永远得到同样的 ID，从而：
- 排程幂等（重复执行不会产生重复闹钟）
- 变更可感知（`fireAt` 变化时覆盖旧排程）
- 跨进程一致（开机重建后能正确匹配）

### 4. 64 条截断策略

iOS 系统硬限 64 条待触发通知。领域层统一处理：

```dart
// domain/services/reminder_planner.dart
const ReminderPlanner({this.maxPending = 60});   // 留 4 条余量
// 超出时：日期近的优先 → 强提醒优先
```

因为截断在**领域层**完成，三端行为一致，不依赖平台特性。

### 5. 数据诚实性

每个结果都带来源标记，UI 用 `DataSourceBadge` 明示：

| 标记 | 含义 | UI 颜色 |
|---|---|---|
| 实时 | 来自 API 主源 | 香槟金 |
| 缓存 | 来自本地缓存 | 中性灰 |
| 估算 | 来自内置规则引擎 | 橙色警示 |

**绝不用估算数据冒充实时数据**——这是本项目的一条硬性原则。

### 6. 冷启动不阻塞

```
启动 → 预热数据库连接（await，约 10ms）
     → 后台任务：能力探测 + 数据同步 + 提醒重排（unawaited）
     → 立即 runApp，展示本地缓存渲染的界面
```

弱网/无网/API 限流时，冷启动速度不受任何影响。

---

## 平台支持矩阵

| 能力 | Android | iOS | 鸿蒙 |
|---|---|---|---|
| 准点触发机制 | `AlarmManager.setExactAndAllowWhileIdle` | `UNCalendarNotificationTrigger` | `reminderAgentManager` |
| 全屏强提醒 | `setFullScreenIntent` | ❌ 不支持 | `maxScreenWantAgent` |
| 突破专注/勿扰 | 通知渠道 + 勿扰访问权限 | `.timeSensitive`（iOS 15+） | 渠道 `bypassDnd` |
| 语音播报 | `TextToSpeech` | `AVSpeechSynthesizer` | `@ohos.ai.tts` |
| 开机重建 | `BootReceiver` | 系统自动托管 | 系统托管 |
| 待触发上限 | ~500 | **64** | ~100 |
| 静音下强制响铃 | ✅ | ❌（需特批） | ✅ |
| 车机形态 | AAOS ✅ | CarPlay ❌ | HarmonyOS Car ✅ |

> 三端差异被 `AlertGateway` 端口隔离，UI 层通过 `getCapabilities()`
> 动态展示能力状态，不做平台分支判断。

---

## 测试

```bash
# 全部测试
flutter test

# 仅领域层（最快，无需引擎）
flutter test test/domain

# 代码分析（当前零告警）
flutter analyze
```

### 测试覆盖

| 文件 | 数量 | 覆盖内容 |
|---|---|---|
| `test/domain/tail_number_test.dart` | 11 | 尾号提取、绿牌识别、本地牌判定、边界情况 |
| `test/domain/restriction_evaluator_test.dart` | 12 | 判定优先级链全路径、豁免规则、时窗边界 |
| `test/domain/reminder_planner_test.dart` | 10 | 两阶段规划、确定性 ID、已过期跳过、64 条截断 |
| `test/data/repositories_test.dart` | 13 | 车辆 CRUD、城市关注、配置维度回退、排程事实源 |
| `test/data/provider_parser_test.dart` | 10 | APISpace / 极速数据真实响应 fixture 解析 |
| `test/data/cached_source_test.dart` | 5 | 四级回退链全部路径 |

**合计 61 个测试，全部通过。**

设计原则：
- 领域测试**零 mock**（纯函数，直接断言）
- 数据测试用 **fixture 常量**（不发真实网络请求）
- 回退链测试用**可控 stub**（精确构造每层失败场景）

---

## 文档索引

| 文档 | 内容 |
|---|---|
| [docs/build-android.md](docs/build-android.md) | Android 构建、AAOS 车机侧载、权限引导清单、国产 ROM 差异 |
| [docs/build-ios.md](docs/build-ios.md) | iOS 构建、时效性通知、64 条限制推算、为什么不做 Critical Alerts |
| [docs/build-ohos.md](docs/build-ohos.md) | Flutter-OH 环境、权限声明合并、系统代理提醒原理、车机形态 |
| [docs/api-providers.md](docs/api-providers.md) | 数据源架构、供应商接入、接口契约、缓存策略、接入新源三步法 |
| [docs/dev-environment.md](docs/dev-environment.md) | 构建验证结果、沙箱网络限制说明、Built-in Kotlin 迁移、环境变量 |

---

## 免责声明

本应用的限行数据来自**第三方数据服务**或**内置规则推算**，
可能与当地交管部门最新通告存在差异。

**请以官方发布为准。** 因数据差异导致的交通违法处罚，
本应用及其开发者不承担任何责任。

内置规则引擎（估算模式）的政策表可能滞后于政策调整，
建议仅用于产品体验评估，生产环境请接入实时数据源。

---

## 版本

**v0.1.0** · Phase 1 MVP · 2026

三端强提醒插件、领域层判定引擎、数据源回退链、
手机/车机双形态 UI 均已完成并通过测试。

---

## 免责声明

- **限行数据**：来自第三方接口，本应用不保证实时性与准确性，**以当地交管部门发布为准**。
  应用在界面上明确区分「实时 / 缓存 / 估算」三种数据状态，不用估算冒充实时。
- **广播内容**：转播中央广播电视总台与中国国际广播电台的公开直播流，
  本应用不生产、不修改、不存储任何广播内容。
- **白噪音**：音量与聆听时长请自行控制，长时间高音量聆听可能损伤听力。

## 开源许可

代码部分待定（建议 MIT）。**注意：内置音频资源有其独立许可** ——
海浪与篝火为 CC BY 4.0，使用时必须保留作者署名。
完整来源、许可与处理流程见 [docs/audio-sources.md](docs/audio-sources.md)。
