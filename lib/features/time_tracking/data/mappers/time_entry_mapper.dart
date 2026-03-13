import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/time_tracking/domain/models/time_entry.dart';

class TimeEntryMapper {
  const TimeEntryMapper._();

  // ---------------------------------------------------------------------------
  // JSON (Supabase) ↔ domain
  // ---------------------------------------------------------------------------

  /// JSON (from Supabase) → TimeEntry domain model
  static TimeEntry fromJson(Map<String, dynamic> json) {
    return TimeEntry(
      id: json['id'] as String,
      staffId: json['staff_id'] as String? ?? '',
      staffName: json['staff_name'] as String? ?? '',
      clientId: json['client_id'] as String,
      clientName: json['client_name'] as String? ?? '',
      taskDescription: json['task_description'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null
          ? DateTime.tryParse(json['end_time'] as String)
          : null,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
      isBillable: json['is_billable'] as bool? ?? true,
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble() ?? 0.0,
      billedAmount: (json['billed_amount'] as num?)?.toDouble() ?? 0.0,
      status: _safeStatus(json['status'] as String? ?? 'completed'),
    );
  }

  /// TimeEntry domain model → JSON (for Supabase insert/update)
  static Map<String, dynamic> toJson(TimeEntry entry) {
    return {
      'id': entry.id,
      'staff_id': entry.staffId,
      'staff_name': entry.staffName,
      'client_id': entry.clientId,
      'client_name': entry.clientName,
      'task_description': entry.taskDescription,
      'start_time': entry.startTime.toIso8601String(),
      'end_time': entry.endTime?.toIso8601String(),
      'duration_minutes': entry.durationMinutes,
      'is_billable': entry.isBillable,
      'hourly_rate': entry.hourlyRate,
      'billed_amount': entry.billedAmount,
      'status': entry.status.name,
    };
  }

  // ---------------------------------------------------------------------------
  // Drift row ↔ domain
  // ---------------------------------------------------------------------------

  /// Drift row → TimeEntry domain model
  static TimeEntry fromRow(TimeEntryRow row) {
    return TimeEntry(
      id: row.id,
      staffId: row.staffId,
      staffName: row.staffName,
      clientId: row.clientId,
      clientName: row.clientName,
      taskDescription: row.taskDescription,
      startTime: row.startTime,
      endTime: row.endTime,
      durationMinutes: row.durationMinutes,
      isBillable: !row.isBilled, // isBilled in DB maps inversely to isBillable
      hourlyRate: row.billingRate,
      billedAmount: row.isBilled ? (row.billingRate * row.durationMinutes / 60) : 0.0,
      status: _safeStatus(row.status),
    );
  }

  /// TimeEntry → Drift companion (for insert/update)
  static TimeEntriesTableCompanion toCompanion(TimeEntry entry) {
    return TimeEntriesTableCompanion(
      id: Value(entry.id),
      clientId: Value(entry.clientId),
      staffId: Value(entry.staffId),
      staffName: Value(entry.staffName),
      clientName: Value(entry.clientName),
      taskDescription: Value(entry.taskDescription),
      startTime: Value(entry.startTime),
      endTime: Value(entry.endTime),
      durationMinutes: Value(entry.durationMinutes),
      billingRate: Value(entry.hourlyRate),
      isBilled: Value(entry.status == TimeEntryStatus.billed),
      notes: const Value(null),
      status: Value(entry.status.name),
      updatedAt: Value(DateTime.now()),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static TimeEntryStatus _safeStatus(String value) {
    try {
      return TimeEntryStatus.values.byName(value);
    } catch (_) {
      return TimeEntryStatus.completed;
    }
  }
}
