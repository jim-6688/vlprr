import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/city_dao.dart';
import 'daos/restriction_dao.dart';
import 'daos/setting_dao.dart';
import 'daos/vehicle_dao.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// TailLimit 本地数据库（drift/SQLite）。
///
/// 缓存策略：限行快照按 (cityId, dateIso) 主键覆盖写入，
/// 由 [RestrictionDayRows.expiresAt] 控制有效性，配合 CachedSource 回退链。
@DriftDatabase(
  tables: [
    VehicleRows,
    MyCityRows,
    CityCacheRows,
    RestrictionDayRows,
    ReminderConfigRows,
    ScheduledRemindersTable,
    AppSettingRows,
  ],
  daos: [VehicleDao, CityDao, RestrictionDao, SettingDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// 测试用：内存库。
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // MVP：首个版本，后续升级在此按版本增量迁移
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'tail_limit.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
