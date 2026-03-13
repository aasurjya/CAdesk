// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_entries_dao.dart';

// ignore_for_file: type=lint
mixin _$TimeEntriesDaoMixin on DatabaseAccessor<AppDatabase> {
  $TimeEntriesTableTable get timeEntriesTable =>
      attachedDatabase.timeEntriesTable;
  TimeEntriesDaoManager get managers => TimeEntriesDaoManager(this);
}

class TimeEntriesDaoManager {
  final _$TimeEntriesDaoMixin _db;
  TimeEntriesDaoManager(this._db);
  $$TimeEntriesTableTableTableManager get timeEntriesTable =>
      $$TimeEntriesTableTableTableManager(
        _db.attachedDatabase,
        _db.timeEntriesTable,
      );
}
