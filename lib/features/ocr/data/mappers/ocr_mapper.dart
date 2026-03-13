import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/ocr/domain/models/ocr_job.dart';

const _uuid = Uuid();

class OcrMapper {
  const OcrMapper._();

  static OcrJob fromRow(OcrJobRow row) {
    return OcrJob(
      id: row.id,
      clientId: row.clientId,
      documentType: _safeDocType(row.documentType),
      inputFilePath: row.inputFilePath,
      status: _safeStatus(row.status),
      parsedData: row.parsedData,
      confidence: row.confidence,
      createdAt: row.createdAt,
      completedAt: row.completedAt,
      errorMessage: row.errorMessage,
    );
  }

  static OcrJobsTableCompanion toCompanion(OcrJob job) {
    return OcrJobsTableCompanion(
      id: Value(job.id.isEmpty ? _uuid.v4() : job.id),
      clientId: Value(job.clientId),
      documentType: Value(job.documentType.name),
      inputFilePath: Value(job.inputFilePath),
      status: Value(job.status.name),
      parsedData: Value(job.parsedData),
      confidence: Value(job.confidence),
      createdAt: Value(job.createdAt),
      completedAt: Value(job.completedAt),
      errorMessage: Value(job.errorMessage),
    );
  }

  static OcrJob fromJson(Map<String, dynamic> json) {
    return OcrJob(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      documentType: _safeDocType(json['document_type'] as String),
      inputFilePath: json['input_file_path'] as String,
      status: _safeStatus(json['status'] as String),
      parsedData: json['parsed_data'] as String?,
      confidence: (json['confidence'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      errorMessage: json['error_message'] as String?,
    );
  }

  static Map<String, dynamic> toJson(OcrJob job) {
    return {
      'id': job.id,
      'client_id': job.clientId,
      'document_type': job.documentType.name,
      'input_file_path': job.inputFilePath,
      'status': job.status.name,
      'parsed_data': job.parsedData,
      'confidence': job.confidence,
      'created_at': job.createdAt.toIso8601String(),
      'completed_at': job.completedAt?.toIso8601String(),
      'error_message': job.errorMessage,
    };
  }

  static OcrDocType _safeDocType(String name) {
    try {
      return OcrDocType.values.byName(name);
    } catch (_) {
      return OcrDocType.invoice;
    }
  }

  static OcrStatus _safeStatus(String name) {
    try {
      return OcrStatus.values.byName(name);
    } catch (_) {
      return OcrStatus.queued;
    }
  }
}
