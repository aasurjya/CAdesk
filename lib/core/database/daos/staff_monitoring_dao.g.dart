// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_monitoring_dao.dart';

// ignore_for_file: type=lint
mixin _$StaffMonitoringDaoMixin on DatabaseAccessor<AppDatabase> {
  $StaffActivitiesTableTable get staffActivitiesTable =>
      attachedDatabase.staffActivitiesTable;
  $StaffPerformanceTableTable get staffPerformanceTable =>
      attachedDatabase.staffPerformanceTable;
  StaffMonitoringDaoManager get managers => StaffMonitoringDaoManager(this);
}

class StaffMonitoringDaoManager {
  final _$StaffMonitoringDaoMixin _db;
  StaffMonitoringDaoManager(this._db);
  $$StaffActivitiesTableTableTableManager get staffActivitiesTable =>
      $$StaffActivitiesTableTableTableManager(
        _db.attachedDatabase,
        _db.staffActivitiesTable,
      );
  $$StaffPerformanceTableTableTableManager get staffPerformanceTable =>
      $$StaffPerformanceTableTableTableManager(
        _db.attachedDatabase,
        _db.staffPerformanceTable,
      );
}
