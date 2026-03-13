import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/startup/domain/models/startup_record.dart';

/// Converts between [StartupRecord] (domain) and Drift / Supabase
/// representations.
class StartupMapper {
  const StartupMapper._();

  // ---------------------------------------------------------------------------
  // JSON (Supabase) → domain
  // ---------------------------------------------------------------------------

  static StartupRecord fromJson(Map<String, dynamic> json) {
    return StartupRecord(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      dpiitNumber: json['dpiit_number'] as String? ?? '',
      incorporationDate: DateTime.parse(
        json['incorporation_date'] as String? ??
            DateTime.now().toIso8601String(),
      ),
      sectorCategory: json['sector_category'] as String? ?? '',
      recognitionStatus: json['recognition_status'] as String? ?? 'pending',
      section80IacEligible:
          json['section_80iac_eligible'] as bool? ?? false,
      section56ExemptEligible:
          json['section_56_exempt_eligible'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  // ---------------------------------------------------------------------------
  // Domain → JSON (Supabase insert / update)
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> toJson(StartupRecord record) {
    return {
      'id': record.id,
      'client_id': record.clientId,
      'dpiit_number': record.dpiitNumber,
      'incorporation_date': record.incorporationDate.toIso8601String(),
      'sector_category': record.sectorCategory,
      'recognition_status': record.recognitionStatus,
      'section_80iac_eligible': record.section80IacEligible,
      'section_56_exempt_eligible': record.section56ExemptEligible,
      'notes': record.notes,
    };
  }

  // ---------------------------------------------------------------------------
  // Drift row → domain
  // ---------------------------------------------------------------------------

  static StartupRecord fromRow(StartupRecordsTableData row) {
    return StartupRecord(
      id: row.id,
      clientId: row.clientId,
      dpiitNumber: row.dpiitNumber,
      incorporationDate: row.incorporationDate,
      sectorCategory: row.sectorCategory ?? '',
      recognitionStatus: row.recognitionStatus ?? 'pending',
      section80IacEligible: row.section80IacEligible,
      section56ExemptEligible: row.section56ExemptEligible,
      notes: row.notes,
    );
  }

  // ---------------------------------------------------------------------------
  // Domain → Drift companion
  // ---------------------------------------------------------------------------

  static StartupRecordsTableCompanion toCompanion(StartupRecord record) {
    return StartupRecordsTableCompanion(
      id: Value(record.id),
      clientId: Value(record.clientId),
      dpiitNumber: Value(record.dpiitNumber),
      incorporationDate: Value(record.incorporationDate),
      sectorCategory: Value(record.sectorCategory),
      recognitionStatus: Value(record.recognitionStatus),
      section80IacEligible: Value(record.section80IacEligible),
      section56ExemptEligible: Value(record.section56ExemptEligible),
      notes: Value(record.notes),
      updatedAt: Value(DateTime.now()),
    );
  }
}
