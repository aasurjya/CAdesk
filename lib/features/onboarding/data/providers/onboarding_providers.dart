import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/onboarding/domain/models/kyc_record.dart';
import 'package:ca_app/features/onboarding/domain/models/onboarding_checklist.dart';
import 'package:ca_app/features/onboarding/domain/models/document_expiry.dart';

// ---------------------------------------------------------------------------
// Mock KYC records
// ---------------------------------------------------------------------------

final _mockKycRecords = <KycRecord>[
  KycRecord(
    id: 'kyc-001',
    clientId: 'cli-001',
    clientName: 'Sharma Textiles Pvt Ltd',
    kycStatus: KycStatus.verified,
    aadhaarVerified: true,
    panVerified: true,
    ckycKin: '50000012345678',
    submittedAt: DateTime(2025, 6, 15),
    verifiedAt: DateTime(2025, 7, 1),
    expiryDate: DateTime(2027, 7, 1),
    remarks: 'All documents verified. CKYC completed.',
  ),
  KycRecord(
    id: 'kyc-002',
    clientId: 'cli-002',
    clientName: 'Patel Electronics',
    kycStatus: KycStatus.underVerification,
    aadhaarVerified: true,
    panVerified: true,
    ckycKin: '',
    submittedAt: DateTime(2026, 2, 20),
    remarks: 'CKYC KIN pending from registry.',
  ),
  KycRecord(
    id: 'kyc-003',
    clientId: 'cli-003',
    clientName: 'Gupta & Sons Trading Co',
    kycStatus: KycStatus.documentsSubmitted,
    aadhaarVerified: true,
    panVerified: false,
    ckycKin: '',
    submittedAt: DateTime(2026, 3, 1),
    remarks: 'PAN verification pending. Address proof under review.',
  ),
  KycRecord(
    id: 'kyc-004',
    clientId: 'cli-004',
    clientName: 'Nair Constructions LLP',
    kycStatus: KycStatus.pending,
    aadhaarVerified: false,
    panVerified: false,
    ckycKin: '',
    submittedAt: DateTime(2026, 3, 5),
    remarks: 'Awaiting documents from client. Follow-up sent.',
  ),
  KycRecord(
    id: 'kyc-005',
    clientId: 'cli-005',
    clientName: 'Desai Pharma Ltd',
    kycStatus: KycStatus.verified,
    aadhaarVerified: true,
    panVerified: true,
    ckycKin: '50000098765432',
    submittedAt: DateTime(2025, 3, 10),
    verifiedAt: DateTime(2025, 4, 1),
    expiryDate: DateTime(2027, 4, 1),
    remarks: 'KYC verified. Annual review due April 2027.',
  ),
  KycRecord(
    id: 'kyc-006',
    clientId: 'cli-006',
    clientName: 'Joshi Automotive Services',
    kycStatus: KycStatus.rejected,
    aadhaarVerified: true,
    panVerified: false,
    ckycKin: '',
    submittedAt: DateTime(2026, 1, 15),
    remarks: 'PAN mismatch with company records. Re-submission required.',
  ),
  KycRecord(
    id: 'kyc-007',
    clientId: 'cli-007',
    clientName: 'Reddy Agro Industries',
    kycStatus: KycStatus.expired,
    aadhaarVerified: true,
    panVerified: true,
    ckycKin: '50000055667788',
    submittedAt: DateTime(2023, 2, 1),
    verifiedAt: DateTime(2023, 3, 1),
    expiryDate: DateTime(2025, 3, 1),
    remarks: 'KYC expired. Renewal documents requested.',
  ),
  KycRecord(
    id: 'kyc-008',
    clientId: 'cli-008',
    clientName: 'Mehta IT Solutions',
    kycStatus: KycStatus.underVerification,
    aadhaarVerified: true,
    panVerified: true,
    ckycKin: '',
    submittedAt: DateTime(2026, 2, 28),
    remarks: 'Documents submitted. Awaiting CKYC registry response.',
  ),
];

// ---------------------------------------------------------------------------
// Mock onboarding checklists
// ---------------------------------------------------------------------------

final _mockChecklists = <OnboardingChecklist>[
  OnboardingChecklist(
    id: 'obc-001',
    clientId: 'cli-002',
    clientName: 'Patel Electronics',
    serviceType: 'GST Registration & Filing',
    items: [
      ChecklistItem(name: 'Engagement Letter Signed', isRequired: true, isCompleted: true, completedAt: DateTime(2026, 2, 18)),
      ChecklistItem(name: 'PAN Card Copy', isRequired: true, isCompleted: true, completedAt: DateTime(2026, 2, 19)),
      ChecklistItem(name: 'Aadhaar Copy (Authorised Signatory)', isRequired: true, isCompleted: true, completedAt: DateTime(2026, 2, 19)),
      ChecklistItem(name: 'Address Proof of Business', isRequired: true, isCompleted: true, completedAt: DateTime(2026, 2, 20)),
      ChecklistItem(name: 'Bank Statement / Cancelled Cheque', isRequired: true, isCompleted: false),
      ChecklistItem(name: 'Photograph of Signatory', isRequired: false, isCompleted: false),
    ],
    overallProgress: 0.67,
    createdAt: DateTime(2026, 2, 15),
  ),
  OnboardingChecklist(
    id: 'obc-002',
    clientId: 'cli-003',
    clientName: 'Gupta & Sons Trading Co',
    serviceType: 'Income Tax & TDS',
    items: [
      ChecklistItem(name: 'Engagement Letter Signed', isRequired: true, isCompleted: true, completedAt: DateTime(2026, 2, 28)),
      ChecklistItem(name: 'PAN Card Copy', isRequired: true, isCompleted: false),
      ChecklistItem(name: 'Previous Year ITR Copies', isRequired: true, isCompleted: false),
      ChecklistItem(name: 'Bank Statements (All Accounts)', isRequired: true, isCompleted: false),
      ChecklistItem(name: 'TDS Certificates (Form 16/16A)', isRequired: true, isCompleted: false),
    ],
    overallProgress: 0.20,
    createdAt: DateTime(2026, 2, 25),
  ),
  OnboardingChecklist(
    id: 'obc-003',
    clientId: 'cli-004',
    clientName: 'Nair Constructions LLP',
    serviceType: 'Statutory Audit',
    items: [
      ChecklistItem(name: 'Engagement Letter Signed', isRequired: true, isCompleted: false),
      ChecklistItem(name: 'LLP Agreement Copy', isRequired: true, isCompleted: false),
      ChecklistItem(name: 'Certificate of Incorporation', isRequired: true, isCompleted: false),
      ChecklistItem(name: 'Previous Audit Report', isRequired: true, isCompleted: false),
      ChecklistItem(name: 'Trial Balance & Financials', isRequired: true, isCompleted: false),
      ChecklistItem(name: 'Bank Reconciliation Statements', isRequired: false, isCompleted: false),
    ],
    overallProgress: 0.0,
    createdAt: DateTime(2026, 3, 5),
  ),
  OnboardingChecklist(
    id: 'obc-004',
    clientId: 'cli-008',
    clientName: 'Mehta IT Solutions',
    serviceType: 'Company Incorporation & ROC',
    items: [
      ChecklistItem(name: 'Engagement Letter Signed', isRequired: true, isCompleted: true, completedAt: DateTime(2026, 2, 25)),
      ChecklistItem(name: 'Director KYC (DIN)', isRequired: true, isCompleted: true, completedAt: DateTime(2026, 2, 26)),
      ChecklistItem(name: 'Digital Signature Certificate', isRequired: true, isCompleted: true, completedAt: DateTime(2026, 2, 27)),
      ChecklistItem(name: 'Name Reservation (RUN)', isRequired: true, isCompleted: true, completedAt: DateTime(2026, 2, 28)),
      ChecklistItem(name: 'MOA & AOA Drafting', isRequired: true, isCompleted: true, completedAt: DateTime(2026, 3, 1)),
      ChecklistItem(name: 'SPICe+ Form Filed', isRequired: true, isCompleted: false),
    ],
    overallProgress: 0.83,
    createdAt: DateTime(2026, 2, 22),
  ),
  OnboardingChecklist(
    id: 'obc-005',
    clientId: 'cli-001',
    clientName: 'Sharma Textiles Pvt Ltd',
    serviceType: 'GST Registration & Filing',
    items: [
      ChecklistItem(name: 'Engagement Letter Signed', isRequired: true, isCompleted: true, completedAt: DateTime(2025, 6, 10)),
      ChecklistItem(name: 'PAN Card Copy', isRequired: true, isCompleted: true, completedAt: DateTime(2025, 6, 10)),
      ChecklistItem(name: 'Aadhaar Copy', isRequired: true, isCompleted: true, completedAt: DateTime(2025, 6, 11)),
      ChecklistItem(name: 'Address Proof', isRequired: true, isCompleted: true, completedAt: DateTime(2025, 6, 12)),
      ChecklistItem(name: 'Bank Details', isRequired: true, isCompleted: true, completedAt: DateTime(2025, 6, 13)),
    ],
    overallProgress: 1.0,
    createdAt: DateTime(2025, 6, 8),
    completedAt: DateTime(2025, 6, 13),
  ),
  OnboardingChecklist(
    id: 'obc-006',
    clientId: 'cli-006',
    clientName: 'Joshi Automotive Services',
    serviceType: 'Income Tax & TDS',
    items: [
      ChecklistItem(name: 'Engagement Letter Signed', isRequired: true, isCompleted: true, completedAt: DateTime(2026, 1, 10)),
      ChecklistItem(name: 'PAN Card Copy', isRequired: true, isCompleted: false),
      ChecklistItem(name: 'Previous Year ITR', isRequired: true, isCompleted: true, completedAt: DateTime(2026, 1, 12)),
      ChecklistItem(name: 'Bank Statements', isRequired: true, isCompleted: false),
    ],
    overallProgress: 0.50,
    createdAt: DateTime(2026, 1, 8),
  ),
];

// ---------------------------------------------------------------------------
// Mock document expiries
// ---------------------------------------------------------------------------

final _mockDocumentExpiries = <DocumentExpiry>[
  DocumentExpiry(
    id: 'exp-001',
    clientId: 'cli-001',
    clientName: 'Sharma Textiles Pvt Ltd',
    documentType: DocumentType.gstCertificate,
    expiryDate: DateTime(2026, 12, 31),
    status: ExpiryStatus.valid,
  ),
  DocumentExpiry(
    id: 'exp-002',
    clientId: 'cli-001',
    clientName: 'Sharma Textiles Pvt Ltd',
    documentType: DocumentType.dsc,
    expiryDate: DateTime(2026, 4, 15),
    reminderSentAt: DateTime(2026, 3, 1),
    status: ExpiryStatus.expiringSoon,
  ),
  DocumentExpiry(
    id: 'exp-003',
    clientId: 'cli-002',
    clientName: 'Patel Electronics',
    documentType: DocumentType.insurance,
    expiryDate: DateTime(2026, 3, 20),
    reminderSentAt: DateTime(2026, 3, 5),
    status: ExpiryStatus.expiringSoon,
  ),
  DocumentExpiry(
    id: 'exp-004',
    clientId: 'cli-003',
    clientName: 'Gupta & Sons Trading Co',
    documentType: DocumentType.professionalTax,
    expiryDate: DateTime(2026, 3, 31),
    status: ExpiryStatus.expiringSoon,
  ),
  DocumentExpiry(
    id: 'exp-005',
    clientId: 'cli-004',
    clientName: 'Nair Constructions LLP',
    documentType: DocumentType.license,
    expiryDate: DateTime(2026, 1, 31),
    reminderSentAt: DateTime(2026, 1, 15),
    status: ExpiryStatus.expired,
  ),
  DocumentExpiry(
    id: 'exp-006',
    clientId: 'cli-005',
    clientName: 'Desai Pharma Ltd',
    documentType: DocumentType.gstCertificate,
    expiryDate: DateTime(2027, 6, 30),
    status: ExpiryStatus.valid,
  ),
  DocumentExpiry(
    id: 'exp-007',
    clientId: 'cli-005',
    clientName: 'Desai Pharma Ltd',
    documentType: DocumentType.insurance,
    expiryDate: DateTime(2026, 8, 15),
    status: ExpiryStatus.valid,
  ),
  DocumentExpiry(
    id: 'exp-008',
    clientId: 'cli-006',
    clientName: 'Joshi Automotive Services',
    documentType: DocumentType.panCard,
    expiryDate: DateTime(2099, 12, 31),
    status: ExpiryStatus.valid,
  ),
  DocumentExpiry(
    id: 'exp-009',
    clientId: 'cli-007',
    clientName: 'Reddy Agro Industries',
    documentType: DocumentType.dsc,
    expiryDate: DateTime(2026, 2, 28),
    reminderSentAt: DateTime(2026, 2, 15),
    status: ExpiryStatus.expired,
  ),
  DocumentExpiry(
    id: 'exp-010',
    clientId: 'cli-007',
    clientName: 'Reddy Agro Industries',
    documentType: DocumentType.license,
    expiryDate: DateTime(2026, 5, 31),
    status: ExpiryStatus.valid,
  ),
  DocumentExpiry(
    id: 'exp-011',
    clientId: 'cli-008',
    clientName: 'Mehta IT Solutions',
    documentType: DocumentType.aadhaar,
    expiryDate: DateTime(2099, 12, 31),
    status: ExpiryStatus.valid,
  ),
  DocumentExpiry(
    id: 'exp-012',
    clientId: 'cli-008',
    clientName: 'Mehta IT Solutions',
    documentType: DocumentType.professionalTax,
    expiryDate: DateTime(2026, 3, 15),
    reminderSentAt: DateTime(2026, 3, 1),
    status: ExpiryStatus.expiringSoon,
  ),
];

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All KYC records.
final kycRecordsProvider = Provider<List<KycRecord>>((ref) {
  return List.unmodifiable(_mockKycRecords);
});

/// All onboarding checklists.
final onboardingChecklistsProvider = Provider<List<OnboardingChecklist>>((ref) {
  return List.unmodifiable(_mockChecklists);
});

/// All document expiries.
final documentExpiriesProvider = Provider<List<DocumentExpiry>>((ref) {
  return List.unmodifiable(_mockDocumentExpiries);
});

/// KYC status filter (null = all).
final kycStatusFilterProvider =
    NotifierProvider<KycStatusFilterNotifier, KycStatus?>(
        KycStatusFilterNotifier.new);

class KycStatusFilterNotifier extends Notifier<KycStatus?> {
  @override
  KycStatus? build() => null;

  void update(KycStatus? value) => state = value;
}

/// Filtered KYC records based on status.
final filteredKycRecordsProvider = Provider<List<KycRecord>>((ref) {
  final records = ref.watch(kycRecordsProvider);
  final status = ref.watch(kycStatusFilterProvider);

  return List.unmodifiable(
    records.where((r) => status == null || r.kycStatus == status),
  );
});

/// Expiry status filter (null = all).
final expiryStatusFilterProvider =
    NotifierProvider<ExpiryStatusFilterNotifier, ExpiryStatus?>(
        ExpiryStatusFilterNotifier.new);

class ExpiryStatusFilterNotifier extends Notifier<ExpiryStatus?> {
  @override
  ExpiryStatus? build() => null;

  void update(ExpiryStatus? value) => state = value;
}

/// Filtered document expiries based on status.
final filteredDocumentExpiriesProvider = Provider<List<DocumentExpiry>>((ref) {
  final expiries = ref.watch(documentExpiriesProvider);
  final status = ref.watch(expiryStatusFilterProvider);

  return List.unmodifiable(
    expiries.where((e) => status == null || e.status == status),
  );
});

/// Active (incomplete) onboarding checklists.
final activeChecklistsProvider = Provider<List<OnboardingChecklist>>((ref) {
  final checklists = ref.watch(onboardingChecklistsProvider);
  return List.unmodifiable(
    checklists.where((c) => c.completedAt == null),
  );
});

/// KYC summary counts.
final kycSummaryProvider = Provider<KycSummary>((ref) {
  final records = ref.watch(kycRecordsProvider);

  return KycSummary(
    total: records.length,
    verified: records.where((r) => r.kycStatus == KycStatus.verified).length,
    pending: records.where((r) =>
        r.kycStatus == KycStatus.pending ||
        r.kycStatus == KycStatus.documentsSubmitted ||
        r.kycStatus == KycStatus.underVerification).length,
    rejected: records.where((r) => r.kycStatus == KycStatus.rejected).length,
    expired: records.where((r) => r.kycStatus == KycStatus.expired).length,
  );
});

/// Immutable summary for KYC dashboard.
class KycSummary {
  const KycSummary({
    required this.total,
    required this.verified,
    required this.pending,
    required this.rejected,
    required this.expired,
  });

  final int total;
  final int verified;
  final int pending;
  final int rejected;
  final int expired;
}
