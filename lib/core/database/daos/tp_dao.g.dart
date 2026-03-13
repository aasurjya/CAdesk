// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tp_dao.dart';

// ignore_for_file: type=lint
mixin _$TpDaoMixin on DatabaseAccessor<AppDatabase> {
  $TpTransactionsTableTable get tpTransactionsTable =>
      attachedDatabase.tpTransactionsTable;
  TpDaoManager get managers => TpDaoManager(this);
}

class TpDaoManager {
  final _$TpDaoMixin _db;
  TpDaoManager(this._db);
  $$TpTransactionsTableTableTableManager get tpTransactionsTable =>
      $$TpTransactionsTableTableTableManager(
        _db.attachedDatabase,
        _db.tpTransactionsTable,
      );
}
