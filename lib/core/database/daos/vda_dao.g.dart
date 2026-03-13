// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vda_dao.dart';

// ignore_for_file: type=lint
mixin _$VdaDaoMixin on DatabaseAccessor<AppDatabase> {
  $VdaRecordsTableTable get vdaRecordsTable => attachedDatabase.vdaRecordsTable;
  VdaDaoManager get managers => VdaDaoManager(this);
}

class VdaDaoManager {
  final _$VdaDaoMixin _db;
  VdaDaoManager(this._db);
  $$VdaRecordsTableTableTableManager get vdaRecordsTable =>
      $$VdaRecordsTableTableTableManager(
        _db.attachedDatabase,
        _db.vdaRecordsTable,
      );
}
