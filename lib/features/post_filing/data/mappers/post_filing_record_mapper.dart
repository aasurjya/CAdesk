import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/post_filing/domain/models/post_filing_record.dart';

class PostFilingRecordMapper {
  const PostFilingRecordMapper._();

  // JSON (from Supabase) → PostFilingRecord domain model
  static PostFilingRecord fromJson(Map<String, dynamic> json) {
    return PostFilingRecord(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      filingId: json['filing_id'] as String,
      activityType: _safeActivity(
        json['activity_type'] as String? ?? 'itrVDownload',
      ),
      status: _safeStatus(json['status'] as String? ?? 'pending'),
      completedAt: _parseDate(json['completed_at'] as String?),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  // PostFilingRecord → JSON (for Supabase insert/update)
  static Map<String, dynamic> toJson(PostFilingRecord record) {
    return {
      'id': record.id,
      'client_id': record.clientId,
      'filing_id': record.filingId,
      'activity_type': record.activityType.name,
      'status': record.status.name,
      'completed_at': record.completedAt?.toIso8601String(),
      'notes': record.notes,
    };
  }

  // Drift row → PostFilingRecord domain model
  static PostFilingRecord fromRow(PostFilingRecordRow row) {
    return PostFilingRecord(
      id: row.id,
      clientId: row.clientId,
      filingId: row.filingId,
      activityType: _safeActivity(row.activityType),
      status: _safeStatus(row.status),
      completedAt: row.completedAt,
      notes: row.notes,
      createdAt: row.createdAt,
    );
  }

  // PostFilingRecord → Drift companion
  static PostFilingRecordsTableCompanion toCompanion(PostFilingRecord record) {
    return PostFilingRecordsTableCompanion(
      id: Value(record.id),
      clientId: Value(record.clientId),
      filingId: Value(record.filingId),
      activityType: Value(record.activityType.name),
      status: Value(record.status.name),
      completedAt: Value(record.completedAt),
      notes: Value(record.notes),
      createdAt: Value(record.createdAt),
      isDirty: const Value(true),
    );
  }

  static DateTime? _parseDate(String? s) {
    if (s == null) return null;
    return DateTime.tryParse(s);
  }

  static PostFilingActivity _safeActivity(String name) {
    try {
      return PostFilingActivity.values.byName(name);
    } catch (_) {
      return PostFilingActivity.itrVDownload;
    }
  }

  static PostFilingStatus _safeStatus(String name) {
    try {
      return PostFilingStatus.values.byName(name);
    } catch (_) {
      return PostFilingStatus.pending;
    }
  }
}
