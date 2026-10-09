import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/car_adaptive_scaffold.dart';

/// 应用外壳：手机版底部导航 / 车机版左侧导航栏。
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  static const List<_ShellDestination> _destinations = [
    _ShellDestination(
      path: Routes.home,
      label: '今日',
      icon: Icons.today_outlined,
      selectedIcon: Icons.today,
    ),
    _ShellDestination(
      path: Routes.calendar,
      label: '日历',
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month,
    ),
    _ShellDestination(
      path: Routes.vehicles,
      label: '车牌',
      icon: Icons.directions_car_outlined,
      selectedIcon: Icons.directions_car,
    ),
    _ShellDestination(
      path: Routes.cities,
      label: '城市',
      icon: Icons.location_city_outlined,
      selectedIcon: Icons.location_city,
    ),
    _ShellDestination(
      path: Routes.settings,
      label: '设置',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
    ),
  ];

  int get _currentIndex {
    for (var i = 0; i < _destinations.length; i++) {
      if (location.startsWith(_destinations[i].path)) return i;
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
              selectedIndex: _currentIndex,
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
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: d.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

/// 车机版左侧导航（大触控目标 + 文字标签常驻）。
class _CarNavigationRail extends StatelessWidget {
  const _CarNavigationRail({
    required this.destinations,
    required this.selectedIndex,
  });

  final List<_ShellDestination> destinations;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
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
            for (var i = 0; i < destinations.length; i++)
              _CarNavItem(
                destination: destinations[i],
                selected: i == selectedIndex,
              ),
          ],
        ),
      ),
    );
  }
}

class _CarNavItem extends StatelessWidget {
  const _CarNavItem({required this.destination, required this.selected});

  final _ShellDestination destination;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.gap12,
        vertical: AppSizes.gap4,
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
                Icon(
                  selected ? destination.selectedIcon : destination.icon,
                  size: 30,
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
    required this.icon,
    required this.selectedIcon,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
