import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/nri_tax/domain/models/nri_tax_record.dart';

class NriTaxMapper {
  const NriTaxMapper._();

  // ---------------------------------------------------------------------------
  // JSON (from Supabase) → NriTaxRecord domain model
  // ---------------------------------------------------------------------------

  static NriTaxRecord fromJson(Map<String, dynamic> json) {
    return NriTaxRecord(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      assessmentYear: json['assessment_year'] as String,
      residencyStatus: _safeResidencyStatus(
        json['residency_status'] as String? ?? 'resident',
      ),
      foreignIncomeSources: json['foreign_income_sources'] as String?,
      dtaaCountry: json['dtaa_country'] as String?,
      dtaaRelief: (json['dtaa_relief'] as num?)?.toDouble(),
      scheduleFA: (json['schedule_fa'] as bool?) ?? false,
      scheduleFSL: (json['schedule_fsl'] as bool?) ?? false,
      status: _safeStatus(json['status'] as String? ?? 'draft'),
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // NriTaxRecord domain model → JSON (for Supabase insert/update)
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> toJson(NriTaxRecord record) {
    return {
      'id': record.id,
      'client_id': record.clientId,
      'assessment_year': record.assessmentYear,
      'residency_status': record.residencyStatus.name,
      'foreign_income_sources': record.foreignIncomeSources,
      'dtaa_country': record.dtaaCountry,
      'dtaa_relief': record.dtaaRelief,
      'schedule_fa': record.scheduleFA,
      'schedule_fsl': record.scheduleFSL,
      'status': record.status.name,
      'created_at': record.createdAt.toIso8601String(),
      'updated_at': record.updatedAt.toIso8601String(),
    };
  }

  // ---------------------------------------------------------------------------
  // Drift row → NriTaxRecord domain model
  // ---------------------------------------------------------------------------

  static NriTaxRecord fromRow(NriTaxRow row) {
    return NriTaxRecord(
      id: row.id,
      clientId: row.clientId,
      assessmentYear: row.assessmentYear,
      residencyStatus: _safeResidencyStatus(row.residencyStatus),
      foreignIncomeSources: row.foreignIncomeSources,
      dtaaCountry: row.dtaaCountry,
      dtaaRelief: row.dtaaRelief,
      scheduleFA: row.scheduleFA,
      scheduleFSL: row.scheduleFSL,
      status: _safeStatus(row.status),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  // ---------------------------------------------------------------------------
  // NriTaxRecord → Drift companion (for insert/update)
  // ---------------------------------------------------------------------------

  static NriTaxTableCompanion toCompanion(NriTaxRecord record) {
    return NriTaxTableCompanion(
      id: Value(record.id),
      clientId: Value(record.clientId),
      assessmentYear: Value(record.assessmentYear),
      residencyStatus: Value(record.residencyStatus.name),
      foreignIncomeSources: Value(record.foreignIncomeSources),
      dtaaCountry: Value(record.dtaaCountry),
      dtaaRelief: Value(record.dtaaRelief),
      scheduleFA: Value(record.scheduleFA),
      scheduleFSL: Value(record.scheduleFSL),
      status: Value(record.status.name),
      createdAt: Value(record.createdAt),
      updatedAt: Value(record.updatedAt),
      isDirty: const Value(true),
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static ResidencyStatus _safeResidencyStatus(String name) {
    try {
      return ResidencyStatus.values.byName(name);
    } catch (_) {
      return ResidencyStatus.resident;
    }
  }

  static NriTaxStatus _safeStatus(String name) {
    try {
      return NriTaxStatus.values.byName(name);
    } catch (_) {
      return NriTaxStatus.draft;
    }
  }
}
