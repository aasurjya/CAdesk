import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/staff_monitoring_table.dart';

part 'staff_monitoring_dao.g.dart';

@DriftAccessor(tables: [StaffActivitiesTable, StaffPerformanceTable])
class StaffMonitoringDao extends DatabaseAccessor<AppDatabase>
    with _$StaffMonitoringDaoMixin {
  StaffMonitoringDao(super.db);

  // --- StaffActivity ops ---

  Future<void> insertActivity(StaffActivitiesTableCompanion companion) =>
      into(staffActivitiesTable).insertOnConflictUpdate(companion);

  Future<List<StaffActivityRow>> getByStaff(String staffId) =>
      (select(staffActivitiesTable)
            ..where((t) => t.staffId.equals(staffId))
            ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
          .get();

  Future<List<StaffActivityRow>> getByPeriod(DateTime from, DateTime to) =>
      (select(staffActivitiesTable)
            ..where(
              (t) =>
                  t.startTime.isBiggerOrEqualValue(from) &
                  t.startTime.isSmallerOrEqualValue(to),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
          .get();

  Future<List<StaffActivityRow>> getByClient(String clientId) =>
      (select(staffActivitiesTable)
            ..where((t) => t.clientId.equals(clientId))
            ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
          .get();

  // --- StaffPerformance ops ---

  Future<void> insertPerformance(StaffPerformanceTableCompanion companion) =>
      into(staffPerformanceTable).insertOnConflictUpdate(companion);

  Future<StaffPerformanceRow?> getPerformance(String staffId, String period) =>
      (select(staffPerformanceTable)
            ..where((t) => t.staffId.equals(staffId) & t.period.equals(period)))
          .getSingleOrNull();
}
