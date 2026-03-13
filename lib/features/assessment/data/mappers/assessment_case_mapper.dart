import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/assessment/domain/models/assessment_case.dart';

class AssessmentCaseMapper {
  const AssessmentCaseMapper._();

  // ---------------------------------------------------------------------------
  // JSON (Supabase) ↔ domain
  // ---------------------------------------------------------------------------

  /// JSON (from Supabase) → AssessmentCase domain model
  static AssessmentCase fromJson(Map<String, dynamic> json) {
    return AssessmentCase(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      assessmentYear: json['assessment_year'] as String,
      caseType: _safeType(json['case_type'] as String? ?? 'intimation143_1'),
      status: _safeStatus(json['status'] as String? ?? 'open'),
      demandAmount: json['demand_amount'] as String? ?? '0.00',
      paidAmount: json['paid_amount'] as String? ?? '0.00',
      dueDate: _parseDateTime(json['due_date'] as String?),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// AssessmentCase domain model → JSON (for Supabase insert/update)
  static Map<String, dynamic> toJson(AssessmentCase assessmentCase) {
    return {
      'id': assessmentCase.id,
      'client_id': assessmentCase.clientId,
      'assessment_year': assessmentCase.assessmentYear,
      'case_type': assessmentCase.caseType.name,
      'status': assessmentCase.status.name,
      'demand_amount': assessmentCase.demandAmount,
      'paid_amount': assessmentCase.paidAmount,
      'due_date': assessmentCase.dueDate?.toIso8601String(),
      'notes': assessmentCase.notes,
    };
  }

  // ---------------------------------------------------------------------------
  // Drift row ↔ domain
  // ---------------------------------------------------------------------------

  /// Drift row → AssessmentCase domain model
  static AssessmentCase fromRow(AssessmentCaseRow row) {
    return AssessmentCase(
      id: row.id,
      clientId: row.clientId,
      assessmentYear: row.assessmentYear,
      caseType: _safeType(row.caseType),
      status: _safeStatus(row.status),
      demandAmount: row.demandAmount,
      paidAmount: row.paidAmount,
      dueDate: row.dueDate,
      notes: row.notes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  /// AssessmentCase → Drift companion (for insert/update)
  static AssessmentCasesTableCompanion toCompanion(
    AssessmentCase assessmentCase,
  ) {
    return AssessmentCasesTableCompanion(
      id: Value(assessmentCase.id),
      clientId: Value(assessmentCase.clientId),
      assessmentYear: Value(assessmentCase.assessmentYear),
      caseType: Value(assessmentCase.caseType.name),
      status: Value(assessmentCase.status.name),
      demandAmount: Value(assessmentCase.demandAmount),
      paidAmount: Value(assessmentCase.paidAmount),
      dueDate: Value(assessmentCase.dueDate),
      notes: Value(assessmentCase.notes),
      createdAt: Value(assessmentCase.createdAt),
      updatedAt: Value(assessmentCase.updatedAt),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static DateTime? _parseDateTime(String? s) {
    if (s == null) return null;
    return DateTime.tryParse(s);
  }

  static AssessmentType _safeType(String value) {
    try {
      return AssessmentType.values.byName(value);
    } catch (_) {
      return AssessmentType.intimation143_1;
    }
  }

  static AssessmentCaseStatus _safeStatus(String value) {
    try {
      return AssessmentCaseStatus.values.byName(value);
    } catch (_) {
      return AssessmentCaseStatus.open;
    }
  }
}
