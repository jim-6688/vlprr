import '../entities/reminder_config.dart';
import '../entities/restriction_day.dart';
import '../entities/vehicle.dart';
import '../repositories/alert_gateway.dart';
import '../repositories/settings_repository.dart';
import '../services/reminder_planner.dart';

/// 应用提醒计划用例：规划目标集合 → 与事实源 diff → 下发到平台网关。
///
/// 触发时机：数据同步完成 / App 冷启动 / 配置变更 / 每日 00:05 兜底任务。
class ApplyReminderPlan {
  ApplyReminderPlan({
    required this.settingsRepository,
    required this.alertGateway,
    this.planner = const ReminderPlanner(),
  });

  final SettingsRepository settingsRepository;
  final AlertGateway alertGateway;
  final ReminderPlanner planner;

  Future<ReminderPlanResult> call({
    required List<RestrictionDay> upcomingDays,
    required List<Vehicle> vehicles,
    required ReminderConfig defaultConfig,
    required Map<String, ReminderConfig> cityConfigs,
    DateTime? now,
  }) async {
    final moment = now ?? DateTime.now();

    final targets = planner.plan(
      days: upcomingDays,
      vehicles: vehicles,
      defaultConfig: defaultConfig,
      cityConfigs: cityConfigs,
      now: moment,
    );

    final existing = await settingsRepository.getScheduledReminders();
    final existingIds = existing.map((r) => r.id).toSet();
    final targetIds = targets.map((r) => r.id).toSet();

    // 取消：存在但不在目标集合中
    final toCancel = existingIds.difference(targetIds).toList();

    // 排程：目标中不存在，或触发时刻发生变化
    final existingById = {for (final r in existing) r.id: r};
    final toSchedule = targets.where((t) {
      final old = existingById[t.id];
      return old == null || old.fireAt != t.fireAt;
    }).toList();

    await alertGateway.applyPlan(toSchedule: toSchedule, toCancel: toCancel);

    // 事实源更新
    if (toCancel.isNotEmpty) {
      await settingsRepository.deleteScheduled(toCancel);
    }
    if (toSchedule.isNotEmpty) {
      await settingsRepository.upsertScheduled(toSchedule);
    }

    return ReminderPlanResult(
      scheduled: toSchedule.length,
      cancelled: toCancel.length,
      totalActive: targets.length,
    );
  }
}

class ReminderPlanResult {
  const ReminderPlanResult({
    required this.scheduled,
    required this.cancelled,
    required this.totalActive,
  });

  final int scheduled;
  final int cancelled;
  final int totalActive;

  @override
  String toString() =>
      'ReminderPlan(+$scheduled -$cancelled = $totalActive)';
}
