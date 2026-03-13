import 'package:uuid/uuid.dart';
import 'package:ca_app/features/rpa/domain/models/rpa_task.dart';
import 'package:ca_app/features/rpa/domain/repositories/rpa_repository.dart';

const _uuid = Uuid();

class MockRpaRepository implements RpaRepository {
  final List<RpaTask> _tasks = [];

  @override
  Future<void> insert(RpaTask task) async {
    final effective = task.id.isEmpty ? task.copyWith(id: _uuid.v4()) : task;
    _tasks.add(effective);
  }

  @override
  Future<List<RpaTask>> getByClient(String clientId) async {
    return List.unmodifiable(
      _tasks.where((t) => t.clientId == clientId).toList(),
    );
  }

  @override
  Future<List<RpaTask>> getByStatus(RpaStatus status) async {
    return List.unmodifiable(
      _tasks.where((t) => t.status == status).toList(),
    );
  }

  @override
  Future<List<RpaTask>> getByType(RpaTaskType taskType) async {
    return List.unmodifiable(
      _tasks.where((t) => t.taskType == taskType).toList(),
    );
  }

  @override
  Future<bool> updateStatus(
    String id,
    RpaStatus status, {
    DateTime? startedAt,
    DateTime? completedAt,
    String? result,
    String? errorMessage,
    int? retryCount,
  }) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return false;
    final updated = _tasks[idx].copyWith(
      status: status,
      startedAt: startedAt,
      completedAt: completedAt,
      result: result,
      errorMessage: errorMessage,
      retryCount: retryCount,
    );
    _tasks[idx] = updated;
    return true;
  }

  @override
  Future<List<RpaTask>> getScheduled(DateTime beforeTime) async {
    return List.unmodifiable(
      _tasks
          .where(
            (t) =>
                t.status == RpaStatus.scheduled &&
                t.scheduledAt.isBefore(beforeTime),
          )
          .toList(),
    );
  }

  @override
  Future<List<RpaTask>> getPending() async {
    return List.unmodifiable(
      _tasks
          .where(
            (t) =>
                t.status == RpaStatus.scheduled ||
                t.status == RpaStatus.running,
          )
          .toList(),
    );
  }

  @override
  Future<bool> cancel(String taskId) async {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return false;
    _tasks[idx] = _tasks[idx].copyWith(status: RpaStatus.cancelled);
    return true;
  }
}
