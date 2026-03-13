// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rpa_dao.dart';

// ignore_for_file: type=lint
mixin _$RpaDaoMixin on DatabaseAccessor<AppDatabase> {
  $RpaTasksTableTable get rpaTasksTable => attachedDatabase.rpaTasksTable;
  RpaDaoManager get managers => RpaDaoManager(this);
}

class RpaDaoManager {
  final _$RpaDaoMixin _db;
  RpaDaoManager(this._db);
  $$RpaTasksTableTableTableManager get rpaTasksTable =>
      $$RpaTasksTableTableTableManager(_db.attachedDatabase, _db.rpaTasksTable);
}
