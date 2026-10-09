import 'package:drift/drift.dart';

import '../../../../domain/entities/vehicle.dart';
import '../app_database.dart';
import '../tables.dart';

part 'vehicle_dao.g.dart';

/// 车辆数据访问对象。
@DriftAccessor(tables: [VehicleRows])
class VehicleDao extends DatabaseAccessor<AppDatabase> with _$VehicleDaoMixin {
  VehicleDao(super.db);

  Stream<List<Vehicle>> watchAll() {
    return (select(vehicleRows)
          ..orderBy([
            (t) => OrderingTerm.desc(t.isDefault),
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .watch()
        .map((rows) => rows.map(_toEntity).toList());
  }

  Future<List<Vehicle>> getAll() async {
    final rows = await (select(vehicleRows)
          ..orderBy([
            (t) => OrderingTerm.desc(t.isDefault),
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .get();
    return rows.map(_toEntity).toList();
  }

  Future<Vehicle?> findByPlate(String plate) async {
    final row = await (select(vehicleRows)..where((t) => t.plate.equals(plate)))
        .getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  Future<void> upsert(Vehicle v) async {
    await into(vehicleRows).insertOnConflictUpdate(
      VehicleRowsCompanion.insert(
        id: v.id,
        plate: v.plate,
        nickname: Value(v.nickname),
        boundCityId: v.boundCityId,
        isActive: Value(v.isActive),
        isDefault: Value(v.isDefault),
        createdAt: Value(v.createdAt ?? DateTime.now()),
      ),
    );
  }

  Future<void> deleteById(String id) async {
    await (delete(vehicleRows)..where((t) => t.id.equals(id))).go();
  }

  /// 设为默认：先清除所有默认，再设置目标。
  Future<void> setDefault(String id) async {
    await transaction(() async {
      await update(vehicleRows).write(const VehicleRowsCompanion(
        isDefault: Value(false),
      ));
      await (update(vehicleRows)..where((t) => t.id.equals(id)))
          .write(const VehicleRowsCompanion(isDefault: Value(true)));
    });
  }

  Vehicle _toEntity(VehicleRow row) => Vehicle(
        id: row.id,
        plate: row.plate,
        nickname: row.nickname,
        boundCityId: row.boundCityId,
        isActive: row.isActive,
        isDefault: row.isDefault,
        createdAt: row.createdAt,
      );
}
