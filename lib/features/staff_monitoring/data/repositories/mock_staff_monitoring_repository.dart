import 'package:uuid/uuid.dart';
import 'package:ca_app/features/staff_monitoring/domain/models/staff_activity.dart';
import 'package:ca_app/features/staff_monitoring/domain/models/staff_performance.dart';
import 'package:ca_app/features/staff_monitoring/domain/repositories/staff_monitoring_repository.dart';

const _uuid = Uuid();

class MockStaffMonitoringRepository implements StaffMonitoringRepository {
  final List<StaffActivity> _activities = [];
  final List<StaffPerformance> _performances = [];

  @override
  Future<void> insertActivity(StaffActivity activity) async {
    final effective = activity.id.isEmpty
        ? activity.copyWith(id: _uuid.v4())
        : activity;
    _activities.add(effective);
  }

  @override
  Future<List<StaffActivity>> getByStaff(String staffId) async {
    return List.unmodifiable(
      _activities.where((a) => a.staffId == staffId).toList(),
    );
  }

  @override
  Future<List<StaffActivity>> getByPeriod(DateTime from, DateTime to) async {
    return List.unmodifiable(
      _activities
          .where(
            (a) =>
                (a.startTime.isAfter(from) ||
                    a.startTime.isAtSameMomentAs(from)) &&
                (a.startTime.isBefore(to) || a.startTime.isAtSameMomentAs(to)),
          )
          .toList(),
    );
  }

  @override
  Future<List<StaffActivity>> getByClient(String clientId) async {
    return List.unmodifiable(
      _activities.where((a) => a.clientId == clientId).toList(),
    );
  }

  @override
  Future<void> insertPerformance(StaffPerformance performance) async {
    final effective = performance.id.isEmpty
        ? performance.copyWith(id: _uuid.v4())
        : performance;
    _performances.add(effective);
  }

  @override
  Future<StaffPerformance?> getPerformance(
    String staffId,
    String period,
  ) async {
    try {
      return _performances.firstWhere(
        (p) => p.staffId == staffId && p.period == period,
      );
    } catch (_) {
      return null;
    }
  }
}
