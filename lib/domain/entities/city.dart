/// 城市实体。
class City {
  const City({
    required this.id,
    required this.name,
    this.province = '',
    this.provinceAbbr = '',
    this.hasRestriction = true,
  });

  /// 行政区码，如 110000（北京）、510100（成都）。
  final String id;

  /// 城市名，如"北京"。
  final String name;

  /// 所属省份名，如"北京市"。
  final String province;

  /// 省份简称（车牌前缀字），如"京"。
  final String provinceAbbr;

  /// 是否执行限行政策（数据源城市覆盖列表下发）。
  final bool hasRestriction;

  City copyWith({
    String? id,
    String? name,
    String? province,
    String? provinceAbbr,
    bool? hasRestriction,
  }) =>
      City(
        id: id ?? this.id,
        name: name ?? this.name,
        province: province ?? this.province,
        provinceAbbr: provinceAbbr ?? this.provinceAbbr,
        hasRestriction: hasRestriction ?? this.hasRestriction,
      );

  Map<String, Object?> toMap() => <String, Object?>{
        'id': id,
        'name': name,
        'province': province,
        'provinceAbbr': provinceAbbr,
        'hasRestriction': hasRestriction,
      };

  factory City.fromMap(Map<Object?, Object?> m) => City(
        id: m['id'] as String? ?? '',
        name: m['name'] as String? ?? '',
        province: m['province'] as String? ?? '',
        provinceAbbr: m['provinceAbbr'] as String? ?? '',
        hasRestriction: m['hasRestriction'] != false,
      );

  @override
  bool operator ==(Object other) => other is City && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'City($id $name)';
}

/// 常用限行城市（Mock 数据源与引导页备选列表）。
const List<City> kKnownRestrictionCities = [
  City(id: '110000', name: '北京', province: '北京市', provinceAbbr: '京'),
  City(id: '120000', name: '天津', province: '天津市', provinceAbbr: '津'),
  City(id: '310000', name: '上海', province: '上海市', provinceAbbr: '沪'),
  City(id: '510100', name: '成都', province: '四川省', provinceAbbr: '川'),
  City(id: '440100', name: '广州', province: '广东省', provinceAbbr: '粤'),
  City(id: '440300', name: '深圳', province: '广东省', provinceAbbr: '粤'),
  City(id: '330100', name: '杭州', province: '浙江省', provinceAbbr: '浙'),
  City(id: '610100', name: '西安', province: '陕西省', provinceAbbr: '陕'),
  City(id: '410100', name: '郑州', province: '河南省', provinceAbbr: '豫'),
  City(id: '420100', name: '武汉', province: '湖北省', provinceAbbr: '鄂'),
  City(id: '130100', name: '石家庄', province: '河北省', provinceAbbr: '冀'),
  City(id: '140100', name: '太原', province: '山西省', provinceAbbr: '晋'),
  City(id: '220100', name: '长春', province: '吉林省', provinceAbbr: '吉'),
  City(id: '230100', name: '哈尔滨', province: '黑龙江省', provinceAbbr: '黑'),
  City(id: '360100', name: '南昌', province: '江西省', provinceAbbr: '赣'),
  City(id: '520100', name: '贵阳', province: '贵州省', provinceAbbr: '贵'),
  City(id: '620100', name: '兰州', province: '甘肃省', provinceAbbr: '甘'),
];
