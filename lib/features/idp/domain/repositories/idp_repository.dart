import 'package:ca_app/features/idp/domain/models/document_job.dart';
import 'package:ca_app/features/idp/domain/models/extracted_field.dart';

/// Abstract contract for Intelligent Document Processing (IDP) data operations.
///
/// Covers document processing jobs and their extracted fields.
abstract class IdpRepository {
  // -------------------------------------------------------------------------
  // DocumentJob operations
  // -------------------------------------------------------------------------

  /// Retrieve all document jobs.
  Future<List<DocumentJob>> getDocumentJobs();

  /// Retrieve document jobs filtered by [status].
  Future<List<DocumentJob>> getDocumentJobsByStatus(String status);

  /// Retrieve a single document job by [id]. Returns null if not found.
  Future<DocumentJob?> getDocumentJobById(String id);

  /// Insert a new [DocumentJob] and return its ID.
  Future<String> insertDocumentJob(DocumentJob job);

  /// Update an existing [DocumentJob]. Returns true on success.
  Future<bool> updateDocumentJob(DocumentJob job);

  /// Delete the document job identified by [id]. Returns true on success.
  Future<bool> deleteDocumentJob(String id);

  // -------------------------------------------------------------------------
  // ExtractedField operations
  // -------------------------------------------------------------------------

  /// Retrieve all extracted fields.
  Future<List<ExtractedField>> getExtractedFields();

  /// Retrieve extracted fields belonging to [jobId].
  Future<List<ExtractedField>> getExtractedFieldsByJob(String jobId);

  /// Update an existing [ExtractedField] (e.g. apply correction).
  /// Returns true on success.
  Future<bool> updateExtractedField(ExtractedField field);
}
