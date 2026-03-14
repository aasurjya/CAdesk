import 'package:ca_app/features/time_tracking/domain/models/time_entry.dart';
import 'package:ca_app/features/time_tracking/domain/repositories/time_tracking_repository.dart';

class MockTimeTrackingRepository implements TimeTrackingRepository {
  static final _now = DateTime.now();
  static final _today = DateTime(_now.year, _now.month, _now.day);

  static final List<TimeEntry> _seed = [
    TimeEntry(
      id: 'te-mock-001',
      staffId: 'staff-01',
      staffName: 'Amit Sharma',
      clientId: 'client-1',
      clientName: 'Rajesh Kumar Sharma',
      taskDescription: 'ITR-2 preparation and filing',
      startTime: _today.add(const Duration(hours: 9)),
      endTime: _today.add(const Duration(hours: 11, minutes: 30)),
      durationMinutes: 150,
      isBillable: true,
      hourlyRate: 2000,
      billedAmount: 5000,
      status: TimeEntryStatus.completed,
    ),
    TimeEntry(
      id: 'te-mock-002',
      staffId: 'staff-02',
      staffName: 'Priya Patel',
      clientId: 'client-1',
      clientName: 'Rajesh Kumar Sharma',
      taskDescription: 'GST-3B reconciliation for Feb 2026',
      startTime: _today.add(const Duration(hours: 13)),
      endTime: _today.add(const Duration(hours: 14, minutes: 30)),
      durationMinutes: 90,
      isBillable: true,
      hourlyRate: 1800,
      billedAmount: 0,
      status: TimeEntryStatus.completed,
    ),
    TimeEntry(
      id: 'te-mock-003',
      staffId: 'staff-01',
      staffName: 'Amit Sharma',
      clientId: 'client-2',
      clientName: 'ABC Infra Pvt Ltd',
      taskDescription: 'Audit fieldwork',
      startTime: _today.subtract(const Duration(days: 5, hours: -9)),
      endTime: _today.subtract(const Duration(days: 5, hours: -12)),
      durationMinutes: 180,
      isBillable: true,
      hourlyRate: 2500,
      billedAmount: 7500,
      status: TimeEntryStatus.billed,
    ),
  ];

  final List<TimeEntry> _state = List.of(_seed);

  @override
  Future<String> insertEntry(TimeEntry entry) async {
    _state.add(entry);
    return entry.id;
  }

  @override
  Future<List<TimeEntry>> getByClient(String clientId) async =>
      List.unmodifiable(_state.where((e) => e.clientId == clientId).toList());

  @override
  Future<List<TimeEntry>> getByDateRange(DateTime from, DateTime to) async =>
      List.unmodifiable(
        _state
            .where(
              (e) => !e.startTime.isBefore(from) && !e.startTime.isAfter(to),
            )
            .toList(),
      );

  @override
  Future<bool> updateEntry(TimeEntry entry) async {
    final idx = _state.indexWhere((e) => e.id == entry.id);
    if (idx == -1) return false;
    final updated = List<TimeEntry>.of(_state)..[idx] = entry;
    _state
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteEntry(String id) async {
    final before = _state.length;
    _state.removeWhere((e) => e.id == id);
    return _state.length < before;
  }

  @override
  Future<List<TimeEntry>> getUnbilled(String clientId) async =>
      List.unmodifiable(
        _state
            .where(
              (e) =>
                  e.clientId == clientId && e.status != TimeEntryStatus.billed,
            )
            .toList(),
      );

  @override
  Future<double> getTotalHours(String clientId, int month, int year) async {
    final entries = _state.where((e) {
      return e.clientId == clientId &&
          e.startTime.month == month &&
          e.startTime.year == year;
    });
    final totalMinutes = entries.fold<int>(
      0,
      (sum, e) => sum + e.durationMinutes,
    );
    return totalMinutes / 60.0;
  }
}
