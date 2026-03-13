// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gst_dao.dart';

// ignore_for_file: type=lint
mixin _$GstDaoMixin on DatabaseAccessor<AppDatabase> {
  $GstClientsTableTable get gstClientsTable => attachedDatabase.gstClientsTable;
  $GstReturnsTableTable get gstReturnsTable => attachedDatabase.gstReturnsTable;
  GstDaoManager get managers => GstDaoManager(this);
}

class GstDaoManager {
  final _$GstDaoMixin _db;
  GstDaoManager(this._db);
  $$GstClientsTableTableTableManager get gstClientsTable =>
      $$GstClientsTableTableTableManager(
        _db.attachedDatabase,
        _db.gstClientsTable,
      );
  $$GstReturnsTableTableTableManager get gstReturnsTable =>
      $$GstReturnsTableTableTableManager(
        _db.attachedDatabase,
        _db.gstReturnsTable,
      );
}
