import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/features/idp/domain/models/document_job.dart';
import 'package:ca_app/features/idp/domain/models/extracted_field.dart';
import 'package:ca_app/features/idp/domain/repositories/idp_repository.dart';

/// Real implementation of [IdpRepository] backed by Supabase.
///
/// Falls back to empty results on network errors to keep the UI responsive.
class IdpRepositoryImpl implements IdpRepository {
  const IdpRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const _jobsTable = 'document_jobs';
  static const _fieldsTable = 'extracted_fields';

  // -------------------------------------------------------------------------
  // DocumentJob
  // -------------------------------------------------------------------------

  @override
  Future<List<DocumentJob>> getDocumentJobs() async {
    try {
      final rows = await _client.from(_jobsTable).select();
      return List.unmodifiable((rows as List).map(_jobFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<DocumentJob>> getDocumentJobsByStatus(String status) async {
    try {
      final rows = await _client.from(_jobsTable).select().eq('status', status);
      return List.unmodifiable((rows as List).map(_jobFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<DocumentJob?> getDocumentJobById(String id) async {
    try {
      final row = await _client.from(_jobsTable).select().eq('id', id).single();
      return _jobFromRow(row);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String> insertDocumentJob(DocumentJob job) async {
    final row = await _client
        .from(_jobsTable)
        .insert(_jobToRow(job))
        .select()
        .single();
    return row['id'] as String;
  }

  @override
  Future<bool> updateDocumentJob(DocumentJob job) async {
    try {
      await _client.from(_jobsTable).update(_jobToRow(job)).eq('id', job.id);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteDocumentJob(String id) async {
    try {
      await _client.from(_jobsTable).delete().eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // ExtractedField
  // -------------------------------------------------------------------------

  @override
  Future<List<ExtractedField>> getExtractedFields() async {
    try {
      final rows = await _client.from(_fieldsTable).select();
      return List.unmodifiable((rows as List).map(_fieldFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<ExtractedField>> getExtractedFieldsByJob(String jobId) async {
    try {
      final rows = await _client
          .from(_fieldsTable)
          .select()
          .eq('job_id', jobId);
      return List.unmodifiable((rows as List).map(_fieldFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<bool> updateExtractedField(ExtractedField field) async {
    try {
      await _client
          .from(_fieldsTable)
          .update(_fieldToRow(field))
          .eq('id', field.id);
      return true;
    } catch (_) {
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // Mappers
  // -------------------------------------------------------------------------

  DocumentJob _jobFromRow(dynamic row) {
    final m = row as Map<String, dynamic>;
    return DocumentJob(
      id: m['id'] as String,
      clientName: m['client_name'] as String,
      documentType: m['document_type'] as String,
      fileName: m['file_name'] as String,
      status: m['status'] as String,
      confidenceScore: (m['confidence_score'] as num).toDouble(),
      totalFields: m['total_fields'] as int,
      extractedFields: m['extracted_fields'] as int,
      flaggedFields: m['flagged_fields'] as int,
      submittedDate: m['submitted_date'] as String,
      processingTime: m['processing_time'] as String,
    );
  }

  Map<String, dynamic> _jobToRow(DocumentJob j) => {
    'id': j.id,
    'client_name': j.clientName,
    'document_type': j.documentType,
    'file_name': j.fileName,
    'status': j.status,
    'confidence_score': j.confidenceScore,
    'total_fields': j.totalFields,
    'extracted_fields': j.extractedFields,
    'flagged_fields': j.flaggedFields,
    'submitted_date': j.submittedDate,
    'processing_time': j.processingTime,
  };

  ExtractedField _fieldFromRow(dynamic row) {
    final m = row as Map<String, dynamic>;
    return ExtractedField(
      id: m['id'] as String,
      jobId: m['job_id'] as String,
      fieldName: m['field_name'] as String,
      extractedValue: m['extracted_value'] as String,
      confidence: (m['confidence'] as num).toDouble(),
      needsReview: m['needs_review'] as bool,
      correctedValue: m['corrected_value'] as String?,
    );
  }

  Map<String, dynamic> _fieldToRow(ExtractedField f) => {
    'id': f.id,
    'job_id': f.jobId,
    'field_name': f.fieldName,
    'extracted_value': f.extractedValue,
    'confidence': f.confidence,
    'needs_review': f.needsReview,
    'corrected_value': f.correctedValue,
  };
}
