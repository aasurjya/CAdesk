// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'llp_dao.dart';

// ignore_for_file: type=lint
mixin _$LlpDaoMixin on DatabaseAccessor<AppDatabase> {
  $LlpFilingsTableTable get llpFilingsTable => attachedDatabase.llpFilingsTable;
  LlpDaoManager get managers => LlpDaoManager(this);
}

class LlpDaoManager {
  final _$LlpDaoMixin _db;
  LlpDaoManager(this._db);
  $$LlpFilingsTableTableTableManager get llpFilingsTable =>
      $$LlpFilingsTableTableTableManager(
        _db.attachedDatabase,
        _db.llpFilingsTable,
      );
}
