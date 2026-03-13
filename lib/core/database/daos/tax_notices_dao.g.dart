// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_notices_dao.dart';

// ignore_for_file: type=lint
mixin _$TaxNoticesDaoMixin on DatabaseAccessor<AppDatabase> {
  $TaxNoticesTableTable get taxNoticesTable => attachedDatabase.taxNoticesTable;
  TaxNoticesDaoManager get managers => TaxNoticesDaoManager(this);
}

class TaxNoticesDaoManager {
  final _$TaxNoticesDaoMixin _db;
  TaxNoticesDaoManager(this._db);
  $$TaxNoticesTableTableTableManager get taxNoticesTable =>
      $$TaxNoticesTableTableTableManager(
        _db.attachedDatabase,
        _db.taxNoticesTable,
      );
}
