// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_dao.dart';

// ignore_for_file: type=lint
mixin _$VehicleDaoMixin on DatabaseAccessor<AppDatabase> {
  $VehicleRowsTable get vehicleRows => attachedDatabase.vehicleRows;
  VehicleDaoManager get managers => VehicleDaoManager(this);
}

class VehicleDaoManager {
  final _$VehicleDaoMixin _db;
  VehicleDaoManager(this._db);
  $$VehicleRowsTableTableManager get vehicleRows =>
      $$VehicleRowsTableTableManager(_db.attachedDatabase, _db.vehicleRows);
}
