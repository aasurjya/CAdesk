import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/income_tax/domain/models/filing_status.dart';
import 'package:ca_app/features/income_tax/domain/models/itr_client.dart';
import 'package:ca_app/features/income_tax/domain/models/itr_type.dart';

class ItrFilingMapper {
  const ItrFilingMapper._();

  // JSON (from Supabase) → ItrClient domain model
  static ItrClient fromJson(Map<String, dynamic> json) {
    return ItrClient(
      id: json['id'] as String,
      name: json['name'] as String,
      pan: json['pan'] as String,
      // aadhaar is NEVER stored in Supabase — default to empty string from remote
      aadhaar: '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      itrType: _safeItrType(json['itr_type'] as String? ?? ''),
      assessmentYear: json['assessment_year'] as String? ?? '',
      filingStatus: _safeFilingStatus(json['filing_status'] as String? ?? ''),
      totalIncome: (json['total_income'] as num?)?.toDouble() ?? 0.0,
      taxPayable: (json['tax_payable'] as num?)?.toDouble() ?? 0.0,
      refundDue: (json['refund_due'] as num?)?.toDouble() ?? 0.0,
      filedDate: DateTime.tryParse(json['filed_date'] as String? ?? ''),
      acknowledgementNumber: json['acknowledgement_number'] as String?,
    );
  }

  // ItrClient domain model → JSON (for Supabase insert/update)
  // aadhaar is NEVER sent to Supabase — DPDP / local-only field
  static Map<String, dynamic> toJson(ItrClient filing) {
    return {
      'id': filing.id,
      'name': filing.name,
      'pan': filing.pan,
      'email': filing.email,
      'phone': filing.phone,
      'itr_type': filing.itrType.name,
      'assessment_year': filing.assessmentYear,
      'filing_status': filing.filingStatus.name,
      'total_income': filing.totalIncome,
      'tax_payable': filing.taxPayable,
      'refund_due': filing.refundDue,
      'filed_date': filing.filedDate?.toIso8601String(),
      'acknowledgement_number': filing.acknowledgementNumber,
    };
  }

  // Drift row → ItrClient domain model
  static ItrClient fromRow(ItrFilingRow row) {
    return ItrClient(
      id: row.id,
      name: row.name,
      pan: row.pan,
      aadhaar: row.aadhaar ?? '',
      email: row.email ?? '',
      phone: row.phone ?? '',
      itrType: _safeItrType(row.itrType),
      assessmentYear: row.assessmentYear,
      filingStatus: _safeFilingStatus(row.filingStatus),
      totalIncome: row.totalIncome ?? 0.0,
      taxPayable: row.taxPayable ?? 0.0,
      refundDue: row.refundDue ?? 0.0,
      filedDate: row.filedDate != null
          ? DateTime.tryParse(row.filedDate!)
          : null,
      acknowledgementNumber: row.acknowledgementNumber,
    );
  }

  // ItrClient → Drift companion (for insert/update)
  static ItrFilingsTableCompanion toCompanion(
    ItrClient filing, {
    String firmId = '',
  }) {
    return ItrFilingsTableCompanion(
      id: Value(filing.id),
      firmId: Value(firmId),
      clientId: Value(filing.id),
      name: Value(filing.name),
      pan: Value(filing.pan),
      aadhaar: Value(filing.aadhaar.isEmpty ? null : filing.aadhaar),
      email: Value(filing.email.isEmpty ? null : filing.email),
      phone: Value(filing.phone.isEmpty ? null : filing.phone),
      itrType: Value(filing.itrType.name),
      assessmentYear: Value(filing.assessmentYear),
      financialYear: Value(_ayToFy(filing.assessmentYear)),
      filingStatus: Value(filing.filingStatus.name),
      totalIncome: Value(filing.totalIncome),
      taxPayable: Value(filing.taxPayable),
      refundDue: Value(filing.refundDue),
      filedDate: Value(filing.filedDate?.toIso8601String()),
      acknowledgementNumber: Value(filing.acknowledgementNumber),
      isDirty: const Value(true),
    );
  }

  static ItrType _safeItrType(String name) {
    try {
      return ItrType.values.byName(name);
    } catch (_) {
      return ItrType.itr1;
    }
  }

  static FilingStatus _safeFilingStatus(String name) {
    try {
      return FilingStatus.values.byName(name);
    } catch (_) {
      return FilingStatus.pending;
    }
  }

  /// Derives financial year from assessment year string.
  /// e.g. "AY 2026-27" → "FY 2025-26", "2026-27" → "FY 2025-26"
  static String _ayToFy(String assessmentYear) {
    final cleaned = assessmentYear.replaceFirst(RegExp(r'^AY\s*'), '').trim();
    final parts = cleaned.split('-');
    if (parts.length == 2) {
      final startYear = int.tryParse(parts[0]);
      if (startYear != null) {
        final fyStart = startYear - 1;
        final fyEnd = parts[1];
        return 'FY $fyStart-$fyEnd';
      }
    }
    return assessmentYear;
  }
}
