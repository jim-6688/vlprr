import '../../domain/entities/restriction_day.dart';
import '../../domain/repositories/restriction_repository.dart';
import '../datasources/local/daos/restriction_dao.dart';

/// 限行数据仓库实现（强类型）。
class RestrictionRepositoryImpl implements RestrictionRepository {
  RestrictionRepositoryImpl(this._dao);

  final RestrictionDao _dao;

  @override
  Future<RestrictionDay?> getDay(String cityId, DateTime date) =>
      _dao.getDay(cityId, date);

  @override
  Stream<RestrictionDay?> watchDay(String cityId, DateTime date) =>
      _dao.watchDay(cityId, date);

  @override
  Future<List<RestrictionDay>> getRange(
    String cityId,
    DateTime start,
    int days,
  ) =>
      _dao.getRange(cityId, start, days);

  @override
  Future<void> upsertDays(List<RestrictionDay> days) => _dao.upsertDays(days);

  @override
  Future<DateTime?> lastSyncAt() => _dao.lastSyncAt();

  @override
  Future<void> markSynced(DateTime at) => _dao.markSynced(at);
}
