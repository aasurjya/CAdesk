// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_dao.dart';

// ignore_for_file: type=lint
mixin _$DashboardDaoMixin on DatabaseAccessor<AppDatabase> {
  $ClientsTableTable get clientsTable => attachedDatabase.clientsTable;
  $TasksTableTable get tasksTable => attachedDatabase.tasksTable;
  $ItrFilingsTableTable get itrFilingsTable => attachedDatabase.itrFilingsTable;
  $GstReturnsTableTable get gstReturnsTable => attachedDatabase.gstReturnsTable;
  $TdsReturnsTableTable get tdsReturnsTable => attachedDatabase.tdsReturnsTable;
  $InvoicesTableTable get invoicesTable => attachedDatabase.invoicesTable;
  DashboardDaoManager get managers => DashboardDaoManager(this);
}

class DashboardDaoManager {
  final _$DashboardDaoMixin _db;
  DashboardDaoManager(this._db);
  $$ClientsTableTableTableManager get clientsTable =>
      $$ClientsTableTableTableManager(_db.attachedDatabase, _db.clientsTable);
  $$TasksTableTableTableManager get tasksTable =>
      $$TasksTableTableTableManager(_db.attachedDatabase, _db.tasksTable);
  $$ItrFilingsTableTableTableManager get itrFilingsTable =>
      $$ItrFilingsTableTableTableManager(
        _db.attachedDatabase,
        _db.itrFilingsTable,
      );
  $$GstReturnsTableTableTableManager get gstReturnsTable =>
      $$GstReturnsTableTableTableManager(
        _db.attachedDatabase,
        _db.gstReturnsTable,
      );
  $$TdsReturnsTableTableTableManager get tdsReturnsTable =>
      $$TdsReturnsTableTableTableManager(
        _db.attachedDatabase,
        _db.tdsReturnsTable,
      );
  $$InvoicesTableTableTableManager get invoicesTable =>
      $$InvoicesTableTableTableManager(_db.attachedDatabase, _db.invoicesTable);
}
