import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// 尾号徽章：以香槟金呈现限行尾号，车机版自动放大。
class TailNumberBadge extends StatelessWidget {
  const TailNumberBadge({
    super.key,
    required this.tails,
    this.large = false,
    this.isCar = false,
    this.dimmed = false,
  });

  /// 限行尾号集合（有序展示）。
  final List<int> tails;

  /// 大号展示（首页主视觉）。
  final bool large;

  /// 车机版适配。
  final bool isCar;

  /// 灰显（不受限场景）。
  final bool dimmed;

  const TailNumberBadge.empty({
    super.key,
    this.large = false,
    this.isCar = false,
    this.dimmed = false,
  }) : tails = const [];

  @override
  Widget build(BuildContext context) {
    if (tails.isEmpty) {
      return Text(
        '不限行',
        style: (isCar ? AppTypography.carTitle : AppTypography.cardTitle)
            .copyWith(color: AppColors.free),
      );
    }

    final sorted = [...tails]..sort();
    final color = dimmed ? AppColors.textTertiary : AppColors.primary;

    if (!large) {
      return Wrap(
        spacing: AppSizes.gap8,
        children: sorted
            .map((t) => _Chip(value: t, color: color, isCar: isCar))
            .toList(),
      );
    }

    return Wrap(
      spacing: AppSizes.gap12,
      runSpacing: AppSizes.gap8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < sorted.length; i++) ...[
          if (i > 0)
            Text(
              '和',
              style: AppTypography.body.copyWith(
                fontSize: isCar ? 32 : 28,
                color: AppColors.textTertiary,
              ),
            ),
          Text(
            '${sorted[i]}',
            style: AppTypography.tailNumberLarge.copyWith(
              color: color,
              fontSize: isCar ? 96 : 64,
            ),
          ),
        ],
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.value, required this.color, required this.isCar});

  final int value;
  final Color color;
  final bool isCar;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCar ? 56 : 40,
      height: isCar ? 56 : 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        '$value',
        style: AppTypography.tailNumberMedium.copyWith(
          color: color,
          fontSize: isCar ? 32 : 28,
        ),
      ),
    );
  }
}

/// 数据来源徽章：展示来源与更新时间，估算数据明确标注。
class DataSourceBadge extends StatelessWidget {
  const DataSourceBadge({
    super.key,
    required this.source,
    this.fetchedAt,
    this.isStale = false,
  });

  final String source;
  final DateTime? fetchedAt;
  final bool isStale;

  static const Map<String, String> _labels = {
    'apispace': 'APISpace 实时数据',
    'jisu': '极速数据实时',
    'mock': '本地估算规则',
    'cache': '本地缓存',
  };

  bool get _isEstimated => source == 'mock';

  @override
  Widget build(BuildContext context) {
    final label = _labels[source] ?? '未知来源';
    final color = _isEstimated ? AppColors.estimated : AppColors.textTertiary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _isEstimated ? Icons.science_outlined : Icons.verified_outlined,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: color),
        ),
        if (fetchedAt != null) ...[
          const SizedBox(width: 8),
          Text(
            _formatTime(fetchedAt!),
            style: AppTypography.caption,
          ),
        ],
        if (isStale) ...[
          const SizedBox(width: 6),
          Text(
            '· 可能已过期',
            style: AppTypography.caption.copyWith(color: AppColors.estimated),
          ),
        ],
      ],
    );
  }

  static String _formatTime(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 1) return '刚刚更新';
    if (diff.inMinutes < 60) return '${diff.inMinutes} 分钟前';
    if (diff.inHours < 24) return '${diff.inHours} 小时前';
    return '${t.month}-${t.day} ${t.hour}:${t.minute.toString().padLeft(2, '0')}';
  }
}

/// 号牌徽章：蓝牌/绿牌配色 + 分段展示。
class PlateBadge extends StatelessWidget {
  const PlateBadge({
    super.key,
    required this.plate,
    this.isCar = false,
    this.compact = false,
  });

  final String plate;
  final bool isCar;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isNEV = _isNEV(plate);
    final bg = isNEV ? AppColors.plateGreen : AppColors.plateBlue;
    final fontSize = isCar ? 24.0 : (compact ? 14.0 : 18.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCar ? 16 : (compact ? 8 : 12),
        vertical: isCar ? 10 : (compact ? 4 : 6),
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        plate,
        style: AppTypography.plate.copyWith(
          fontSize: fontSize,
          color: Colors.white,
          letterSpacing: isCar ? 3 : 1.5,
        ),
      ),
    );
  }

  static bool _isNEV(String plate) {
    final p = plate.replaceAll(RegExp(r'[\s\-·]'), '').toUpperCase();
    if (p.length != 8) return false;
    final body = p.substring(2);
    return body.startsWith('D') ||
        body.startsWith('F') ||
        body.endsWith('D') ||
        body.endsWith('F');
  }
}

/// 受限状态卡片外壳（统一视觉语言）。
class StatusCard extends StatelessWidget {
  const StatusCard({
    super.key,
    required this.child,
    this.accent = AppColors.primary,
    this.padding,
  });

  final Widget child;
  final Color accent;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppSizes.gap16 + 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.outline),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.08),
            AppColors.surface,
          ],
        ),
      ),
      child: child,
    );
  }
}
