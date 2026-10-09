import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/reminder_config.dart';
import '../../../../domain/entities/restriction_day.dart';
import '../../../widgets/car_adaptive_scaffold.dart';

/// 权限引导区块：逐项展示强提醒所需权限的授权状态，并提供跳转设置入口。
///
/// 设计原则：
/// - **只做引导，不做静默失败**：任何权限缺失都明确告知后果（降级为普通通知等）。
/// - **能力探测优先**：先看平台是否支持该能力（如 iOS 无全屏意图），不支持则显示"该平台不支持"而非"未授权"。
class PermissionGuideSection extends ConsumerWidget {
  const PermissionGuideSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capsAsync = ref.watch(alertCapabilitiesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: '权限与能力',
          subtitle: '强提醒依赖以下系统能力',
        ),
        capsAsync.when(
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.gap16),
              child: LoadingState(),
            ),
          ),
          error: (e, _) => Card(
            child: ListTile(
              leading: const Icon(Icons.error_outline, color: AppColors.restricted),
              title: const Text('能力探测失败', style: AppTypography.body),
              subtitle: Text('$e', style: AppTypography.caption),
            ),
          ),
          data: (caps) => Card(
            child: Column(
              children: [
                _GuideTile(
                  icon: Icons.notifications_active_outlined,
                  title: '通知权限',
                  description: caps.hasStrongAlertPath
                      ? '已具备强提醒通道（${caps.platformName}）'
                      : '未检测到强提醒通道，将降级为普通通知',
                  status: caps.hasStrongAlertPath
                      ? _PermStatus.granted
                      : _PermStatus.missing,
                ),
                const Divider(height: 1),
                _GuideTile(
                  icon: Icons.alarm_outlined,
                  title: '精确闹钟',
                  description: caps.exactAlarmSupported
                      ? '可在指定时刻准点触发'
                      : '系统未授予，触发时间可能被延迟（省电策略）',
                  status: caps.exactAlarmSupported
                      ? _PermStatus.granted
                      : _PermStatus.optional,
                ),
                const Divider(height: 1),
                _GuideTile(
                  icon: Icons.fullscreen,
                  title: '全屏强提醒',
                  description: caps.fullScreenIntentSupported
                      ? '锁屏时可点亮屏幕全屏展示'
                      : '当前平台不支持全屏意图',
                  status: caps.fullScreenIntentSupported
                      ? _PermStatus.granted
                      : _PermStatus.unsupported,
                ),
                const Divider(height: 1),
                _GuideTile(
                  icon: Icons.record_voice_over_outlined,
                  title: '语音播报',
                  description: caps.ttsSupported
                      ? '触发时可用中文朗读车牌与尾号'
                      : '当前平台不支持语音合成',
                  status: caps.ttsSupported
                      ? _PermStatus.granted
                      : _PermStatus.unsupported,
                ),
                const Divider(height: 1),
                _GuideTile(
                  icon: Icons.do_not_disturb_off_outlined,
                  title: '绕过勿扰模式',
                  description: caps.bypassDndSupported
                      ? '需在系统设置中额外授予"勿扰访问权限"'
                      : '当前平台不支持绕过勿扰',
                  status: caps.bypassDndSupported
                      ? _PermStatus.optional
                      : _PermStatus.unsupported,
                ),
                const Divider(height: 1),
                _GuideTile(
                  icon: Icons.timer_outlined,
                  title: '时效性通知',
                  description: caps.timeSensitiveSupported
                      ? 'iOS 15+ 可突破专注模式过滤'
                      : '当前平台不支持时效性通知',
                  status: caps.timeSensitiveSupported
                      ? _PermStatus.granted
                      : _PermStatus.unsupported,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_open_outlined, color: AppColors.primary),
                  title: const Text('一键申请权限', style: TextStyle(fontSize: 15)),
                  subtitle: const Text(
                    '触发系统授权弹窗，并在必要时跳转系统设置页',
                    style: AppTypography.caption,
                  ),
                  trailing: FilledButton(
                    onPressed: () async {
                      final ok =
                          await ref.read(alertGatewayProvider).requestPermission();
                      ref.invalidate(alertCapabilitiesProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok ? '权限申请已提交，请留意系统弹窗' : '部分权限需手动在系统设置中开启',
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('申请'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 重新计算并下发提醒计划。
  ///
  /// 被配置变更（提醒开关/时间调整）后调用，保证事实源与系统排程一致。
  /// 集中在此处实现，避免各调用点重复拼装参数。
  static Future<void> reschedule(WidgetRef ref) async {
    try {
      final now = DateTime.now();
      final cities = ref.read(myCitiesProvider).valueOrNull ?? const [];
      if (cities.isEmpty) return;

      final restrictionRepo = ref.read(restrictionRepositoryProvider);
      final vehicleRepo = ref.read(vehicleRepositoryProvider);
      final settingsRepo = ref.read(settingsRepositoryProvider);

      // 汇总所有关注城市在时间窗内的限行日
      final days = <RestrictionDay>[];
      for (final c in cities) {
        days.addAll(await restrictionRepo.getRange(c.id, now, 7));
      }

      final vehicles = await vehicleRepo.getAll();
      final defaultConfig = await settingsRepo.getConfig(ReminderConfig.defaultKey);
      final cityConfigs = await ref.read(databaseProvider).settingDao.getAllConfigs();

      await ref.read(applyReminderPlanProvider).call(
            upcomingDays: days,
            vehicles: vehicles,
            defaultConfig: defaultConfig,
            cityConfigs: cityConfigs,
            now: now,
          );
    } catch (_) {
      // 重排失败不阻断 UI；下次冷启动/同步时会自动重试。
    }
  }
}

enum _PermStatus { granted, optional, missing, unsupported }

class _GuideTile extends StatelessWidget {
  const _GuideTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.status,
  });

  final IconData icon;
  final String title;
  final String description;
  final _PermStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, label, trailingIcon) = switch (status) {
      _PermStatus.granted => (AppColors.free, '已具备', Icons.check_circle),
      _PermStatus.optional => (AppColors.estimated, '建议开启', Icons.info),
      _PermStatus.missing => (AppColors.restricted, '未授权', Icons.error),
      _PermStatus.unsupported => (AppColors.textTertiary, '不支持', Icons.block),
    };

    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Row(
        children: [
          Text(title, style: AppTypography.cardTitle.copyWith(fontSize: 15)),
          const SizedBox(width: AppSizes.gap8),
          Icon(trailingIcon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(description, style: AppTypography.caption),
      ),
      isThreeLine: true,
    );
  }
}
