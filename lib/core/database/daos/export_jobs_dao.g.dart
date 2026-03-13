// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_jobs_dao.dart';

// ignore_for_file: type=lint
mixin _$ExportJobsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ExportJobsTableTable get exportJobsTable => attachedDatabase.exportJobsTable;
  ExportJobsDaoManager get managers => ExportJobsDaoManager(this);
}

class ExportJobsDaoManager {
  final _$ExportJobsDaoMixin _db;
  ExportJobsDaoManager(this._db);
  $$ExportJobsTableTableTableManager get exportJobsTable =>
      $$ExportJobsTableTableTableManager(
        _db.attachedDatabase,
        _db.exportJobsTable,
      );
}
