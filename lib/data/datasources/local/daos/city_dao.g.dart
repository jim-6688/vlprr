// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_dao.dart';

// ignore_for_file: type=lint
mixin _$CityDaoMixin on DatabaseAccessor<AppDatabase> {
  $MyCityRowsTable get myCityRows => attachedDatabase.myCityRows;
  $CityCacheRowsTable get cityCacheRows => attachedDatabase.cityCacheRows;
  $AppSettingRowsTable get appSettingRows => attachedDatabase.appSettingRows;
  CityDaoManager get managers => CityDaoManager(this);
}

class CityDaoManager {
  final _$CityDaoMixin _db;
  CityDaoManager(this._db);
  $$MyCityRowsTableTableManager get myCityRows =>
      $$MyCityRowsTableTableManager(_db.attachedDatabase, _db.myCityRows);
  $$CityCacheRowsTableTableManager get cityCacheRows =>
      $$CityCacheRowsTableTableManager(_db.attachedDatabase, _db.cityCacheRows);
  $$AppSettingRowsTableTableManager get appSettingRows =>
      $$AppSettingRowsTableTableManager(
          _db.attachedDatabase, _db.appSettingRows);
}
