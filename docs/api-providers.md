# 限行数据源接入说明

> TailLimit 的限行数据通过**可插拔的数据源端口**获取。
> 领域层只依赖 `VehicleLimitSource` 抽象，具体供应商实现位于 data 层。

---

## 一、架构设计

```
┌─────────────────────────────────────────────────────────┐
│  domain/repositories/vehicle_limit_source.dart          │
│  abstract class VehicleLimitSource {                    │
│    Future<List<City>> fetchCities();                    │
│    Future<List<RestrictionDay>> fetchDays(city, from, n);│
│  }                                                       │
└────────────────────────┬────────────────────────────────┘
                         │ 实现（六边形架构 Port / Adapter）
        ┌────────────────┴────────────────┐
        │                                 │
┌───────▼────────┐  ┌──────────────┐  ┌──▼─────────────┐
│ CachedSource   │─▶│ ApispaceSource│  │ MockSource     │
│ （回退链装饰器）│  │ JisuSource   │  │（本地规则引擎）│
└────────────────┘  └──────────────┘  └────────────────┘
```

### 四级回退链

`CachedSource` 装饰器保证**任何情况下都有数据可展示**：

| 优先级 | 来源 | 触发条件 | 标记 |
|---|---|---|---|
| 1 | drift 缓存（未过期） | 缓存日期覆盖请求范围 | `isEstimated=false` |
| 2 | API 主源（写透缓存） | 缓存缺失/过期且 API 可用 | `isEstimated=false` |
| 3 | drift 缓存（已过期） | API 失败但存在历史缓存 | `isCache=true` |
| 4 | MockSource 本地规则引擎 | API 失败且无缓存 | **`isEstimated=true`** |

**数据诚实性原则**：每一层都会在结果上标记真实来源，
UI 层通过 `DataSourceBadge` 明确展示"实时 / 缓存 / 估算"，
绝不用估算数据冒充实时数据。

---

## 二、支持的供应商

### APISpace

- **官网**：apispace.com
- **接口**：`/traffic-restriction/v1/citylist`、`/traffic-restriction/v1/query`
- **覆盖**：65 个限行城市、800+ 限行区域
- **计费**：按次调用，有免费额度

```bash
flutter run \
  --dart-define=LIMIT_SOURCE=apispace \
  --dart-define=LIMIT_API_KEY=你的key
```

**认证方式**：请求头 `X-APISpace-Token: <key>`

**响应结构**（简化）：

```json
{
  "code": 0,
  "data": {
    "city": { "cityId": "2", "cityName": "上海" },
    "restriction": {
      "date": "2026-03-15",
      "limitedNumber": "4,9",
      "time": "7:30-20:00",
      "area": "外环高速以内（不含）",
      "type": "tailRotation"
    }
  }
}
```

解析实现：`lib/data/datasources/remote/provider_parser.dart#parseApispaceDay`

### 极速数据（JisuAPI）

- **官网**：jisuapi.com
- **接口**：`/trafficrestriction/city`、`/trafficrestriction/query`
- **覆盖**：300+ 城市
- **计费**：按次，有免费试用

```bash
flutter run \
  --dart-define=LIMIT_SOURCE=jisu \
  --dart-define=LIMIT_API_KEY=你的key
```

**认证方式**：查询参数 `appkey=<key>`

解析实现：`lib/data/datasources/remote/provider_parser.dart#parseJisuDay`

### 内置规则引擎（MockSource）

**无需任何 Key，开箱即跑**。内置 12 个主要城市的限行政策常量表：

| 城市 | 政策类型 | 限行时段 |
|---|---|---|
| 北京 | 尾号轮换（5 组） | 7:00-20:00（五环内） |
| 上海 | 尾号轮换 + 外牌限行 | 7:30-20:00（外环内） |
| 广州 | 尾号轮换（4 组，末位字母按 0） | 7:30-19:30 |
| 深圳 | 尾号轮换 | 7:00-9:00 / 17:30-19:30 |
| 天津 | 尾号轮换 | 7:00-19:00（外环内） |
| 成都 | 尾号轮换 | 7:30-20:00（绕城内） |
| 杭州 | 尾号轮换 | 7:00-9:00 / 16:30-18:30 |
| 西安 | 尾号轮换 | 7:00-20:00（三环内） |
| 郑州 | 尾号轮换 | 7:00-21:00（三环内） |
| 武汉 | 尾号轮换 | 7:00-22:00（三环内） |
| 南京 | 尾号轮换 | 7:00-9:00 / 17:00-19:00 |
| 长春 | 尾号轮换 | 7:00-19:00 |

实现：`lib/domain/services/local_rotation_engine.dart`

**特殊政策说明**（`noMeasureNotes`）：

- **广州**：部分时段取消限行（节假日、重大活动期间）
- **武汉**：疫情期间曾长期暂停限行
- **长春**：冬季与夏季时段不同

> ⚠️ 内置规则可能存在滞后。**务必在 UI 中标注"估算"**，
> 并在免责说明中提示用户以官方通告为准。

---

## 三、接入新供应商

只需三步，无需改动领域层：

### 1. 实现源

```dart
// lib/data/datasources/remote/your_source.dart
class YourSource implements VehicleLimitSource {
  YourSource({required Dio dio, required String apiKey})
      : _dio = dio, _apiKey = apiKey;

  final Dio _dio;
  final String _apiKey;

  @override
  Future<List<City>> fetchCities() async {
    try {
      final resp = await _dio.get('/your/cities',
          options: Options(headers: {'Authorization': _apiKey}));
      return ProviderParser.parseYourCities(resp.data);
    } on DioException catch (e) {
      throw SourceException('城市列表获取失败', cause: e);
    }
  }

  @override
  Future<List<RestrictionDay>> fetchDays(
      City city, DateTime from, int days) async {
    final resp = await _dio.get('/your/query', queryParameters: {
      'city': city.name,
      'start': dateToIso(from),
      'days': days,
    });
    return ProviderParser.parseYourDay(resp.data, city.id);
  }

  @override
  bool get isEstimated => false;
}
```

### 2. 注册到工厂

```dart
// lib/data/datasources/remote/source_factory.dart
enum LimitSourceKind { mock, apispace, jisu, yourSource }  // ← 加一项

static VehicleLimitSource build({...}) {
  final primary = switch (kind) {
    LimitSourceKind.apispace => ApispaceSource(...),
    LimitSourceKind.jisu => JisuSource(...),
    LimitSourceKind.yourSource => YourSource(...),          // ← 加分支
    LimitSourceKind.mock => null,
  };
  // 关键：apiKey 为空自动降级，保证永不启动失败
  if (primary == null || apiKey.isEmpty) {
    return CachedSource(primary: MockSource(), fallback: MockSource(), ...);
  }
  return CachedSource(primary: primary, fallback: MockSource(), ...);
}
```

### 3. 补解析器与测试

```dart
// lib/data/datasources/remote/provider_parser.dart
static List<RestrictionDay> parseYourDay(dynamic json, String cityId) {
  // 用 inferType 推断限行类型，用 parseTails 解析尾号文本
  final tails = parseTails(json['limited_number'] as String);
  return [
    RestrictionDay(
      cityId: cityId,
      dateIso: json['date'] as String,
      tailsText: json['limited_number'] as String,
      timeWindowText: json['time'] as String,
      type: inferType(json),
      isEstimated: false,
    ),
  ];
}
```

测试用 fixture 常量（参考 `test/data/provider_parser_test.dart`），
**不发真实网络请求**。

---

## 四、接口契约（关键约束）

实现 `VehicleLimitSource` 时必须遵守：

| 约束 | 说明 |
|---|---|
| **不抛裸异常** | 网络/Dio 异常必须包装为 `SourceException` |
| **不返回 null** | 无数据返回空列表，由回退链处理 |
| **标注来源** | `isEstimated` 必须如实反映数据性质 |
| **幂等** | 重复调用相同参数应返回一致结果 |
| **不修改入参** | `from` 是值对象，不得原地改写 |

`SourceException` 定义：

```dart
// lib/domain/repositories/vehicle_limit_source.dart
class SourceException implements Exception {
  const SourceException(this.message, {this.cause});
  final String message;
  final Object? cause;
}
```

---

## 五、缓存策略

### 缓存表结构

```sql
CREATE TABLE city_cache_rows (
  city_id TEXT PRIMARY KEY,
  city_name TEXT NOT NULL,
  province TEXT,
  is_covered INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE restriction_day_rows (
  city_id TEXT NOT NULL,
  date_iso TEXT NOT NULL,        -- YYYY-MM-DD
  tails_text TEXT NOT NULL,      -- "4,9" 或 "所有外牌"
  time_window_text TEXT NOT NULL,-- "7:30-20:00"
  area_text TEXT,
  type_name TEXT NOT NULL,
  is_estimated INTEGER NOT NULL,
  synced_at INTEGER NOT NULL,
  PRIMARY KEY (city_id, date_iso)
);
```

### 过期判定

```dart
// CachedSource 内部逻辑
final covered = cached.map((d) => d.dateIso).toSet();
final needed = generateDateRange(from, days);
if (covered.containsAll(needed)) {
  return cached;   // 命中，不发网络请求
}
// 否则拉取主源
```

**测试覆盖**（`test/data/cached_source_test.dart`）：

- ✅ 主源成功时返回主源数据并写透缓存
- ✅ 缓存命中时不再请求主源
- ✅ 主源失败时回退到本地规则引擎（估算数据）
- ✅ 主源失败但有未过期缓存时优先用缓存
- ✅ 缓存不足天数时重新拉取

---

## 六、同步时机

| 触发点 | 位置 | 说明 |
|---|---|---|
| 应用冷启动 | `bootstrap.dart#_warmUp` | 后台执行，不阻塞首帧 |
| 手动刷新 | 首页刷新按钮 | 用户主动触发 |
| 设置页同步 | `DataSourceSection` | 展示同步结果 |
| 引导完成 | `onboarding_screen.dart#_finish` | 首次数据填充 |

同步完成后自动触发**提醒重排**（`ApplyReminderPlan`），
保证系统闹钟与最新数据一致。

### 冷启动不阻塞设计

```dart
// bootstrap.dart
await _warmUpDatabase(container);           // 仅预热数据库连接
unawaited(_warmUp(container, config));      // 网络/同步全部后台
runApp(...);                                // 立即启动 UI
```

用户先看到**本地缓存渲染**的界面，数据在后台刷新后自动更新。
这样在无网络、弱网、API 限流等情况下，冷启动速度不受影响。

---

## 七、成本与限流建议

| 关注点 | 建议 |
|---|---|
| 调用量 | 每城市每次同步 1 次调用；14 天数据一次拉取 |
| 缓存 TTL | 建议 6~12 小时（限行政策日级变化，无需频繁拉） |
| 请求去重 | `CachedSource` 已实现（缓存覆盖则不请求） |
| 失败重试 | 依赖回退链，不做指数退避（避免消耗额度） |
| 额度监控 | 建议在自建后端加中转与统计（v1.1） |

### 从直连迁移到自建后端

架构已为此预留：只需新增一个 `BackendSource` 实现同一接口，
在 `SourceFactory` 中注册。**领域层与 UI 层零改动。**

这也是选择"直连 API（MVP）"而非一开始就自建后端的原因——
先用最小成本验证产品，跑通后再按需加中转层。
