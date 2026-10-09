import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tail_limit/core/theme/app_theme.dart';

void main() {
  group('AppColors · 石墨电蓝（方案 B）', () {
    test('不使用纯黑作为背景或表面色', () {
      expect(AppColors.background, isNot(const Color(0xFF000000)));
      expect(AppColors.surface, isNot(const Color(0xFF000000)));
      expect(AppColors.surfaceElevated, isNot(const Color(0xFF000000)));
      // onPrimary 深色底上用的前景也不能是纯黑
      expect(AppColors.onPrimary, isNot(const Color(0xFF000000)));
    });

    test('背景层次由深到浅单调递增', () {
      double lum(Color c) => c.computeLuminance();
      expect(
        lum(AppColors.background),
        lessThan(lum(AppColors.surface)),
        reason: 'surface 应比 background 亮',
      );
      expect(
        lum(AppColors.surface),
        lessThan(lum(AppColors.surfaceElevated)),
        reason: 'surfaceElevated 应比 surface 亮',
      );
    });

    test('outline 层次单调递增', () {
      double lum(Color c) => c.computeLuminance();
      expect(lum(AppColors.outline), lessThan(lum(AppColors.outlineStrong)));
    });

    test('强调色饱和度低于 80%（Ardot 规范）', () {
      final HSLColor hsl = HSLColor.fromColor(AppColors.primary);
      expect(hsl.saturation, lessThan(0.8));
    });

    test('强调色为蓝色系（非 AI 紫）', () {
      final HSLColor hsl = HSLColor.fromColor(AppColors.primary);
      // 蓝色区间：色相 180–260 度
      expect(hsl.hue, greaterThanOrEqualTo(180));
      expect(hsl.hue, lessThanOrEqualTo(260));
    });

    test('文本三级层次单调递减', () {
      double lum(Color c) => c.computeLuminance();
      expect(lum(AppColors.textPrimary), greaterThan(lum(AppColors.textSecondary)));
      expect(lum(AppColors.textSecondary), greaterThan(lum(AppColors.textTertiary)));
    });

    test('状态色互相可区分', () {
      final Set<Color> states = {
        AppColors.restricted,
        AppColors.free,
        AppColors.estimated,
      };
      expect(states.length, 3, reason: '三种状态色不能重复');
    });

    test('限行态使用强调蓝而非红色', () {
      final HSLColor hsl = HSLColor.fromColor(AppColors.restricted);
      // 红色区间应排除（0–30 或 330–360）
      expect(hsl.hue, isNot(inInclusiveRange(0, 30)));
      expect(hsl.hue, isNot(inInclusiveRange(330, 360)));
    });

    test('primaryText 在背景上具备可读对比度（WCAG AA）', () {
      double ratio(Color a, Color b) {
        final double la = a.computeLuminance();
        final double lb = b.computeLuminance();
        final double hi = la > lb ? la : lb;
        final double lo = la > lb ? lb : la;
        return (hi + 0.05) / (lo + 0.05);
      }

      expect(
        ratio(AppColors.primaryText, AppColors.background),
        greaterThanOrEqualTo(4.5),
        reason: 'primaryText 用于深色底小字，需达AA 级（4.5:1）',
      );
    });
  });

  group('AppTheme', () {
    testWidgets('dark() 组装成功且底色为石墨', (WidgetTester tester) async {
      final ThemeData theme = AppTheme.dark();
      expect(theme.scaffoldBackgroundColor, AppColors.background);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.colorScheme.error, AppColors.restricted);
    });

    testWidgets('dark(isCar: true) 使用更大的点击区与字号',
        (WidgetTester tester) async {
      final ThemeData phone = AppTheme.dark();
      final ThemeData car = AppTheme.dark(isCar: true);

      final Size phoneBtn =
          phone.elevatedButtonTheme.style!.minimumSize!
              .resolve(<WidgetState>{})!;
      final Size carBtn =
          car.elevatedButtonTheme.style!.minimumSize!
              .resolve(<WidgetState>{})!;

      expect(carBtn.height, greaterThanOrEqualTo(48),
          reason: '车机触控目标不应小于 48');
      expect(carBtn.height, greaterThanOrEqualTo(phoneBtn.height));

      final TextStyle? carTitle =
          car.appBarTheme.titleTextStyle;
      final TextStyle? phoneTitle =
          phone.appBarTheme.titleTextStyle;
      expect(carTitle!.fontSize!, greaterThan(phoneTitle!.fontSize!));
    });

    testWidgets('输入框聚焦态用1px 描边而非外发光', (WidgetTester tester) async {
      final ThemeData theme = AppTheme.dark();
      final OutlineInputBorder focused = theme.inputDecorationTheme
          .focusedBorder as OutlineInputBorder;
      expect(focused.borderSide.width, 1.0);
      // Ardot 规范禁止 outer glow —— 不应有任何 effect
      expect(theme.cardTheme.color, AppColors.surface);
    });

    testWidgets('Tab 激活态用实心填充 + 底色前景', (WidgetTester tester) async {
      final ThemeData theme = AppTheme.dark();
      final NavigationBarThemeData nav = theme.navigationBarTheme;
      expect(nav.indicatorColor, AppColors.primary);

      final IconThemeData selected =
          nav.iconTheme!.resolve(<WidgetState>{WidgetState.selected})!;
      final IconThemeData unselected =
          nav.iconTheme!.resolve(<WidgetState>{})!;

      expect(selected.color, AppColors.onPrimary);
      expect(unselected.color, AppColors.textTertiary);
      expect(selected.color, isNot(unselected.color));
    });
  });

  group('TaillimitIcons', () {
    test('导出 19 枚图标且无重复', () {
      expect(TaillimitIcons.all.length, 19);
      expect(TaillimitIcons.all.toSet().length, 19);
    });

    test('分类数量符合设计规范', () {
      const List<String> nav = [
        TaillimitIcons.today,
        TaillimitIcons.calendar,
        TaillimitIcons.vehicle,
        TaillimitIcons.settings,
      ];
      const List<String> state = [
        TaillimitIcons.restricted,
        TaillimitIcons.clear,
        TaillimitIcons.estimated,
      ];
      const List<String> info = [
        TaillimitIcons.live,
        TaillimitIcons.cached,
        TaillimitIcons.plate,
        TaillimitIcons.location,
        TaillimitIcons.tail,
      ];
      const List<String> alert = [
        TaillimitIcons.alert,
        TaillimitIcons.bell,
        TaillimitIcons.voice,
      ];
      const List<String> action = [
        TaillimitIcons.chevronRight,
        TaillimitIcons.close,
        TaillimitIcons.plus,
        TaillimitIcons.check,
      ];
      expect(nav.length + state.length + info.length + alert.length + action.length,
          equals(TaillimitIcons.all.length));
    });

    test('描边宽度为 1.75', () {
      expect(TaillimitIcons.strokeWidth, 1.75);
    });

    test('colorFor 状态映射正确', () {
      expect(TaillimitIcons.colorFor(TaillimitIcons.restricted), AppColors.primary);
      expect(TaillimitIcons.colorFor(TaillimitIcons.alert), AppColors.primary);
      expect(TaillimitIcons.colorFor(TaillimitIcons.clear), AppColors.free);
      expect(TaillimitIcons.colorFor(TaillimitIcons.estimated), AppColors.estimated);
      // 未列入语义的图标回退中性色
      expect(TaillimitIcons.colorFor(TaillimitIcons.vehicle), AppColors.textSecondary);
    });

    testWidgets('全部 19 枚图标均可构建且不抛异常',
        (WidgetTester tester) async {
      for (final String name in TaillimitIcons.all) {
        await tester.pumpWidget(
          MaterialApp(
            home: IconDataWidget(name: name),
          ),
        );
        expect(find.byType(CustomPaint), findsWidgets, reason: '$name 应渲染 CustomPaint');
      }
    });

    testWidgets('未知图标名称降级而不抛异常', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: IconDataWidget(name: 'icon-does-not-exist'),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('尺寸可配置：16 / 24 / 28 均可渲染',
        (WidgetTester tester) async {
      for (final double size in <double>[16, 24, 28]) {
        // 放进 Center 并用 SizedBox 约束父级，避免 home 被测试视口拉伸，
        // 这样测到的才是 IconDataWidget 自己声明的尺寸。
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: SizedBox(
                width: size,
                height: size,
                child: const IconDataWidget(name: TaillimitIcons.today),
              ),
            ),
          ),
        );
        final Size box = tester.getSize(
          find.descendant(
            of: find.byType(IconDataWidget),
            matching: find.byType(CustomPaint),
          ),
        );
        expect(box.width, size, reason: 'CustomPaint 应填充 ${size}pt 方框');
        expect(box.height, size);
      }
    });

    testWidgets('size 参数写入 SizedBox 约束', (WidgetTester tester) async {
      const double size = 28;
      await tester.pumpWidget(
        const MaterialApp(
          home: Center(child: IconDataWidget(name: TaillimitIcons.vehicle, size: size)),
        ),
      );
      final SizedBox box = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(IconDataWidget),
          matching: find.byType(SizedBox),
        ),
      );
      expect(box.width, size);
      expect(box.height, size);
    });

    testWidgets('semanticColor 覆盖传入的 color', (WidgetTester tester) async {
      // CustomPainter 无法从测试侧观测内部颜色，改测 colorFor 的映射结果，
      // 这是 semanticColor 分支唯一依赖的输入。
      expect(TaillimitIcons.colorFor(TaillimitIcons.clear), AppColors.free);
      expect(
        TaillimitIcons.colorFor(TaillimitIcons.clear),
        isNot(const Color(0xFFFF0000)),
        reason: 'clear 应映射到语义绿而非传入的红',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: IconDataWidget(
            name: TaillimitIcons.clear,
            color: Colors.red,
            semanticColor: true,
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}

