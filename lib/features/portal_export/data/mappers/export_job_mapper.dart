import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/portal_export/domain/models/export_job.dart';

class ExportJobMapper {
  const ExportJobMapper._();

  // JSON (from Supabase) → ExportJob domain model
  static ExportJob fromJson(Map<String, dynamic> json) {
    return ExportJob(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      exportType: _safeExportType(json['export_type'] as String? ?? 'itrXml'),
      status: _safeStatus(json['status'] as String? ?? 'queued'),
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      completedAt: _parseDate(json['completed_at'] as String?),
      filePath: json['file_path'] as String?,
      errorMessage: json['error_message'] as String?,
    );
  }

  // ExportJob → JSON (for Supabase insert/update)
  static Map<String, dynamic> toJson(ExportJob job) {
    return {
      'id': job.id,
      'client_id': job.clientId,
      'export_type': job.exportType.name,
      'status': job.status.name,
      'completed_at': job.completedAt?.toIso8601String(),
      'file_path': job.filePath,
      'error_message': job.errorMessage,
    };
  }

  // Drift row → ExportJob domain model
  static ExportJob fromRow(ExportJobRow row) {
    return ExportJob(
      id: row.id,
      clientId: row.clientId,
      exportType: _safeExportType(row.exportType),
      status: _safeStatus(row.status),
      createdAt: row.createdAt,
      completedAt: row.completedAt,
      filePath: row.filePath,
      errorMessage: row.errorMessage,
    );
  }

  // ExportJob → Drift companion
  static ExportJobsTableCompanion toCompanion(ExportJob job) {
    return ExportJobsTableCompanion(
      id: Value(job.id),
      clientId: Value(job.clientId),
      exportType: Value(job.exportType.name),
      status: Value(job.status.name),
      createdAt: Value(job.createdAt),
      completedAt: Value(job.completedAt),
      filePath: Value(job.filePath),
      errorMessage: Value(job.errorMessage),
      isDirty: const Value(true),
    );
  }

  static DateTime? _parseDate(String? s) {
    if (s == null) return null;
    return DateTime.tryParse(s);
  }

  static ExportType _safeExportType(String name) {
    try {
      return ExportType.values.byName(name);
    } catch (_) {
      return ExportType.itrXml;
    }
  }

  static ExportJobStatus _safeStatus(String name) {
    try {
      return ExportJobStatus.values.byName(name);
    } catch (_) {
      return ExportJobStatus.queued;
    }
  }
}
