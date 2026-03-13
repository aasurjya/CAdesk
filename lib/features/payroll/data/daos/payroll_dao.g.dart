// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payroll_dao.dart';

// ignore_for_file: type=lint
mixin _$PayrollDaoMixin on DatabaseAccessor<AppDatabase> {
  $PayrollEntriesTableTable get payrollEntriesTable =>
      attachedDatabase.payrollEntriesTable;
  PayrollDaoManager get managers => PayrollDaoManager(this);
}

class PayrollDaoManager {
  final _$PayrollDaoMixin _db;
  PayrollDaoManager(this._db);
  $$PayrollEntriesTableTableTableManager get payrollEntriesTable =>
      $$PayrollEntriesTableTableTableManager(
        _db.attachedDatabase,
        _db.payrollEntriesTable,
      );
}
