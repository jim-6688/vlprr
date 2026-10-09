import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/car_adaptive_scaffold.dart';
import 'today_status_provider.dart';
import 'widgets/today_card.dart';
import 'widgets/tomorrow_strip.dart';

/// 首页：今日限行状态 + 明日预告 + 车辆列表。
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(todayStatusProvider);
    final isCar = FormFactor.isCar(context);

    return CarAdaptiveScaffold(
      title: '今日限行',
      actions: [
        IconButton(
          tooltip: '刷新数据',
          icon: const Icon(Icons.refresh),
          onPressed: () async {
            ref.invalidate(todayStatusProvider);
            try {
              final result = await ref.read(syncRestrictionsProvider).call(
                    days: ref.read(appConfigProvider).syncDays,
                  );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result.allSuccess
                          ? '已更新 ${result.dayCount} 天限行数据'
                          : '部分城市更新失败（${result.failedCityIds.length} 个）',
                    ),
                  ),
                );
              }
              ref.invalidate(todayStatusProvider);
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('更新失败：$e')),
                );
              }
            }
          },
        ),
      ],
      primary: statusAsync.when(
        loading: () => const LoadingState(label: '正在获取限行信息'),
        error: (e, _) => ErrorState(
          message: '加载失败：$e',
          onRetry: () => ref.invalidate(todayStatusProvider),
        ),
        data: (status) {
          if (status.city == null) {
            return EmptyState(
              icon: Icons.location_city_outlined,
              title: '尚未选择城市',
              description: '请先添加关注城市与本车车牌，即可获取限行提醒',
              action: ElevatedButton(
                onPressed: () => context.go(Routes.cities),
                child: const Text('选择城市'),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: AppSizes.gap32),
            children: [
              const SizedBox(height: AppSizes.gap16),
              TodayCard(status: status, isCar: isCar),
              const SizedBox(height: AppSizes.gap16),
              TomorrowStrip(
                tomorrow: status.tomorrow,
                isCar: isCar,
              ),
              if (status.hasNoVehicle) ...[
                const SizedBox(height: AppSizes.gap16),
                _AddVehiclePrompt(isCar: isCar),
              ],
            ],
          );
        },
      ),
      secondary: statusAsync.valueOrNull?.city == null
          ? null
          : _QuickPanel(status: statusAsync.value!),
    );
  }
}

/// 车机版右侧快捷面板。
class _QuickPanel extends StatelessWidget {
  const _QuickPanel({required this.status});

  final TodayStatusView status;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSizes.gap16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.gap16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('我的车辆', style: AppTypography.cardTitle),
                const SizedBox(height: AppSizes.gap12),
                if (status.vehicleStatuses.isEmpty)
                  const Text('暂无绑定车辆', style: AppTypography.caption)
                else
                  for (final s in status.vehicleStatuses)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.gap12),
                      child: Row(
                        children: [
                          PlateBadge(plate: s.vehicle.plate, compact: true),
                          const SizedBox(width: AppSizes.gap12),
                          Expanded(
                            child: Text(
                              s.isRestricted ? '今日限行' : '今日不限',
                              style: AppTypography.body.copyWith(
                                color: s.isRestricted
                                    ? AppColors.restricted
                                    : AppColors.free,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                const SizedBox(height: AppSizes.gap8),
                OutlinedButton.icon(
                  onPressed: () => context.go(Routes.vehicles),
                  icon: const Icon(Icons.add),
                  label: const Text('管理车牌'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSizes.gap16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.gap16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('数据来源', style: AppTypography.cardTitle),
                const SizedBox(height: AppSizes.gap12),
                DataSourceBadge(
                  source: status.dataSource,
                  fetchedAt: status.fetchedAt,
                  isStale: status.isStale,
                ),
                if (status.isEstimated) ...[
                  const SizedBox(height: AppSizes.gap12),
                  const Text(
                    '当前为本地估算规则，可能与交管最新通告存在差异。'
                    '配置 API Key 后可获取实时数据。',
                    style: AppTypography.caption,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AddVehiclePrompt extends StatelessWidget {
  const _AddVehiclePrompt({required this.isCar});

  final bool isCar;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.gap16),
        child: Row(
          children: [
            const Icon(Icons.directions_car_outlined, color: AppColors.primary),
            const SizedBox(width: AppSizes.gap12),
            const Expanded(
              child: Text(
                '绑定车牌后即可自动判定并提醒限行',
                style: AppTypography.body,
              ),
            ),
            TextButton(
              onPressed: () => context.go(Routes.vehicles),
              child: const Text('去绑定'),
            ),
          ],
        ),
      ),
    );
  }
}
