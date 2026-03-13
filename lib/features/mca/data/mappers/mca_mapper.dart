import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/mca/domain/models/mca_filing_data.dart';

/// Converts between [McaFilingData] (domain) and Drift / Supabase
/// representations.
class McaMapper {
  const McaMapper._();

  // ---------------------------------------------------------------------------
  // JSON (Supabase) → domain
  // ---------------------------------------------------------------------------

  /// Parse a Supabase JSON map into a [McaFilingData].
  static McaFilingData fromJson(Map<String, dynamic> json) {
    return McaFilingData(
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
      remarks: json['remarks'] as String?,
    );
  }

  // ---------------------------------------------------------------------------
  // Domain → JSON (Supabase insert / update)
  // ---------------------------------------------------------------------------

  /// Serialize a [McaFilingData] to a Supabase-ready JSON map.
  static Map<String, dynamic> toJson(McaFilingData filing) {
    return {
      'id': filing.id,
      'client_id': filing.clientId,
      'form_type': filing.formType.name,
      'financial_year': filing.financialYear,
      'due_date': filing.dueDate.toIso8601String(),
      'filed_date': filing.filedDate?.toIso8601String(),
      'status': filing.status,
      'filing_number': filing.filingNumber,
      'remarks': filing.remarks,
    };
  }

  // ---------------------------------------------------------------------------
  // Drift row → domain
  // ---------------------------------------------------------------------------

  /// Map a Drift [MCAFilingsTableData] row to [McaFilingData].
  static McaFilingData fromRow(MCAFilingsTableData row) {
    return McaFilingData(
      id: row.id,
      clientId: row.clientId,
      formType: _safeFormType(row.formType ?? 'other'),
      financialYear: row.financialYear ?? '',
      dueDate: row.dueDate ?? DateTime.now(),
      filedDate: row.filedDate,
      status: row.status ?? 'pending',
      filingNumber: row.filingNumber,
      remarks: row.remarks,
    );
  }

  // ---------------------------------------------------------------------------
  // Domain → Drift companion
  // ---------------------------------------------------------------------------

  /// Convert a [McaFilingData] to a Drift companion for insert / update.
  static MCAFilingsTableCompanion toCompanion(McaFilingData filing) {
    return MCAFilingsTableCompanion(
      id: Value(filing.id),
      clientId: Value(filing.clientId),
      formType: Value(filing.formType.name),
      financialYear: Value(filing.financialYear),
      dueDate: Value(filing.dueDate),
      filedDate: Value(filing.filedDate),
      status: Value(filing.status),
      filingNumber: Value(filing.filingNumber),
      remarks: Value(filing.remarks),
      updatedAt: Value(DateTime.now()),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static MCAFormType _safeFormType(String value) {
    try {
      return MCAFormType.values.firstWhere((e) => e.name == value);
    } catch (_) {
      return MCAFormType.other;
    }
  }
}
