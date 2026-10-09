import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/city.dart';
import '../../../domain/services/local_rotation_engine.dart';
import '../../widgets/car_adaptive_scaffold.dart';

/// 城市管理页：我的城市 + 搜索添加。
class CitiesScreen extends ConsumerStatefulWidget {
  const CitiesScreen({super.key});

  @override
  ConsumerState<CitiesScreen> createState() => _CitiesScreenState();
}

class _CitiesScreenState extends ConsumerState<CitiesScreen> {
  final _searchController = TextEditingController();
  List<City> _searchResults = const [];
  bool _searching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    setState(() => _searching = true);
    try {
      final results =
          await ref.read(cityRepositoryProvider).searchAvailableCities(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _searching = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _searchResults = const LocalRotationEngine().supportedCities();
          _searching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final citiesAsync = ref.watch(myCitiesProvider);
    final isCar = FormFactor.isCar(context);

    return CarAdaptiveScaffold(
      title: '关注城市',
      primary: citiesAsync.when(
        loading: () => const LoadingState(),
        error: (e, _) => ErrorState(message: '加载失败：$e'),
        data: (myCities) => ListView(
          padding: const EdgeInsets.only(
            top: AppSizes.gap16,
            bottom: AppSizes.gap32,
          ),
          children: [
            // —— 已关注城市 ——
            const SectionHeader(
              title: '已关注',
              subtitle: '首页展示列表第一个城市；每个城市可独立配置提醒',
            ),
            if (myCities.isEmpty)
              _EmptyMyCities(isCar: isCar)
            else
              for (final c in myCities) ...[
                _CityTile(
                  city: c,
                  isCar: isCar,
                  isPrimary: myCities.first.id == c.id,
                  onRemove: () =>
                      ref.read(cityRepositoryProvider).removeMyCity(c.id),
                ),
                const SizedBox(height: AppSizes.gap8),
              ],

            // —— 搜索添加 ——
            const SectionHeader(
              title: '添加城市',
              subtitle: '覆盖全国 65 个限行城市',
            ),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '输入城市名，如"成都"',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchResults = const []);
                        },
                      )
                    : null,
              ),
              onChanged: (v) {
                setState(() {});
                _search(v);
              },
            ),
            const SizedBox(height: AppSizes.gap12),

            if (_searching)
              const Padding(
                padding: EdgeInsets.all(AppSizes.gap24),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              _buildResults(myCities),

            const SizedBox(height: AppSizes.gap24),
            _NoMeasureHint(isCar: isCar),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(List<City> myCities) {
    final myIds = myCities.map((c) => c.id).toSet();
    final candidates = _searchResults.isEmpty
        ? const LocalRotationEngine().supportedCities()
        : _searchResults;
    final available = candidates.where((c) => !myIds.contains(c.id)).toList();

    if (available.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.gap24),
        child: Center(
          child: Text('没有更多可添加的城市', style: AppTypography.caption),
        ),
      );
    }

    return Wrap(
      spacing: AppSizes.gap8,
      runSpacing: AppSizes.gap8,
      children: available
          .map(
            (c) => ActionChip(
              avatar: const Icon(
                Icons.add,
                size: 16,
                color: AppColors.primary,
              ),
              label: Text(c.name),
              onPressed: () async {
                await ref.read(cityRepositoryProvider).addMyCity(c);
                if (mounted) {
                  setState(() {});
                }
              },
            ),
          )
          .toList(),
    );
  }
}

class _CityTile extends ConsumerWidget {
  const _CityTile({
    required this.city,
    required this.isCar,
    required this.isPrimary,
    required this.onRemove,
  });

  final City city;
  final bool isCar;
  final bool isPrimary;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isCar ? AppSizes.gap24 : AppSizes.gap16),
        child: Row(
          children: [
            Container(
              width: isCar ? 56 : 44,
              height: isCar ? 56 : 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                city.provinceAbbr.isEmpty ? city.name[0] : city.provinceAbbr,
                style: TextStyle(
                  fontSize: isCar ? 26 : 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.gap16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        city.name,
                        style: AppTypography.cardTitle.copyWith(
                          fontSize: isCar ? 22 : 16,
                        ),
                      ),
                      if (isPrimary) ...[
                        const SizedBox(width: AppSizes.gap8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '主展示',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSizes.gap4),
                  Text(city.province, style: AppTypography.caption),
                ],
              ),
            ),
            TextButton(
              onPressed: () => context.go('/settings'),
              child: const Text('提醒设置'),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.textTertiary,
              ),
              onPressed: onRemove,
              tooltip: '取消关注',
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMyCities extends StatelessWidget {
  const _EmptyMyCities({required this.isCar});

  final bool isCar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.gap24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.outline),
      ),
      child: const Row(
        children: [
          Icon(Icons.location_city_outlined, color: AppColors.textTertiary),
          SizedBox(width: AppSizes.gap12),
          Expanded(
            child: Text(
              '还没有关注任何城市，从下方选择一个开始',
              style: AppTypography.body,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoMeasureHint extends StatelessWidget {
  const _NoMeasureHint({required this.isCar});

  final bool isCar;

  @override
  Widget build(BuildContext context) {
    const notes = LocalRotationEngine.noMeasureNotes;
    if (notes.isEmpty) return const SizedBox.shrink();

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
              const Icon(Icons.info_outline, size: 16, color: AppColors.estimated),
              const SizedBox(width: AppSizes.gap8),
              Text(
                '特殊规则城市',
                style: AppTypography.cardTitle.copyWith(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.gap8),
          const Text(
            '以下城市的限行规则较为特殊，建议以当地交管最新通告为准：',
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSizes.gap8),
          Text(
            notes.entries.map((e) => '· ${e.value}').join('\n'),
            style: AppTypography.caption.copyWith(height: 1.8),
          ),
        ],
      ),
    );
  }
}
