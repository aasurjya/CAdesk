// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practice_dao.dart';

// ignore_for_file: type=lint
mixin _$PracticeDaoMixin on DatabaseAccessor<AppDatabase> {
  $PracticeWorkflowsTableTable get practiceWorkflowsTable =>
      attachedDatabase.practiceWorkflowsTable;
  PracticeDaoManager get managers => PracticeDaoManager(this);
}

class PracticeDaoManager {
  final _$PracticeDaoMixin _db;
  PracticeDaoManager(this._db);
  $$PracticeWorkflowsTableTableTableManager get practiceWorkflowsTable =>
      $$PracticeWorkflowsTableTableTableManager(
        _db.attachedDatabase,
        _db.practiceWorkflowsTable,
      );
}
