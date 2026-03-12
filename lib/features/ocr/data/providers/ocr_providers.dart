import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/ocr/domain/models/ocr_document.dart';
import 'package:ca_app/features/ocr/domain/models/ocr_extracted_data.dart';
import 'package:ca_app/features/ocr/domain/models/ocr_extraction_result.dart';
import 'package:ca_app/features/ocr/domain/models/extracted_form16.dart';
import 'package:ca_app/features/ocr/domain/models/extracted_bank_statement.dart';
import 'package:ca_app/features/ocr/domain/models/extracted_invoice.dart';
import 'package:ca_app/features/ocr/domain/services/ocr_pipeline_service.dart';
import 'package:ca_app/features/ocr/domain/services/ocr_data_mapper_service.dart';

// ---------------------------------------------------------------------------
// OcrJob — UI-level job model wrapping an OcrDocument and optional result
// ---------------------------------------------------------------------------

enum OcrJobStatus { queued, processing, completed, failed }

class OcrJob {
  const OcrJob({
    required this.jobId,
    required this.fileName,
    required this.document,
    required this.status,
    this.result,
    this.errorMessage,
  });

  final String jobId;
  final String fileName;
  final OcrDocument document;
  final OcrJobStatus status;
  final OcrExtractionResult? result;
  final String? errorMessage;

  double get confidence => result?.document.confidence ?? document.confidence;

  OcrJob copyWith({
    String? jobId,
    String? fileName,
    OcrDocument? document,
    OcrJobStatus? status,
    OcrExtractionResult? result,
    String? errorMessage,
  }) {
    return OcrJob(
      jobId: jobId ?? this.jobId,
      fileName: fileName ?? this.fileName,
      document: document ?? this.document,
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ---------------------------------------------------------------------------
// Mock seed data — 5 diverse OCR jobs
// ---------------------------------------------------------------------------

final _now = DateTime(2026, 3, 12, 10, 30);

final _mockJobs = <OcrJob>[
  OcrJob(
    jobId: 'job-001',
    fileName: 'Form16_Rajesh_AY2026.pdf',
    document: OcrDocument(
      documentId: 'doc-001',
      documentType: DocumentType.form16,
      rawText:
          'FORM NO. 16\n'
          'Name and address of the Employer: Infosys Ltd\n'
          'Assessment Year: 2025-26\n'
          'TAN of Deductor: BLRA01234C\n'
          'PAN of Employee: ABCDE1234F\n'
          'Gross Salary: 1800000\n'
          'Standard Deduction: 50000\n'
          'Taxable Income: 1750000\n'
          'Tax Deducted: 320000',
      confidence: 0.94,
      extractedAt: _now.subtract(const Duration(hours: 2)),
      pageCount: 2,
      processingStatus: ProcessingStatus.completed,
    ),
    status: OcrJobStatus.completed,
    result: OcrExtractionResult(
      document: OcrDocument(
        documentId: 'doc-001',
        documentType: DocumentType.form16,
        rawText: '',
        confidence: 0.94,
        extractedAt: _now.subtract(const Duration(hours: 2)),
        pageCount: 2,
        processingStatus: ProcessingStatus.completed,
      ),
      extractedData: const Form16ExtractedData(
        ExtractedForm16(
          employeePan: 'ABCDE1234F',
          employerTan: 'BLRA01234C',
          employerName: 'Infosys Ltd',
          financialYear: 2025,
          assessmentYear: '2025-26',
          grossSalary: 180000000,
          taxableIncome: 175000000,
          tdsDeducted: 32000000,
          professionalTax: 240000,
          standardDeduction: 5000000,
          confidence: 0.94,
        ),
      ),
      validationErrors: const [],
      requiresManualReview: false,
    ),
  ),
  OcrJob(
    jobId: 'job-002',
    fileName: 'BankStatement_HDFC_Feb2026.pdf',
    document: OcrDocument(
      documentId: 'doc-002',
      documentType: DocumentType.bankStatement,
      rawText:
          'STATEMENT OF ACCOUNT\n'
          'Account Number: XXXXXX4521\n'
          'IFSC: HDFC0001234\n'
          'Opening Balance: 125000.00\n'
          'Closing Balance: 98750.50',
      confidence: 0.88,
      extractedAt: _now.subtract(const Duration(hours: 5)),
      pageCount: 4,
      processingStatus: ProcessingStatus.completed,
    ),
    status: OcrJobStatus.completed,
    result: OcrExtractionResult(
      document: OcrDocument(
        documentId: 'doc-002',
        documentType: DocumentType.bankStatement,
        rawText: '',
        confidence: 0.88,
        extractedAt: _now.subtract(const Duration(hours: 5)),
        pageCount: 4,
        processingStatus: ProcessingStatus.completed,
      ),
      extractedData: const BankStatementExtractedData(
        ExtractedBankStatement(
          accountNumber: 'XXXXXX4521',
          bankName: 'HDFC Bank',
          ifscCode: 'HDFC0001234',
          period: 'Feb 2026',
          openingBalance: 12500000,
          closingBalance: 9875050,
          transactions: [],
        ),
      ),
      validationErrors: const [],
      requiresManualReview: false,
    ),
  ),
  OcrJob(
    jobId: 'job-003',
    fileName: 'GST_Invoice_TechVista_Mar2026.pdf',
    document: OcrDocument(
      documentId: 'doc-003',
      documentType: DocumentType.invoice,
      rawText:
          'TAX INVOICE\n'
          'Invoice No.: INV-2026-0312\n'
          'Invoice Date: 12-03-2026\n'
          'Seller: TechVista Solutions LLP\n'
          'Buyer: ABC Infra Pvt Ltd\n'
          'Total Amount: 59000\n'
          'GST Amount: 9000',
      confidence: 0.72,
      extractedAt: _now.subtract(const Duration(minutes: 30)),
      pageCount: 1,
      processingStatus: ProcessingStatus.completed,
    ),
    status: OcrJobStatus.completed,
    result: OcrExtractionResult(
      document: OcrDocument(
        documentId: 'doc-003',
        documentType: DocumentType.invoice,
        rawText: '',
        confidence: 0.72,
        extractedAt: _now.subtract(const Duration(minutes: 30)),
        pageCount: 1,
        processingStatus: ProcessingStatus.completed,
      ),
      extractedData: const InvoiceExtractedData(
        ExtractedInvoice(
          invoiceNumber: 'INV-2026-0312',
          invoiceDate: null,
          sellerName: 'TechVista Solutions LLP',
          sellerGstin: null,
          buyerName: 'ABC Infra Pvt Ltd',
          buyerGstin: null,
          lineItems: [],
          totalAmount: 5900000,
          gstAmount: 900000,
          hsnCode: null,
        ),
      ),
      validationErrors: const ['Low confidence — manual review recommended'],
      requiresManualReview: true,
    ),
  ),
  OcrJob(
    jobId: 'job-004',
    fileName: 'Form26AS_Priya_AY2026.pdf',
    document: OcrDocument(
      documentId: 'doc-004',
      documentType: DocumentType.form26as,
      rawText: 'FORM 26AS\nTAX CREDIT STATEMENT\nAssessment Year: 2025-26',
      confidence: 0.91,
      extractedAt: _now.subtract(const Duration(minutes: 5)),
      pageCount: 3,
      processingStatus: ProcessingStatus.processing,
    ),
    status: OcrJobStatus.processing,
  ),
  OcrJob(
    jobId: 'job-005',
    fileName: 'SalarySlip_Vikram_Mar2026.pdf',
    document: OcrDocument(
      documentId: 'doc-005',
      documentType: DocumentType.salarySlip,
      rawText: '',
      confidence: 0.0,
      extractedAt: _now,
      pageCount: 1,
      processingStatus: ProcessingStatus.failed,
    ),
    status: OcrJobStatus.failed,
    errorMessage: 'Unable to extract text — image quality too low.',
  ),
];

// ---------------------------------------------------------------------------
// OcrJobListNotifier
// ---------------------------------------------------------------------------

class OcrJobListNotifier extends Notifier<List<OcrJob>> {
  @override
  List<OcrJob> build() => List.unmodifiable(_mockJobs);

  /// Submits a new [doc] through the mock pipeline and appends the result.
  Future<void> submitJob(OcrDocument doc, String fileName) async {
    final pendingJob = OcrJob(
      jobId: 'job-${DateTime.now().millisecondsSinceEpoch}',
      fileName: fileName,
      document: doc,
      status: OcrJobStatus.queued,
    );

    state = List.unmodifiable([pendingJob, ...state]);

    // Simulate processing delay
    await Future<void>.delayed(const Duration(seconds: 2));

    final processingJob = pendingJob.copyWith(status: OcrJobStatus.processing);
    state = List.unmodifiable(
      state.map((j) => j.jobId == pendingJob.jobId ? processingJob : j),
    );

    await Future<void>.delayed(const Duration(seconds: 2));

    // Run mock extraction through pipeline
    final pipeline = OcrPipelineService.instance;
    OcrExtractionResult result;

    try {
      final completedDoc = doc.copyWith(
        processingStatus: ProcessingStatus.completed,
        confidence: 0.87,
      );

      final OcrExtractedData extractedData;
      switch (doc.documentType) {
        case DocumentType.form16:
        case DocumentType.form16a:
          final form16 = pipeline.extractForm16(doc.rawText);
          extractedData = Form16ExtractedData(form16);
        case DocumentType.bankStatement:
          final stmt = pipeline.extractBankStatement(doc.rawText);
          extractedData = BankStatementExtractedData(stmt);
        case DocumentType.invoice:
        case DocumentType.gstCertificate:
          final inv = pipeline.extractInvoice(doc.rawText);
          extractedData = InvoiceExtractedData(inv);
        case DocumentType.form26as:
        case DocumentType.panCard:
        case DocumentType.aadhaarCard:
        case DocumentType.salarySlip:
          extractedData = const UnknownExtractedData();
      }

      result = OcrExtractionResult.fromDocument(
        document: completedDoc,
        extractedData: extractedData,
        validationErrors: const [],
      );

      final completedJob = pendingJob.copyWith(
        document: completedDoc,
        status: OcrJobStatus.completed,
        result: result,
      );

      state = List.unmodifiable(
        state.map((j) => j.jobId == pendingJob.jobId ? completedJob : j),
      );
    } catch (_) {
      final failedJob = pendingJob.copyWith(
        status: OcrJobStatus.failed,
        errorMessage: 'Processing failed — please try again.',
      );
      state = List.unmodifiable(
        state.map((j) => j.jobId == pendingJob.jobId ? failedJob : j),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final ocrJobListProvider =
    NotifierProvider<OcrJobListNotifier, List<OcrJob>>(
      OcrJobListNotifier.new,
    );

class OcrActiveJobNotifier extends Notifier<OcrJob?> {
  @override
  OcrJob? build() => null;

  void select(OcrJob? job) => state = job;
}

final ocrActiveJobProvider =
    NotifierProvider<OcrActiveJobNotifier, OcrJob?>(OcrActiveJobNotifier.new);

final ocrPipelineProvider = Provider<OcrPipelineService>(
  (ref) => OcrPipelineService.instance,
);

final ocrDataMapperProvider = Provider<OcrDataMapperService>(
  (ref) => OcrDataMapperService.instance,
);

// ---------------------------------------------------------------------------
// Derived providers
// ---------------------------------------------------------------------------

/// Jobs that are queued or currently processing.
final ocrQueuedJobsProvider = Provider<List<OcrJob>>((ref) {
  final jobs = ref.watch(ocrJobListProvider);
  return jobs
      .where(
        (j) =>
            j.status == OcrJobStatus.queued ||
            j.status == OcrJobStatus.processing,
      )
      .toList();
});

/// Jobs that have completed or failed.
final ocrHistoryJobsProvider = Provider<List<OcrJob>>((ref) {
  final jobs = ref.watch(ocrJobListProvider);
  return jobs
      .where(
        (j) =>
            j.status == OcrJobStatus.completed ||
            j.status == OcrJobStatus.failed,
      )
      .toList();
});
