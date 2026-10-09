/// 车辆实体：绑定的车牌号信息。
class Vehicle {
  const Vehicle({
    required this.id,
    required this.plate,
    this.nickname = '',
    required this.boundCityId,
    this.isActive = true,
    this.isDefault = false,
    this.createdAt,
  });

  /// 本地唯一 ID（UUID）。
  final String id;

  /// 规范化完整车牌，如 "京A12345" / "川AD12345"（绿牌 8 位）。
  final String plate;

  /// 备注名，如"我的车"、"家里油车"。
  final String nickname;

  /// 绑定城市 ID（按该城市限行政策判定）。
  final String boundCityId;

  /// 是否启用提醒（停用的车不参与判定与排程）。
  final bool isActive;

  /// 是否默认车辆（首页优先展示）。
  final bool isDefault;

  final DateTime? createdAt;

  /// 是否新能源号牌（绿牌自动识别）。
  bool get isNEV => _isNEV(plate);

  /// 展示名：备注优先，否则车牌。
  String get displayName => nickname.isNotEmpty ? nickname : plate;

  Vehicle copyWith({
    String? id,
    String? plate,
    String? nickname,
    String? boundCityId,
    bool? isActive,
    bool? isDefault,
    DateTime? createdAt,
  }) =>
      Vehicle(
        id: id ?? this.id,
        plate: plate ?? this.plate,
        nickname: nickname ?? this.nickname,
        boundCityId: boundCityId ?? this.boundCityId,
        isActive: isActive ?? this.isActive,
        isDefault: isDefault ?? this.isDefault,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) => other is Vehicle && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Vehicle($id $plate@$boundCityId)';
}

bool _isNEV(String plate) {
  final p = plate.replaceAll(RegExp(r'[\s\-·]'), '').toUpperCase();
  if (p.length == 8) {
    final body = p.substring(2);
    return body.startsWith('D') ||
        body.startsWith('F') ||
        body.endsWith('D') ||
        body.endsWith('F');
  }
  return false;
}
