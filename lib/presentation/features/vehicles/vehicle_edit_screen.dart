import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/plate_utils.dart';
import '../../../domain/entities/city.dart';
import '../../../domain/entities/reminder_config.dart';
import '../../../domain/entities/restriction_day.dart';
import '../../../domain/entities/vehicle.dart';
import '../../widgets/app_widgets.dart';

/// 车牌编辑页：新增 / 编辑。
class VehicleEditScreen extends ConsumerStatefulWidget {
  const VehicleEditScreen({super.key, this.vehicleId});

  /// 为 null 表示新增。
  final String? vehicleId;

  @override
  ConsumerState<VehicleEditScreen> createState() => _VehicleEditScreenState();
}

class _VehicleEditScreenState extends ConsumerState<VehicleEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _plateController;
  late final TextEditingController _nicknameController;

  String _cityId = '';
  bool _isActive = true;
  bool _loading = false;
  Vehicle? _editing;
  bool _initialized = false;

  bool get isNew => widget.vehicleId == null;

  @override
  void initState() {
    super.initState();
    _plateController = TextEditingController();
    _nicknameController = TextEditingController();
  }

  @override
  void dispose() {
    _plateController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    if (_initialized) return;
    _initialized = true;

    final id = widget.vehicleId;
    if (id != null) {
      final all = await ref.read(vehicleRepositoryProvider).getAll();
      for (final v in all) {
        if (v.id == id) {
          _editing = v;
          _plateController.text = v.plate;
          _nicknameController.text = v.nickname;
          _cityId = v.boundCityId;
          _isActive = v.isActive;
          break;
        }
      }
    }

    final cities = await ref.read(cityRepositoryProvider).getMyCities();
    if (_cityId.isEmpty && cities.isNotEmpty) {
      _cityId = cities.first.id;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _loadExisting();
    final citiesAsync = ref.watch(myCitiesProvider);
    final cities = citiesAsync.valueOrNull ?? const <City>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? '添加车牌' : '编辑车牌'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/vehicles'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.pagePadding),
                children: [
                  // —— 车牌输入 ——
                  const _Label(text: '车牌号'),
                  TextFormField(
                    controller: _plateController,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 8,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼A-Za-z0-9·]')),
                    ],
                    style: AppTypography.plate,
                    decoration: const InputDecoration(
                      hintText: '如 京A12345',
                      counterText: '',
                    ),
                    validator: (v) => PlateUtils.validate(v ?? ''),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSizes.gap8),
                  _PlatePreview(plate: _plateController.text),

                  const SizedBox(height: AppSizes.gap24),

                  // —— 绑定城市 ——
                  const _Label(text: '绑定城市', hint: '按该城市限行规则判定'),
                  if (cities.isEmpty)
                    _EmptyCityHint(onTap: () => context.go('/cities'))
                  else
                    Wrap(
                      spacing: AppSizes.gap8,
                      runSpacing: AppSizes.gap8,
                      children: cities
                          .map(
                            (c) => ChoiceChip(
                              label: Text(c.name),
                              selected: _cityId == c.id,
                              onSelected: (_) => setState(() => _cityId = c.id),
                            ),
                          )
                          .toList(),
                    ),

                  const SizedBox(height: AppSizes.gap24),

                  // —— 备注名 ——
                  const _Label(text: '备注名', hint: '可选，便于区分多辆车'),
                  TextFormField(
                    controller: _nicknameController,
                    maxLength: 12,
                    decoration: const InputDecoration(
                      hintText: '如 我的车 / 家里油车',
                      counterText: '',
                    ),
                  ),

                  const SizedBox(height: AppSizes.gap16),

                  // —— 启用提醒 ——
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('启用限行提醒'),
                    subtitle: const Text('关闭后该车辆不参与判定与提醒排程'),
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),

                  const SizedBox(height: AppSizes.gap24),

                  ElevatedButton(
                    onPressed: _loading || cities.isEmpty ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isNew ? '添加' : '保存'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_cityId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择绑定城市')),
      );
      return;
    }

    setState(() => _loading = true);

    final plate = PlateUtils.normalize(_plateController.text);
    final repo = ref.read(vehicleRepositoryProvider);

    try {
      // 车牌唯一性校验
      final existing = await repo.findByPlate(plate);
      if (existing != null && existing.id != widget.vehicleId) {
        if (mounted) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('该车牌已存在')),
          );
        }
        return;
      }

      final vehicle = Vehicle(
        id: _editing?.id ?? _generateId(),
        plate: plate,
        nickname: _nicknameController.text.trim(),
        boundCityId: _cityId,
        isActive: _isActive,
        isDefault: _editing?.isDefault ?? false,
      );

      if (isNew) {
        await repo.add(vehicle);
      } else {
        await repo.update(vehicle);
      }

      // 车辆变更后重算提醒计划
      await _reschedule();

      if (mounted) context.go('/vehicles');
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败：$e')),
        );
      }
    }
  }

  /// 车辆变更后重算提醒计划。
  Future<void> _reschedule() async {
    final apply = ref.read(applyReminderPlanProvider);
    final cityRepo = ref.read(cityRepositoryProvider);
    final vehicleRepo = ref.read(vehicleRepositoryProvider);
    final restrictionRepo = ref.read(restrictionRepositoryProvider);
    final settingsRepo = ref.read(settingsRepositoryProvider);

    final cities = await cityRepo.getMyCities();
    if (cities.isEmpty) return;

    final vehicles = await vehicleRepo.getAll();
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, now.day);

    final allDays = <RestrictionDay>[];
    for (final c in cities) {
      allDays.addAll(await restrictionRepo.getRange(c.id, from, 14));
    }

    final defaultConfig =
        await settingsRepo.getConfig(ReminderConfig.defaultKey);
    final cityConfigs = <String, ReminderConfig>{};
    for (final c in cities) {
      cityConfigs[c.id] = await settingsRepo.getConfig(c.id);
    }

    await apply.call(
      upcomingDays: allDays,
      vehicles: vehicles,
      defaultConfig: defaultConfig,
      cityConfigs: cityConfigs,
      now: now,
    );
  }

  static String _generateId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    return 'v${now.toRadixString(36)}';
  }
}

/// 车牌实时预览（含新能源识别）。
class _PlatePreview extends StatelessWidget {
  const _PlatePreview({required this.plate});

  final String plate;

  @override
  Widget build(BuildContext context) {
    final normalized = PlateUtils.normalize(plate);
    if (normalized.length < 6) return const SizedBox.shrink();

    final isNEV = PlateUtils.isNewEnergy(normalized);
    final tail = _tail(normalized);

    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.gap12),
      child: Row(
        children: [
          PlateBadge(plate: normalized),
          const SizedBox(width: AppSizes.gap12),
          if (isNEV)
            const _MiniTag(text: '新能源', color: AppColors.plateGreen),
          const SizedBox(width: AppSizes.gap8),
          Text(
            tail == null ? '尾号无法识别' : '限行尾号：$tail',
            style: AppTypography.caption.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  static String? _tail(String plate) {
    for (var i = plate.length - 1; i >= 0; i--) {
      if (RegExp(r'\d').hasMatch(plate[i])) return plate[i];
    }
    return null;
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: color),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text, this.hint});

  final String text;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.gap8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(text, style: AppTypography.cardTitle),
          if (hint != null) ...[
            const SizedBox(width: AppSizes.gap8),
            Text(hint!, style: AppTypography.caption),
          ],
        ],
      ),
    );
  }
}

class _EmptyCityHint extends StatelessWidget {
  const _EmptyCityHint({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.gap16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.estimated, size: 20),
          const SizedBox(width: AppSizes.gap12),
          const Expanded(
            child: Text('请先添加关注城市', style: AppTypography.body),
          ),
          TextButton(onPressed: onTap, child: const Text('去添加')),
        ],
      ),
    );
  }
}
