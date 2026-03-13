// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itr_filings_dao.dart';

// ignore_for_file: type=lint
mixin _$ItrFilingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ItrFilingsTableTable get itrFilingsTable => attachedDatabase.itrFilingsTable;
  ItrFilingsDaoManager get managers => ItrFilingsDaoManager(this);
}

class ItrFilingsDaoManager {
  final _$ItrFilingsDaoMixin _db;
  ItrFilingsDaoManager(this._db);
  $$ItrFilingsTableTableTableManager get itrFilingsTable =>
      $$ItrFilingsTableTableTableManager(
        _db.attachedDatabase,
        _db.itrFilingsTable,
      );
}
