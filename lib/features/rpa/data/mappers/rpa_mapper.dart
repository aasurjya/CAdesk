import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/rpa/domain/models/rpa_task.dart';

const _uuid = Uuid();

class RpaMapper {
  const RpaMapper._();

  static RpaTask fromRow(RpaTaskRow row) {
    return RpaTask(
      id: row.id,
      taskType: _safeTaskType(row.taskType),
      clientId: row.clientId,
      status: _safeStatus(row.status),
      scheduledAt: row.scheduledAt,
      startedAt: row.startedAt,
      completedAt: row.completedAt,
      result: row.result,
      errorMessage: row.errorMessage,
      retryCount: row.retryCount,
    );
  }

  static RpaTasksTableCompanion toCompanion(RpaTask task) {
    return RpaTasksTableCompanion(
      id: Value(task.id.isEmpty ? _uuid.v4() : task.id),
      taskType: Value(task.taskType.name),
      clientId: Value(task.clientId),
      status: Value(task.status.name),
      scheduledAt: Value(task.scheduledAt),
      startedAt: Value(task.startedAt),
      completedAt: Value(task.completedAt),
      result: Value(task.result),
      errorMessage: Value(task.errorMessage),
      retryCount: Value(task.retryCount),
    );
  }

  static RpaTask fromJson(Map<String, dynamic> json) {
    return RpaTask(
      id: json['id'] as String,
      taskType: _safeTaskType(json['task_type'] as String),
      clientId: json['client_id'] as String?,
      status: _safeStatus(json['status'] as String),
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      result: json['result'] as String?,
      errorMessage: json['error_message'] as String?,
      retryCount: json['retry_count'] as int? ?? 0,
    );
  }

  static Map<String, dynamic> toJson(RpaTask task) {
    return {
      'id': task.id,
      'task_type': task.taskType.name,
      'client_id': task.clientId,
      'status': task.status.name,
      'scheduled_at': task.scheduledAt.toIso8601String(),
      'started_at': task.startedAt?.toIso8601String(),
      'completed_at': task.completedAt?.toIso8601String(),
      'result': task.result,
      'error_message': task.errorMessage,
      'retry_count': task.retryCount,
    };
  }

  static RpaTaskType _safeTaskType(String name) {
    try {
      return RpaTaskType.values.byName(name);
    } catch (_) {
      return RpaTaskType.portalStatusCheck;
    }
  }

  static RpaStatus _safeStatus(String name) {
    try {
      return RpaStatus.values.byName(name);
    } catch (_) {
      return RpaStatus.scheduled;
    }
  }
}
