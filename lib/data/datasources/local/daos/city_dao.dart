import 'package:drift/drift.dart';

import '../../../../domain/entities/city.dart';
import '../app_database.dart';
import '../tables.dart';

part 'city_dao.g.dart';

/// 城市数据访问对象：我的城市（关注城市）+ 数据源城市覆盖缓存 + 应用设置。
@DriftAccessor(tables: [MyCityRows, CityCacheRows, AppSettingRows])
class CityDao extends DatabaseAccessor<AppDatabase> with _$CityDaoMixin {
  CityDao(super.db);

  static const String onboardingKey = 'onboarding_completed';

  // —— 我的城市 ——

  Stream<List<City>> watchMyCities() {
    return (select(myCityRows)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch()
        .map((rows) => rows.map(_toEntity).toList());
  }

  Future<List<City>> getMyCities() async {
    final rows = await (select(myCityRows)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    return rows.map(_toEntity).toList();
  }

  Future<City?> getCity(String id) async {
    final row = await (select(myCityRows)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  Future<void> addMyCity(City city) async {
    final count = await myCitiesCount();
    await into(myCityRows).insertOnConflictUpdate(
      MyCityRowsCompanion.insert(
        id: city.id,
        name: city.name,
        province: Value(city.province),
        provinceAbbr: Value(city.provinceAbbr),
        hasRestriction: Value(city.hasRestriction),
        sortOrder: Value(count),
      ),
    );
  }

  Future<void> removeMyCity(String id) async {
    await (delete(myCityRows)..where((t) => t.id.equals(id))).go();
  }

  Future<int> myCitiesCount() async {
    final countExp = myCityRows.id.count();
    final query = selectOnly(myCityRows)..addColumns([countExp]);
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  // —— 城市覆盖缓存 ——

  Future<void> upsertCitiesCache(List<City> cities) async {
    await batch((b) {
      for (final c in cities) {
        b.insert(
          cityCacheRows,
          CityCacheRowsCompanion.insert(
            id: c.id,
            name: c.name,
            province: Value(c.province),
            provinceAbbr: Value(c.provinceAbbr),
          ),
          onConflict: DoUpdate((_) => CityCacheRowsCompanion(
                name: Value(c.name),
                province: Value(c.province),
                provinceAbbr: Value(c.provinceAbbr),
              )),
        );
      }
    });
  }

  Future<List<City>> searchCitiesCache(String query) async {
    final q = query.trim();
    final sel = select(cityCacheRows);
    final prepared = q.isEmpty
        ? sel
        : (sel
          ..where((t) =>
              t.name.like('%$q%') |
              t.province.like('%$q%') |
              t.provinceAbbr.equals(q)));
    final rows = await prepared.get();
    return rows
        .map((r) => City(
              id: r.id,
              name: r.name,
              province: r.province,
              provinceAbbr: r.provinceAbbr,
            ))
        .toList();
  }

  // —— 应用设置 ——

  Future<String?> getSetting(String key) async {
    final row =
        await (select(appSettingRows)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(appSettingRows).insertOnConflictUpdate(
      AppSettingRowsCompanion.insert(key: key, value: value),
    );
  }

  Stream<bool> watchOnboardingCompleted() {
    return (select(appSettingRows)..where((t) => t.key.equals(onboardingKey)))
        .watchSingleOrNull()
        .map((row) => row?.value == 'true');
  }

  Future<void> markOnboardingCompleted() => setSetting(onboardingKey, 'true');

  City _toEntity(MyCityRow row) => City(
        id: row.id,
        name: row.name,
        province: row.province,
        provinceAbbr: row.provinceAbbr,
        hasRestriction: row.hasRestriction,
      );
}
