import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/filing/domain/models/filing_record.dart';

class FilingRecordMapper {
  const FilingRecordMapper._();

  // JSON (from Supabase) → FilingRecord domain model
  static FilingRecord fromJson(Map<String, dynamic> json) {
    return FilingRecord(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      filingType: _safeFilingType(json['filing_type'] as String? ?? 'itr1'),
      financialYear: json['financial_year'] as String,
      status: _safeFilingStatus(json['status'] as String? ?? 'pending'),
      filedDate: _parseDate(json['filed_date'] as String?),
      acknowledgementNumber: json['acknowledgement_number'] as String?,
      remarks: json['remarks'] as String?,
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  // FilingRecord → JSON (for Supabase insert/update)
  static Map<String, dynamic> toJson(FilingRecord record) {
    return {
      'id': record.id,
      'client_id': record.clientId,
      'filing_type': record.filingType.name,
      'financial_year': record.financialYear,
      'status': record.status.name,
      'filed_date': record.filedDate?.toIso8601String(),
      'acknowledgement_number': record.acknowledgementNumber,
      'remarks': record.remarks,
    };
  }

  // Drift row → FilingRecord domain model
  static FilingRecord fromRow(FilingRecordRow row) {
    return FilingRecord(
      id: row.id,
      clientId: row.clientId,
      filingType: _safeFilingType(row.filingType),
      financialYear: row.financialYear,
      status: _safeFilingStatus(row.status),
      filedDate: row.filedDate,
      acknowledgementNumber: row.acknowledgementNumber,
      remarks: row.remarks,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  // FilingRecord → Drift companion (for insert/update)
  static FilingRecordsTableCompanion toCompanion(FilingRecord record) {
    return FilingRecordsTableCompanion(
      id: Value(record.id),
      clientId: Value(record.clientId),
      filingType: Value(record.filingType.name),
      financialYear: Value(record.financialYear),
      status: Value(record.status.name),
      filedDate: Value(record.filedDate),
      acknowledgementNumber: Value(record.acknowledgementNumber),
      remarks: Value(record.remarks),
      createdAt: Value(record.createdAt),
      updatedAt: Value(record.updatedAt),
      isDirty: const Value(true),
    );
  }

  static DateTime? _parseDate(String? s) {
    if (s == null) return null;
    return DateTime.tryParse(s);
  }

  static FilingType _safeFilingType(String name) {
    try {
      return FilingType.values.byName(name);
    } catch (_) {
      return FilingType.itr1;
    }
  }

  static FilingStatus _safeFilingStatus(String name) {
    try {
      return FilingStatus.values.byName(name);
    } catch (_) {
      return FilingStatus.pending;
    }
  }
}
