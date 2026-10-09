import '../../domain/entities/vehicle.dart';

/// 车牌输入工具：规范化、校验、省份简称表。
class PlateUtils {
  const PlateUtils._();

  /// 省份简称列表（含直辖市与自治区简称）。
  static const List<String> provinceChars = [
    '京', '津', '沪', '渝', '冀', '豫', '云', '辽', '黑', '湘',
    '皖', '鲁', '新', '苏', '浙', '赣', '鄂', '桂', '甘', '晋',
    '蒙', '陕', '吉', '闽', '贵', '粤', '青', '藏', '川', '宁', '琼',
  ];

  /// 规范化车牌：去空格/分隔符、转大写、去除"·"。
  static String normalize(String raw) {
    return raw
        .replaceAll(RegExp(r'[\s\-·.]'), '')
        .toUpperCase()
        .trim();
  }

  /// 校验车牌合法性。
  ///
  /// 规则：
  /// - 普通蓝牌：省份简称 + 字母 + 5 位（字母数字），共 7 位
  /// - 新能源绿牌：省份简称 + 字母 + 6 位，共 8 位
  /// - 警车/使领馆等特殊号牌本 MVP 不做校验
  static String? validate(String raw) {
    final plate = normalize(raw);
    if (plate.isEmpty) return '请输入车牌号';

    if (plate.length < 7) return '车牌号长度不足（至少 7 位）';
    if (plate.length > 8) return '车牌号长度超限（最多 8 位）';

    final first = plate.substring(0, 1);
    if (!provinceChars.contains(first)) {
      return '车牌首位应为省份简称，如"京""沪""川"';
    }

    final second = plate.substring(1, 2);
    if (!RegExp(r'^[A-Z]$').hasMatch(second)) {
      return '车牌第 2 位应为城市字母代码';
    }

    final body = plate.substring(2);
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(body)) {
      return '车牌仅可包含字母与数字';
    }

    if (plate.length == 7) {
      // 普通牌：不含 I/O，末位可为字母
      if (body.contains('I') || body.contains('O')) {
        return '车牌不含字母 I 与 O';
      }
    }

    return null;
  }

  /// 是否新能源号牌。
  static bool isNewEnergy(String raw) => _isNEV(normalize(raw));

  /// 车牌展示分段（用于号牌徽章渲染）：省份 + 字母 + 序号。
  static (String, String, String) segments(String raw) {
    final plate = normalize(raw);
    if (plate.length < 7) return (plate, '', '');
    return (
      plate.substring(0, 1),
      plate.substring(1, 2),
      plate.substring(2),
    );
  }

  /// 从车牌推断省份简称。
  static String provinceOf(String raw) {
    final plate = normalize(raw);
    if (plate.isEmpty) return '';
    final first = plate.substring(0, 1);
    return provinceChars.contains(first) ? first : '';
  }

  static bool _isNEV(String plate) {
    if (plate.length != 8) return false;
    final body = plate.substring(2);
    return body.startsWith('D') ||
        body.startsWith('F') ||
        body.endsWith('D') ||
        body.endsWith('F');
  }

  /// 构建 Vehicle（自动识别新能源、推断省份）。
  static Vehicle buildVehicle({
    required String id,
    required String plateRaw,
    required String boundCityId,
    String nickname = '',
  }) {
    final plate = normalize(plateRaw);
    return Vehicle(
      id: id,
      plate: plate,
      nickname: nickname,
      boundCityId: boundCityId,
    );
  }
}
