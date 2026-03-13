import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/gst/domain/models/gst_return.dart';

class GstReturnMapper {
  const GstReturnMapper._();

  // JSON (from Supabase) → GstReturn domain model
  static GstReturn fromJson(Map<String, dynamic> json) {
    return GstReturn(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      gstin: json['gstin'] as String,
      returnType: _safeReturnType(json['return_type'] as String? ?? 'gstr1'),
      periodMonth: (json['period_month'] as num).toInt(),
      periodYear: (json['period_year'] as num).toInt(),
      dueDate: DateTime.parse(json['due_date'] as String),
      filedDate: _parseDate(json['filed_date'] as String?),
      status: _safeReturnStatus(json['status'] as String? ?? 'pending'),
      taxableValue: (json['taxable_value'] as num?)?.toDouble() ?? 0,
      igst: (json['igst'] as num?)?.toDouble() ?? 0,
      cgst: (json['cgst'] as num?)?.toDouble() ?? 0,
      sgst: (json['sgst'] as num?)?.toDouble() ?? 0,
      cess: (json['cess'] as num?)?.toDouble() ?? 0,
      itcClaimed: (json['itc_claimed'] as num?)?.toDouble() ?? 0,
    );
  }

  // GstReturn domain model → JSON (for Supabase insert/update)
  static Map<String, dynamic> toJson(GstReturn gstReturn) {
    return {
      'id': gstReturn.id,
      'client_id': gstReturn.clientId,
      'gstin': gstReturn.gstin,
      'return_type': gstReturn.returnType.name,
      'period_month': gstReturn.periodMonth,
      'period_year': gstReturn.periodYear,
      'due_date': gstReturn.dueDate.toIso8601String(),
      'filed_date': gstReturn.filedDate?.toIso8601String(),
      'status': gstReturn.status.name,
      'taxable_value': gstReturn.taxableValue,
      'igst': gstReturn.igst,
      'cgst': gstReturn.cgst,
      'sgst': gstReturn.sgst,
      'cess': gstReturn.cess,
      'itc_claimed': gstReturn.itcClaimed,
    };
  }

  // Drift row → GstReturn domain model
  static GstReturn fromRow(GstReturnRow row) {
    return GstReturn(
      id: row.id,
      clientId: row.clientId,
      gstin: row.gstin,
      returnType: _safeReturnType(row.returnType),
      periodMonth: row.periodMonth,
      periodYear: row.periodYear,
      dueDate: row.dueDate != null
          ? DateTime.parse(row.dueDate!)
          : DateTime(row.periodYear, row.periodMonth + 1, 20),
      filedDate: row.filedDate != null
          ? DateTime.tryParse(row.filedDate!)
          : null,
      status: _safeReturnStatus(row.status),
      taxableValue: row.taxableValue,
      igst: row.igst,
      cgst: row.cgst,
      sgst: row.sgst,
      cess: row.cess,
      itcClaimed: row.itcClaimed,
    );
  }

  // GstReturn → Drift companion (for insert/update)
  static GstReturnsTableCompanion toCompanion(
    GstReturn gstReturn, {
    String firmId = '',
  }) {
    return GstReturnsTableCompanion(
      id: Value(gstReturn.id),
      firmId: Value(firmId),
      clientId: Value(gstReturn.clientId),
      gstin: Value(gstReturn.gstin),
      returnType: Value(gstReturn.returnType.name),
      periodMonth: Value(gstReturn.periodMonth),
      periodYear: Value(gstReturn.periodYear),
      dueDate: Value(gstReturn.dueDate.toIso8601String()),
      filedDate: Value(gstReturn.filedDate?.toIso8601String()),
      status: Value(gstReturn.status.name),
      taxableValue: Value(gstReturn.taxableValue),
      igst: Value(gstReturn.igst),
      cgst: Value(gstReturn.cgst),
      sgst: Value(gstReturn.sgst),
      cess: Value(gstReturn.cess),
      itcClaimed: Value(gstReturn.itcClaimed),
      isDirty: const Value(true),
    );
  }

  static GstReturnType _safeReturnType(String name) {
    try {
      return GstReturnType.values.byName(name);
    } catch (_) {
      return GstReturnType.gstr1;
    }
  }

  static GstReturnStatus _safeReturnStatus(String name) {
    try {
      return GstReturnStatus.values.byName(name);
    } catch (_) {
      return GstReturnStatus.pending;
    }
  }

  static DateTime? _parseDate(String? s) {
    if (s == null) return null;
    return DateTime.tryParse(s);
  }
}
