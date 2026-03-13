// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compliance_dao.dart';

// ignore_for_file: type=lint
mixin _$ComplianceDaoMixin on DatabaseAccessor<AppDatabase> {
  $ComplianceEventsTableTable get complianceEventsTable =>
      attachedDatabase.complianceEventsTable;
  ComplianceDaoManager get managers => ComplianceDaoManager(this);
}

class ComplianceDaoManager {
  final _$ComplianceDaoMixin _db;
  ComplianceDaoManager(this._db);
  $$ComplianceEventsTableTableTableManager get complianceEventsTable =>
      $$ComplianceEventsTableTableTableManager(
        _db.attachedDatabase,
        _db.complianceEventsTable,
      );
}
