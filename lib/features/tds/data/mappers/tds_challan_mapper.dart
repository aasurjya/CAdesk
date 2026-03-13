import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/tds/domain/models/tds_challan.dart';

class TdsChallanMapper {
  const TdsChallanMapper._();

  // ---------------------------------------------------------------------------
  // JSON (from Supabase) → TdsChallan domain model
  // ---------------------------------------------------------------------------

  static TdsChallan fromJson(Map<String, dynamic> json) {
    return TdsChallan(
      id: json['id'] as String,
      deductorId: json['deductor_id'] as String,
      challanNumber: json['challan_number'] as String,
      bsrCode: json['bsr_code'] as String,
      section: json['section'] as String,
      deducteeCount: (json['deductee_count'] as num?)?.toInt() ?? 0,
      tdsAmount: (json['tds_amount'] as num?)?.toDouble() ?? 0.0,
      surcharge: (json['surcharge'] as num?)?.toDouble() ?? 0.0,
      educationCess: (json['education_cess'] as num?)?.toDouble() ?? 0.0,
      interest: (json['interest'] as num?)?.toDouble() ?? 0.0,
      penalty: (json['penalty'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      paymentDate: json['payment_date'] as String,
      month: (json['month'] as num).toInt(),
      financialYear: json['financial_year'] as String,
      status: json['status'] as String? ?? 'Due',
    );
  }

  // ---------------------------------------------------------------------------
  // TdsChallan domain model → JSON (for Supabase insert/update)
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> toJson(TdsChallan challan) {
    return {
      'id': challan.id,
      'deductor_id': challan.deductorId,
      'challan_number': challan.challanNumber,
      'bsr_code': challan.bsrCode,
      'section': challan.section,
      'deductee_count': challan.deducteeCount,
      'tds_amount': challan.tdsAmount,
      'surcharge': challan.surcharge,
      'education_cess': challan.educationCess,
      'interest': challan.interest,
      'penalty': challan.penalty,
      'total_amount': challan.totalAmount,
      'payment_date': challan.paymentDate,
      'month': challan.month,
      'financial_year': challan.financialYear,
      'status': challan.status,
    };
  }

  // ---------------------------------------------------------------------------
  // Drift row → TdsChallan domain model
  // ---------------------------------------------------------------------------

  static TdsChallan fromRow(TdsChallanRow row) {
    return TdsChallan(
      id: row.id,
      deductorId: row.deductorId,
      challanNumber: row.challanNumber,
      bsrCode: row.bsrCode,
      section: row.section,
      deducteeCount: row.deducteeCount,
      tdsAmount: row.tdsAmount,
      surcharge: row.surcharge,
      educationCess: row.educationCess,
      interest: row.interest,
      penalty: row.penalty,
      totalAmount: row.totalAmount,
      paymentDate: row.paymentDate,
      month: row.month,
      financialYear: row.financialYear,
      status: row.status,
    );
  }

  // ---------------------------------------------------------------------------
  // TdsChallan → Drift companion (for insert/update)
  // ---------------------------------------------------------------------------

  static TdsChallansTableCompanion toCompanion(
    TdsChallan challan, {
    String firmId = '',
    String clientId = '',
  }) {
    return TdsChallansTableCompanion(
      id: Value(challan.id),
      firmId: Value(firmId),
      clientId: Value(clientId),
      deductorId: Value(challan.deductorId),
      challanNumber: Value(challan.challanNumber),
      bsrCode: Value(challan.bsrCode),
      section: Value(challan.section),
      deducteeCount: Value(challan.deducteeCount),
      tdsAmount: Value(challan.tdsAmount),
      surcharge: Value(challan.surcharge),
      educationCess: Value(challan.educationCess),
      interest: Value(challan.interest),
      penalty: Value(challan.penalty),
      totalAmount: Value(challan.totalAmount),
      paymentDate: Value(challan.paymentDate),
      month: Value(challan.month),
      financialYear: Value(challan.financialYear),
      status: Value(challan.status),
      isDirty: const Value(true),
    );
  }
}
