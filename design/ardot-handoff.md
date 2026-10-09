# Ardot 接入说明 & 画布构建脚本

> 用途：把 TailLimit 的 UI 设计稿落到腾讯 Ardot 画布上。
> 当前状态：**沙箱环境无法直连 Ardot MCP**（MCP 服务由 Ardot 桌面客户端本地启动，沙箱内无此客户端）。
> 因此本文件提供两条路径：A) 本地启用 MCP 后由 AI 直接操作画布；B) 手动在 Ardot 内执行构建脚本。

---

## 一、为什么现在连不上

我尝试过：

```bash
curl http://127.0.0.1:50501/api/v1/mcp
# → HTTP 000（连接被拒绝）
```

Ardot 的 MCP 是**本地 HTTP 服务**，监听 `127.0.0.1:50501`，由 **Ardot 桌面客户端**在启动时拉起。
我的运行环境是一台隔离沙箱，`127.0.0.1` 指向的是沙箱自己，不是你的电脑，所以：

- 端口不存在 → 工具加载不出 → 无法 `batch_edit` 画布

这不是配置问题，是环境隔离的硬限制。

> 官方原文：*MCP currently works only inside the Ardot desktop app.*

---

## 二、路径 A：启用 MCP（推荐，一次配置长期可用）

### 1. 安装 Ardot 桌面客户端

- 下载：<https://ardot.tencent.com>
- 当前 **macOS 优先**，Windows 版本官方标注「即将推出」

### 2. 在客户端内启用 MCP 服务

1. 打开 Ardot 桌面端
2. 打开或新建一个设计文件（**必须先有打开的文件**，MCP 依赖当前编辑上下文）
3. 右上角找到 **MCP 配置入口** → 启用 **Agent 接入**
4. 记下服务地址，默认是：

```
http://127.0.0.1:50501/api/v1/mcp
```

### 3. 写入 MCP 配置

在你的 MCP 客户端配置文件中加入：

```json
{
  "mcpServers": {
    "ardot": {
      "type": "http",
      "url": "http://127.0.0.1:50501/api/v1/mcp"
    }
  }
}
```

### 4. 验证连通

```bash
curl -s -o /dev/null -w "HTTP %{http_code}\n" http://127.0.0.1:50501/api/v1/mcp
# 期望：HTTP 200 或 405（405 说明服务在，只是方法不对，也是正常的）
```

### 5. 告诉我，我接管画布

跑通后跟我说一声，我会按下面的流程直接操作：

| 步骤 | 工具 | 动作 |
|---|---|---|
| Step 0 | `fetch_editor_state` | 确认文件已打开、拿到 `fileId` / `pageId` |
| Step 1 | `fetch_variables` + `fetch_component_lib` + `fetch_guidelines` | 并行读取现有变量、组件、规范 |
| Step 2 | `apply_variables` | 写入 TailLimit 的 Design Tokens（见第四节） |
| Step 3 | `locate_available_space` | 在根画布找空位，避免叠图 |
| Step 4 | `batch_edit` | 分批构建（每批 ≤ 25 ops） |
| Step 5 | `capture_screenshot` + `capture_layout` | 分级验证，改到无重叠/无裁切 |

---

## 三、路径 B：手动执行构建脚本

如果暂时不想折腾 MCP，可以把下面的语句序列粘进 Ardot 的 Agent 对话，由它执行。

### 关键约束（Ardot 专有语法，写错会静默失效）

| 错误写法 | 正确写法 | 说明 |
|---|---|---|
| `textColor: "#FFF"` | `fill: "#FFFFFF"` | 文字颜色统一走 `fill` |
| `backgroundColor` | `fill` | 背景也是 `fill` |
| `color` / `fillColor` | `fill` | 同上 |
| `borderRadius: 12` | `cornerRadius: 12` | 圆角属性名 |
| `fontWeight: "bold"` | `fontWeight: "700"` | 字重必须是数字字符串 |
| `fontWeight: "semibold"` | `fontWeight: "600"` | 同上 |
| `alignItems: "center"` | `counterAxisAlignItems: "CENTER"` | 交叉轴，大写枚举 |
| `justifyContent: "center"` | `primaryAxisAlignItems: "CENTER"` | 主轴，大写枚举 |
| — | 每个节点必须有 `name` | 否则后续无法定位 |
| — | 插入根画布前必须 `locate_available_space` | 否则会和已有内容重叠 |

其他要点：

- 文字默认**没有颜色**，不设 `fill` 就是隐形的
- 长文本换行要**同时**设 `textAutoResize: "HEIGHT"` 和 `width: "fill_container"`
- 子节点设了 `x`/`y` 在 flexbox 父容器里**会被忽略**，要绝对定位得设 `layoutPositioning: "ABSOLUTE"`
- `fill_container` 只能用在 flexbox 父容器下；`hug_contents` 只能用在自身是 flexbox 的节点上
- 变量绑定格式 `$:SetName:VariableName`（比 SKILL.md 里提到的 `$` 前缀更完整）

---

## 四、Design Tokens（三套方案通用结构）

无论选哪个视觉方向，变量集结构一致，只换值。命名规则：`$:<SetName>:<VariableName>`。

### Set: `Primitives`

| 变量 | 类型 | A 暖陶 | B 电蓝 | C 玻璃浅色 |
|---|---|---|---|---|
| `bg` | COLOR | `#17140F` | `#0D0F11` | `#F4F5F7` |
| `surface` | COLOR | `#221D16` | `#141719` | `#FFFFFF` |
| `outline` | COLOR | `#322A20` | `#23282C` | `#E4E6EA` |
| `accent` | COLOR | `#C2643F` | `#3B82C4` | `#1B1E22` |
| `clear` | COLOR | `#6E8F72` | `#4E9A6E` | `#2E7D4F` |
| `restricted` | COLOR | `#C2643F` | `#3B82C4` | `#C0392B` |
| `text-primary` | COLOR | `#F2EAE0` | `#EDF1F5` | `#1B1E22` |
| `text-secondary` | COLOR | `#9A8B79` | `#98A2AC` | `#5C6470` |
| `text-tertiary` | COLOR | `#6E6255` | `#5E6771` | `#8890A0` |

### Set: `Semantic`

| 变量 | 绑定到 | 用途 |
|---|---|---|
| `bg-app` | `Primitives:bg` | 页面底 |
| `bg-card` | `Primitives:surface` | 卡片 |
| `border-subtle` | `Primitives:outline` | 1px 描边 |
| `text-body` | `Primitives:text-secondary` | 正文 |
| `text-title` | `Primitives:text-primary` | 标题 |
| `state-restricted` | `Primitives:restricted` | 限行中 |
| `state-clear` | `Primitives:clear` | 不限行 |

### Set: `Spacing`（FLOAT）

| 变量 | 值 | 用途 |
|---|---|---|
| `screen-w` | `402` | iPhone 17 Pro 逻辑宽 |
| `screen-h` | `874` | 逻辑高 |
| `status-bar` | `54` | 状态栏 |
| `safe-top` | `62` | 含灵动岛 |
| `safe-bottom` | `34` | Home Indicator |
| `gutter` | `18` | 左右边距（只加在 wrapper 上） |
| `gap-lg` | `24` | 区块间距 |
| `gap-md` | `14` | 区块内间距 |
| `gap-sm` | `9` | 紧邻元素 |
| `radius-card` | `20` | 大卡片 |
| `radius-sm` | `13` | 输入框 / 按钮 |
| `radius-pill` | `33` | Tab 药丸 |

### Set: `Typography`（FLOAT）

遵循 iOS HIG 字阶，正文 ≥ 13pt。

| 变量 | 值 | 用途 |
|---|---|---|
| `size-hero` | `32` | 首页主数值（尾号） |
| `size-h1` | `26` | 引导页大标题 |
| `size-title` | `15` | 导航标题（**全 App 统一**） |
| `size-body` | `13.5` | 正文 |
| `size-caption` | `11` | 标签 / 说明 |
| `size-tab` | `8.5` | Tab 文字 |

字体栈（避开 Ardot 明令禁止的 Inter）：

```
Geist / Satoshi / Outfit  →  主字体
Geist Mono / JetBrains Mono  →  车牌号、时间、数值
```

中文回退：`PingFang SC` → `HarmonyOS Sans` → `Microsoft YaHei`

---

## 五、画布构建批次规划

以 **方案 B（石墨电蓝）** 为例，Home 屏拆成 4 批，每批都在 25 ops 以内：

### Batch 1 — 屏幕骨架（T1，验证用 `capture_layout`）

```
screen=I(document, {type:"frame", name:"Home / 今日限行", layout:"vertical",
  width:402, height:874, fill:"$:Primitives:bg", clipsContent:true})

statusBar=I(screen, {type:"frame", name:"Status Bar", layout:"horizontal",
  width:"fill_container", height:54, primaryAxisAlignItems:"SPACE_BETWEEN",
  counterAxisAlignItems:"CENTER", paddingLeft:20, paddingRight:20, fills:[]})
statusTime=I(statusBar, {type:"text", name:"Time", content:"9:41", fontSize:15,
  fontWeight:"600", fill:"$:Primitives:text-primary"})
statusIcons=I(statusBar, {type:"text", name:"Indicators", content:"5G ▮▮▮",
  fontSize:11, fontWeight:"600", fill:"$:Primitives:text-primary"})

wrapper=I(screen, {type:"frame", name:"Content Wrapper", layout:"vertical",
  width:"fill_container", height:"fill_container", gap:14,
  paddingLeft:18, paddingRight:18, paddingBottom:14, fills:[]})
```

> 注意：整屏内容必须装在**唯一一个 wrapper** 里，左右边距只在 wrapper 上加一次，子区块不再各自加 padding。

### Batch 2 — 导航 + 主状态卡（T3，验证用 `capture_screenshot`）

```
navRow=I(wrapper, {type:"frame", name:"Nav Row", layout:"horizontal",
  width:"fill_container", height:"hug_contents",
  primaryAxisAlignItems:"SPACE_BETWEEN", counterAxisAlignItems:"CENTER",
  paddingTop:4, paddingBottom:6, fills:[]})
navTitle=I(navRow, {type:"text", name:"Page Title", content:"今日限行",
  fontSize:15, fontWeight:"700", fill:"$:Primitives:text-primary"})
navIcon=I(navRow, {type:"text", name:"Action Icon", content:"◍",
  fontSize:13, fill:"$:Primitives:text-secondary"})

hero=I(wrapper, {type:"frame", name:"Status Card", layout:"vertical",
  width:"fill_container", height:"hug_contents", gap:9,
  paddingTop:20, paddingBottom:20, paddingLeft:18, paddingRight:18,
  fill:"$:Primitives:surface", cornerRadius:"$:Spacing:radius-card",
  stroke:"$:Semantic:border-subtle", strokeWeight:1})

heroLine=I(hero, {type:"frame", name:"Accent Mark", layout:"none",
  width:3, height:"fill_container", fill:"$:Primitives:accent",
  layoutPositioning:"ABSOLUTE"})

plate=I(hero, {type:"text", name:"Plate Badge", content:"京A·5F72Q",
  fontSize:10.5, fontFamily:"Geist Mono", fill:"$:Primitives:text-secondary",
  textAlignHorizontal:"RIGHT", textAutoResize:"HEIGHT", width:"fill_container"})

heroDate=I(hero, {type:"text", name:"Date Label", content:"THURSDAY · 10月9日",
  fontSize:10.5, fontWeight:"600", fill:"$:Primitives:text-tertiary",
  textAutoResize:"HEIGHT", width:"fill_container"})

heroValue=I(hero, {type:"text", name:"Restriction Value", content:"尾号 2 和 7",
  fontSize:"$:Typography:size-hero", fontWeight:"750", lineHeight:34,
  fill:"$:Semantic:text-title", textAutoResize:"HEIGHT", width:"fill_container"})

heroDesc=I(hero, {type:"text", name:"Description",
  content:"今天 07:00–20:00 五环路以内限行\n你的车牌尾号 7，今日不可通行",
  fontSize:12.5, lineHeight:18, fill:"$:Semantic:text-body",
  textAutoResize:"HEIGHT", width:"fill_container"})
```

### Batch 3 — 双卡 + 城市列表（T2/T3，跳过验证）

```
row2=I(wrapper, {type:"frame", name:"Stat Row", layout:"horizontal",
  width:"fill_container", height:"hug_contents", gap:11, fills:[]})
tomorrow=I(row2, {type:"frame", name:"Tomorrow Card", layout:"vertical",
  width:"fill_container", height:"hug_contents", gap:5, padding:14,
  fill:"$:Primitives:surface", cornerRadius:15,
  stroke:"$:Semantic:border-subtle", strokeWeight:1})
tmLabel=I(tomorrow, {type:"text", name:"Label", content:"明日", fontSize:10,
  fontWeight:"600", fill:"$:Primitives:text-tertiary",
  textAutoResize:"HEIGHT", width:"fill_container"})
tmValue=I(tomorrow, {type:"text", name:"Value", content:"不限行", fontSize:17,
  fontWeight:"680", fill:"$:Primitives:clear",
  textAutoResize:"HEIGHT", width:"fill_container"})
tmDesc=I(tomorrow, {type:"text", name:"Desc", content:"尾号 3, 8", fontSize:10.5,
  fill:"$:Primitives:text-tertiary", textAutoResize:"HEIGHT", width:"fill_container"})

source=I(row2, {type:"frame", name:"Source Card", layout:"vertical",
  width:"fill_container", height:"hug_contents", gap:5, padding:14,
  fill:"$:Primitives:surface", cornerRadius:15,
  stroke:"$:Semantic:border-subtle", strokeWeight:1})
srcLabel=I(source, {type:"text", name:"Label", content:"数据源", fontSize:10,
  fontWeight:"600", fill:"$:Primitives:text-tertiary",
  textAutoResize:"HEIGHT", width:"fill_container"})
srcValue=I(source, {type:"text", name:"Value", content:"实时", fontSize:17,
  fontWeight:"680", fill:"$:Semantic:text-title",
  textAutoResize:"HEIGHT", width:"fill_container"})
srcDesc=I(source, {type:"text", name:"Desc", content:"2 分钟前", fontSize:10.5,
  fill:"$:Primitives:text-tertiary", textAutoResize:"HEIGHT", width:"fill_container"})

cityList=I(wrapper, {type:"frame", name:"City List", layout:"vertical",
  width:"fill_container", height:"hug_contents",
  fill:"$:Primitives:surface", cornerRadius:15,
  stroke:"$:Semantic:border-subtle", strokeWeight:1, clipsContent:true})
```

### Batch 4 — Tab 药丸（T4，双验证）

```
tabArea=I(wrapper, {type:"frame", name:"Tab Bar Area", layout:"vertical",
  width:"fill_container", height:"hug_contents", paddingTop:12, paddingBottom:16,
  primaryAxisAlignItems:"MIN", fills:[]})
pill=I(tabArea, {type:"frame", name:"Tab Pill", layout:"horizontal",
  width:"fill_container", height:56, gap:3, padding:4,
  fill:"$:Primitives:surface", cornerRadius:"$:Spacing:radius-pill",
  stroke:"$:Semantic:border-subtle", strokeWeight:1})
tabActive=I(pill, {type:"frame", name:"Tab / Today / Active", layout:"vertical",
  width:"fill_container", height:"fill_container", gap:3,
  primaryAxisAlignItems:"CENTER", counterAxisAlignItems:"CENTER",
  fill:"$:Primitives:accent", cornerRadius:24})
tabIcon=I(tabActive, {type:"text", name:"Icon", content:"◉", fontSize:14,
  fill:"$:Primitives:bg"})
tabLabel=I(tabActive, {type:"text", name:"Label", content:"TODAY", fontSize:8.5,
  fontWeight:"600", fill:"$:Primitives:bg"})
```

> Tab 必须是 3–5 个，标签**全大写**，激活态用**实心填充**而不是只换颜色。

---

## 六、多屏排布规则

Ardot 移动端场景要求：

- 每屏是独立的 **402 × 874 pt** Frame
- 多屏时**水平排布**，屏间距 **≥ 40 pt**
- 全部挂在同一个 **Design Board** 下
- 可点击元素 **≥ 44 × 44 pt**
- 正文 **≥ 13 pt**

TailLimit 本次三屏：

```
[Home 今日限行]  ←40pt→  [Onboarding 绑定车牌]  ←40pt→  [Strong Alert 强提醒]
```

---

## 七、强提醒弹层特别注意

这是产品最核心的差异点，设计上要区分于普通通知：

| 要素 | 处理 |
|---|---|
| 遮罩 | 深色底 `opacity 0.75–0.9`，浅色方案用 `backdrop-filter: blur` |
| 弹层 | 底部 Sheet，圆角 `26px` 上边、0 下边 |
| 抓手 | 34 × 4px，圆角 2px |
| 徽标 | 「⚑ 今日限行 · 强提醒」，10px / 700 / 大写 / 字距 0.7 |
| 主标题 | 车牌 + 「今天不能进五环」，22px / 750，两行断开 |
| 说明 | 时间窗 + 你的尾号，13px / 行高 1.6 |
| 状态条 | 「语音播报已开启 ON」——体现强提醒能力 |
| 操作 | 左「知道了」幽灵按钮 + 右「看详情」实心按钮，各 48pt 高 |

---

## 八、验收清单

生成后逐条自检：

- [ ] 每屏严格 **402 × 874 pt**
- [ ] 顶部状态栏 54pt + 灵动岛安全区到 62pt，NavBar 从 62pt 起
- [ ] 底部 Home Indicator 34pt 预留；有 TabBar 时底部合计 83pt
- [ ] 可点击元素 ≥ 44 × 44 pt
- [ ] 正文 ≥ 13 pt
- [ ] 每屏完成后跑过 `capture_screenshot`
- [ ] `capture_layout` 无重叠、无裁切
- [ ] 所有颜色走变量绑定，无硬编码色值
- [ ] 无 `#000000`、无外发光、无 AI 紫
- [ ] 每个节点都有 `name`

---

## 九、设计完成后回到代码

选定的 Design Tokens 会同步回 Flutter，替换 `lib/core/theme/app_colors.dart`。

当前实现（将被替换）：

```dart
static const Color background = Color(0xFF1A1A1A);   // 深空灰
static const Color primary    = Color(0xFFC9A96E);   // 香槟金
```

替换策略：

1. 保留 `AppColors` 的**语义命名**（`background` / `surface` / `primary` / `restricted` / `free` …）
2. 只改色值，表现层代码零改动
3. 新增一组 `AppDimensions` 常量承载 `Spacing` 变量
4. 字体按平台分发加载 Geist / HarmonyOS Sans
