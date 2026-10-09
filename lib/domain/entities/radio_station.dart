/// 广播频道实体与分类。
///
/// 数据来源：中央广播电视总台（央广）CDN 公开直播流 + CRI 环球资讯广播。
/// 所有地址均为**实测可用**的 HLS（m3u8）流，不含任何第三方聚合源。
library;
/// 频道分类。
enum RadioCategory {
  /// 新闻资讯
  news('新闻', 'NEWS'),

  /// 经济财经
  finance('财经', 'FINANCE'),

  /// 音乐
  music('音乐', 'MUSIC'),

  /// 文艺
  culture('文艺', 'CULTURE'),

  /// 交通
  traffic('交通', 'TRAFFIC');

  const RadioCategory(this.label, this.tag);

  /// 中文标签。
  final String label;

  /// 用于界面排序与分组的短标识。
  final String tag;
}

/// 一个可播放的广播频道。
class RadioStation {
  const RadioStation({
    required this.id,
    required this.name,
    required this.category,
    required this.streamUrl,
    required this.frequency,
    this.description = '',
    this.isFallback = false,
  });

  /// 频道唯一标识，同时作为 HLS URL 中的路径片段。
  final String id;

  /// 频道名称，如「中国之声」。
  final String name;

  /// 所属分类。
  final RadioCategory category;

  /// HLS 直播流地址（m3u8）。
  final String streamUrl;

  /// 频率标识，如「FM 84.0」。
  final String frequency;

  /// 一句话简介。
  final String description;

  /// 是否为备用源。
  ///
  /// 主源失效时（如 CDN 域名调整）会自动切换到备用源，
  /// 界面上标注为「备用」，让用户知道当前播放的不是主链路。
  final bool isFallback;

  /// 播放此频道所需的 User-Agent。
  ///
  /// 部分 CDN 会拒绝空 UA 的请求，必须伪装成常规浏览器。
  static const String userAgent =
      'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/120.0 Mobile Safari/537.36';

  @override
  String toString() => 'RadioStation($name, $frequency)';
}

/// 官方免费广播频道目录。
///
/// **地址经过实测校验**（HTTP 200 且响应体含 `#EXTM3U`）。
/// 央广 CDN 域名或路径若变更，只需在此处更新，无需改动其他代码。
class RadioDirectory {
  const RadioDirectory._();

  /// 央广各频率直播流的基础地址。
  static const String _cnrBase = 'https://ngcdn001.cnr.cn/live';

  /// 主源（央广 CDN）。
  ///
  /// 格式：`_cnrBase/{频道拼音缩写}/index.m3u8`
  static const List<RadioStation> primary = <RadioStation>[
    RadioStation(
      id: 'zgzs',
      name: '中国之声',
      category: RadioCategory.news,
      frequency: 'FM 84.0',
      description: '中央广播电视总台第一套广播，全天候新闻与时事',
      streamUrl: '$_cnrBase/zgzs/index.m3u8',
    ),
    RadioStation(
      id: 'jjzs',
      name: '经济之声',
      category: RadioCategory.finance,
      frequency: 'FM 91.4',
      description: '财经资讯、证券行情与经济解读',
      streamUrl: '$_cnrBase/jjzs/index.m3u8',
    ),
    RadioStation(
      id: 'yyzs',
      name: '音乐之声',
      category: RadioCategory.music,
      frequency: 'FM 96.6',
      description: '流行音乐与音乐资讯',
      streamUrl: '$_cnrBase/yyzs/index.m3u8',
    ),
    RadioStation(
      id: 'zhzs',
      name: '中华之声',
      category: RadioCategory.culture,
      frequency: 'FM 87.4',
      description: '传统文化、历史人文与曲艺节目',
      streamUrl: '$_cnrBase/zhzs/index.m3u8',
    ),
    RadioStation(
      id: 'wyzs',
      name: '文艺之声',
      category: RadioCategory.culture,
      frequency: 'FM 97.4',
      description: '文学艺术、广播剧与戏曲节目',
      streamUrl: '$_cnrBase/wyzs/index.m3u8',
    ),
    RadioStation(
      id: 'cri905',
      name: '环球资讯',
      category: RadioCategory.news,
      frequency: 'FM 90.5',
      description: '中国国际广播电台，新闻与时事评论',
      streamUrl: 'http://sk.cri.cn/905.m3u8',
    ),
  ];

  /// 备用源。
  ///
  /// [RadioStation.primary] 全部失败后按顺序尝试。
  /// 当前央广未提供公开备用 CDN，这里保留空列表作为扩展位——
  /// 一旦官方开放，填入即可生效，无需改动播放逻辑。
  static const List<RadioStation> fallback = <RadioStation>[];

  /// 按分类分组的完整目录，用于界面渲染。
  static Map<RadioCategory, List<RadioStation>> get grouped {
    final Map<RadioCategory, List<RadioStation>> result =
        <RadioCategory, List<RadioStation>>{};
    for (final RadioStation station in all) {
      result.putIfAbsent(station.category, () => <RadioStation>[]).add(station);
    }
    return result;
  }

  /// 主源 + 备用源。
  static List<RadioStation> get all => <RadioStation>[...primary, ...fallback];

  /// 按 id 查找频道，找不到返回 null。
  ///
  /// 恢复上次收听的持久化数据时会用到，因此**不能**对未知 id 抛异常。
  static RadioStation? byId(String id) {
    for (final RadioStation station in all) {
      if (station.id == id) return station;
    }
    return null;
  }
}
