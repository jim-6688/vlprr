import 'package:flutter/material.dart';

/// TailLimit 色板：石墨电蓝（方案 B）。
///
/// 设计约束（对齐 Ardot style-guide）：
/// - 无纯黑 [#000000]，最深为 [background] #0D0F11；
/// - 单一强调色 [primary] #3B82C4，饱和度 < 80%；
/// - 不使用 AI 紫 / 霓虹渐变；
/// - 颜色只承载语义，不做装饰。
///
/// 语义命名在视觉改版中保持不变——换色只改值，不改键。
class AppColors {
  const AppColors._();

  // —— 背景层次（石墨）——
  static const Color background = Color(0xFF0D0F11);
  static const Color surface = Color(0xFF141719);
  static const Color surfaceElevated = Color(0xFF1A1E21);
  static const Color outline = Color(0xFF23282C);
  static const Color outlineStrong = Color(0xFF2B3238);

  // —— 主强调（电蓝）——
  static const Color primary = Color(0xFF3B82C4);
  static const Color primaryDark = Color(0xFF2E6CA8);
  static const Color primaryContainer = Color(0xFF16283A);

  /// 强调色上的前景（如实心按钮文字），用底色而非纯黑，避免纯黑。
  static const Color onPrimary = Color(0xFF0D0F11);

  /// 强调色的可读变体——用于深色底上的小字号文字与图标。
  /// [primary] 在 #0D0F11 上做小字时对比度不足，此值提亮到 WCAG AA。
  static const Color primaryText = Color(0xFF5FA4E0);

  // —— 语义色 ——
  /// 受限（限行中）。
  ///
  /// 刻意使用强调蓝而非红色：深色底上高饱和红会让整个界面退化成警报器，
  /// 而限行通知每日触发 1–2 次，长期视觉疲劳会驱使用户关闭通知权限。
  static const Color restricted = Color(0xFF3B82C4);
  static const Color restrictedContainer = Color(0xFF16283A);

  /// 不受限（灰绿，低调——"没事"就不该抢注意力）。
  static const Color free = Color(0xFF4E9A6E);
  static const Color freeContainer = Color(0xFF16241B);

  /// 估算数据来源提示（琥珀）。
  static const Color estimated = Color(0xFFB8894A);
  static const Color estimatedContainer = Color(0xFF2A2117);

  // —— 文本 ——
  static const Color textPrimary = Color(0xFFEDF1F5);
  static const Color textSecondary = Color(0xFF98A2AC);
  static const Color textTertiary = Color(0xFF5E6771);
  static const Color textOnAccent = Color(0xFF0D0F11);

  // —— 车牌号牌配色（国标，非主题色）——
  /// 普通蓝牌
  static const Color plateBlue = Color(0xFF2C5AA0);
  /// 新能源绿牌
  static const Color plateGreen = Color(0xFF2E7D4F);
}
