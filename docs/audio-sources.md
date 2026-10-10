# 内置音频来源与许可

本文件记录 TailLimit 内置的全部音频资源及其许可条款。

**合规底线**：凡标注 `CC BY` 的资源，应用内必须有可见的署名展示位置；
凡标注 `NC`（非商用）或 `ND`（禁止改作）的资源，一律不得内置。

---

## 一、当前内置资源

| 文件 | 标题 | 时长 | 体积 | 来源作者 | 许可 |
|---|---|---:|---:|---|---|
| `assets/audio/ocean_waves.ogg` | 海岸浪涛 | 118.0s | 803 KB | Buk（Blanket 音频集） | CC BY 4.0 |
| `assets/audio/campfire.ogg` | 篝火燃烧 | 25.5s | 151 KB | Goodkoalas（Blanket 音频集） | CC BY 4.0 |

合计约 **954 KB**。

许可全文：<https://creativecommons.org/licenses/by/4.0/legalcode>

### 上游来源

原始录音取自 [Blanket](https://github.com/rafaelmardojai/blanket) 项目的音频集
（`data/resources/sounds/`），该集本身来自 [Freesound](https://freesound.org) 的
CC0 / CC BY 录音。TailLimit 未修改录音内容，仅做响度归一化、循环接缝处理与格式转码。

- 海岸浪涛原始文件：`data/resources/sounds/waves.ogg`
- 篝火燃烧原始文件：`data/resources/sounds/fireplace.ogg`

### 处理过程

两个文件均经`tool/prepare_audio.py` 处理：

| 处理步骤 | 说明 |
|---|---|
| 响度归一化 | 统一到 **-20 LUFS**。这是背景音的合适响度，不刺耳也不会盖过语音播报 |
| 循环接缝处理 | `ocean_waves` 录音本身首尾波形连续，未做处理；`campfire` 原始录音尾部为纯静音，施加 **4 秒等功率交叉淡化** |
| 格式转码 | 统一为 **Opus / 48kHz / 立体声 / 64kbps**。Opus 在此码率下环境音听感无损，占原始体积约 29% |
| 削波检查 | 峰值 0.80 与 0.95，**满幅样本 0**，无削波 |
| 接缝验证 | 循环接缝跳变分别为 1.0dB 与 4.7dB，均低于 6dB 的可闻阈值 |

---

## 二、待办：应用内署名页

`CC BY 4.0` 要求「以合理方式注明作者」。当前署名信息已结构化存放在
`lib/domain/entities/noise.dart` 的 `AudioCredit` 中，并有测试守护
（见 `test/domain/audio_assets_test.dart`），但**尚未在界面上展示**。

上架前必须补齐，建议位置：

- 白噪音页 → 单个音色的详情弹层
- 设置 → 关于 → 音源致谢（集中展示全部）

`AudioCredit` 已提供 `title` / `author` / `source` / `license` / `licenseUrl`
字段，界面层只需遍历 `NoiseKind.values` 中 `credit != null` 的项渲染。

---

## 三、未内置的资源及原因

### 3.1 CC0 / 公有领域但暂未使用

共58 个零署名义务的音源可用。已评估未采用的代表性条目：

| 资源 | 未采用原因 |
|---|---|
| 火车车厢、老地铁、高速列车 | 行驶场景下有车厢噪声与播报声，可能干扰驾驶注意力 |
| 打字机、机械钟、键盘 | 属于 ASMR / 专注类，不属于放松类，且有重复事件感 |
| 猫呼噜 | 部分用户对猫毛过敏，且叫声易打断平静感 |
| 城市街道 | 含交通噪声与路人交谈声，不适合闭眼休息 |

### 3.2 因下载渠道受限未采用

`BigSoundBank` 系列有大量优质 CC0 录音（海岸浪潮、林间鸟鸣、溪畔森林等），
但其下载需提交表单并有等待期，自动化批量获取不可行。
若后续需扩充，建议走人工下载 + 本脚本处理。

### 3.3 非 CC0 而未采用

`city`、`train`（Blanket 内的同名条目）等为 CC BY，虽可署名后使用，
但当前无必要——已有 CC BY 资源足以覆盖同类需求。

---

## 四、扩充音源的操作流程

```bash
# 1. 下载原始录音（走 jsDelivr CDN，直连 raw.githubusercontent 可能超时）
curl -o raw.ogg "https://cdn.jsdelivr.net/gh/rafaelmardojai/blanket@<commit>/data/resources/sounds/<name>.ogg"

# 2. 检查原始文件能否自然循环
python3 tool/prepare_audio.py --inspect raw.ogg

# 3. 处理（脚本会自动测量响度增益）
python3 tool/prepare_audio.py --source raw.ogg --output assets/audio/<name>.ogg
# 若第2 步判定「需要交叉淡化」，追加 --xfade 4.0

# 4. 在 lib/domain/entities/noise.dart 的枚举与 credit 中登记

# 5. 跑测试——存在性、体积、格式、署名合规都会自动校验
flutter test test/domain/audio_assets_test.dart
```

### 体积控制

新增音源时守住两条线（已有测试守护）：

- 单文件 < 3 MB
- 实录音合计 < 12 MB

Opus 48k 单声道/立体声的粗略估算：**时长秒数 × 8 KB**。若要放进更多音色，
优先考虑降码率至 48k 或转单声道，而不是缩短录音——环境音的放松感依赖
持续性，反复循环 25 秒比听 2 分钟更耐听。

---

## 五、检查清单

新增音源时逐条确认：

- [ ] 许可不是 NC（禁止商用）或 ND（禁止改作）
- [ ] CC BY 类已在 `AudioCredit` 中填写完整的作者、来源链接、许可链接
- [ ] 已确认接缝自然，或已施加交叉淡化
- [ ] 峰值 < 1.0，满幅样本数为 0
- [ ] `flutter test test/domain/audio_assets_test.dart` 通过
- [ ] 若为 CC BY，应用内已有可见的署名展示位置