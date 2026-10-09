import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/city.dart';
import '../../../domain/entities/vehicle.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/car_adaptive_scaffold.dart';

/// 车牌管理页。
class VehiclesScreen extends ConsumerWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final citiesAsync = ref.watch(myCitiesProvider);
    final isCar = FormFactor.isCar(context);

    return CarAdaptiveScaffold(
      title: '我的车牌',
      actions: [
        if (!isCar)
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '添加车牌',
            onPressed: () => context.go(Routes.vehicleEdit),
          ),
      ],
      primary: vehiclesAsync.when(
        loading: () => const LoadingState(),
        error: (e, _) => ErrorState(message: '加载失败：$e'),
        data: (vehicles) {
          final cities = citiesAsync.valueOrNull ?? const [];

          if (vehicles.isEmpty) {
            return EmptyState(
              icon: Icons.directions_car_outlined,
              title: '尚未绑定车牌',
              description: '绑定车牌后，将根据所在城市限行规则自动判定并提醒',
              action: ElevatedButton.icon(
                onPressed: () {
                  if (cities.isEmpty) {
                    context.go(Routes.cities);
                  } else {
                    context.go(Routes.vehicleEdit);
                  }
                },
                icon: const Icon(Icons.add),
                label: Text(cities.isEmpty ? '先选择城市' : '添加车牌'),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.only(
              top: AppSizes.gap16,
              bottom: AppSizes.gap32,
            ),
            children: [
              for (final v in vehicles) ...[
                _VehicleCard(
                  vehicle: v,
                  cityName: _cityName(cities, v.boundCityId),
                  isCar: isCar,
                  onEdit: () =>
                      context.go('${Routes.vehicleEdit}?id=${v.id}'),
                  onSetDefault: () => ref
                      .read(vehicleRepositoryProvider)
                      .setDefault(v.id),
                  onToggleActive: (active) => ref
                      .read(vehicleRepositoryProvider)
                      .update(v.copyWith(isActive: active)),
                  onDelete: () => _confirmDelete(context, ref, v.id, v.plate),
                ),
                const SizedBox(height: AppSizes.gap12),
              ],
              const SizedBox(height: AppSizes.gap8),
              OutlinedButton.icon(
                onPressed: () {
                  if (cities.isEmpty) {
                    context.go(Routes.cities);
                    return;
                  }
                  context.go(Routes.vehicleEdit);
                },
                icon: const Icon(Icons.add),
                label: const Text('添加车牌'),
              ),
              const SizedBox(height: AppSizes.gap24),
              _PlateRuleHint(isCar: isCar),
            ],
          );
        },
      ),
    );
  }

  String _cityName(List<City> cities, String cityId) {
    for (final c in cities) {
      if (c.id == cityId) return c.name;
    }
    return '未绑定城市';
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
    String plate,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除车牌'),
        content: Text('确定要删除 $plate 吗？相关提醒将一并取消。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除', style: TextStyle(color: AppColors.restricted)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(vehicleRepositoryProvider).delete(id);
    }
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.vehicle,
    required this.cityName,
    required this.isCar,
    required this.onEdit,
    required this.onSetDefault,
    required this.onToggleActive,
    required this.onDelete,
  });

  final Vehicle vehicle;
  final String cityName;
  final bool isCar;
  final VoidCallback onEdit;
  final VoidCallback onSetDefault;
  final ValueChanged<bool> onToggleActive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        onTap: onEdit,
        child: Padding(
          padding: EdgeInsets.all(isCar ? AppSizes.gap24 : AppSizes.gap16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PlateBadge(
                    plate: vehicle.plate,
                    isCar: isCar,
                  ),
                  const SizedBox(width: AppSizes.gap12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (vehicle.nickname.isNotEmpty)
                              Flexible(
                                child: Text(
                                  vehicle.nickname,
                                  style: AppTypography.cardTitle.copyWith(
                                    fontSize: isCar ? 22 : 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            if (vehicle.isDefault) ...[
                              const SizedBox(width: AppSizes.gap8),
                              const _Tag(text: '默认', color: AppColors.primary),
                            ],
                            if (vehicle.isNEV) ...[
                              const SizedBox(width: AppSizes.gap8),
                              const _Tag(text: '新能源', color: AppColors.plateGreen),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSizes.gap4),
                        Text(
                          '$cityName · 尾号 ${_tailHint(vehicle.plate)}',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: vehicle.isActive,
                    onChanged: onToggleActive,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.gap8),
              Row(
                children: [
                  if (!vehicle.isDefault)
                    TextButton(
                      onPressed: onSetDefault,
                      child: const Text('设为默认'),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: onEdit,
                    child: const Text('编辑'),
                  ),
                  TextButton(
                    onPressed: onDelete,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.restricted,
                    ),
                    child: const Text('删除'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _tailHint(String plate) {
    final p = plate.replaceAll(RegExp(r'[\s\-·]'), '').toUpperCase();
    for (var i = p.length - 1; i >= 0; i--) {
      if (RegExp(r'\d').hasMatch(p[i])) return p[i];
    }
    return '-';
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _PlateRuleHint extends StatelessWidget {
  const _PlateRuleHint({required this.isCar});

  final bool isCar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.gap16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: AppColors.textTertiary),
              const SizedBox(width: AppSizes.gap8),
              Text('关于尾号判定', style: AppTypography.cardTitle.copyWith(fontSize: 14)),
            ],
          ),
          const SizedBox(height: AppSizes.gap8),
          Text(
            '· 普通号牌取最后一位数字作为尾号\n'
            '· 部分城市（如北京）末位为字母时取前一位数字\n'
            '· 新能源号牌（绿牌）多数城市不限行，以当地政策为准',
            style: AppTypography.caption.copyWith(height: 1.8),
          ),
        ],
      ),
    );
  }
}
