import '../entities/reminder_config.dart';
import '../entities/scheduled_reminder.dart';

/// 设置/提醒配置仓库抽象。
abstract class SettingsRepository {
  /// 读取配置：优先城市维度，回退全局默认。
  Future<ReminderConfig> getConfig(String cityId);

  /// 监听配置（含默认回退逻辑）。
  Stream<ReminderConfig> watchConfig(String cityId);

  Future<void> saveConfig(ReminderConfig config);

  /// —— 排程事实源（scheduled_reminders 表）——

  Future<List<ScheduledReminder>> getScheduledReminders();

  Stream<List<ScheduledReminder>> watchScheduledReminders();

  Future<void> upsertScheduled(List<ScheduledReminder> reminders);

  Future<void> deleteScheduled(List<String> ids);

  Future<void> clearScheduled();
}
