import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/portal_parser/domain/models/portal_import.dart';

class PortalImportMapper {
  const PortalImportMapper._();

  // JSON (from Supabase) → PortalImport domain model
  static PortalImport fromJson(Map<String, dynamic> json) {
    return PortalImport(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      importType: _safeImportType(json['import_type'] as String? ?? 'form26as'),
      importDate: DateTime.parse(
        json['import_date'] as String? ?? DateTime.now().toIso8601String(),
      ),
      rawData: json['raw_data'] as String?,
      parsedRecords: json['parsed_records'] as int?,
      status: _safeStatus(json['status'] as String? ?? 'pending'),
      errorMessage: json['error_message'] as String?,
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  // PortalImport → JSON (for Supabase insert/update)
  static Map<String, dynamic> toJson(PortalImport import) {
    return {
      'id': import.id,
      'client_id': import.clientId,
      'import_type': import.importType.name,
      'import_date': import.importDate.toIso8601String(),
      'raw_data': import.rawData,
      'parsed_records': import.parsedRecords,
      'status': import.status.name,
      'error_message': import.errorMessage,
    };
  }

  // Drift row → PortalImport domain model
  static PortalImport fromRow(PortalImportRow row) {
    return PortalImport(
      id: row.id,
      clientId: row.clientId,
      importType: _safeImportType(row.importType),
      importDate: row.importDate,
      rawData: row.rawData,
      parsedRecords: row.parsedRecords,
      status: _safeStatus(row.status),
      errorMessage: row.errorMessage,
      createdAt: row.createdAt,
    );
  }

  // PortalImport → Drift companion
  static PortalImportsTableCompanion toCompanion(PortalImport import) {
    return PortalImportsTableCompanion(
      id: Value(import.id),
      clientId: Value(import.clientId),
      importType: Value(import.importType.name),
      importDate: Value(import.importDate),
      rawData: Value(import.rawData),
      parsedRecords: Value(import.parsedRecords),
      status: Value(import.status.name),
      errorMessage: Value(import.errorMessage),
      createdAt: Value(import.createdAt),
      isDirty: const Value(true),
    );
  }

  static ImportType _safeImportType(String name) {
    try {
      return ImportType.values.byName(name);
    } catch (_) {
      return ImportType.form26as;
    }
  }

  static ImportStatus _safeStatus(String name) {
    try {
      return ImportStatus.values.byName(name);
    } catch (_) {
      return ImportStatus.pending;
    }
  }
}
