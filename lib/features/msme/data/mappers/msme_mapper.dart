import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/msme/domain/models/msme_record.dart';

/// Converts between [MsmeRecord] (domain) and Drift / Supabase representations.
class MsmeMapper {
  const MsmeMapper._();

  // ---------------------------------------------------------------------------
  // JSON (Supabase) → domain
  // ---------------------------------------------------------------------------

  static MsmeRecord fromJson(Map<String, dynamic> json) {
    return MsmeRecord(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      udyamNumber: json['udyam_number'] as String? ?? '',
      registrationDate: DateTime.parse(
        json['registration_date'] as String? ??
            DateTime.now().toIso8601String(),
      ),
      category: _safeCategory(json['category'] as String? ?? 'micro'),
      annualTurnover: json['annual_turnover'] as String?,
      employeeCount: json['employee_count'] as int?,
      status: json['status'] as String? ?? 'active',
    );
  }

  // ---------------------------------------------------------------------------
  // Domain → JSON (Supabase insert / update)
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> toJson(MsmeRecord record) {
    return {
      'id': record.id,
      'client_id': record.clientId,
      'udyam_number': record.udyamNumber,
      'registration_date': record.registrationDate.toIso8601String(),
      'category': record.category.name,
      'annual_turnover': record.annualTurnover,
      'employee_count': record.employeeCount,
      'status': record.status,
    };
  }

  // ---------------------------------------------------------------------------
  // Drift row → domain
  // ---------------------------------------------------------------------------

  static MsmeRecord fromRow(MsmeRecordsTableData row) {
    return MsmeRecord(
      id: row.id,
      clientId: row.clientId,
      udyamNumber: row.udyamNumber,
      registrationDate: row.registrationDate,
      category: _safeCategory(row.category ?? 'micro'),
      annualTurnover: row.annualTurnover,
      employeeCount: row.employeeCount,
      status: row.status ?? 'active',
    );
  }

  // ---------------------------------------------------------------------------
  // Domain → Drift companion
  // ---------------------------------------------------------------------------

  static MsmeRecordsTableCompanion toCompanion(MsmeRecord record) {
    return MsmeRecordsTableCompanion(
      id: Value(record.id),
      clientId: Value(record.clientId),
      udyamNumber: Value(record.udyamNumber),
      registrationDate: Value(record.registrationDate),
      category: Value(record.category.name),
      annualTurnover: Value(record.annualTurnover),
      employeeCount: Value(record.employeeCount),
      status: Value(record.status),
      updatedAt: Value(DateTime.now()),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static MsmeCategory _safeCategory(String value) {
    try {
      return MsmeCategory.values.firstWhere((e) => e.name == value);
    } catch (_) {
      return MsmeCategory.micro;
    }
  }
}
