import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// 形态判定：手机（单栏） / 车机（双栏大屏）。
class FormFactor {
  const FormFactor._();

  /// 是否为车机形态（逻辑宽度 ≥ 840dp）。
  static bool isCar(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppSizes.carBreakpoint;

  /// 页面内边距。
  static double pagePadding(BuildContext context) =>
      isCar(context) ? AppSizes.carPagePadding : AppSizes.pagePadding;

  /// 触控目标最小尺寸。
  static double touchTarget(BuildContext context) =>
      isCar(context) ? AppSizes.carTouchTarget : AppSizes.touchTarget;
}

/// 自适应脚手架：手机单栏 / 车机双栏（左主区 + 右侧栏）。
///
/// 车机场景设计约束：
/// - 触控目标 ≥ 76dp
/// - 单层导航，不使用侧滑返回
/// - 字号整体放大（见 AppTheme.dark(isCar: true)）
/// - 内容宽度约束，避免超宽屏拉伸
class CarAdaptiveScaffold extends StatelessWidget {
  const CarAdaptiveScaffold({
    super.key,
    required this.primary,
    this.secondary,
    this.title,
    this.actions,
    this.horizontalPadding,
  });

  /// 主内容区（手机版全宽）。
  final Widget primary;

  /// 车机版右侧栏（可选）。
  final Widget? secondary;

  final String? title;
  final List<Widget>? actions;
  final double? horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final isCar = FormFactor.isCar(context);
    final padding = horizontalPadding ?? FormFactor.pagePadding(context);

    final content = isCar && secondary != null
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: primary),
              const SizedBox(width: AppSizes.gap24),
              SizedBox(
                width: 380,
                child: SingleChildScrollView(child: secondary),
              ),
            ],
          )
        : primary;

    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              actions: actions,
              automaticallyImplyLeading: false,
            ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

/// 区块标题（含可选副标题与操作）。
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSizes.gap24,
        bottom: AppSizes.gap12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.cardTitle),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSizes.gap4),
                  Text(subtitle!, style: AppTypography.caption),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// 空状态占位。
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.gap32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: AppColors.textTertiary),
            const SizedBox(height: AppSizes.gap16),
            Text(title, style: AppTypography.cardTitle),
            if (description != null) ...[
              const SizedBox(height: AppSizes.gap8),
              Text(
                description!,
                style: AppTypography.body,
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSizes.gap24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// 加载中占位。
class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          if (label != null) ...[
            const SizedBox(height: AppSizes.gap16),
            Text(label!, style: AppTypography.body),
          ],
        ],
      ),
    );
  }
}

/// 错误状态占位。
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.gap32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.restricted,
            ),
            const SizedBox(height: AppSizes.gap16),
            Text(
              message,
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSizes.gap24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
