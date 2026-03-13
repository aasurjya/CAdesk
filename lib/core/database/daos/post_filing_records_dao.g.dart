// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_filing_records_dao.dart';

// ignore_for_file: type=lint
mixin _$PostFilingRecordsDaoMixin on DatabaseAccessor<AppDatabase> {
  $PostFilingRecordsTableTable get postFilingRecordsTable =>
      attachedDatabase.postFilingRecordsTable;
  PostFilingRecordsDaoManager get managers => PostFilingRecordsDaoManager(this);
}

class PostFilingRecordsDaoManager {
  final _$PostFilingRecordsDaoMixin _db;
  PostFilingRecordsDaoManager(this._db);
  $$PostFilingRecordsTableTableTableManager get postFilingRecordsTable =>
      $$PostFilingRecordsTableTableTableManager(
        _db.attachedDatabase,
        _db.postFilingRecordsTable,
      );
}
