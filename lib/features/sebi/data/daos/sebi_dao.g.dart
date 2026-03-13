// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sebi_dao.dart';

// ignore_for_file: type=lint
mixin _$SebiDaoMixin on DatabaseAccessor<AppDatabase> {
  $SebiComplianceTableTable get sebiComplianceTable =>
      attachedDatabase.sebiComplianceTable;
  SebiDaoManager get managers => SebiDaoManager(this);
}

class SebiDaoManager {
  final _$SebiDaoMixin _db;
  SebiDaoManager(this._db);
  $$SebiComplianceTableTableTableManager get sebiComplianceTable =>
      $$SebiComplianceTableTableTableManager(
        _db.attachedDatabase,
        _db.sebiComplianceTable,
      );
}
