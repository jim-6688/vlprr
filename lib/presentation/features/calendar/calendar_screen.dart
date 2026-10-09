import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/city.dart';
import '../../../domain/entities/restriction_day.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/car_adaptive_scaffold.dart';
import '../home/today_status_provider.dart';

/// 限行日历页：月视图 + 日详情。
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);
  String? _selectedCityId;

  @override
  Widget build(BuildContext context) {
    final citiesAsync = ref.watch(myCitiesProvider);
    final cities = citiesAsync.valueOrNull ?? const <City>[];
    final isCar = FormFactor.isCar(context);

    final cityId = _selectedCityId ??
        (cities.isNotEmpty ? cities.first.id : '');

    if (cityId.isEmpty) {
      return const CarAdaptiveScaffold(
        title: '限行日历',
        primary: EmptyState(
          icon: Icons.calendar_month_outlined,
          title: '暂无城市',
          description: '请先添加关注城市',
        ),
      );
    }

    final calendarAsync = ref.watch(calendarProvider(cityId));

    return CarAdaptiveScaffold(
      title: '限行日历',
      actions: [
        if (cities.length > 1)
          PopupMenuButton<String>(
            initialValue: cityId,
            onSelected: (v) => setState(() => _selectedCityId = v),
            itemBuilder: (ctx) => cities
                .map((c) => PopupMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.gap16),
              child: Row(
                children: [
                  Text(
                    cities.firstWhere((c) => c.id == cityId).name,
                    style: AppTypography.body.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                ],
              ),
            ),
          ),
      ],
      primary: calendarAsync.when(
        loading: () => const LoadingState(),
        error: (e, _) => ErrorState(
          message: '加载失败：$e',
          onRetry: () => ref.invalidate(calendarProvider(cityId)),
        ),
        data: (days) => ListView(
          padding: const EdgeInsets.only(
            top: AppSizes.gap16,
            bottom: AppSizes.gap32,
          ),
          children: [
            _MonthHeader(
              month: _month,
              onPrev: () => setState(
                () => _month = DateTime(_month.year, _month.month - 1, 1),
              ),
              onNext: () => setState(
                () => _month = DateTime(_month.year, _month.month + 1, 1),
              ),
            ),
            const SizedBox(height: AppSizes.gap16),
            _MonthGrid(
              month: _month,
              days: days,
              isCar: isCar,
              onSelect: (day) => _showDayDetail(context, day),
            ),
            const SizedBox(height: AppSizes.gap24),
            _Legend(isCar: isCar),
            if (days.isNotEmpty) ...[
              const SizedBox(height: AppSizes.gap16),
              DataSourceBadge(
                source: days.first.source,
                fetchedAt: days.first.fetchedAt,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDayDetail(BuildContext context, RestrictionDay day) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.gap24,
          0,
          AppSizes.gap24,
          AppSizes.gap32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${day.date.month} 月 ${day.date.day} 日 · ${_weekdayName(day.date)}',
              style: AppTypography.pageTitle.copyWith(fontSize: 20),
            ),
            const SizedBox(height: AppSizes.gap16),
            Row(
              children: [
                Text(
                  day.isRestrictedDay ? '限行' : '不限行',
                  style: AppTypography.cardTitle.copyWith(
                    color: day.isRestrictedDay
                        ? AppColors.primary
                        : AppColors.free,
                  ),
                ),
                const SizedBox(width: AppSizes.gap16),
                if (day.restrictedTails.isNotEmpty)
                  TailNumberBadge(tails: day.restrictedTails.toList()),
              ],
            ),
            const SizedBox(height: AppSizes.gap16),
            _DetailRow(label: '时段', value: day.timeWindowText),
            if (day.areaText.isNotEmpty)
              _DetailRow(label: '区域', value: day.areaText),
            if (day.ruleText.isNotEmpty)
              _DetailRow(label: '规则', value: day.ruleText),
            _DetailRow(label: '来源', value: _sourceLabel(day.source)),
          ],
        ),
      ),
    );
  }

  static String _sourceLabel(String source) {
    switch (source) {
      case 'apispace':
        return 'APISpace 实时数据';
      case 'jisu':
        return '极速数据实时';
      case 'mock':
        return '本地估算规则（以官方通告为准）';
      case 'cache':
        return '本地缓存';
      default:
        return source;
    }
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onPrev,
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          '${month.year} 年 ${month.month} 月',
          style: AppTypography.pageTitle.copyWith(fontSize: 20),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.days,
    required this.isCar,
    required this.onSelect,
  });

  final DateTime month;
  final List<RestrictionDay> days;
  final bool isCar;
  final ValueChanged<RestrictionDay> onSelect;

  @override
  Widget build(BuildContext context) {
    final firstWeekday = month.weekday; // 1=Mon
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final dayMap = {
      for (final d in days)
        if (d.date.year == month.year && d.date.month == month.month)
          d.date.day: d,
    };

    const weekLabels = ['一', '二', '三', '四', '五', '六', '日'];
    final today = DateTime.now();

    return Column(
      children: [
        Row(
          children: weekLabels
              .map(
                (w) => Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.gap8),
                      child: Text(
                        w,
                        style: AppTypography.caption,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: AppSizes.gap8,
            crossAxisSpacing: AppSizes.gap8,
            childAspectRatio: isCar ? 1.4 : 0.92,
          ),
          itemCount: (firstWeekday - 1) + daysInMonth,
          itemBuilder: (context, index) {
            if (index < firstWeekday - 1) return const SizedBox.shrink();
            final dayNum = index - (firstWeekday - 1) + 1;
            final day = dayMap[dayNum];
            final isToday = today.year == month.year &&
                today.month == month.month &&
                today.day == dayNum;

            return _DayCell(
              dayNumber: dayNum,
              day: day,
              isToday: isToday,
              isCar: isCar,
              onTap: day == null ? null : () => onSelect(day),
            );
          },
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.dayNumber,
    required this.day,
    required this.isToday,
    required this.isCar,
    this.onTap,
  });

  final int dayNumber;
  final RestrictionDay? day;
  final bool isToday;
  final bool isCar;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final restricted = day?.isRestrictedDay == true &&
        (day?.restrictedTails.isNotEmpty ?? false);

    return Material(
      color: restricted
          ? AppColors.primaryContainer
          : AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(isCar ? AppSizes.gap12 : AppSizes.gap8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isToday ? AppColors.primary : AppColors.outline,
              width: isToday ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$dayNumber',
                style: TextStyle(
                  fontSize: isCar ? 22 : 15,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                  color: isToday
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
              ),
              if (restricted) ...[
                SizedBox(height: isCar ? 6 : 4),
                Text(
                  day!.tailsText,
                  style: TextStyle(
                    fontSize: isCar ? 14 : 10,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ] else if (day != null) ...[
                SizedBox(height: isCar ? 6 : 4),
                Text(
                  '不限',
                  style: TextStyle(
                    fontSize: isCar ? 13 : 10,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.isCar});

  final bool isCar;

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: AppSizes.gap24,
      runSpacing: AppSizes.gap8,
      children: [
        _LegendItem(
          color: AppColors.primaryContainer,
          borderColor: AppColors.primary,
          label: '限行日（显示尾号）',
        ),
        _LegendItem(
          color: AppColors.surface,
          borderColor: AppColors.outline,
          label: '不限行',
        ),
        _LegendItem(
          color: AppColors.surface,
          borderColor: AppColors.primary,
          label: '今天',
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.borderColor,
    required this.label,
  });

  final Color color;
  final Color borderColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor, width: 1.5),
          ),
        ),
        const SizedBox(width: AppSizes.gap8),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.gap12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(label, style: AppTypography.caption),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.body.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _weekdayName(DateTime d) {
  const names = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  return names[d.weekday - 1];
}
