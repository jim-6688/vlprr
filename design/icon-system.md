# TailLimit 功能图标系统

> 视觉方向：**B · 石墨电蓝 Graphite Electric**
> 风格：24pt 线性网格 · 1.75 stroke · round cap/join · 无填充装饰
> 原则：**图标即功能语义**。每个图形必须能脱离上下文被读懂，且形状互不混淆。

---

## 一、设计原则

### 1.1 为什么重做

原方案底部 Tab 用了 `◉ ▦ ◫ ◎` 这类 Unicode 几何符号作为占位。它们的问题不是"丑"，而是**没有语义**——`◉` 到底是今日、状态、还是定位？用户只能靠文字标签猜。图标应当在标签缺失时仍可辨识。

### 1.2 三条硬规则

| 规则 | 说明 |
|---|---|
| **24pt 网格，1.75 描边** | 全部图形建立在 24×24 viewBox 上，描边统一 1.75，视觉重量一致 |
| **形状差异 > 细节差异** | 19 个图标里，圆形（状态）、方形（容器）、三角（警示）、波形（信号）四大类轮廓必须一眼可分 |
| **颜色承载语义，不承载装饰** | 颜色只有三个用法：强调（可点/当前）、语义（限行/不限/估算）、中性（不可点）。没有第五种。 |

### 1.3 语义色映射

| 语义 | 色值 | 用在哪 |
|---|---|---|
| 强调 / 可交互 | `#3B82C4` | Tab 当前项、主按钮、今日限行标记线 |
| 限行 | `#3B82C4` | restricted 状态图标、alert 三角 |
| 不限行 | `#4E9A6E` | clear 状态、live 实时信号 |
| 估算 / 不确定 | `#B8894A` | estimated 问号图标 |
| 中性 | `#98A2AC` / `#5E6771` | 列表项、辅助信息、不可点 |

> 注意 B 方案的 `restricted` 用的是强调蓝而非红色。这不是妥协——蓝在深色底上对比度足够传达"需要注意"，而红色会让整个界面退化成警报器。红色只保留在方案 C 的浅色底上。

---

## 二、图标总览（19 枚）

### 导航 / Tab（4 枚）

| ID | 语义 | 用在哪 |
|---|---|---|
| `icon/today` | 今日限行 | Tab 1 · 首页标题旁 |
| `icon/calendar` | 日历 | Tab 2 · 日历页 |
| `icon/vehicle` | 车辆 | Tab 3 · 车辆管理 |
| `icon/settings` | 设置 | Tab 4 · 设置页 |

### 状态（3 枚）— 圆形类，轮廓统一便于并排比较

| ID | 语义 | 用在哪 |
|---|---|---|
| `icon/restricted` | 限行中 | 城市列表 · 限行城市 |
| `icon/clear` | 不限行 | 城市列表 · 不限行城市 |
| `icon/estimated` | 估算数据 | 数据源标记（实时/缓存/估算三态） |

### 信息（5 枚）

| ID | 语义 | 用在哪 |
|---|---|---|
| `icon/live` | 实时数据源 | 首页「数据源」卡 · 同步状态 |
| `icon/cached` | 缓存数据源 | 同上 |
| `icon/plate` | 车牌 | 车辆卡片 · 强提醒弹层 |
| `icon/location` | 城市 | 城市列表 · 绑定城市 |
| `icon/tail` | 尾号 | 限行尾号数值 |

### 提醒（3 枚）— 三角/铃/波形，轮廓差异最大

| ID | 语义 | 用在哪 |
|---|---|---|
| `icon/alert` | **强提醒** | 强提醒弹层徽标 · 权限引导 |
| `icon/bell` | 普通提醒 | 设置项 · 提醒列表 |
| `icon/voice` | 语音播报 | 强提醒弹层状态条 · 权限引导 |

### 操作（4 枚）

| ID | 语义 | 用在哪 |
|---|---|---|
| `icon/chevron-right` | 进入下一级 | 列表行尾部 |
| `icon/close` | 关闭 / 取消 | 弹层关闭 · 输入清除 |
| `icon/plus` | 添加 | 添加车辆 / 添加城市 |
| `icon/check` | 已完成 / 选中 | 引导页完成态 · 多选 |

---

## 三、SVG 源码

> Ardot 规范：图标用 `type: "frame"` + `svg` 属性，**必须设 `layout: "none"`**。
> 下面 `COLOR` 占位符在实际使用时替换为对应语义色值。

### icon/today — 今日限行

```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="3.25" y="5.25" width="17.5" height="15.5" rx="2.5" stroke="COLOR" stroke-width="1.75"/>
  <path d="M3.25 9.75h17.5" stroke="COLOR" stroke-width="1.75" stroke-linecap="round"/>
  <path d="M8 3.25v3.5M16 3.25v3.5" stroke="COLOR" stroke-width="1.75" stroke-linecap="round"/>
  <path d="M9 13.6l6 3.9" stroke="COLOR" stroke-width="1.75" stroke-linecap="round"/>
</svg>
```

> 日历 + 斜线。斜线只占下半场，避开日期分隔线，保证两个形都可读。

### icon/calendar — 日历

```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="3.25" y="5.25" width="17.5" height="15.5" rx="2.5" stroke="COLOR" stroke-width="1.75"/>
  <path d="M3.25 9.75h17.5M8 3.25v3.5M16 3.25v3.5" stroke="COLOR" stroke-width="1.75" stroke-linecap="round"/>
  <circle cx="8.2" cy="13.4" r="1.1" fill="COLOR"/>
  <circle cx="12" cy="13.4" r="1.1" fill="COLOR"/>
  <circle cx="15.8" cy="13.4" r="1.1" fill="COLOR"/>
  <circle cx="8.2" cy="17.1" r="1.1" fill="COLOR"/>
  <circle cx="12" cy="17.1" r="1.1" fill="COLOR"/>
</svg>
```

> 与 `today` 的区别只在内部：圆点网格 vs 斜线。轮廓完全一致，符合"同一容器、不同状态"。

### icon/vehicle — 车辆

```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M5.6 16.8l1.1-4.2a2 2 0 0 1 1.94-1.5h6.72a2 2 0 0 1 1.94 1.5l1.1 4.2" stroke="COLOR" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M4 16.8h16" stroke="COLOR" stroke-width="1.75" stroke-linecap="round"/>
  <path d="M4 16.8v1.9c0 .33.27.6.6.6h1.5c.33 0 .6-.27.6-.6v-1.9" stroke="COLOR" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M17.3 16.8v1.9c0 .33.27.6.6.6h1.5c.33 0 .6-.27.6-.6v-1.9" stroke="COLOR" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M6.6 12.7h10.8" stroke="COLOR" stroke-width="1.75" stroke-linecap="round"/>
</svg>
```

> 车顶弧线 + 车底横线 + 两个轮子 + 挡风玻璃分隔线。侧视角而非俯视，俯视图在小尺寸下会糊成一团。

### icon/settings — 设置

```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="12" cy="12" r="3.1" stroke="COLOR" stroke-width="1.75"/>
  <path d="M12 3.4v2.3M12 18.3v2.3M3.4 12h2.3M18.3 12h2.3" stroke="COLOR" stroke-width="1.75" stroke-linecap="round"/>
  <path d="M5.9 5.9l1.6 1.6M16.5 16.5l1.6 1.6M18.1 5.9l-1.6 1.6M7.5 16.5l-1.6 1.6" stroke="COLOR" stroke-width="1.75" stroke-linecap="round"/>
</svg>
```

> 中心圆 + 八向辐射短线。**不画完整齿轮**——24pt 下 8 个齿会互相粘连，这套"辐射"读法在 16pt 依然清晰。

### icon/restricted — 限行中

```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="12" cy="12" r="8.6" stroke="#3B82C4" stroke-width="1.75"/>
  <path d="M6.2 17.8L17.8 6.2" stroke="#3B82C4" stroke-width="1.75" stroke-linecap="round"/>
</svg>
```

### icon/clear — 不限行

```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="12" cy="12" r="8.6" stroke="#4E9A6E" stroke-width="1.75"/>
  <path d="M7.9 12.2l2.9 2.9 5.3-6" stroke="#4E9A6E" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

> `restricted` 与 `clear` 共用同一外圆（r=8.6），只换内部笔画。这是状态切换的标准做法——外形稳定，用户感知到的是"内容变了"而非"图标换了"。

### icon/estimated — 估算数据

```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="12" cy="12" r="8.6" stroke="#B8894A" stroke-width="1.75"/>
  <path d="M9.2 9.6a2.9 2.9 0 0 1 5.6.9c0 1.9-2.8 2.4-2.8 4" stroke="#B8894A" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"/>
  <circle cx="12" cy="17.4" r="1.05" fill="#B8894A"/>
</svg>
```

> 第三个状态用问号而非第三种形状。三态（实时/缓存/估算）共享外圆，构成完整家族。

### icon/live — 实时数据源

```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="12" cy="12" r="2.1" fill="#4E9A6E"/>
  <path d="M8.3 8.3a5.2 5.2 0 0 0 0 7.4M15.7 15.7a5.2 5.2 0 0 0 0-7.4" stroke="#4E9A6E" stroke-width="1.75" stroke-linecap="round"/>
  <path d="M5.6 5.6a9.1 9.1 0 0 0 0 12.8M18.4 18.4a9.1 9.1 0 0 0 0-12.8" stroke="#4E9A6E" stroke-width="1.75" stroke-linecap="round"/>
</svg>
```

> 双层扩散波 + 实心源点。与 `cached`（时钟）区分明确：一个表达"正在连接"，一个表达"停在某个时间点"。

### icon/cached — 缓存数据源

```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="12" cy="12" r="8.6" stroke="#5E6771" stroke-width="1.75"/>
  <path d="M12 7.2V12l3.2 1.9" stroke="#5E6771" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

### icon/plate — 车牌

```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="2.75" y="7.25" width="18.5" height="9.5" rx="2" stroke="COLOR" stroke-width="1.75"/>
  <path d="M6.8 12h4.4" stroke="COLOR" stroke-width="1.75" stroke-linecap="round"/>
  <circle cx="16.6" cy="12" r="1.15" fill="COLOR"/>
</svg>
```

> 圆角矩形 + 号码横杠 + 右侧圆点（车牌铆钉）。横杠长度刻意做短，暗示"号码还有余位"。

### icon/location — 城市

```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 21.2s7.2-6 7.2-11.2a7.2 7.2 0 1 0-14.4 0C4.8 15.2 12 21.2 12 21.2z" stroke="COLOR" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"/>
  <circle cx="12" cy="9.8" r="2.6" stroke="COLOR" stroke-width="1.75"/>
</svg>
```

### icon/tail — 尾号

```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M9.6 8.4l-3.2 7.2M15.6 8.4l-3.2 7.2" stroke="COLOR" stroke-width="1.75" stroke-linecap="round"/>
  <path d="M6.9 11.1h11M6.1 13.9h11" stroke="COLOR" stroke-width="1.75" stroke-linecap="round"/>
</svg>
```

> `#` 号。中英文语境都读作"编号"，与"尾号"这个概念贴合度最高。

### icon/alert — 强提醒

```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 3.9l8.7 15a1.05 1.05 0 0 1-.91 1.6H4.21a1.05 1.05 0 0 1-.91-1.6L12 3.9z" stroke="#3B82C4" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M12 9.5v4" stroke="#3B82C4" stroke-width="1.75" stroke-linecap="round"/>
  <circle cx="12" cy="16.5" r="1.05" fill="#3B82C4"/>
</svg>
```

> 三角 + 感叹号。这是全套里唯一使用三角轮廓的图形——**形状独占**是它能表达"最高优先级"的原因。

### icon/bell — 普通提醒

```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M18.2 16.6v-4.9a6.2 6.2 0 1 0-12.4 0v4.9l-1.7 1.9h15.8l-1.7-1.9z" stroke="COLOR" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M9.9 20.3a2.25 2.25 0 0 0 4.2 0" stroke="COLOR" stroke-width="1.75" stroke-linecap="round"/>
</svg>
```

> 铃身 + 铃舌弧线。与 `alert` 的三角形成"常规 / 紧急"两级，形状上完全不同不会混淆。

### icon/voice — 语音播报

```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M3.9 9.4h3.2L11.5 5.6v12.8L7.1 14.6H3.9a.9.9 0 0 1-.9-.9v-3.4a.9.9 0 0 1 .9-.9z" stroke="COLOR" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M14.8 9.2a3.9 3.9 0 0 1 0 5.6" stroke="COLOR" stroke-width="1.75" stroke-linecap="round"/>
  <path d="M17.6 6.7a7.5 7.5 0 0 1 0 10.6" stroke="COLOR" stroke-width="1.75" stroke-linecap="round"/>
</svg>
```

> 喇叭 + 双层声波。它同时也是 `alert` 的可见性锚点——用户开启强提醒后，这里会出现一个此前不存在的图标，形成正反馈。

### icon/chevron-right

```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M9.4 5.6l6.4 6.4-6.4 6.4" stroke="COLOR" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

### icon/close

```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M6.6 6.6l10.8 10.8M17.4 6.6L6.6 17.4" stroke="COLOR" stroke-width="1.75" stroke-linecap="round"/>
</svg>
```

### icon/plus

```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 5.4v13.2M5.4 12h13.2" stroke="COLOR" stroke-width="1.75" stroke-linecap="round"/>
</svg>
```

### icon/check

```svg
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M5.4 12.4l4.4 4.4 8.8-9.6" stroke="#4E9A6E" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

---

## 四、尺寸与使用规范

| 场景 | 图标尺寸 | 容器 | 说明 |
|---|---|---|---|
| Tab Bar 图标 | **24 pt** | 48pt 高药丸 | Ardot 要求 24–28pt |
| 列表行图标 | 20 pt | — | 与 13pt 正文视觉对齐 |
| 卡片内图标 | 16 pt | — | 次要信息 |
| 强提醒徽标 | 14 pt | 28pt 高胶囊 | 与 10pt 大写文字同高 |
| 首页状态卡 | 28 pt | — | 强调区 |
| **可点击热区** | — | **≥ 44 × 44 pt** | 图标本身 24pt，热区必须外扩 |

### 颜色使用顺序（优先级从高到低）

```
1. 强调 #3B82C4      Tab 当前项 / 主按钮 / 今日限行标记线
2. 语义色            restricted / clear / estimated
3. 中性 #98A2AC      列表图标 / 未激活 Tab
4. 弱化 #5E6771      禁用态 / 装饰性图标
```

**禁止**：用图标色表达与功能无关的含义（比如用红色表示"删除"以外的任何事）。

---

## 五、Ardot 画布构建脚本

### 5.1 创建图标组件（示例：三个 Tab 图标）

> 规范要求：图标先做成 **COMPONENT**，再以 `type: "ref"` 实例化。
> 创建图标 frame 时**必须设 `layout: "none"`**，否则 SVG 内容会被布局系统重排。

```javascript
// ========== Batch 1: 三个 Tab 图标组件（3 ops）==========
ICON = "#EDF1F5"   // 中性色，激活态由父容器 fill 覆盖

iconToday = I(document, {
  type: "component", name: "icon/today",
  layout: "none", width: 24, height: 24, fills: [],
  svg: "<svg width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" xmlns=\"http://www.w3.org/2000/svg\"><rect x=\"3.25\" y=\"5.25\" width=\"17.5\" height=\"15.5\" rx=\"2.5\" stroke=\"" + ICON + "\" stroke-width=\"1.75\"/><path d=\"M3.25 9.75h17.5\" stroke=\"" + ICON + "\" stroke-width=\"1.75\" stroke-linecap=\"round\"/><path d=\"M8 3.25v3.5M16 3.25v3.5\" stroke=\"" + ICON + "\" stroke-width=\"1.75\" stroke-linecap=\"round\"/><path d=\"M9 13.6l6 3.9\" stroke=\"" + ICON + "\" stroke-width=\"1.75\" stroke-linecap=\"round\"/></svg>"
})

iconCalendar = I(document, {
  type: "component", name: "icon/calendar",
  layout: "none", width: 24, height: 24, fills: [],
  svg: "<svg width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" xmlns=\"http://www.w3.org/2000/svg\"><rect x=\"3.25\" y=\"5.25\" width=\"17.5\" height=\"15.5\" rx=\"2.5\" stroke=\"" + ICON + "\" stroke-width=\"1.75\"/><path d=\"M3.25 9.75h17.5M8 3.25v3.5M16 3.25v3.5\" stroke=\"" + ICON + "\" stroke-width=\"1.75\" stroke-linecap=\"round\"/><circle cx=\"8.2\" cy=\"13.4\" r=\"1.1\" fill=\"" + ICON + "\"/><circle cx=\"12\" cy=\"13.4\" r=\"1.1\" fill=\"" + ICON + "\"/><circle cx=\"15.8\" cy=\"13.4\" r=\"1.1\" fill=\"" + ICON + "\"/><circle cx=\"8.2\" cy=\"17.1\" r=\"1.1\" fill=\"" + ICON + "\"/><circle cx=\"12\" cy=\"17.1\" r=\"1.1\" fill=\"" + ICON + "\"/></svg>"
})

iconVehicle = I(document, {
  type: "component", name: "icon/vehicle",
  layout: "none", width: 24, height: 24, fills: [],
  svg: "<svg width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" xmlns=\"http://www.w3.org/2000/svg\"><path d=\"M5.6 16.8l1.1-4.2a2 2 0 0 1 1.94-1.5h6.72a2 2 0 0 1 1.94 1.5l1.1 4.2\" stroke=\"" + ICON + "\" stroke-width=\"1.75\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/><path d=\"M4 16.8h16\" stroke=\"" + ICON + "\" stroke-width=\"1.75\" stroke-linecap=\"round\"/><path d=\"M4 16.8v1.9c0 .33.27.6.6.6h1.5c.33 0 .6-.27.6-.6v-1.9\" stroke=\"" + ICON + "\" stroke-width=\"1.75\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/><path d=\"M17.3 16.8v1.9c0 .33.27.6.6.6h1.5c.33 0 .6-.27.6-.6v-1.9\" stroke=\"" + ICON + "\" stroke-width=\"1.75\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/><path d=\"M6.6 12.7h10.8\" stroke=\"" + ICON + "\" stroke-width=\"1.75\" stroke-linecap=\"round\"/></svg>"
})
```

> 组件创建后**必须跑一次 `capture_screenshot`** 验证 SVG 渲染正确。SVG 内容写错时 Ardot 不会报错，只会静默显示空白框。

### 5.2 替换 Tab 药丸中的占位符

```javascript
// ========== Batch 2: Tab 实例化（4 ops）==========
tabIcon1 = U(tabActive, { children: [ I(tabActive, {type:"ref", ref: iconToday}) ] })
tabIcon2 = I(pill,    {type:"ref", ref: iconCalendar})
tabIcon3 = I(pill,    {type:"ref", ref: iconVehicle})
tabIcon4 = I(pill,    {type:"ref", ref: iconSettings})

// 图标间距：药丸内 layout 改 vertical，gap 3
U(tabActive, { layout: "vertical", gap: 3, padding: 6,
  primaryAxisAlignItems: "CENTER", counterAxisAlignItems: "CENTER" })
```

### 5.3 城市列表状态图标

```javascript
// ========== Batch 3: 列表状态（2 ops）==========
dotRestricted = I(cityRowA, { type: "component", name: "icon/restricted",
  layout: "none", width: 20, height: 20, fills: [],
  svg: "<svg width=\"20\" height=\"20\" viewBox=\"0 0 24 24\" fill=\"none\" xmlns=\"http://www.w3.org/2000/svg\"><circle cx=\"12\" cy=\"12\" r=\"8.6\" stroke=\"#3B82C4\" stroke-width=\"1.75\"/><path d=\"M6.2 17.8L17.8 6.2\" stroke=\"#3B82C4\" stroke-width=\"1.75\" stroke-linecap=\"round\"/></svg>"
})

dotClear = I(cityRowB, { type: "component", name: "icon/clear",
  layout: "none", width: 20, height: 20, fills: [],
  svg: "<svg width=\"20\" height=\"20\" viewBox=\"0 0 24 24\" fill=\"none\" xmlns=\"http://www.w3.org/2000/svg\"><circle cx=\"12\" cy=\"12\" r=\"8.6\" stroke=\"#4E9A6E\" stroke-width=\"1.75\"/><path d=\"M7.9 12.2l2.9 2.9 5.3-6\" stroke=\"#4E9A6E\" stroke-width=\"1.75\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/></svg>"
})
```

> **状态切换只换实例指向的组件**，不改颜色、不改尺寸。用户看到的是"同一个位置换了个符号"，而不是界面跳变。

---

## 六、回填 Flutter

SVG 需要转成 Flutter 可用的绘制代码。三种路径，按成本排序：

### 路径 1：`flutter_svg`（推荐）

```yaml
dependencies:
  flutter_svg: ^2.0.10
```

```dart
import 'package:flutter_svg/flutter_svg.dart';

class TaillimitIcon extends StatelessWidget {
  const TaillimitIcon(this.name, {super.key, this.size = 24, this.color});

  final String name;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/$name.svg',
      width: size,
      height: size,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}
```

19 个 SVG 存为 `assets/icons/`，注册进 `pubspec.yaml` 的 `assets:` 段。

**关键**：用 `colorFilter` 在运行时染色，而不是为每种颜色各存一份 SVG。上面所有 SVG 都写死了色值，落地时要把 `COLOR` 占位符换成 `currentColor`，`flutter_svg` 才能正确着色。

### 路径 2：`Icon` + `IconData`（零依赖，但受限）

19 个自定义图形超出 Material Icons 覆盖范围，只能自建 `IconData`：

```dart
IconData buildIcon(String name) => IconData(
  0xe900 + _codePoint[name]!,
  fontFamily: 'TaillimitIcons',
);
```

需要额外一个字体文件。**不推荐**——多一个字体依赖，且无法运行时染色。

### 路径 3：矢量路径直接绘制（无依赖）

```dart
CustomPaint(painter: TaillimitIconPainter(name: 'restricted', color: accent))
```

每个图标一个 `Path`。零依赖零资源，但 19 个图标要手写 19 个 `Path`，维护成本高。

**建议**：路径 1。`flutter_svg` 是社区标准方案，19 个 SVG 的维护成本远低于 19 段手写路径。

---

## 七、验收清单

- [ ] 全部图标建立在 24×24 viewBox，描边统一 1.75
- [ ] 四大类轮廓可区分：圆（状态）/ 方（容器）/ 三角（警示）/ 波形（信号）
- [ ] `restricted` / `clear` / `estimated` 共享外圆 r=8.6
- [ ] `today` / `calendar` 共享日历外框
- [ ] `alert` 是唯一使用三角轮廓的图形
- [ ] 所有图标 frame 设了 `layout: "none"`
- [ ] 所有图标组件创建后跑过 `capture_screenshot`
- [ ] 可点击热区 ≥ 44 × 44 pt
- [ ] 颜色仅承载语义，无装饰性用色
- [ ] Tab 图标 24pt，标签 10pt 全大写
- [ ] SVG 中色值已替换为 `currentColor`（供运行时染色）
