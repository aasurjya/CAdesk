import 'package:ca_app/features/idp/domain/models/document_job.dart';
import 'package:ca_app/features/idp/domain/models/extracted_field.dart';
import 'package:ca_app/features/idp/domain/repositories/idp_repository.dart';

/// In-memory mock implementation of [IdpRepository].
///
/// Seeded with realistic sample data for development and testing.
/// All state mutations return new lists (immutable patterns).
class MockIdpRepository implements IdpRepository {
  static const List<DocumentJob> _seedJobs = [
    DocumentJob(
      id: 'mock-job-001',
      clientName: 'Rajesh Kumar Sharma',
      documentType: 'Form 16',
      fileName: 'form16_fy2025_rajesh.pdf',
      status: 'Completed',
      confidenceScore: 0.96,
      totalFields: 24,
      extractedFields: 23,
      flaggedFields: 1,
      submittedDate: '10 Mar 2026',
      processingTime: '1.8s',
    ),
    DocumentJob(
      id: 'mock-job-002',
      clientName: 'Priya Nair',
      documentType: '26AS',
      fileName: '26as_fy2025_priya.pdf',
      status: 'Review',
      confidenceScore: 0.82,
      totalFields: 18,
      extractedFields: 15,
      flaggedFields: 3,
      submittedDate: '11 Mar 2026',
      processingTime: '2.4s',
    ),
    DocumentJob(
      id: 'mock-job-003',
      clientName: 'Patel Trading Company',
      documentType: 'Bank Statement',
      fileName: 'bank_stmt_mar2026_patel.pdf',
      status: 'Processing',
      confidenceScore: 0.0,
      totalFields: 50,
      extractedFields: 20,
      flaggedFields: 0,
      submittedDate: '14 Mar 2026',
      processingTime: 'pending',
    ),
  ];

  static const List<ExtractedField> _seedFields = [
    ExtractedField(
      id: 'mock-field-001',
      jobId: 'mock-job-001',
      fieldName: 'Gross Salary',
      extractedValue: '8,40,000',
      confidence: 0.98,
      needsReview: false,
    ),
    ExtractedField(
      id: 'mock-field-002',
      jobId: 'mock-job-001',
      fieldName: 'TDS Deducted',
      extractedValue: '72,500',
      confidence: 0.62,
      needsReview: true,
    ),
    ExtractedField(
      id: 'mock-field-003',
      jobId: 'mock-job-002',
      fieldName: 'Total Tax Deducted',
      extractedValue: '1,25,000',
      confidence: 0.88,
      needsReview: false,
    ),
  ];

  final List<DocumentJob> _jobs = List.of(_seedJobs);
  final List<ExtractedField> _fields = List.of(_seedFields);

  // -------------------------------------------------------------------------
  // DocumentJob
  // -------------------------------------------------------------------------

  @override
  Future<List<DocumentJob>> getDocumentJobs() async => List.unmodifiable(_jobs);

  @override
  Future<List<DocumentJob>> getDocumentJobsByStatus(String status) async =>
      List.unmodifiable(_jobs.where((j) => j.status == status).toList());

  @override
  Future<DocumentJob?> getDocumentJobById(String id) async {
    final matches = _jobs.where((j) => j.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Future<String> insertDocumentJob(DocumentJob job) async {
    _jobs.add(job);
    return job.id;
  }

  @override
  Future<bool> updateDocumentJob(DocumentJob job) async {
    final idx = _jobs.indexWhere((j) => j.id == job.id);
    if (idx == -1) return false;
    final updated = List<DocumentJob>.of(_jobs)..[idx] = job;
    _jobs
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteDocumentJob(String id) async {
    final before = _jobs.length;
    _jobs.removeWhere((j) => j.id == id);
    return _jobs.length < before;
  }

  // -------------------------------------------------------------------------
  // ExtractedField
  // -------------------------------------------------------------------------

  @override
  Future<List<ExtractedField>> getExtractedFields() async =>
      List.unmodifiable(_fields);

  @override
  Future<List<ExtractedField>> getExtractedFieldsByJob(String jobId) async =>
      List.unmodifiable(_fields.where((f) => f.jobId == jobId).toList());

  @override
  Future<bool> updateExtractedField(ExtractedField field) async {
    final idx = _fields.indexWhere((f) => f.id == field.id);
    if (idx == -1) return false;
    final updated = List<ExtractedField>.of(_fields)..[idx] = field;
    _fields
      ..clear()
      ..addAll(updated);
    return true;
  }
}
