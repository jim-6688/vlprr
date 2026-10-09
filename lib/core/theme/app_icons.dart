import 'package:flutter/material.dart';

import 'app_colors.dart';

/// TailLimit 功能图标集。
///
/// 设计规范（对齐 Ardot style-guide）：
/// - 全部图形建立在 [iconSize] × [iconSize] 的逻辑网格上，描边 [strokeWidth]；
/// - 形状优先：圆（状态）/ 方（容器）/ 三角（警示）/ 波形（信号）四大类
///   轮廓必须一眼可分；
/// - 状态家族（限行/不限/估算）共享外圆，切换时只换内部笔画；
/// - 颜色由调用方传入，图标本身不硬编码色值。
///
/// 全部使用 [CustomPainter] 手工绘制而非图标字体：19 个图形不值得引入
/// `flutter_svg` 依赖，且字体方案无法在运行时按语义染色。
class TaillimitIcons {
  const TaillimitIcons._();

  // —— 尺寸 ——
  /// 网格边长。24 与 Ardot 移动端规范一致。
  static const double iconSize = 24;
  /// 列表行 / 卡片内图标。
  static const double iconSizeSm = 16;
  /// Tab Bar 图标。
  static const double iconSizeMd = 24;
  /// 首页状态卡强调图标。
  static const double iconSizeLg = 28;
  /// 强提醒徽标内图标。
  static const double iconSizeXs = 14;

  /// 描边宽度，全集统一。几何定义在 [_IconPainter] 内，此处仅作对外契约声明。
  static const double strokeWidth = 1.75;

  // ==================================================================
  //  对外接口：按名称构建图标
  // ==================================================================

  /// 图标名称枚举，与设计稿 `icon/xxx` 一一对应。
  static const String today = 'today';
  static const String calendar = 'calendar';
  static const String vehicle = 'vehicle';
  static const String settings = 'settings';
  static const String restricted = 'restricted';
  static const String clear = 'clear';
  static const String estimated = 'estimated';
  static const String live = 'live';
  static const String cached = 'cached';
  static const String plate = 'plate';
  static const String location = 'location';
  static const String tail = 'tail';
  static const String alert = 'alert';
  static const String bell = 'bell';
  static const String voice = 'voice';
  static const String chevronRight = 'chevron-right';
  static const String close = 'close';
  static const String plus = 'plus';
  static const String check = 'check';

  /// 全部图标名称，供设置页的"图标预览"调试网格使用。
  static const List<String> all = <String>[
    today, calendar, vehicle, settings,
    restricted, clear, estimated,
    live, cached, plate, location, tail,
    alert, bell, voice,
    chevronRight, close, plus, check,
  ];

  /// 按名称取图标。未知名称回退到 [settings]，避免抛异常导致整页崩溃。
  static IconDataWidget icon(String name) =>
      IconDataWidget(name: name);

  /// 依语义取默认色值。
  static Color colorFor(String name) {
    switch (name) {
      case restricted:
      case alert:
      case today:
        return AppColors.primary;
      case clear:
      case check:
      case live:
        return AppColors.free;
      case estimated:
        return AppColors.estimated;
      default:
        return AppColors.textSecondary;
    }
  }
}

/// 渲染单个功能图标。
///
/// [color] 为空时取主题前景色；[semanticColor] 为真时按
/// [TaillimitIcons.colorFor] 取语义色（限行=蓝 / 不限行=绿 / 估算=琥珀）。
class IconDataWidget extends StatelessWidget {
  const IconDataWidget({
    required this.name,
    super.key,
    this.size = TaillimitIcons.iconSize,
    this.color,
    this.semanticColor = false,
  });

  final String name;
  final double size;
  final Color? color;

  /// 传 true 时忽略 [color]，改用 [TaillimitIcons.colorFor]。
  final bool semanticColor;

  @override
  Widget build(BuildContext context) {
    final Color resolved = semanticColor
        ? TaillimitIcons.colorFor(name)
        : (color ?? Theme.of(context).colorScheme.onSurface);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _IconPainter(name: name, color: resolved),
      ),
    );
  }
}

/// 单个功能图标的绘制器。
///
/// 几何定义统一放在 [_IconPainter] 内部（24×24 逻辑网格），绘制时按
/// [CustomPaint] 的 [Size] 等比缩放，因此同一份定义可服务16 / 24 / 28pt。
class _IconPainter extends CustomPainter {
  _IconPainter({required this.name, required this.color});

  final String name;
  final Color color;

  /// 网格边长。几何常量均定义在此坐标系内。
  static const double _k = 24.0;

  Paint get _st =>
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = TaillimitIcons.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

  Paint get _fl =>
      Paint()
        ..color = color
        ..style = PaintingStyle.fill;

  // —— 几何基元（24×24 网格坐标）——
  static Rect _rect(double l, double t, double w, double h) =>
      Rect.fromLTWH(l, t, w, h);

  /// [center] 已是网格坐标的圆外接矩形。
  static Rect _circleRectAt(Offset center, double r) =>
      Rect.fromCircle(center: center, radius: r);

  static void _circle(Canvas canvas, Offset c, double r, Paint p) =>
      canvas.drawCircle(c, r, p);

  static void _line(Canvas canvas, Offset a, Offset b, Paint p) =>
      canvas.drawLine(a, b, p);

  static void _rrect(Canvas canvas, Rect r, double radius, Paint p) =>
      canvas.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(radius)), p);

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.shortestSide / _k;
    canvas.save();
    canvas.scale(s);
    final Paint st = _st;
    final Paint fl = _fl;

    switch (name) {
      // —— 导航 ——
      case TaillimitIcons.today:
        // 日历 + 斜线（斜线只占下半场，避开日期分隔线）
        _rrect(canvas, _rect(3.25, 5.25, 17.5, 15.5), 2.5, st);
        _line(canvas, const Offset(3.25, 9.75), const Offset(20.75, 9.75), st);
        _line(canvas, const Offset(8, 3.25), const Offset(8, 6.75), st);
        _line(canvas, const Offset(16, 3.25), const Offset(16, 6.75), st);
        _line(canvas, const Offset(9, 13.6), const Offset(15, 17.5), st);

      case TaillimitIcons.calendar:
        _rrect(canvas, _rect(3.25, 5.25, 17.5, 15.5), 2.5, st);
        _line(canvas, const Offset(3.25, 9.75), const Offset(20.75, 9.75), st);
        _line(canvas, const Offset(8, 3.25), const Offset(8, 6.75), st);
        _line(canvas, const Offset(16, 3.25), const Offset(16, 6.75), st);
        for (final p in const [
          Offset(8.2, 13.4),
          Offset(12, 13.4),
          Offset(15.8, 13.4),
          Offset(8.2, 17.1),
          Offset(12, 17.1),
        ]) {
          canvas.drawCircle(p, 1.1, fl);
        }

      case TaillimitIcons.vehicle:
        // 侧视角：车顶弧 + 车底横线 + 两轮 + 挡风玻璃分隔
        canvas.drawPath(
          Path()
            ..moveTo(5.6, 16.8)
            ..lineTo(6.7, 12.6)
            ..quadraticBezierTo(7.1, 10.5, 9.24, 10.5)
            ..lineTo(14.76, 10.5)
            ..quadraticBezierTo(16.9, 10.5, 17.3, 12.6)
            ..lineTo(18.4, 16.8),
          st,
        );
        _line(canvas, const Offset(4, 16.8), const Offset(20, 16.8), st);
        canvas.drawPath(
          Path()
            ..moveTo(4, 16.8)
            ..lineTo(4, 18.7)
            ..cubicTo(4, 19.03, 4.27, 19.3, 4.6, 19.3)
            ..lineTo(6.1, 19.3)
            ..cubicTo(6.43, 19.3, 6.7, 19.03, 6.7, 18.7)
            ..lineTo(6.7, 16.8),
          st,
        );
        canvas.drawPath(
          Path()
            ..moveTo(17.3, 16.8)
            ..lineTo(17.3, 18.7)
            ..cubicTo(17.3, 19.03, 17.57, 19.3, 17.9, 19.3)
            ..lineTo(19.4, 19.3)
            ..cubicTo(19.73, 19.3, 19.99, 19.03, 19.99, 18.7)
            ..lineTo(20, 16.8),
          st,
        );
        _line(canvas, const Offset(6.6, 12.7), const Offset(17.4, 12.7), st);

      case TaillimitIcons.settings:
        // 中心圆 + 八向辐射短线（24pt 下完整齿轮的齿会互相粘连）
        _circle(canvas, const Offset(12, 12), 3.1, st);
        for (final p in const [
          Offset(12, 5.7), Offset(12, 18.3),
          Offset(5.7, 12), Offset(18.3, 12),
          Offset(7.5, 7.5), Offset(16.5, 16.5),
          Offset(16.5, 7.5), Offset(7.5, 16.5),
        ]) {
          final double dx = (p.dx - 12) * 0.23;
          final double dy = (p.dy - 12) * 0.23;
          _line(canvas, Offset(p.dx + dx, p.dy + dy), Offset(p.dx - dx, p.dy - dy), st);
        }

      // —— 状态（共享外圆 r=8.6）——
      case TaillimitIcons.restricted:
        _circle(canvas, const Offset(12, 12), 8.6, st);
        _line(canvas, const Offset(6.2, 17.8), const Offset(17.8, 6.2), st);

      case TaillimitIcons.clear:
        _circle(canvas, const Offset(12, 12), 8.6, st);
        canvas.drawPath(
          Path()
            ..moveTo(7.9, 12.2)
            ..lineTo(10.8, 15.1)
            ..lineTo(16.1, 9.1),
          st,
        );

      case TaillimitIcons.estimated:
        _circle(canvas, const Offset(12, 12), 8.6, st);
        // 问号钩：上段圆弧 + 下段竖钩
        canvas.drawArc(
          _circleRectAt(const Offset(12, 10.6), 2.9),
          3.34,
          4.2,
          false,
          st,
        );
        canvas.drawPath(
          Path()
            ..moveTo(11.2, 12.5)
            ..cubicTo(11.0, 13.4, 12, 13.8, 12, 14.5),
          st,
        );
        canvas.drawCircle(const Offset(12, 17.4), 1.05, fl);

      // —— 信息 ——
      case TaillimitIcons.live:
        canvas.drawCircle(const Offset(12, 12), 2.1, fl);
        canvas.drawArc(
            _circleRectAt(const Offset(12, 12), 4.2),
            -2.0, 4.0, false, st);
        canvas.drawArc(
            _circleRectAt(const Offset(12, 12), 4.2),
            1.15, 4.0, false, st);
        canvas.drawArc(
            _circleRectAt(const Offset(12, 12), 7.2),
            -2.0, 4.0, false, st);
        canvas.drawArc(
            _circleRectAt(const Offset(12, 12), 7.2),
            1.15, 4.0, false, st);

      case TaillimitIcons.cached:
        _circle(canvas, const Offset(12, 12), 8.6, st);
        _line(canvas, const Offset(12, 7.2), const Offset(12, 12), st);
        _line(canvas, const Offset(12, 12), const Offset(15.2, 13.9), st);

      case TaillimitIcons.plate:
        _rrect(canvas, _rect(2.75, 7.25, 18.5, 9.5), 2, st);
        _line(canvas, const Offset(6.8, 12), const Offset(11.2, 12), st);
        canvas.drawCircle(const Offset(16.6, 12), 1.15, fl);

      case TaillimitIcons.location:
        canvas.drawPath(
          Path()
            ..moveTo(12, 21.2)
            ..cubicTo(12, 21.2, 19.2, 15.2, 19.2, 10)
            ..arcToPoint(
              const Offset(4.8, 10),
              radius: const Radius.circular(7.2),
              clockwise: false,
            )
            ..cubicTo(4.8, 15.2, 12, 21.2, 12, 21.2)
            ..close(),
          st,
        );
        _circle(canvas, const Offset(12, 9.8), 2.6, st);

      case TaillimitIcons.tail:
        _line(canvas, const Offset(9.6, 8.4), const Offset(6.4, 15.6), st);
        _line(canvas, const Offset(15.6, 8.4), const Offset(12.4, 15.6), st);
        _line(canvas, const Offset(6.9, 11.1), const Offset(17.9, 11.1), st);
        _line(canvas, const Offset(6.1, 13.9), const Offset(17.1, 13.9), st);

      // —— 提醒 ——
      case TaillimitIcons.alert:
        // 全系统唯一三角轮廓——形状独占才能表达"最高优先级"
        canvas.drawPath(
          Path()
            ..moveTo(12, 3.9)
            ..lineTo(20.7, 18.9)
            ..arcToPoint(
              const Offset(3.3, 18.9),
              radius: const Radius.circular(1.05),
              clockwise: false,
            )
            ..close(),
          st,
        );
        _line(canvas, const Offset(12, 9.5), const Offset(12, 13.5), st);
        canvas.drawCircle(const Offset(12, 16.5), 1.05, fl);

      case TaillimitIcons.bell:
        canvas.drawPath(
          Path()
            ..moveTo(5.8, 18.5)
            ..lineTo(18.2, 18.5)
            ..lineTo(16.5, 16.6)
            ..lineTo(16.5, 11.7)
            ..arcToPoint(
              const Offset(5.8, 11.7),
              radius: const Radius.circular(6.2),
              clockwise: true,
            )
            ..lineTo(5.8, 16.6)
            ..close(),
          st,
        );
        canvas.drawArc(
          _rect(9.9, 18.6, 4.2, 3.0),
          0.0,
          3.14,
          false,
          st,
        );

      case TaillimitIcons.voice:
        canvas.drawPath(
          Path()
            ..moveTo(3.9, 9.4)
            ..lineTo(7.1, 9.4)
            ..lineTo(11.5, 5.6)
            ..lineTo(11.5, 18.4)
            ..lineTo(7.1, 14.6)
            ..lineTo(3.9, 14.6)
            ..cubicTo(3.4, 14.6, 3.0, 14.2, 3.0, 13.7)
            ..lineTo(3.0, 10.3)
            ..cubicTo(3.0, 9.8, 3.4, 9.4, 3.9, 9.4)
            ..close(),
          st,
        );
        canvas.drawArc(
            _circleRectAt(const Offset(17.6, 12), 3.1),
            -1.1, 2.2, false, st);
        canvas.drawArc(
            _circleRectAt(const Offset(20.1, 12), 5.8),
            -1.1, 2.2, false, st);

      // —— 操作 ——
      case TaillimitIcons.chevronRight:
        canvas.drawPath(
          Path()
            ..moveTo(9.4, 5.6)
            ..lineTo(15.8, 12)
            ..lineTo(9.4, 18.4),
          st,
        );

      case TaillimitIcons.close:
        _line(canvas, const Offset(6.6, 6.6), const Offset(17.4, 17.4), st);
        _line(canvas, const Offset(17.4, 6.6), const Offset(6.6, 17.4), st);

      case TaillimitIcons.plus:
        _line(canvas, const Offset(12, 5.4), const Offset(12, 18.6), st);
        _line(canvas, const Offset(5.4, 12), const Offset(18.6, 12), st);

      case TaillimitIcons.check:
        canvas.drawPath(
          Path()
            ..moveTo(5.4, 12.4)
            ..lineTo(9.8, 16.8)
            ..lineTo(18.6, 7.2),
          st,
        );

      // 未知名称静默降级为设置图标——不抛异常，避免一处拼写错误导致整页崩溃
      default:
        canvas.drawCircle(const Offset(12, 12), 3.1, st);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_IconPainter old) =>
      old.color != color || old.name != name;
}
