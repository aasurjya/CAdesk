import 'package:ca_app/features/rpa/domain/models/rpa_task.dart';

abstract class RpaRepository {
  Future<void> insert(RpaTask task);
  Future<List<RpaTask>> getByClient(String clientId);
  Future<List<RpaTask>> getByStatus(RpaStatus status);
  Future<List<RpaTask>> getByType(RpaTaskType taskType);
  Future<bool> updateStatus(
    String id,
    RpaStatus status, {
    DateTime? startedAt,
    DateTime? completedAt,
    String? result,
    String? errorMessage,
    int? retryCount,
  });
  Future<List<RpaTask>> getScheduled(DateTime beforeTime);
  Future<List<RpaTask>> getPending();
  Future<bool> cancel(String taskId);
}
