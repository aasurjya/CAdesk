import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/sebi/domain/models/sebi_compliance_data.dart';

/// Converts between [SebiComplianceData] (domain) and Drift / Supabase
/// representations.
class SebiMapper {
  const SebiMapper._();

  // ---------------------------------------------------------------------------
  // JSON (Supabase) → domain
  // ---------------------------------------------------------------------------

  static SebiComplianceData fromJson(Map<String, dynamic> json) {
    return SebiComplianceData(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      complianceType: _safeType(json['compliance_type'] as String? ?? 'other'),
      dueDate: DateTime.parse(
        json['due_date'] as String? ?? DateTime.now().toIso8601String(),
      ),
      filedDate: json['filed_date'] != null
          ? DateTime.tryParse(json['filed_date'] as String)
          : null,
      status: json['status'] as String? ?? 'pending',
      description: json['description'] as String?,
      penalty: json['penalty'] as String?,
    );
  }

  // ---------------------------------------------------------------------------
  // Domain → JSON (Supabase insert / update)
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> toJson(SebiComplianceData compliance) {
    return {
      'id': compliance.id,
      'client_id': compliance.clientId,
      'compliance_type': compliance.complianceType.name,
      'due_date': compliance.dueDate.toIso8601String(),
      'filed_date': compliance.filedDate?.toIso8601String(),
      'status': compliance.status,
      'description': compliance.description,
      'penalty': compliance.penalty,
    };
  }

  // ---------------------------------------------------------------------------
  // Drift row → domain
  // ---------------------------------------------------------------------------

  static SebiComplianceData fromRow(SebiComplianceTableData row) {
    return SebiComplianceData(
      id: row.id,
      clientId: row.clientId,
      complianceType: _safeType(row.complianceType ?? 'other'),
      dueDate: row.dueDate,
      filedDate: row.filedDate,
      status: row.status ?? 'pending',
      description: row.description,
      penalty: row.penalty,
    );
  }

  // ---------------------------------------------------------------------------
  // Domain → Drift companion
  // ---------------------------------------------------------------------------

  static SebiComplianceTableCompanion toCompanion(
    SebiComplianceData compliance,
  ) {
    return SebiComplianceTableCompanion(
      id: Value(compliance.id),
      clientId: Value(compliance.clientId),
      complianceType: Value(compliance.complianceType.name),
      dueDate: Value(compliance.dueDate),
      filedDate: Value(compliance.filedDate),
      status: Value(compliance.status),
      description: Value(compliance.description),
      penalty: Value(compliance.penalty),
      updatedAt: Value(DateTime.now()),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static SebiType _safeType(String value) {
    try {
      return SebiType.values.firstWhere((e) => e.name == value);
    } catch (_) {
      return SebiType.other;
    }
  }
}
