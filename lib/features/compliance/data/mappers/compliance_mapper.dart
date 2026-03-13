import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/compliance/domain/models/compliance_event.dart';

class ComplianceMapper {
  const ComplianceMapper._();

  /// JSON (from Supabase) → ComplianceEvent domain model
  static ComplianceEvent fromJson(Map<String, dynamic> json) {
    return ComplianceEvent(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      type: _safeComplianceEventType(json['type'] as String? ?? 'other'),
      description: json['description'] as String,
      dueDate: DateTime.parse(
        json['due_date'] as String? ?? DateTime.now().toIso8601String(),
      ),
      filedDate: json['filed_date'] != null ? DateTime.parse(json['filed_date'] as String) : null,
      status: _safeComplianceEventStatus(json['status'] as String? ?? 'pending'),
      penalty: (json['penalty'] as num?)?.toDouble(),
    );
  }

  /// ComplianceEvent domain model → JSON (for Supabase insert/update)
  static Map<String, dynamic> toJson(ComplianceEvent event) {
    return {
      'id': event.id,
      'client_id': event.clientId,
      'type': event.type.name,
      'description': event.description,
      'due_date': event.dueDate.toIso8601String(),
      'filed_date': event.filedDate?.toIso8601String(),
      'status': event.status.name,
      'penalty': event.penalty,
    };
  }

  /// Drift row → ComplianceEvent domain model
  static ComplianceEvent fromRow(ComplianceEventRow row) {
    return ComplianceEvent(
      id: row.id,
      clientId: row.clientId,
      type: _safeComplianceEventType(row.type),
      description: row.description,
      dueDate: row.dueDate,
      filedDate: row.filedDate,
      status: _safeComplianceEventStatus(row.status),
      penalty: row.penalty,
    );
  }

  /// ComplianceEvent → Drift companion (for insert/update)
  static ComplianceEventsTableCompanion toCompanion(ComplianceEvent event) {
    return ComplianceEventsTableCompanion(
      id: Value(event.id),
      clientId: Value(event.clientId),
      type: Value(event.type.name),
      description: Value(event.description),
      dueDate: Value(event.dueDate),
      filedDate: Value(event.filedDate),
      status: Value(event.status.name),
      penalty: Value(event.penalty),
      isDirty: const Value(true),
    );
  }

  static ComplianceEventType _safeComplianceEventType(String value) {
    try {
      return ComplianceEventType.values.firstWhere((e) => e.name == value);
    } catch (_) {
      return ComplianceEventType.other;
    }
  }

  static ComplianceEventStatus _safeComplianceEventStatus(String value) {
    try {
      return ComplianceEventStatus.values.firstWhere((e) => e.name == value);
    } catch (_) {
      return ComplianceEventStatus.pending;
    }
  }
}
