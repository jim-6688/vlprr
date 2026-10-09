import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/car_adaptive_scaffold.dart';

/// 应用外壳：手机版底部导航 / 车机版左侧导航栏。
///
/// 四栏结构（2026-10 调整）：今日 / 广播 / 白噪音 / 设置。
///
/// 日历、车牌、城市三页已从主导航降级——它们是"今日"的辅助视图，
/// 不值得占用一级入口。路由保留，可从首页卡片直接跳转，
/// 车机侧 Rail 则把它们放进"限行数据"分组。
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  /// 主导航四项。
  static const List<_ShellDestination> _destinations = [
    _ShellDestination(
      path: Routes.home,
      label: '今日',
      iconName: TaillimitIcons.today,
      semanticColor: true,
    ),
    _ShellDestination(
      path: Routes.radio,
      label: '广播',
      iconName: TaillimitIcons.radio,
      semanticColor: true,
    ),
    _ShellDestination(
      path: Routes.noise,
      label: '白噪音',
      iconName: TaillimitIcons.noise,
      semanticColor: true,
    ),
    _ShellDestination(
      path: Routes.settings,
      label: '设置',
      iconName: TaillimitIcons.settings,
      semanticColor: true,
    ),
  ];

  /// 车机版额外项（限行数据分组）。
  ///
  /// 车机屏幕宽、驾驶员操作频率低，把限行相关页平铺出来更合理。
  static const List<_ShellDestination> _carExtras = [
    _ShellDestination(
      path: Routes.calendar,
      label: '限行日历',
      iconName: TaillimitIcons.calendar,
      semanticColor: true,
    ),
    _ShellDestination(
      path: Routes.vehicles,
      label: '我的车牌',
      iconName: TaillimitIcons.vehicle,
      semanticColor: true,
    ),
    _ShellDestination(
      path: Routes.cities,
      label: '关注城市',
      iconName: TaillimitIcons.location,
      semanticColor: true,
    ),
  ];

  int get _currentIndex {
    for (var i = 0; i < _destinations.length; i++) {
      if (location.startsWith(_destinations[i].path)) return i;
    }
    // 限行数据子页归入"今日"高亮，让用户不丢失位置感
    for (final _ShellDestination d in _carExtras) {
      if (location.startsWith(d.path)) return 0;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isCar = FormFactor.isCar(context);

    if (isCar) {
      return Scaffold(
        body: Row(
          children: [
            _CarNavigationRail(
              destinations: _destinations,
              extras: _carExtras,
              selectedPath: location,
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          final path = _destinations[index].path;
          if (location == path) return;
          context.go(path);
        },
        destinations: _destinations
            .map(
              (d) => NavigationDestination(
                icon: IconDataWidget(
                  name: d.iconName,
                  size: TaillimitIcons.iconSizeMd,
                  semanticColor: true,
                ),
                label: d.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

/// 车机版左侧导航（大触控目标 + 文字标签常驻 + 分组）。
class _CarNavigationRail extends StatelessWidget {
  const _CarNavigationRail({
    required this.destinations,
    required this.extras,
    required this.selectedPath,
  });

  final List<_ShellDestination> destinations;
  final List<_ShellDestination> extras;
  final String selectedPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: AppColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.gap24,
                AppSizes.gap24,
                AppSizes.gap24,
                AppSizes.gap16,
              ),
              child: Text(
                'TailLimit',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: AppSizes.gap12),
            for (final _ShellDestination d in destinations)
              _CarNavItem(destination: d, selected: selectedPath.startsWith(d.path)),
            const SizedBox(height: AppSizes.gap24),
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.gap24,
                0,
                AppSizes.gap24,
                AppSizes.gap8,
              ),
              child: Text(
                '限行数据',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            for (final _ShellDestination d in extras)
              _CarNavItem(
                destination: d,
                selected: selectedPath.startsWith(d.path),
                indented: true,
              ),
          ],
        ),
      ),
    );
  }
}

class _CarNavItem extends StatelessWidget {
  const _CarNavItem({
    required this.destination,
    required this.selected,
    this.indented = false,
  });

  final _ShellDestination destination;
  final bool selected;
  final bool indented;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: indented ? AppSizes.gap24 : AppSizes.gap12,
        right: AppSizes.gap12,
        top: AppSizes.gap4,
        bottom: AppSizes.gap4,
      ),
      child: Material(
        color: selected ? AppColors.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (selected) return;
            context.go(destination.path);
          },
          child: Container(
            constraints: const BoxConstraints(
              minHeight: AppSizes.carTouchTarget,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.gap16,
              vertical: AppSizes.gap12,
            ),
            child: Row(
              children: [
                IconDataWidget(
                  name: destination.iconName,
                  size: 30,
                  semanticColor: true,
                  color: selected ? AppColors.primary : AppColors.textTertiary,
                ),
                const SizedBox(width: AppSizes.gap16),
                Text(
                  destination.label,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color:
                        selected ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShellDestination {
  const _ShellDestination({
    required this.path,
    required this.label,
    required this.iconName,
    this.semanticColor = false,
  });

  final String path;
  final String label;

  /// 图标名，对应 [TaillimitIcons] 常量。
  final String iconName;

  /// 是否按语义着色（限行=蓝 / 播放类=强调色）。
  final bool semanticColor;
}
