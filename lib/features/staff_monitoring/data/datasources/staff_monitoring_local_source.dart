import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/staff_monitoring/data/mappers/staff_monitoring_mapper.dart';
import 'package:ca_app/features/staff_monitoring/domain/models/staff_activity.dart';
import 'package:ca_app/features/staff_monitoring/domain/models/staff_performance.dart';

class StaffMonitoringLocalSource {
  const StaffMonitoringLocalSource(this._db);

  final AppDatabase _db;

  Future<void> insertActivity(StaffActivity activity) =>
      _db.staffMonitoringDao.insertActivity(
        StaffMonitoringMapper.activityToCompanion(activity),
      );

  Future<List<StaffActivity>> getByStaff(String staffId) async {
    final rows = await _db.staffMonitoringDao.getByStaff(staffId);
    return rows.map(StaffMonitoringMapper.activityFromRow).toList();
  }

  Future<List<StaffActivity>> getByPeriod(DateTime from, DateTime to) async {
    final rows = await _db.staffMonitoringDao.getByPeriod(from, to);
    return rows.map(StaffMonitoringMapper.activityFromRow).toList();
  }

  Future<List<StaffActivity>> getByClient(String clientId) async {
    final rows = await _db.staffMonitoringDao.getByClient(clientId);
    return rows.map(StaffMonitoringMapper.activityFromRow).toList();
  }

  Future<void> insertPerformance(StaffPerformance performance) =>
      _db.staffMonitoringDao.insertPerformance(
        StaffMonitoringMapper.performanceToCompanion(performance),
      );

  Future<StaffPerformance?> getPerformance(
    String staffId,
    String period,
  ) async {
    final row = await _db.staffMonitoringDao.getPerformance(staffId, period);
    return row != null ? StaffMonitoringMapper.performanceFromRow(row) : null;
  }
}
