// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ocr_dao.dart';

// ignore_for_file: type=lint
mixin _$OcrDaoMixin on DatabaseAccessor<AppDatabase> {
  $OcrJobsTableTable get ocrJobsTable => attachedDatabase.ocrJobsTable;
  OcrDaoManager get managers => OcrDaoManager(this);
}

class OcrDaoManager {
  final _$OcrDaoMixin _db;
  OcrDaoManager(this._db);
  $$OcrJobsTableTableTableManager get ocrJobsTable =>
      $$OcrJobsTableTableTableManager(_db.attachedDatabase, _db.ocrJobsTable);
}
