// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_dao.dart';

// ignore_for_file: type=lint
mixin _$AuditDaoMixin on DatabaseAccessor<AppDatabase> {
  $AuditAssignmentsTableTable get auditAssignmentsTable =>
      attachedDatabase.auditAssignmentsTable;
  $AuditReportsTableTable get auditReportsTable =>
      attachedDatabase.auditReportsTable;
  AuditDaoManager get managers => AuditDaoManager(this);
}

class AuditDaoManager {
  final _$AuditDaoMixin _db;
  AuditDaoManager(this._db);
  $$AuditAssignmentsTableTableTableManager get auditAssignmentsTable =>
      $$AuditAssignmentsTableTableTableManager(
        _db.attachedDatabase,
        _db.auditAssignmentsTable,
      );
  $$AuditReportsTableTableTableManager get auditReportsTable =>
      $$AuditReportsTableTableTableManager(
        _db.attachedDatabase,
        _db.auditReportsTable,
      );
}
