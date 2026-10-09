import '../value_objects/time_window.dart';

/// 判定结果类别。
enum VerdictKind {
  /// 受限（当日限行）。
  restricted,

  /// 不受限（尾号未命中 / 当天无限行措施）。
  notRestricted,

  /// 新能源豁免（政策豁免，展示"绿牌不限行"）。
  exemptNewEnergy,

  /// 非本地牌仅区域限行判定为不限（本地牌通行自由）。
  exemptLocalPlate,
}

/// 单车单城单日的限行判定结果。
class RestrictionVerdict {
  const RestrictionVerdict({
    required this.vehicleId,
    required this.plate,
    required this.cityId,
    required this.date,
    required this.kind,
    this.reasonText = '',
    this.windows = const [],
    this.tailsText = '',
    this.areaText = '',
  });

  final String vehicleId;
  final String plate;
  final String cityId;
  final DateTime date;
  final VerdictKind kind;

  /// 判定说明（人话文案）。
  final String reasonText;

  /// 受限时段。
  final List<TimeWindow> windows;

  /// 当日限行尾号文本。
  final String tailsText;

  final String areaText;

  bool get isRestricted => kind == VerdictKind.restricted;

  RestrictionVerdict copyWith({
    String? vehicleId,
    String? plate,
    String? cityId,
    DateTime? date,
    VerdictKind? kind,
    String? reasonText,
    List<TimeWindow>? windows,
    String? tailsText,
    String? areaText,
  }) =>
      RestrictionVerdict(
        vehicleId: vehicleId ?? this.vehicleId,
        plate: plate ?? this.plate,
        cityId: cityId ?? this.cityId,
        date: date ?? this.date,
        kind: kind ?? this.kind,
        reasonText: reasonText ?? this.reasonText,
        windows: windows ?? this.windows,
        tailsText: tailsText ?? this.tailsText,
        areaText: areaText ?? this.areaText,
      );
  @override
  String toString() => 'Verdict($plate@$cityId $date ${kind.name})';
}

/// 领域服务判定常量文案。
class VerdictText {
  static const String restricted = '今日限行，请合理安排出行';
  static const String notRestricted = '今日不限行';
  static const String exemptNewEnergy = '新能源号牌不限行';
  static const String noMeasure = '当日无限行措施';
  static const String localFree = '本地号牌不限行';
}
