// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting_dao.dart';

// ignore_for_file: type=lint
mixin _$SettingDaoMixin on DatabaseAccessor<AppDatabase> {
  $ReminderConfigRowsTable get reminderConfigRows =>
      attachedDatabase.reminderConfigRows;
  $ScheduledRemindersTableTable get scheduledRemindersTable =>
      attachedDatabase.scheduledRemindersTable;
  SettingDaoManager get managers => SettingDaoManager(this);
}

class SettingDaoManager {
  final _$SettingDaoMixin _db;
  SettingDaoManager(this._db);
  $$ReminderConfigRowsTableTableManager get reminderConfigRows =>
      $$ReminderConfigRowsTableTableManager(
          _db.attachedDatabase, _db.reminderConfigRows);
  $$ScheduledRemindersTableTableTableManager get scheduledRemindersTable =>
      $$ScheduledRemindersTableTableTableManager(
          _db.attachedDatabase, _db.scheduledRemindersTable);
}
