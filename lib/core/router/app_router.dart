import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/features/calendar/calendar_screen.dart';
import '../../presentation/features/cities/cities_screen.dart';
import '../../presentation/features/home/home_screen.dart';
import '../../presentation/features/noise/noise_screen.dart';
import '../../presentation/features/onboarding/onboarding_screen.dart';
import '../../presentation/features/radio/radio_screen.dart';
import '../../presentation/features/settings/settings_screen.dart';
import '../../presentation/features/shell/app_shell.dart';
import '../../presentation/features/vehicles/vehicle_edit_screen.dart';
import '../../presentation/features/vehicles/vehicles_screen.dart';
import '../di/providers.dart';

/// 路由路径常量。
class Routes {
  const Routes._();

  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String radio = '/radio';
  static const String noise = '/noise';
  static const String settings = '/settings';

  // —— 以下为限行数据子页，不占主导航栏位——
  static const String calendar = '/calendar';
  static const String vehicles = '/vehicles';
  static const String vehicleEdit = '/vehicles/edit';
  static const String cities = '/cities';
}

/// 应用路由表。
///
/// 首启引导判定：onboardingCompletedProvider 为 false 时进入引导页。
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.home,
    redirect: (context, state) {
      final completed =
          ref.read(onboardingCompletedProvider).valueOrNull ?? true;
      final isOnboarding = state.matchedLocation == Routes.onboarding;

      if (!completed && !isOnboarding) return Routes.onboarding;
      if (completed && isOnboarding) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: Routes.radio,
            builder: (context, state) => const RadioScreen(),
          ),
          GoRoute(
            path: Routes.noise,
            builder: (context, state) => const NoiseScreen(),
          ),
          GoRoute(
            path: Routes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),

          // —— 限行数据子页：从首页卡片或车机侧栏进入——
          GoRoute(
            path: Routes.calendar,
            builder: (context, state) => const CalendarScreen(),
          ),
          GoRoute(
            path: Routes.vehicles,
            builder: (context, state) => const VehiclesScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) {
                  final id = state.uri.queryParameters['id'];
                  return VehicleEditScreen(vehicleId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: Routes.cities,
            builder: (context, state) => const CitiesScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('页面不存在')),
      body: Center(child: Text('未找到路径：${state.uri}')),
    ),
  );
});
