// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'msme_dao.dart';

// ignore_for_file: type=lint
mixin _$MsmeDaoMixin on DatabaseAccessor<AppDatabase> {
  $MsmeRecordsTableTable get msmeRecordsTable =>
      attachedDatabase.msmeRecordsTable;
  MsmeDaoManager get managers => MsmeDaoManager(this);
}

class MsmeDaoManager {
  final _$MsmeDaoMixin _db;
  MsmeDaoManager(this._db);
  $$MsmeRecordsTableTableTableManager get msmeRecordsTable =>
      $$MsmeRecordsTableTableTableManager(
        _db.attachedDatabase,
        _db.msmeRecordsTable,
      );
}
