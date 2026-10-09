import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 字体规格：含车机版大字号与尾号大数字规格。
class AppTypography {
  const AppTypography._();

  /// 尾号大数字（首页限行卡核心视觉）。
  static const TextStyle tailNumberLarge = TextStyle(
    fontSize: 64,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: -1,
    color: AppColors.primary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// 尾号中号（列表/日历用）。
  static const TextStyle tailNumberMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.1,
    color: AppColors.primary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// 车牌号牌。
  static const TextStyle plate = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    color: AppColors.textPrimary,
  );

  /// 页面标题。
  static const TextStyle pageTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// 卡片标题。
  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// 正文。
  static const TextStyle body = TextStyle(
    fontSize: 14,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  /// 说明文本。
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 1.4,
    color: AppColors.textTertiary,
  );

  /// 车机版放大后的正文。
  static const TextStyle carBody = TextStyle(
    fontSize: 18,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  /// 车机版放大后的标题。
  static const TextStyle carTitle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}
