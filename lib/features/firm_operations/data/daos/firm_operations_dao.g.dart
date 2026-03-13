// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firm_operations_dao.dart';

// ignore_for_file: type=lint
mixin _$FirmOperationsDaoMixin on DatabaseAccessor<AppDatabase> {
  $FirmInfoTableTable get firmInfoTable => attachedDatabase.firmInfoTable;
  $TeamMembersTableTable get teamMembersTable =>
      attachedDatabase.teamMembersTable;
  $ClientAssignmentsTableTable get clientAssignmentsTable =>
      attachedDatabase.clientAssignmentsTable;
  FirmOperationsDaoManager get managers => FirmOperationsDaoManager(this);
}

class FirmOperationsDaoManager {
  final _$FirmOperationsDaoMixin _db;
  FirmOperationsDaoManager(this._db);
  $$FirmInfoTableTableTableManager get firmInfoTable =>
      $$FirmInfoTableTableTableManager(_db.attachedDatabase, _db.firmInfoTable);
  $$TeamMembersTableTableTableManager get teamMembersTable =>
      $$TeamMembersTableTableTableManager(
        _db.attachedDatabase,
        _db.teamMembersTable,
      );
  $$ClientAssignmentsTableTableTableManager get clientAssignmentsTable =>
      $$ClientAssignmentsTableTableTableManager(
        _db.attachedDatabase,
        _db.clientAssignmentsTable,
      );
}
