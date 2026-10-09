import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/plate_utils.dart';
import '../../../domain/entities/city.dart';
import '../../../domain/entities/reminder_config.dart';
import '../../../domain/entities/restriction_day.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/car_adaptive_scaffold.dart';

/// 首次启动引导：三步完成基础配置。
///
/// 1. 选择关注城市（决定限行政策来源）
/// 2. 绑定车牌号（决定是否受限）
/// 3. 授权通知（决定强提醒能否触达）
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _step = 0;

  City? _selectedCity;
  final _plateController = TextEditingController();
  final _aliasController = TextEditingController();
  String? _plateError;
  bool _finished = false;

  @override
  void dispose() {
    _controller.dispose();
    _plateController.dispose();
    _aliasController.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
      _controller.animateToPage(
        _step,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
      _controller.animateToPage(
        _step,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
  }

  /// 第 1 步 → 第 2 步：写入城市。
  Future<void> _commitCity() async {
    final city = _selectedCity;
    if (city == null) return;
    await ref.read(cityRepositoryProvider).addMyCity(city);
    _next();
  }

  /// 第 2 步 → 第 3 步：写入车牌（可跳过）。
  Future<void> _commitVehicle() async {
    final raw = _plateController.text.trim();
    if (raw.isEmpty) {
      _next();
      return;
    }
    final normalized = PlateUtils.normalize(raw);
    final error = PlateUtils.validate(normalized);
    if (error != null) {
      setState(() => _plateError = error);
      return;
    }

    final city = _selectedCity;
    if (city != null) {
      await ref.read(vehicleRepositoryProvider).add(
            PlateUtils.buildVehicle(
              id: _newVehicleId(normalized),
              plateRaw: normalized,
              boundCityId: city.id,
              nickname: _aliasController.text.trim(),
            ),
          );
    }
    _next();
  }

  /// 生成车辆本地 ID（时间戳 + 车牌后 4 位，保证同车重复添加可覆盖）。
  static String _newVehicleId(String plate) {
    final tail = plate.length >= 4 ? plate.substring(plate.length - 4) : plate;
    return 'v_${DateTime.now().millisecondsSinceEpoch}_$tail';
  }

  /// 第 3 步：申请权限 + 完成引导 + 首次同步。
  Future<void> _finish() async {
    if (_finished) return;
    setState(() => _finished = true);

    final config = ref.read(appConfigProvider);

    // 1) 通知授权（失败不阻断，用户可在设置中补授权）
    try {
      await ref.read(alertGatewayProvider).requestPermission();
    } catch (_) {}

    // 2) 标记引导完成
    await ref.read(cityRepositoryProvider).markOnboardingCompleted();

    // 3) 首次数据同步
    try {
      await ref.read(syncRestrictionsProvider).call(days: config.syncDays);
    } catch (_) {}

    // 4) 排程提醒
    await _reschedule();

    if (mounted) {
      ref.invalidate(onboardingCompletedProvider);
      context.go(Routes.home);
    }
  }

  Future<void> _reschedule() async {
    try {
      final now = DateTime.now();
      final cities = await ref.read(cityRepositoryProvider).getMyCities();
      if (cities.isEmpty) return;

      final days = <RestrictionDay>[];
      for (final c in cities) {
        days.addAll(
          await ref.read(restrictionRepositoryProvider).getRange(c.id, now, 7),
        );
      }
      final vehicles = await ref.read(vehicleRepositoryProvider).getAll();
      final defaultConfig =
          await ref.read(settingsRepositoryProvider).getConfig(ReminderConfig.defaultKey);
      final cityConfigs = await ref.read(databaseProvider).settingDao.getAllConfigs();

      await ref.read(applyReminderPlanProvider).call(
            upcomingDays: days,
            vehicles: vehicles,
            defaultConfig: defaultConfig,
            cityConfigs: cityConfigs,
            now: now,
          );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isCar = FormFactor.isCar(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isCar ? AppSizes.maxContentWidth : 520,
            ),
            child: Column(
              children: [
                _StepIndicator(current: _step),
                Expanded(
                  child: PageView(
                    controller: _controller,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _CityStep(
                        selected: _selectedCity,
                        onSelect: (c) => setState(() => _selectedCity = c),
                      ),
                      _VehicleStep(
                        plateController: _plateController,
                        aliasController: _aliasController,
                        errorText: _plateError,
                        cityName: _selectedCity?.name,
                        onChanged: () {
                          if (_plateError != null) {
                            setState(() => _plateError = null);
                          } else {
                            setState(() {});
                          }
                        },
                      ),
                      const _PermissionStep(),
                    ],
                  ),
                ),
                _BottomBar(
                  step: _step,
                  canProceed: _step != 0 || _selectedCity != null,
                  busy: _finished,
                  onBack: _back,
                  onNext: switch (_step) {
                    0 => _commitCity,
                    1 => _commitVehicle,
                    _ => _finish,
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 顶部步骤指示器。
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current});

  final int current;

  static const _labels = ['选择城市', '绑定车牌', '开启提醒'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePadding,
        AppSizes.gap24,
        AppSizes.pagePadding,
        AppSizes.gap8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TailLimit', style: AppTypography.pageTitle),
          const SizedBox(height: AppSizes.gap8),
          Text(
            '限号当日强提醒，出行更从容',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.gap24),
          Row(
            children: [
              for (var i = 0; i < _labels.length; i++) ...[
                _StepDot(index: i, current: current, label: _labels[i]),
                if (i < _labels.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      color: i < current
                          ? AppColors.primary
                          : AppColors.outline,
                    ),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.index,
    required this.current,
    required this.label,
  });

  final int index;
  final int current;
  final String label;

  @override
  Widget build(BuildContext context) {
    final done = index < current;
    final active = index == current;
    final color = done || active ? AppColors.primary : AppColors.textTertiary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.primary : Colors.transparent,
            border: Border.all(color: color, width: 1.5),
          ),
          child: done
              ? const Icon(Icons.check, size: 15, color: AppColors.primary)
              : Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active ? AppColors.background : color,
                  ),
                ),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 11, color: color)),
      ],
    );
  }
}

/// 第 1 步：选择城市。
class _CityStep extends ConsumerWidget {
  const _CityStep({required this.selected, required this.onSelect});

  final City? selected;
  final ValueChanged<City> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cities = ref.watch(myCitiesProvider).valueOrNull ?? const <City>[];
    final recommended = _recommendedCities(cities);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePadding,
        AppSizes.gap16,
        AppSizes.pagePadding,
        AppSizes.gap16,
      ),
      children: [
        const SectionHeader(
          title: '选择你的城市',
          subtitle: '限行政策按城市制定，可同时关注多个城市',
        ),
        Wrap(
          spacing: AppSizes.gap8,
          runSpacing: AppSizes.gap8,
          children: [
            for (final c in recommended)
              ChoiceChip(
                label: Text(c.name),
                selected: selected?.id == c.id,
                onSelected: (_) => onSelect(c),
                labelStyle: TextStyle(
                  color: selected?.id == c.id
                      ? AppColors.background
                      : AppColors.textPrimary,
                ),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surface,
                side: const BorderSide(color: AppColors.outline),
                showCheckmark: false,
              ),
          ],
        ),
        const SizedBox(height: AppSizes.gap24),
        Text(
          '未找到你的城市？限行覆盖 65 个主要城市，'
          '可在"城市管理"页搜索添加，或先选择邻近城市。',
          style: AppTypography.caption.copyWith(height: 1.8),
        ),
      ],
    );
  }

  /// 推荐城市：先展示无措施说明的城市（政策透明），再按拼音序补足。
  static List<City> _recommendedCities(List<City> mine) {
    final mineIds = mine.map((c) => c.id).toSet();
    final all = kKnownRestrictionCities
        .where((c) => !mineIds.contains(c.id))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return all.take(24).toList();
  }
}

/// 第 2 步：绑定车牌。
class _VehicleStep extends StatelessWidget {
  const _VehicleStep({
    required this.plateController,
    required this.aliasController,
    required this.errorText,
    required this.cityName,
    required this.onChanged,
  });

  final TextEditingController plateController;
  final TextEditingController aliasController;
  final String? errorText;
  final String? cityName;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final raw = plateController.text.trim();
    final normalized = PlateUtils.normalize(raw);
    final valid = normalized.isNotEmpty && PlateUtils.validate(normalized) == null;
    final isNev = valid && PlateUtils.isNewEnergy(normalized);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePadding,
        AppSizes.gap16,
        AppSizes.pagePadding,
        AppSizes.gap16,
      ),
      children: [
        SectionHeader(
          title: '绑定车牌号',
          subtitle: cityName == null ? '用于判定是否受限' : '将按 $cityName 政策判定',
        ),
        TextField(
          controller: plateController,
          textCapitalization: TextCapitalization.characters,
          maxLength: 8,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            labelText: '车牌号',
            hintText: '如 沪A12345',
            errorText: errorText,
            prefixIcon: const Icon(Icons.directions_car_outlined),
          ),
          style: const TextStyle(
            fontSize: 20,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (valid)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.gap16),
            child: Row(
              children: [
                PlateBadge(plate: normalized),
                const SizedBox(width: AppSizes.gap8),
                Text(
                  isNev ? '新能源绿牌 · 多数城市豁免限行' : '蓝牌 · 按尾号轮换规则判定',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        TextField(
          controller: aliasController,
          maxLength: 12,
          decoration: const InputDecoration(
            labelText: '备注（可选）',
            hintText: '如 我的车 / 通勤车',
            prefixIcon: Icon(Icons.label_outline),
          ),
        ),
        const SizedBox(height: AppSizes.gap8),
        const Text(
          '也可以暂时跳过，稍后在"我的车辆"中添加。',
          style: AppTypography.caption,
        ),
      ],
    );
  }
}

/// 第 3 步：权限说明。
class _PermissionStep extends ConsumerWidget {
  const _PermissionStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capsAsync = ref.watch(alertCapabilitiesProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.pagePadding,
        AppSizes.gap16,
        AppSizes.pagePadding,
        AppSizes.gap16,
      ),
      children: [
        const SectionHeader(
          title: '开启强提醒',
          subtitle: '限号当日，即使锁屏也能收到提醒',
        ),
        Card(
          child: Column(
            children: [
              const _FeatureTile(
                icon: Icons.notifications_active_outlined,
                title: '通知权限',
                description: '必选。用于发送提醒通知',
              ),
              const Divider(height: 1),
              const _FeatureTile(
                icon: Icons.fullscreen,
                title: '全屏强提醒',
                description: 'Android 锁屏时点亮屏幕全屏展示',
              ),
              const Divider(height: 1),
              const _FeatureTile(
                icon: Icons.record_voice_over_outlined,
                title: '语音播报',
                description: '触发时朗读车牌与限行尾号',
              ),
              const Divider(height: 1),
              const _FeatureTile(
                icon: Icons.alarm_outlined,
                title: '精确闹钟',
                description: '保证在指定时刻准点触发',
              ),
              if (capsAsync.valueOrNull != null) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(AppSizes.gap16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: AppSizes.gap8),
                      Expanded(
                        child: Text(
                          '当前平台：${capsAsync.valueOrNull!.platformName}'
                          '${capsAsync.valueOrNull!.hasStrongAlertPath ? " · 支持强提醒通道" : " · 将降级为普通通知"}',
                          style: AppTypography.caption,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSizes.gap16),
        Text(
          '点击"完成"后将弹出系统授权窗口。'
          '若误点拒绝，可随时在"设置 → 权限与能力"中重新开启。',
          style: AppTypography.caption.copyWith(height: 1.8),
        ),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTypography.cardTitle.copyWith(fontSize: 15)),
      subtitle: Text(description, style: AppTypography.caption),
    );
  }
}

/// 底部操作栏。
class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.step,
    required this.canProceed,
    required this.busy,
    required this.onBack,
    required this.onNext,
  });

  final int step;
  final bool canProceed;
  final bool busy;
  final VoidCallback onBack;
  final Future<void> Function() onNext;

  @override
  Widget build(BuildContext context) {
    final isLast = step == 2;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.pagePadding,
        AppSizes.gap8,
        AppSizes.pagePadding,
        isLast ? AppSizes.gap8 : AppSizes.gap24,
      ),
      child: Row(
        children: [
          if (step > 0)
            TextButton(
              onPressed: busy ? null : onBack,
              child: const Text('上一步'),
            ),
          const Spacer(),
          FilledButton(
            onPressed: (!canProceed || busy) ? null : () => onNext(),
            style: FilledButton.styleFrom(
              minimumSize: const Size(120, AppSizes.touchTarget),
            ),
            child: busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    isLast
                        ? '完成'
                        : (step == 1 ? '下一步（可跳过）' : '下一步'),
                  ),
          ),
        ],
      ),
    );
  }
}
