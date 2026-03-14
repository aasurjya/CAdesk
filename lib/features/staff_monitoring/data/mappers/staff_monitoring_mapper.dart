import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/staff_monitoring/domain/models/staff_activity.dart';
import 'package:ca_app/features/staff_monitoring/domain/models/staff_performance.dart';

const _uuid = Uuid();

class StaffMonitoringMapper {
  const StaffMonitoringMapper._();

  // --- StaffActivity ---

  static StaffActivity activityFromRow(StaffActivityRow row) {
    return StaffActivity(
      id: row.id,
      staffId: row.staffId,
      activityType: _safeActivityType(row.activityType),
      clientId: row.clientId,
      taskId: row.taskId,
      startTime: row.startTime,
      endTime: row.endTime,
      durationMinutes: row.durationMinutes,
      notes: row.notes,
    );
  }

  static StaffActivitiesTableCompanion activityToCompanion(StaffActivity a) {
    return StaffActivitiesTableCompanion(
      id: Value(a.id.isEmpty ? _uuid.v4() : a.id),
      staffId: Value(a.staffId),
      activityType: Value(a.activityType.name),
      clientId: Value(a.clientId),
      taskId: Value(a.taskId),
      startTime: Value(a.startTime),
      endTime: Value(a.endTime),
      durationMinutes: Value(a.durationMinutes),
      notes: Value(a.notes),
    );
  }

  static StaffActivity activityFromJson(Map<String, dynamic> json) {
    return StaffActivity(
      id: json['id'] as String,
      staffId: json['staff_id'] as String,
      activityType: _safeActivityType(json['activity_type'] as String),
      clientId: json['client_id'] as String?,
      taskId: json['task_id'] as String?,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      notes: json['notes'] as String?,
    );
  }

  static Map<String, dynamic> activityToJson(StaffActivity a) {
    return {
      'id': a.id,
      'staff_id': a.staffId,
      'activity_type': a.activityType.name,
      'client_id': a.clientId,
      'task_id': a.taskId,
      'start_time': a.startTime.toIso8601String(),
      'end_time': a.endTime?.toIso8601String(),
      'duration_minutes': a.durationMinutes,
      'notes': a.notes,
    };
  }

  // --- StaffPerformance ---

  static StaffPerformance performanceFromRow(StaffPerformanceRow row) {
    return StaffPerformance(
      id: row.id,
      staffId: row.staffId,
      period: row.period,
      tasksCompleted: row.tasksCompleted,
      hoursLogged: row.hoursLogged,
      clientsHandled: row.clientsHandled,
      avgCompletionTime: row.avgCompletionTime,
      createdAt: row.createdAt,
    );
  }

  static StaffPerformanceTableCompanion performanceToCompanion(
    StaffPerformance p,
  ) {
    return StaffPerformanceTableCompanion(
      id: Value(p.id.isEmpty ? _uuid.v4() : p.id),
      staffId: Value(p.staffId),
      period: Value(p.period),
      tasksCompleted: Value(p.tasksCompleted),
      hoursLogged: Value(p.hoursLogged),
      clientsHandled: Value(p.clientsHandled),
      avgCompletionTime: Value(p.avgCompletionTime),
      createdAt: Value(p.createdAt),
    );
  }

  static StaffPerformance performanceFromJson(Map<String, dynamic> json) {
    return StaffPerformance(
      id: json['id'] as String,
      staffId: json['staff_id'] as String,
      period: json['period'] as String,
      tasksCompleted: json['tasks_completed'] as int? ?? 0,
      hoursLogged: (json['hours_logged'] as num?)?.toDouble() ?? 0.0,
      clientsHandled: json['clients_handled'] as int? ?? 0,
      avgCompletionTime:
          (json['avg_completion_time'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static Map<String, dynamic> performanceToJson(StaffPerformance p) {
    return {
      'id': p.id,
      'staff_id': p.staffId,
      'period': p.period,
      'tasks_completed': p.tasksCompleted,
      'hours_logged': p.hoursLogged,
      'clients_handled': p.clientsHandled,
      'avg_completion_time': p.avgCompletionTime,
      'created_at': p.createdAt.toIso8601String(),
    };
  }

  static ActivityType _safeActivityType(String name) {
    try {
      return ActivityType.values.byName(name);
    } catch (_) {
      return ActivityType.other;
    }
  }
}
