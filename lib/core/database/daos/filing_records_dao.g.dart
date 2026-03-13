// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filing_records_dao.dart';

// ignore_for_file: type=lint
mixin _$FilingRecordsDaoMixin on DatabaseAccessor<AppDatabase> {
  $FilingRecordsTableTable get filingRecordsTable =>
      attachedDatabase.filingRecordsTable;
  FilingRecordsDaoManager get managers => FilingRecordsDaoManager(this);
}

class FilingRecordsDaoManager {
  final _$FilingRecordsDaoMixin _db;
  FilingRecordsDaoManager(this._db);
  $$FilingRecordsTableTableTableManager get filingRecordsTable =>
      $$FilingRecordsTableTableTableManager(
        _db.attachedDatabase,
        _db.filingRecordsTable,
      );
}
