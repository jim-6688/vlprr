import '../entities/restriction_day.dart';

/// 限行数据仓库抽象：RestrictionDay 快照的存取。
abstract class RestrictionRepository {
  /// 取某城市某日快照（缓存优先由上层装饰器保证）。
  Future<RestrictionDay?> getDay(String cityId, DateTime date);

  /// 监听某城市某日快照。
  Stream<RestrictionDay?> watchDay(String cityId, DateTime date);

  /// 取区间 [start, start+days) 的快照列表。
  Future<List<RestrictionDay>> getRange(String cityId, DateTime start, int days);

  /// 写入/更新快照。
  Future<void> upsertDays(List<RestrictionDay> days);

  /// 上次全量同步时间。
  Future<DateTime?> lastSyncAt();

  Future<void> markSynced(DateTime at);
}
