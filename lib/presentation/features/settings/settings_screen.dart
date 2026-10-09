import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/city.dart';
import '../../../domain/entities/reminder_config.dart';
import '../../../domain/entities/scheduled_reminder.dart';
import '../../../domain/value_objects/restriction_type.dart';
import '../../widgets/car_adaptive_scaffold.dart';
import '../home/today_status_provider.dart';
import 'widgets/permission_guide.dart';

/// 设置页：提醒配置中心 + 权限引导 + 数据源状态。
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final citiesAsync = ref.watch(myCitiesProvider);
    final cities = citiesAsync.valueOrNull ?? const <City>[];

    if (cities.isEmpty) {
      return const CarAdaptiveScaffold(
        title: '设置',
        primary: EmptyState(
          icon: Icons.settings_outlined,
          title: '暂无配置项',
          description: '添加关注城市后可配置提醒',
        ),
      );
    }

    final cityId = cities.first.id;

    return CarAdaptiveScaffold(
      title: '提醒设置',
      primary: ListView(
        padding: const EdgeInsets.only(
          top: AppSizes.gap16,
          bottom: AppSizes.gap32,
        ),
        children: [
          _ReminderConfigSection(cityId: cityId, cityName: cities.first.name),
          const SizedBox(height: AppSizes.gap24),
          const PermissionGuideSection(),
          const SizedBox(height: AppSizes.gap24),
          const DataSourceSection(),
          const SizedBox(height: AppSizes.gap24),
          const ScheduledListSection(),
          const SizedBox(height: AppSizes.gap24),
          const _AboutSection(),
        ],
      ),
    );
  }
}

/// 提醒配置区块。
class _ReminderConfigSection extends ConsumerWidget {
  const _ReminderConfigSection({required this.cityId, required this.cityName});

  final String cityId;
  final String cityName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(cityConfigProvider(cityId));

    return configAsync.when(
      loading: () => const LoadingState(),
      error: (e, _) => ErrorState(message: '加载失败：$e'),
      data: (config) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: '提醒配置',
            subtitle: '当前城市：$cityName',
          ),
          Card(
            child: Column(
              children: [
                // —— 前一日预告 ——
                SwitchListTile(
                  value: config.previewEnabled,
                  onChanged: (v) => _save(ref, config.copyWith(previewEnabled: v)),
                  title: const Text('前一日预告'),
                  subtitle: Text('限行前一天 ${_fmt(config.previewMinutesOfDay)} 提醒'),
                ),
                if (config.previewEnabled)
                  _TimePickerTile(
                    label: '预告时间',
                    minutesOfDay: config.previewMinutesOfDay,
                    onChanged: (m) => _save(
                      ref,
                      config.copyWith(previewMinutesOfDay: m),
                    ),
                  ),
                const Divider(height: 1),

                // —— 当日强提醒 ——
                SwitchListTile(
                  value: config.strongEnabled,
                  onChanged: (v) => _save(ref, config.copyWith(strongEnabled: v)),
                  title: const Text('限号当日强提醒'),
                  subtitle: const Text('全屏通知 + 语音播报，限行时段前触发'),
                ),
                if (config.strongEnabled) ...[
                  _TimePickerTile(
                    label: '提前时长',
                    minutesOfDay: config.strongLeadMinutes,
                    isDuration: true,
                    onChanged: (m) => _save(
                      ref,
                      config.copyWith(strongLeadMinutes: m),
                    ),
                  ),
                  _TimePickerTile(
                    label: '无时段时提醒',
                    minutesOfDay: config.strongFallbackMinutesOfDay,
                    onChanged: (m) => _save(
                      ref,
                      config.copyWith(strongFallbackMinutesOfDay: m),
                    ),
                  ),
                ],
                const Divider(height: 1),

                // —— 强提醒手段 ——
                SwitchListTile(
                  value: config.voiceEnabled,
                  onChanged: (v) => _save(ref, config.copyWith(voiceEnabled: v)),
                  title: const Text('语音播报'),
                  subtitle: const Text('触发时朗读车牌与限行尾号'),
                ),
                SwitchListTile(
                  value: config.fullScreenEnabled,
                  onChanged: (v) =>
                      _save(ref, config.copyWith(fullScreenEnabled: v)),
                  title: const Text('全屏强提醒'),
                  subtitle: const Text('锁屏状态下直接点亮并全屏展示（Android）'),
                ),
                SwitchListTile(
                  value: config.bypassDndEnabled,
                  onChanged: (v) =>
                      _save(ref, config.copyWith(bypassDndEnabled: v)),
                  title: const Text('尝试绕过勿扰模式'),
                  subtitle: const Text('需系统授权，仅 Android 支持'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save(WidgetRef ref, ReminderConfig config) async {
    await ref.read(settingsRepositoryProvider).saveConfig(config);
    await PermissionGuideSection.reschedule(ref);
  }

  static String _fmt(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '$h:${m.toString().padLeft(2, '0')}';
  }
}

/// 时间选择项。
class _TimePickerTile extends StatelessWidget {
  const _TimePickerTile({
    required this.label,
    required this.minutesOfDay,
    required this.onChanged,
    this.isDuration = false,
  });

  final String label;
  final int minutesOfDay;
  final ValueChanged<int> onChanged;
  final bool isDuration;

  @override
  Widget build(BuildContext context) {
    final h = minutesOfDay ~/ 60;
    final m = minutesOfDay % 60;
    final text = isDuration
        ? '$minutesOfDay 分钟'
        : '$h:${m.toString().padLeft(2, '0')}';

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16, right: 16),
      title: Text(label, style: AppTypography.body),
      trailing: TextButton(
        onPressed: () async {
          if (isDuration) {
            final v = await _pickDuration(context, minutesOfDay);
            if (v != null) onChanged(v);
          } else {
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(hour: h, minute: m),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  timePickerTheme: const TimePickerThemeData(
                    backgroundColor: AppColors.surfaceElevated,
                    dialBackgroundColor: AppColors.surface,
                    hourMinuteColor: AppColors.primaryContainer,
                  ),
                ),
                child: child!,
              ),
            );
            if (picked != null) onChanged(picked.hour * 60 + picked.minute);
          }
        },
        child: Text(
          text,
          style: AppTypography.body.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }

  Future<int?> _pickDuration(BuildContext context, int current) {
    const options = [0, 5, 10, 15, 30, 60];
    return showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSizes.gap16),
            const Text('提前时长', style: AppTypography.cardTitle),
            const SizedBox(height: AppSizes.gap8),
            for (final o in options)
              ListTile(
                title: Text(
                  o == 0 ? '限行时段开始时' : '提前 $o 分钟',
                  style: TextStyle(
                    color: o == current
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
                trailing: o == current
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(ctx, o),
              ),
            const SizedBox(height: AppSizes.gap16),
          ],
        ),
      ),
    );
  }
}

/// 数据源状态区块。
class DataSourceSection extends ConsumerWidget {
  const DataSourceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final lastSyncAsync = ref.watch(lastSyncProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: '数据源',
          subtitle: '限行数据获取状态',
        ),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  config.isEstimatedMode
                      ? Icons.science_outlined
                      : Icons.cloud_done_outlined,
                  color: config.isEstimatedMode
                      ? AppColors.estimated
                      : AppColors.primary,
                ),
                title: Text(
                  config.isEstimatedMode ? '本地估算规则' : _sourceName(config.sourceKind.name),
                  style: AppTypography.cardTitle.copyWith(fontSize: 15),
                ),
                subtitle: Text(
                  config.isEstimatedMode
                      ? '未配置 API Key，使用内置规则引擎。数据可能与官方通告存在差异。'
                      : '已接入实时数据源，同步未来 ${config.syncDays} 天限行数据',
                  style: AppTypography.caption,
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.sync, color: AppColors.textTertiary),
                title: const Text('最近同步', style: TextStyle(fontSize: 15)),
                subtitle: Text(
                  lastSyncAsync.valueOrNull == null
                      ? '尚未同步'
                      : _fmtTime(lastSyncAsync.valueOrNull!),
                  style: AppTypography.caption,
                ),
                trailing: TextButton(
                  onPressed: () async {
                    final result = await ref.read(syncRestrictionsProvider).call(
                          days: config.syncDays,
                        );
                    ref.invalidate(lastSyncProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('已同步 ${result.dayCount} 天数据'),
                        ),
                      );
                    }
                  },
                  child: const Text('立即同步'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _sourceName(String kind) {
    switch (kind) {
      case 'apispace':
        return 'APISpace 实时数据源';
      case 'jisu':
        return '极速数据实时源';
      default:
        return '本地估算规则';
    }
  }

  static String _fmtTime(DateTime t) =>
      '${t.month}-${t.day} ${t.hour}:${t.minute.toString().padLeft(2, '0')}';
}

/// 已排程提醒列表。
class ScheduledListSection extends ConsumerWidget {
  const ScheduledListSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(scheduledRemindersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: '待触发提醒',
          subtitle: '已排程的提醒将在此列出',
        ),
        remindersAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSizes.gap16),
            child: LoadingState(),
          ),
          error: (e, _) => ErrorState(message: '$e'),
          data: (reminders) {
            if (reminders.isEmpty) {
              return const Card(
                child: ListTile(
                  leading: Icon(
                    Icons.notifications_off_outlined,
                    color: AppColors.textTertiary,
                  ),
                  title: Text('暂无待触发提醒', style: AppTypography.body),
                  subtitle: Text(
                    '绑定车牌并完成数据同步后自动排程',
                    style: AppTypography.caption,
                  ),
                ),
              );
            }

            // 仅展示最近 10 条
            final shown = reminders.take(10).toList();
            return Card(
              child: Column(
                children: [
                  for (var i = 0; i < shown.length; i++) ...[
                    _ReminderTile(reminder: shown[i]),
                    if (i < shown.length - 1) const Divider(height: 1),
                  ],
                  if (reminders.length > shown.length)
                    Padding(
                      padding: const EdgeInsets.all(AppSizes.gap12),
                      child: Text(
                        '另有 ${reminders.length - shown.length} 条提醒已排程',
                        style: AppTypography.caption,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({required this.reminder});

  final ScheduledReminder reminder;

  @override
  Widget build(BuildContext context) {
    final isStrong = reminder.kind == ReminderKind.strong;
    return ListTile(
      leading: Icon(
        isStrong ? Icons.notifications_active : Icons.notifications_outlined,
        color: isStrong ? AppColors.primary : AppColors.textTertiary,
      ),
      title: Text(
        reminder.title,
        style: AppTypography.cardTitle.copyWith(fontSize: 15),
      ),
      subtitle: Text(
        '${reminder.plateText} · ${_fmt(reminder.fireAt)}',
        style: AppTypography.caption,
      ),
      trailing: isStrong
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '强提醒',
                style: TextStyle(fontSize: 11, color: AppColors.primary),
              ),
            )
          : null,
    );
  }

  static String _fmt(DateTime t) {
    final now = DateTime.now();
    final isToday = t.year == now.year && t.month == now.month && t.day == now.day;
    final date = isToday
        ? '今天'
        : '${t.month}-${t.day}';
    return '$date ${t.hour}:${t.minute.toString().padLeft(2, '0')}';
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: '关于'),
        Card(
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.info_outline, color: AppColors.textTertiary),
                title: Text('TailLimit 车辆限号提醒', style: TextStyle(fontSize: 15)),
                subtitle: Text('v0.1.0 · 支持 Android / iOS / 鸿蒙', style: TextStyle(fontSize: 12)),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(AppSizes.gap16),
                child: Text(
                  '免责说明：本应用限行数据来自第三方数据服务或内置规则推算，'
                  '可能与当地交管部门最新通告存在差异。请以官方发布为准，'
                  '因数据差异导致的处罚本应用不承担责任。',
                  style: AppTypography.caption.copyWith(height: 1.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
