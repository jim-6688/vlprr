import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/restriction_day.dart';

/// 明日预告条：提示次日限行尾号，便于提前安排出行。
class TomorrowStrip extends StatelessWidget {
  const TomorrowStrip({
    super.key,
    required this.tomorrow,
    required this.isCar,
  });

  final RestrictionDay? tomorrow;
  final bool isCar;

  @override
  Widget build(BuildContext context) {
    if (tomorrow == null) return const SizedBox.shrink();

    final day = tomorrow!;
    final willRestrict = day.isRestrictedDay && day.restrictedTails.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(isCar ? AppSizes.gap24 : AppSizes.gap16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Icon(
            willRestrict ? Icons.notifications_active_outlined : Icons.event_available_outlined,
            color: willRestrict ? AppColors.primary : AppColors.textTertiary,
            size: isCar ? 30 : 22,
          ),
          const SizedBox(width: AppSizes.gap12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '明日（${_weekday(day.date)}）',
                  style: AppTypography.caption.copyWith(
                    fontSize: isCar ? 16 : 12,
                  ),
                ),
                const SizedBox(height: AppSizes.gap4),
                Text(
                  willRestrict
                      ? '限行尾号 ${day.tailsText} · ${day.timeWindowText}'
                      : '不限行',
                  style: AppTypography.body.copyWith(
                    fontSize: isCar ? 20 : 15,
                    color: willRestrict
                        ? AppColors.textPrimary
                        : AppColors.free,
                  ),
                ),
              ],
            ),
          ),
          if (willRestrict)
            Icon(
              Icons.arrow_forward_ios,
              size: isCar ? 20 : 14,
              color: AppColors.textTertiary,
            ),
        ],
      ),
    );
  }

  static String _weekday(DateTime d) {
    const names = ['一', '二', '三', '四', '五', '六', '日'];
    return '周${names[d.weekday - 1]}';
  }
}
