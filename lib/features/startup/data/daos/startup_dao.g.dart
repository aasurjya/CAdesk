// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'startup_dao.dart';

// ignore_for_file: type=lint
mixin _$StartupDaoMixin on DatabaseAccessor<AppDatabase> {
  $StartupRecordsTableTable get startupRecordsTable =>
      attachedDatabase.startupRecordsTable;
  StartupDaoManager get managers => StartupDaoManager(this);
}

class StartupDaoManager {
  final _$StartupDaoMixin _db;
  StartupDaoManager(this._db);
  $$StartupRecordsTableTableTableManager get startupRecordsTable =>
      $$StartupRecordsTableTableTableManager(
        _db.attachedDatabase,
        _db.startupRecordsTable,
      );
}
