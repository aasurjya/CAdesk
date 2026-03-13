// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mca_dao.dart';

// ignore_for_file: type=lint
mixin _$McaDaoMixin on DatabaseAccessor<AppDatabase> {
  $MCAFilingsTableTable get mCAFilingsTable => attachedDatabase.mCAFilingsTable;
  McaDaoManager get managers => McaDaoManager(this);
}

class McaDaoManager {
  final _$McaDaoMixin _db;
  McaDaoManager(this._db);
  $$MCAFilingsTableTableTableManager get mCAFilingsTable =>
      $$MCAFilingsTableTableTableManager(
        _db.attachedDatabase,
        _db.mCAFilingsTable,
      );
}
