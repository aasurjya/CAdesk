import 'package:ca_app/features/staff_monitoring/data/datasources/staff_monitoring_local_source.dart';
import 'package:ca_app/features/staff_monitoring/data/datasources/staff_monitoring_remote_source.dart';
import 'package:ca_app/features/staff_monitoring/data/mappers/staff_monitoring_mapper.dart';
import 'package:ca_app/features/staff_monitoring/domain/models/staff_activity.dart';
import 'package:ca_app/features/staff_monitoring/domain/models/staff_performance.dart';
import 'package:ca_app/features/staff_monitoring/domain/repositories/staff_monitoring_repository.dart';

class StaffMonitoringRepositoryImpl implements StaffMonitoringRepository {
  const StaffMonitoringRepositoryImpl({
    required this.remote,
    required this.local,
  });

  final StaffMonitoringRemoteSource remote;
  final StaffMonitoringLocalSource local;

  @override
  Future<void> insertActivity(StaffActivity activity) async {
    try {
      await remote.insertActivity(
        StaffMonitoringMapper.activityToJson(activity),
      );
    } catch (_) {
      // No-op — fall through to local write
    }
    await local.insertActivity(activity);
  }

  @override
  Future<List<StaffActivity>> getByStaff(String staffId) async {
    try {
      final jsonList = await remote.fetchByStaff(staffId);
      final activities = jsonList
          .map(StaffMonitoringMapper.activityFromJson)
          .toList();
      for (final a in activities) {
        await local.insertActivity(a);
      }
      return List.unmodifiable(activities);
    } catch (_) {
      return local.getByStaff(staffId);
    }
  }

  @override
  Future<List<StaffActivity>> getByPeriod(DateTime from, DateTime to) async {
    try {
      final jsonList = await remote.fetchByPeriod(from, to);
      final activities = jsonList
          .map(StaffMonitoringMapper.activityFromJson)
          .toList();
      return List.unmodifiable(activities);
    } catch (_) {
      return local.getByPeriod(from, to);
    }
  }

  @override
  Future<List<StaffActivity>> getByClient(String clientId) async {
    try {
      final jsonList = await remote.fetchByClient(clientId);
      final activities = jsonList
          .map(StaffMonitoringMapper.activityFromJson)
          .toList();
      return List.unmodifiable(activities);
    } catch (_) {
      return local.getByClient(clientId);
    }
  }

  @override
  Future<void> insertPerformance(StaffPerformance performance) async {
    try {
      await remote.insertPerformance(
        StaffMonitoringMapper.performanceToJson(performance),
      );
    } catch (_) {
      // No-op — fall through to local write
    }
    await local.insertPerformance(performance);
  }

  @override
  Future<StaffPerformance?> getPerformance(
    String staffId,
    String period,
  ) async {
    try {
      final json = await remote.fetchPerformance(staffId, period);
      if (json == null) return null;
      final performance = StaffMonitoringMapper.performanceFromJson(json);
      await local.insertPerformance(performance);
      return performance;
    } catch (_) {
      return local.getPerformance(staffId, period);
    }
  }
}
