import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/restriction_verdict.dart';
import '../../../widgets/app_widgets.dart';
import '../today_status_provider.dart';

/// 今日限行卡：首页核心视觉。
///
/// 展示层级：
/// 1. 状态结论（限行 / 不限行 / 新能源豁免）
/// 2. 尾号大数字（受限时香槟金）
/// 3. 时段与区域
/// 4. 数据来源徽章
class TodayCard extends ConsumerWidget {
  const TodayCard({super.key, required this.status, required this.isCar});

  final TodayStatusView status;
  final bool isCar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (status.hasNoData) {
      return StatusCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('暂无今日限行数据', style: AppTypography.cardTitle.copyWith(fontSize: isCar ? 26 : 18)),
            const SizedBox(height: AppSizes.gap8),
            const Text('下拉刷新或检查网络后重试', style: AppTypography.body),
          ],
        ),
      );
    }

    final day = status.today!;
    final primary = status.primaryVehicle;

    // 主展示车辆的判定（用于状态结论文案）
    final primaryStatus = status.vehicleStatuses.isNotEmpty
        ? status.vehicleStatuses.first
        : null;
    final isRestricted = primaryStatus?.isRestricted ?? false;
    final isExempt =
        primaryStatus?.verdict.kind == VerdictKind.exemptNewEnergy;

    final accent = isRestricted ? AppColors.primary : AppColors.free;
    final statusText = _statusText(isRestricted, isExempt);

    return StatusCard(
      accent: accent,
      padding: EdgeInsets.all(isCar ? AppSizes.gap24 : AppSizes.gap16 + 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // —— 状态结论 ——
          Row(
            children: [
              Icon(
                isRestricted
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
                color: accent,
                size: isCar ? 32 : 24,
              ),
              const SizedBox(width: AppSizes.gap8),
              Expanded(
                child: Text(
                  statusText,
                  style: (isCar ? AppTypography.carTitle : AppTypography.cardTitle)
                      .copyWith(color: accent, fontSize: isCar ? 28 : 18),
                ),
              ),
              if (status.city != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.gap12,
                    vertical: AppSizes.gap4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppSizes.chipRadius),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Text(
                    status.city!.name,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSizes.gap24),

          // —— 尾号大数字 ——
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TailNumberBadge(
                  tails: day.restrictedTails.toList(),
                  large: true,
                  isCar: isCar,
                  dimmed: !isRestricted && !day.isRestrictedDay,
                ),
              ),
            ],
          ),

          if (day.isRestrictedDay && day.restrictedTails.isNotEmpty) ...[
            const SizedBox(height: AppSizes.gap8),
            Text(
              '限行尾号',
              style: AppTypography.caption.copyWith(
                fontSize: isCar ? 16 : 12,
              ),
            ),
          ],

          const SizedBox(height: AppSizes.gap24),

          // —— 时段与区域 ——
          _InfoRow(
            icon: Icons.schedule,
            label: '限行时段',
            value: day.isRestrictedDay ? day.timeWindowText : '全天不限行',
            isCar: isCar,
          ),
          if (day.areaText.isNotEmpty) ...[
            const SizedBox(height: AppSizes.gap12),
            _InfoRow(
              icon: Icons.map_outlined,
              label: '限行区域',
              value: day.areaText,
              isCar: isCar,
              maxLines: 3,
            ),
          ],

          // —— 主车辆 ——
          if (primary != null) ...[
            const SizedBox(height: AppSizes.gap16),
            const Divider(height: AppSizes.gap24),
            Row(
              children: [
                PlateBadge(plate: primary.plate, isCar: isCar, compact: !isCar),
                const SizedBox(width: AppSizes.gap12),
                Expanded(
                  child: Text(
                    primaryStatus?.verdict.reasonText ?? '',
                    style: AppTypography.body.copyWith(
                      fontSize: isCar ? 18 : 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          // —— 数据来源 ——
          const SizedBox(height: AppSizes.gap16),
          DataSourceBadge(
            source: status.dataSource,
            fetchedAt: status.fetchedAt,
            isStale: status.isStale,
          ),
        ],
      ),
    );
  }

  String _statusText(bool isRestricted, bool isExempt) {
    if (isExempt) return '新能源号牌不限行';
    if (isRestricted) return '今日限行';
    return '今日不限行';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isCar,
    this.maxLines = 1,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isCar;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: isCar ? 24 : 18, color: AppColors.textTertiary),
        const SizedBox(width: AppSizes.gap12),
        SizedBox(
          width: isCar ? 110 : 80,
          child: Text(
            label,
            style: AppTypography.body.copyWith(fontSize: isCar ? 18 : 14),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.body.copyWith(
              color: AppColors.textPrimary,
              fontSize: isCar ? 18 : 14,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
