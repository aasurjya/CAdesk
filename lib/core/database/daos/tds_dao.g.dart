// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tds_dao.dart';

// ignore_for_file: type=lint
mixin _$TdsDaoMixin on DatabaseAccessor<AppDatabase> {
  $TdsReturnsTableTable get tdsReturnsTable => attachedDatabase.tdsReturnsTable;
  $TdsChallansTableTable get tdsChallansTable =>
      attachedDatabase.tdsChallansTable;
  TdsDaoManager get managers => TdsDaoManager(this);
}

class TdsDaoManager {
  final _$TdsDaoMixin _db;
  TdsDaoManager(this._db);
  $$TdsReturnsTableTableTableManager get tdsReturnsTable =>
      $$TdsReturnsTableTableTableManager(
        _db.attachedDatabase,
        _db.tdsReturnsTable,
      );
  $$TdsChallansTableTableTableManager get tdsChallansTable =>
      $$TdsChallansTableTableTableManager(
        _db.attachedDatabase,
        _db.tdsChallansTable,
      );
}
