/// 尺寸与间距常量。
class AppSizes {
  const AppSizes._();

  /// 手机版触控目标最小尺寸。
  static const double touchTarget = 48;

  /// 车机版触控目标（驾驶场景需更大）。
  static const double carTouchTarget = 76;

  /// 手机/车机断点（逻辑宽度 dp）。
  static const double carBreakpoint = 840;

  /// 内容最大宽度（超宽屏居中约束）。
  static const double maxContentWidth = 1100;

  static const double cardRadius = 16;
  static const double chipRadius = 999;

  static const double gap4 = 4;
  static const double gap8 = 8;
  static const double gap12 = 12;
  static const double gap16 = 16;
  static const double gap24 = 24;
  static const double gap32 = 32;

  static const double pagePadding = 16;
  static const double carPagePadding = 32;

  /// 表单字段最小高度。
  static const double fieldHeight = 56;
}
