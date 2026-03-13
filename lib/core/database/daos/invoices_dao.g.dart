// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoices_dao.dart';

// ignore_for_file: type=lint
mixin _$InvoicesDaoMixin on DatabaseAccessor<AppDatabase> {
  $InvoicesTableTable get invoicesTable => attachedDatabase.invoicesTable;
  $PaymentsTableTable get paymentsTable => attachedDatabase.paymentsTable;
  InvoicesDaoManager get managers => InvoicesDaoManager(this);
}

class InvoicesDaoManager {
  final _$InvoicesDaoMixin _db;
  InvoicesDaoManager(this._db);
  $$InvoicesTableTableTableManager get invoicesTable =>
      $$InvoicesTableTableTableManager(_db.attachedDatabase, _db.invoicesTable);
  $$PaymentsTableTableTableManager get paymentsTable =>
      $$PaymentsTableTableTableManager(_db.attachedDatabase, _db.paymentsTable);
}
