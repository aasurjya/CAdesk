import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/fema/domain/models/fema_filing_data.dart';

/// Converts between [FemaFilingData] (domain) and Drift / Supabase
/// representations.
class FemaMapper {
  const FemaMapper._();

  // ---------------------------------------------------------------------------
  // JSON (Supabase) → domain
  // ---------------------------------------------------------------------------

  static FemaFilingData fromJson(Map<String, dynamic> json) {
    return FemaFilingData(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      filingType: _safeFilingType(json['filing_type'] as String? ?? 'other'),
      transactionDate: DateTime.parse(
        json['transaction_date'] as String? ??
            DateTime.now().toIso8601String(),
      ),
      amount: json['amount'] as String? ?? '0',
      currency: json['currency'] as String? ?? 'INR',
      approvalRequired: json['approval_required'] as bool? ?? false,
      status: json['status'] as String? ?? 'pending',
      filingNumber: json['filing_number'] as String?,
      remarks: json['remarks'] as String?,
    );
  }

  // ---------------------------------------------------------------------------
  // Domain → JSON (Supabase insert / update)
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> toJson(FemaFilingData filing) {
    return {
      'id': filing.id,
      'client_id': filing.clientId,
      'filing_type': filing.filingType.name,
      'transaction_date': filing.transactionDate.toIso8601String(),
      'amount': filing.amount,
      'currency': filing.currency,
      'approval_required': filing.approvalRequired,
      'status': filing.status,
      'filing_number': filing.filingNumber,
      'remarks': filing.remarks,
    };
  }

  // ---------------------------------------------------------------------------
  // Drift row → domain
  // ---------------------------------------------------------------------------

  static FemaFilingData fromRow(FemaFilingsTableData row) {
    return FemaFilingData(
      id: row.id,
      clientId: row.clientId,
      filingType: _safeFilingType(row.filingType ?? 'other'),
      transactionDate: row.transactionDate,
      amount: row.amount ?? '0',
      currency: row.currency ?? 'INR',
      approvalRequired: row.approvalRequired,
      status: row.status ?? 'pending',
      filingNumber: row.filingNumber,
      remarks: row.remarks,
    );
  }

  // ---------------------------------------------------------------------------
  // Domain → Drift companion
  // ---------------------------------------------------------------------------

  static FemaFilingsTableCompanion toCompanion(FemaFilingData filing) {
    return FemaFilingsTableCompanion(
      id: Value(filing.id),
      clientId: Value(filing.clientId),
      filingType: Value(filing.filingType.name),
      transactionDate: Value(filing.transactionDate),
      amount: Value(filing.amount),
      currency: Value(filing.currency),
      approvalRequired: Value(filing.approvalRequired),
      status: Value(filing.status),
      filingNumber: Value(filing.filingNumber),
      remarks: Value(filing.remarks),
      updatedAt: Value(DateTime.now()),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static FemaType _safeFilingType(String value) {
    try {
      return FemaType.values.firstWhere((e) => e.name == value);
    } catch (_) {
      return FemaType.other;
    }
  }
}
