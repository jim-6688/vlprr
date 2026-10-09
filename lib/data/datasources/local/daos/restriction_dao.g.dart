// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restriction_dao.dart';

// ignore_for_file: type=lint
mixin _$RestrictionDaoMixin on DatabaseAccessor<AppDatabase> {
  $RestrictionDayRowsTable get restrictionDayRows =>
      attachedDatabase.restrictionDayRows;
  $AppSettingRowsTable get appSettingRows => attachedDatabase.appSettingRows;
  RestrictionDaoManager get managers => RestrictionDaoManager(this);
}

class RestrictionDaoManager {
  final _$RestrictionDaoMixin _db;
  RestrictionDaoManager(this._db);
  $$RestrictionDayRowsTableTableManager get restrictionDayRows =>
      $$RestrictionDayRowsTableTableManager(
          _db.attachedDatabase, _db.restrictionDayRows);
  $$AppSettingRowsTableTableManager get appSettingRows =>
      $$AppSettingRowsTableTableManager(
          _db.attachedDatabase, _db.appSettingRows);
}
