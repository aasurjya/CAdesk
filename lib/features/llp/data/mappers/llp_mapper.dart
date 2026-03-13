import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/llp/domain/models/llp_filing.dart';

/// Converts between [LlpFiling] (domain) and Drift / Supabase representations.
class LlpMapper {
  const LlpMapper._();

  // ---------------------------------------------------------------------------
  // JSON (Supabase) → domain
  // ---------------------------------------------------------------------------

  static LlpFiling fromJson(Map<String, dynamic> json) {
    return LlpFiling(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      formType: _safeFormType(json['form_type'] as String? ?? 'other'),
      financialYear: json['financial_year'] as String? ?? '',
      dueDate: DateTime.parse(
        json['due_date'] as String? ?? DateTime.now().toIso8601String(),
      ),
      filedDate: json['filed_date'] != null
          ? DateTime.tryParse(json['filed_date'] as String)
          : null,
      status: json['status'] as String? ?? 'pending',
      filingNumber: json['filing_number'] as String?,
    );
  }

  // ---------------------------------------------------------------------------
  // Domain → JSON (Supabase insert / update)
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> toJson(LlpFiling filing) {
    return {
      'id': filing.id,
      'client_id': filing.clientId,
      'form_type': filing.formType.name,
      'financial_year': filing.financialYear,
      'due_date': filing.dueDate.toIso8601String(),
      'filed_date': filing.filedDate?.toIso8601String(),
      'status': filing.status,
      'filing_number': filing.filingNumber,
    };
  }

  // ---------------------------------------------------------------------------
  // Drift row → domain
  // ---------------------------------------------------------------------------

  static LlpFiling fromRow(LlpFilingsTableData row) {
    return LlpFiling(
      id: row.id,
      clientId: row.clientId,
      formType: _safeFormType(row.formType ?? 'other'),
      financialYear: row.financialYear ?? '',
      dueDate: row.dueDate ?? DateTime.now(),
      filedDate: row.filedDate,
      status: row.status ?? 'pending',
      filingNumber: row.filingNumber,
    );
  }

  // ---------------------------------------------------------------------------
  // Domain → Drift companion
  // ---------------------------------------------------------------------------

  static LlpFilingsTableCompanion toCompanion(LlpFiling filing) {
    return LlpFilingsTableCompanion(
      id: Value(filing.id),
      clientId: Value(filing.clientId),
      formType: Value(filing.formType.name),
      financialYear: Value(filing.financialYear),
      dueDate: Value(filing.dueDate),
      filedDate: Value(filing.filedDate),
      status: Value(filing.status),
      filingNumber: Value(filing.filingNumber),
      updatedAt: Value(DateTime.now()),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static LlpFormType _safeFormType(String value) {
    try {
      return LlpFormType.values.firstWhere((e) => e.name == value);
    } catch (_) {
      return LlpFormType.other;
    }
  }
}
