import 'package:flutter/material.dart';

/// TailLimit 色板：深空灰 + 香槟金。
class AppColors {
  const AppColors._();

  // —— 背景层次（深空灰）——
  static const Color background = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFF242424);
  static const Color surfaceElevated = Color(0xFF2A2A2A);
  static const Color outline = Color(0xFF2E2E2E);
  static const Color outlineStrong = Color(0xFF3A3A3A);

  // —— 主强调（香槟金）——
  static const Color primary = Color(0xFFC9A96E);
  static const Color primaryDark = Color(0xFF9E8557);
  static const Color primaryContainer = Color(0xFF3A3126);
  static const Color onPrimary = Color(0xFF1A1A1A);

  // —— 语义色 ——
  /// 受限（警示，限制在"外牌禁行"等强提示场景）
  static const Color restricted = Color(0xFFD9534F);
  static const Color restrictedContainer = Color(0xFF3A2422);

  /// 不受限（灰绿，低调）
  static const Color free = Color(0xFF6E8B6E);
  static const Color freeContainer = Color(0xFF232B23);

  /// 估算数据来源提示（琥珀）
  static const Color estimated = Color(0xFFB8894A);

  // —— 文本 ——
  static const Color textPrimary = Color(0xFFEDEDED);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textTertiary = Color(0xFF6E6E6E);
  static const Color textOnAccent = Color(0xFF1A1A1A);

  // —— 车牌号牌配色 ——
  /// 普通蓝牌
  static const Color plateBlue = Color(0xFF2C5AA0);
  /// 新能源绿牌
  static const Color plateGreen = Color(0xFF2E7D4F);
}
