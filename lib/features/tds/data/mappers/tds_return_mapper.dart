import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';

class TdsReturnMapper {
  const TdsReturnMapper._();

  // ---------------------------------------------------------------------------
  // JSON (from Supabase) → TdsReturn domain model
  // ---------------------------------------------------------------------------

  static TdsReturn fromJson(Map<String, dynamic> json) {
    return TdsReturn(
      id: json['id'] as String,
      deductorId: json['deductor_id'] as String,
      tan: json['tan'] as String,
      formType: _safeFormType(json['form_type'] as String? ?? 'form26Q'),
      quarter: _safeQuarter(json['quarter'] as String? ?? 'q1'),
      financialYear: json['financial_year'] as String,
      status: _safeStatus(json['filing_status'] as String? ?? 'pending'),
      totalDeductions: (json['total_deductions'] as num?)?.toDouble() ?? 0.0,
      totalTaxDeducted: (json['total_tax_deducted'] as num?)?.toDouble() ?? 0.0,
      totalDeposited: (json['total_deposited'] as num?)?.toDouble() ?? 0.0,
      filedDate: _parseDateTime(json['filed_date'] as String?),
      tokenNumber: json['token_number'] as String?,
    );
  }

  // ---------------------------------------------------------------------------
  // TdsReturn domain model → JSON (for Supabase insert/update)
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> toJson(TdsReturn tdsReturn) {
    return {
      'id': tdsReturn.id,
      'deductor_id': tdsReturn.deductorId,
      'tan': tdsReturn.tan,
      'form_type': tdsReturn.formType.name,
      'quarter': tdsReturn.quarter.name,
      'financial_year': tdsReturn.financialYear,
      'filing_status': tdsReturn.status.name,
      'total_deductions': tdsReturn.totalDeductions,
      'total_tax_deducted': tdsReturn.totalTaxDeducted,
      'total_deposited': tdsReturn.totalDeposited,
      'filed_date': tdsReturn.filedDate?.toIso8601String(),
      'token_number': tdsReturn.tokenNumber,
    };
  }

  // ---------------------------------------------------------------------------
  // Drift row → TdsReturn domain model
  // ---------------------------------------------------------------------------

  static TdsReturn fromRow(TdsReturnRow row) {
    return TdsReturn(
      id: row.id,
      deductorId: row.deductorId,
      tan: row.tan,
      formType: _safeFormType(row.formType),
      quarter: _safeQuarter(row.quarter),
      financialYear: row.financialYear,
      status: _safeStatus(row.status),
      totalDeductions: row.totalDeductions,
      totalTaxDeducted: row.totalTaxDeducted,
      totalDeposited: row.totalDeposited,
      filedDate: row.filedDate != null
          ? DateTime.tryParse(row.filedDate!)
          : null,
      tokenNumber: row.tokenNumber,
    );
  }

  // ---------------------------------------------------------------------------
  // TdsReturn → Drift companion (for insert/update)
  // ---------------------------------------------------------------------------

  static TdsReturnsTableCompanion toCompanion(
    TdsReturn tdsReturn, {
    String firmId = '',
    String clientId = '',
  }) {
    return TdsReturnsTableCompanion(
      id: Value(tdsReturn.id),
      firmId: Value(firmId),
      clientId: Value(clientId),
      deductorId: Value(tdsReturn.deductorId),
      tan: Value(tdsReturn.tan),
      formType: Value(tdsReturn.formType.name),
      quarter: Value(tdsReturn.quarter.name),
      financialYear: Value(tdsReturn.financialYear),
      status: Value(tdsReturn.status.name),
      totalDeductions: Value(tdsReturn.totalDeductions),
      totalTaxDeducted: Value(tdsReturn.totalTaxDeducted),
      totalDeposited: Value(tdsReturn.totalDeposited),
      filedDate: Value(tdsReturn.filedDate?.toIso8601String()),
      tokenNumber: Value(tdsReturn.tokenNumber),
      isDirty: const Value(true),
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static TdsFormType _safeFormType(String name) {
    try {
      return TdsFormType.values.byName(name);
    } catch (_) {
      return TdsFormType.form26Q;
    }
  }

  static TdsQuarter _safeQuarter(String name) {
    try {
      return TdsQuarter.values.byName(name);
    } catch (_) {
      return TdsQuarter.q1;
    }
  }

  static TdsReturnStatus _safeStatus(String name) {
    try {
      return TdsReturnStatus.values.byName(name);
    } catch (_) {
      return TdsReturnStatus.pending;
    }
  }

  static DateTime? _parseDateTime(String? s) {
    if (s == null) return null;
    return DateTime.tryParse(s);
  }
}
