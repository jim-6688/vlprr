import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/di/providers.dart';
import 'domain/entities/reminder_config.dart';
import 'domain/entities/restriction_day.dart';

/// 应用启动引导。
///
/// 顺序严格如下：
/// 1. 绑定 Flutter 引擎
/// 2. 构建 ProviderContainer（注入编译期配置）
/// 3. 预热数据库（触发 drift 连接与迁移）
/// 4. 非阻塞预热：能力探测 + 数据同步 + 提醒重排
/// 5. 启动 UI
///
/// 第 4 步全部放在 `unawaited` 中，保证**冷启动不被网络阻塞**：
/// 用户先看到本地缓存渲染的界面，数据在后台刷新后自动更新。
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromDartDefines();
  final container = ProviderContainer(
    overrides: [appConfigProvider.overrideWithValue(config)],
  );

  // 预热数据库：提前建表/迁移，避免首帧后卡顿。
  try {
    final db = container.read(databaseProvider);
    await db.customSelect('SELECT 1').get();
    container.read(restrictionRepositoryProvider); // 触发 DAO 初始化
  } catch (e) {
    debugPrint('[bootstrap] 数据库预热失败：$e');
  }

  // 后台预热：不阻塞首帧。
  unawaited(_warmUp(container, config));

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const TailLimitApp(),
    ),
  );
}

/// 后台预热任务：能力探测 → 数据同步 → 提醒重排。
Future<void> _warmUp(ProviderContainer container, AppConfig config) async {
  // 1) 平台能力探测（供权限引导与降级决策使用）
  try {
    await container.read(alertGatewayProvider).capabilities();
  } catch (e) {
    debugPrint('[warmUp] 能力探测失败：$e');
  }

  // 2) 数据同步（无关注城市时跳过）
  try {
    final cities = await container.read(cityRepositoryProvider).getMyCities();
    if (cities.isNotEmpty) {
      await container.read(syncRestrictionsProvider).call(days: config.syncDays);
    }
  } catch (e) {
    debugPrint('[warmUp] 数据同步失败：$e');
  }

  // 3) 提醒重排（保证系统闹钟与最新数据/配置一致）
  try {
    await _reschedule(container);
  } catch (e) {
    debugPrint('[warmUp] 提醒重排失败：$e');
  }

  // 4) 刷新依赖派生状态
  container.invalidate(lastSyncProvider);
  container.invalidate(alertCapabilitiesProvider);
}

Future<void> _reschedule(ProviderContainer container) async {
  final cities = await container.read(cityRepositoryProvider).getMyCities();
  if (cities.isEmpty) return;

  final now = DateTime.now();

  final days = <RestrictionDay>[];
  for (final c in cities) {
    days.addAll(
      await container.read(restrictionRepositoryProvider).getRange(c.id, now, 7),
    );
  }

  final vehicles = await container.read(vehicleRepositoryProvider).getAll();
  final defaultConfig =
      await container.read(settingsRepositoryProvider).getConfig(ReminderConfig.defaultKey);
  final cityConfigs = await container.read(databaseProvider).settingDao.getAllConfigs();

  await container.read(applyReminderPlanProvider).call(
        upcomingDays: days,
        vehicles: vehicles,
        defaultConfig: defaultConfig,
        cityConfigs: cityConfigs,
        now: now,
      );
}
