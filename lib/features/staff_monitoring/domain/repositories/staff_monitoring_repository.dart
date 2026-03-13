import 'package:ca_app/features/staff_monitoring/domain/models/staff_activity.dart';
import 'package:ca_app/features/staff_monitoring/domain/models/staff_performance.dart';

abstract class StaffMonitoringRepository {
  Future<void> insertActivity(StaffActivity activity);
  Future<List<StaffActivity>> getByStaff(String staffId);
  Future<List<StaffActivity>> getByPeriod(DateTime from, DateTime to);
  Future<List<StaffActivity>> getByClient(String clientId);
  Future<void> insertPerformance(StaffPerformance performance);
  Future<StaffPerformance?> getPerformance(String staffId, String period);
}
