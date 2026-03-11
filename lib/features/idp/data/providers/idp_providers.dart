import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/idp/domain/models/document_job.dart';
import 'package:ca_app/features/idp/domain/models/extracted_field.dart';

// ---------------------------------------------------------------------------
// Mock data — 10 document jobs
// ---------------------------------------------------------------------------

final _mockDocumentJobs = <DocumentJob>[
  const DocumentJob(
    id: 'job-01',
    clientName: 'Rajesh Kumar',
    documentType: 'Form 16',
    fileName: 'Rajesh_Kumar_Form16_FY2024-25.pdf',
    status: 'Completed',
    confidenceScore: 0.98,
    totalFields: 24,
    extractedFields: 24,
    flaggedFields: 0,
    submittedDate: '10 Mar 2026',
    processingTime: '1.8s',
  ),
  const DocumentJob(
    id: 'job-02',
    clientName: 'Priya Mehta',
    documentType: '26AS',
    fileName: 'Priya_Mehta_26AS_FY2024-25.pdf',
    status: 'Completed',
    confidenceScore: 0.95,
    totalFields: 18,
    extractedFields: 18,
    flaggedFields: 1,
    submittedDate: '10 Mar 2026',
    processingTime: '2.1s',
  ),
  const DocumentJob(
    id: 'job-03',
    clientName: 'Amit Shah',
    documentType: 'Bank Statement',
    fileName: 'Amit_Shah_HDFC_Statement_FY2024-25.pdf',
    status: 'Review',
    confidenceScore: 0.87,
    totalFields: 48,
    extractedFields: 45,
    flaggedFields: 3,
    submittedDate: '11 Mar 2026',
    processingTime: '4.2s',
  ),
  const DocumentJob(
    id: 'job-04',
    clientName: 'Sunita Patel',
    documentType: 'AIS',
    fileName: 'Sunita_Patel_AIS_FY2024-25.pdf',
    status: 'Processing',
    confidenceScore: 0.0,
    totalFields: 22,
    extractedFields: 0,
    flaggedFields: 0,
    submittedDate: '11 Mar 2026',
    processingTime: 'pending',
  ),
  const DocumentJob(
    id: 'job-05',
    clientName: 'GreenBuild Infra',
    documentType: 'P&L',
    fileName: 'GreenBuild_Infra_PL_FY2024-25.pdf',
    status: 'Completed',
    confidenceScore: 0.92,
    totalFields: 34,
    extractedFields: 32,
    flaggedFields: 2,
    submittedDate: '09 Mar 2026',
    processingTime: '3.6s',
  ),
  const DocumentJob(
    id: 'job-06',
    clientName: 'TechForge Pvt Ltd',
    documentType: 'Balance Sheet',
    fileName: 'TechForge_BalanceSheet_FY2024-25.pdf',
    status: 'Review',
    confidenceScore: 0.89,
    totalFields: 30,
    extractedFields: 28,
    flaggedFields: 2,
    submittedDate: '10 Mar 2026',
    processingTime: '3.1s',
  ),
  const DocumentJob(
    id: 'job-07',
    clientName: 'Kavitha Nair',
    documentType: 'Form 16',
    fileName: 'Kavitha_Nair_Form16_FY2024-25.pdf',
    status: 'Completed',
    confidenceScore: 0.99,
    totalFields: 24,
    extractedFields: 24,
    flaggedFields: 0,
    submittedDate: '08 Mar 2026',
    processingTime: '1.5s',
  ),
  const DocumentJob(
    id: 'job-08',
    clientName: 'Ravi Verma',
    documentType: 'Salary Slip',
    fileName: 'Ravi_Verma_SalarySlips_12months.zip',
    status: 'Queued',
    confidenceScore: 0.0,
    totalFields: 0,
    extractedFields: 0,
    flaggedFields: 0,
    submittedDate: '11 Mar 2026',
    processingTime: 'pending',
  ),
  const DocumentJob(
    id: 'job-09',
    clientName: 'Meena Krishnan',
    documentType: 'TIS',
    fileName: 'Meena_Krishnan_TIS_FY2024-25.pdf',
    status: 'Failed',
    confidenceScore: 0.0,
    totalFields: 0,
    extractedFields: 0,
    flaggedFields: 0,
    submittedDate: '09 Mar 2026',
    processingTime: '0.3s',
  ),
  const DocumentJob(
    id: 'job-10',
    clientName: 'Shyam Lal',
    documentType: 'Bank Statement',
    fileName: 'Shyam_Lal_SBI_Statement_FY2024-25.pdf',
    status: 'Completed',
    confidenceScore: 0.91,
    totalFields: 45,
    extractedFields: 42,
    flaggedFields: 3,
    submittedDate: '08 Mar 2026',
    processingTime: '3.9s',
  ),
];

// ---------------------------------------------------------------------------
// Mock data — 15 extracted fields across 4 completed jobs
// ---------------------------------------------------------------------------

final _mockExtractedFields = <ExtractedField>[
  // job-01  Rajesh Kumar — Form 16
  const ExtractedField(
    id: 'ef-01',
    jobId: 'job-01',
    fieldName: 'PAN',
    extractedValue: 'ABCKR1234A',
    confidence: 0.99,
    needsReview: false,
  ),
  const ExtractedField(
    id: 'ef-02',
    jobId: 'job-01',
    fieldName: 'Employer Name',
    extractedValue: 'Infosys Technologies Ltd',
    confidence: 0.98,
    needsReview: false,
  ),
  const ExtractedField(
    id: 'ef-03',
    jobId: 'job-01',
    fieldName: 'Gross Salary',
    extractedValue: '₹18,40,000',
    confidence: 0.97,
    needsReview: false,
  ),
  const ExtractedField(
    id: 'ef-04',
    jobId: 'job-01',
    fieldName: 'TDS Deducted',
    extractedValue: '₹2,10,500',
    confidence: 0.98,
    needsReview: false,
  ),
  // job-02  Priya Mehta — 26AS
  const ExtractedField(
    id: 'ef-05',
    jobId: 'job-02',
    fieldName: 'PAN',
    extractedValue: 'BQKPM5678B',
    confidence: 0.99,
    needsReview: false,
  ),
  const ExtractedField(
    id: 'ef-06',
    jobId: 'job-02',
    fieldName: 'Total TDS (Part A)',
    extractedValue: '₹84,200',
    confidence: 0.96,
    needsReview: false,
  ),
  const ExtractedField(
    id: 'ef-07',
    jobId: 'job-02',
    fieldName: 'Advance Tax Paid',
    extractedValue: '₹12,500',
    confidence: 0.72,
    needsReview: true,
    correctedValue: '₹12,000',
  ),
  // job-05  GreenBuild Infra — P&L
  const ExtractedField(
    id: 'ef-08',
    jobId: 'job-05',
    fieldName: 'Total Revenue',
    extractedValue: '₹4,82,00,000',
    confidence: 0.93,
    needsReview: false,
  ),
  const ExtractedField(
    id: 'ef-09',
    jobId: 'job-05',
    fieldName: 'Cost of Materials',
    extractedValue: '₹2,91,50,000',
    confidence: 0.91,
    needsReview: false,
  ),
  const ExtractedField(
    id: 'ef-10',
    jobId: 'job-05',
    fieldName: 'Net Profit',
    extractedValue: '₹68,40,000',
    confidence: 0.88,
    needsReview: true,
  ),
  const ExtractedField(
    id: 'ef-11',
    jobId: 'job-05',
    fieldName: 'Depreciation',
    extractedValue: '₹14,20,000',
    confidence: 0.65,
    needsReview: true,
  ),
  // job-07  Kavitha Nair — Form 16
  const ExtractedField(
    id: 'ef-12',
    jobId: 'job-07',
    fieldName: 'PAN',
    extractedValue: 'CNKRK9012C',
    confidence: 0.99,
    needsReview: false,
  ),
  const ExtractedField(
    id: 'ef-13',
    jobId: 'job-07',
    fieldName: 'Employer Name',
    extractedValue: 'Wipro Limited',
    confidence: 0.99,
    needsReview: false,
  ),
  const ExtractedField(
    id: 'ef-14',
    jobId: 'job-07',
    fieldName: 'Gross Salary',
    extractedValue: '₹12,80,000',
    confidence: 0.99,
    needsReview: false,
  ),
  const ExtractedField(
    id: 'ef-15',
    jobId: 'job-07',
    fieldName: 'TDS Deducted',
    extractedValue: '₹98,400',
    confidence: 0.98,
    needsReview: false,
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final allDocumentJobsProvider = Provider<List<DocumentJob>>((ref) {
  return List.unmodifiable(_mockDocumentJobs);
});

final allExtractedFieldsProvider = Provider<List<ExtractedField>>((ref) {
  return List.unmodifiable(_mockExtractedFields);
});

// Status filter notifier
class SelectedDocStatusNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? status) => state = status;
}

final selectedDocStatusProvider =
    NotifierProvider<SelectedDocStatusNotifier, String?>(
  SelectedDocStatusNotifier.new,
);

final filteredDocumentJobsProvider = Provider<List<DocumentJob>>((ref) {
  final all = ref.watch(allDocumentJobsProvider);
  final status = ref.watch(selectedDocStatusProvider);
  if (status == null) {
    return all;
  }
  return List.unmodifiable(all.where((j) => j.status == status).toList());
});

final fieldsForJobProvider =
    Provider.family<List<ExtractedField>, String>((ref, jobId) {
  final all = ref.watch(allExtractedFieldsProvider);
  return List.unmodifiable(all.where((f) => f.jobId == jobId).toList());
});
