import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/payroll/domain/models/payroll_entry.dart';

/// Bi-directional converter between [PayrollEntry] domain model,
/// Drift [PayrollEntriesTableData] rows, and Supabase JSON maps.
///
/// All decimal monetary fields are persisted as strings to preserve
/// full precision without floating-point rounding.
class PayrollMapper {
  const PayrollMapper._();

  // ---------------------------------------------------------------------------
  // JSON (Supabase) → PayrollEntry domain model
  // ---------------------------------------------------------------------------
  static PayrollEntry fromJson(Map<String, dynamic> json) {
    return PayrollEntry(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      employeeId: json['employee_id'] as String? ?? '',
      month: json['month'] as int,
      year: json['year'] as int,
      basicSalary: _decimalString(json['basic_salary']),
      allowances: _decimalString(json['allowances']),
      deductions: _decimalString(json['deductions']),
      tdsDeducted: _decimalString(json['tds_deducted']),
      pfDeducted: _decimalString(json['pf_deducted']),
      esiDeducted: _decimalString(json['esi_deducted']),
      netSalary: _decimalString(json['net_salary']),
      status: json['status'] as String? ?? 'draft',
    );
  }

  // ---------------------------------------------------------------------------
  // PayrollEntry domain model → JSON (Supabase insert/update)
  // ---------------------------------------------------------------------------
  static Map<String, dynamic> toJson(PayrollEntry entry) {
    return {
      'id': entry.id,
      'client_id': entry.clientId,
      'employee_id': entry.employeeId,
      'month': entry.month,
      'year': entry.year,
      'basic_salary': entry.basicSalary,
      'allowances': entry.allowances,
      'deductions': entry.deductions,
      'tds_deducted': entry.tdsDeducted,
      'pf_deducted': entry.pfDeducted,
      'esi_deducted': entry.esiDeducted,
      'net_salary': entry.netSalary,
      'status': entry.status,
    };
  }

  // ---------------------------------------------------------------------------
  // Drift row → PayrollEntry domain model
  // ---------------------------------------------------------------------------
  static PayrollEntry fromRow(PayrollEntriesTableData row) {
    return PayrollEntry(
      id: row.id,
      clientId: row.clientId,
      employeeId: row.employeeId ?? '',
      month: row.month,
      year: row.year,
      basicSalary: row.basicSalary ?? '0.00',
      allowances: row.allowances ?? '0.00',
      deductions: row.deductions ?? '0.00',
      tdsDeducted: row.tdsDeducted ?? '0.00',
      pfDeducted: row.pfDeducted ?? '0.00',
      esiDeducted: row.esiDeducted ?? '0.00',
      netSalary: row.netSalary ?? '0.00',
      status: row.status ?? 'draft',
    );
  }

  // ---------------------------------------------------------------------------
  // PayrollEntry domain model → Drift companion (insert/update)
  // ---------------------------------------------------------------------------
  static PayrollEntriesTableCompanion toCompanion(PayrollEntry entry) {
    return PayrollEntriesTableCompanion(
      id: Value(entry.id),
      clientId: Value(entry.clientId),
      employeeId: Value(entry.employeeId.isEmpty ? null : entry.employeeId),
      month: Value(entry.month),
      year: Value(entry.year),
      basicSalary: Value(entry.basicSalary),
      allowances: Value(entry.allowances),
      deductions: Value(entry.deductions),
      tdsDeducted: Value(entry.tdsDeducted),
      pfDeducted: Value(entry.pfDeducted),
      esiDeducted: Value(entry.esiDeducted),
      netSalary: Value(entry.netSalary),
      status: Value(entry.status),
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Normalises a JSON value (String or num) to a decimal string.
  /// Returns '0.00' for null or unparseable input.
  static String _decimalString(dynamic raw) {
    if (raw == null) return '0.00';
    if (raw is String) return raw.isEmpty ? '0.00' : raw;
    if (raw is num) return raw.toStringAsFixed(2);
    return '0.00';
  }
}
