// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_dao.dart';

// ignore_for_file: type=lint
mixin _$SyncDaoMixin on DatabaseAccessor<AppDatabase> {
  $SyncQueueTableTable get syncQueueTable => attachedDatabase.syncQueueTable;
  $SyncConflictsTableTable get syncConflictsTable =>
      attachedDatabase.syncConflictsTable;
  SyncDaoManager get managers => SyncDaoManager(this);
}

class SyncDaoManager {
  final _$SyncDaoMixin _db;
  SyncDaoManager(this._db);
  $$SyncQueueTableTableTableManager get syncQueueTable =>
      $$SyncQueueTableTableTableManager(
        _db.attachedDatabase,
        _db.syncQueueTable,
      );
  $$SyncConflictsTableTableTableManager get syncConflictsTable =>
      $$SyncConflictsTableTableTableManager(
        _db.attachedDatabase,
        _db.syncConflictsTable,
      );
}
