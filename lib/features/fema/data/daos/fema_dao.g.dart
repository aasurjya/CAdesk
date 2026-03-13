// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fema_dao.dart';

// ignore_for_file: type=lint
mixin _$FemaDaoMixin on DatabaseAccessor<AppDatabase> {
  $FemaFilingsTableTable get femaFilingsTable =>
      attachedDatabase.femaFilingsTable;
  FemaDaoManager get managers => FemaDaoManager(this);
}

class FemaDaoManager {
  final _$FemaDaoMixin _db;
  FemaDaoManager(this._db);
  $$FemaFilingsTableTableTableManager get femaFilingsTable =>
      $$FemaFilingsTableTableTableManager(
        _db.attachedDatabase,
        _db.femaFilingsTable,
      );
}
