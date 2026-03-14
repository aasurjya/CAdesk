import 'package:ca_app/features/onboarding/domain/models/document_expiry.dart';
import 'package:ca_app/features/onboarding/domain/models/kyc_record.dart';
import 'package:ca_app/features/onboarding/domain/models/onboarding_checklist.dart';
import 'package:ca_app/features/onboarding/domain/repositories/onboarding_repository.dart';

/// In-memory mock implementation of [OnboardingRepository].
///
/// Seeded with realistic sample data for development and testing.
class MockOnboardingRepository implements OnboardingRepository {
  static final List<KycRecord> _kycSeed = [
    KycRecord(
      id: 'kyc-001',
      clientId: 'mock-client-001',
      clientName: 'Sharma Industries Pvt Ltd',
      kycStatus: KycStatus.verified,
      aadhaarVerified: true,
      panVerified: true,
      ckycKin: 'KIN100001',
      submittedAt: DateTime(2026, 1, 10),
      verifiedAt: DateTime(2026, 1, 20),
      remarks: 'All documents verified successfully',
    ),
    KycRecord(
      id: 'kyc-002',
      clientId: 'mock-client-002',
      clientName: 'Patel Exports Ltd',
      kycStatus: KycStatus.pending,
      aadhaarVerified: false,
      panVerified: true,
      ckycKin: 'KIN100002',
      submittedAt: DateTime(2026, 2, 5),
      remarks: 'Awaiting Aadhaar verification',
    ),
    KycRecord(
      id: 'kyc-003',
      clientId: 'mock-client-003',
      clientName: 'Reddy Tech Solutions',
      kycStatus: KycStatus.underVerification,
      aadhaarVerified: true,
      panVerified: true,
      ckycKin: 'KIN100003',
      submittedAt: DateTime(2026, 2, 28),
      expiryDate: DateTime(2028, 2, 28),
      remarks: 'Under review by compliance team',
    ),
  ];

  static final List<OnboardingChecklist> _checklistSeed = [
    OnboardingChecklist(
      id: 'checklist-001',
      clientId: 'mock-client-001',
      clientName: 'Sharma Industries Pvt Ltd',
      serviceType: 'GST Registration',
      items: const [
        ChecklistItem(
          name: 'PAN Card',
          isRequired: true,
          isCompleted: true,
          documentUrl: 'https://example.com/pan-001',
        ),
        ChecklistItem(
          name: 'Aadhaar Card',
          isRequired: true,
          isCompleted: true,
        ),
        ChecklistItem(
          name: 'Bank Statement',
          isRequired: true,
          isCompleted: false,
        ),
      ],
      overallProgress: 0.67,
      createdAt: DateTime(2026, 1, 1),
    ),
    OnboardingChecklist(
      id: 'checklist-002',
      clientId: 'mock-client-002',
      clientName: 'Patel Exports Ltd',
      serviceType: 'Company Incorporation',
      items: const [
        ChecklistItem(
          name: 'Director DIN',
          isRequired: true,
          isCompleted: true,
        ),
        ChecklistItem(name: 'MOA Draft', isRequired: true, isCompleted: false),
      ],
      overallProgress: 0.5,
      createdAt: DateTime(2026, 2, 1),
    ),
    OnboardingChecklist(
      id: 'checklist-003',
      clientId: 'mock-client-003',
      clientName: 'Reddy Tech Solutions',
      serviceType: 'ITR Filing',
      items: const [
        ChecklistItem(name: 'Form 16', isRequired: true, isCompleted: true),
        ChecklistItem(
          name: 'Capital Gains Statement',
          isRequired: false,
          isCompleted: true,
        ),
        ChecklistItem(
          name: 'Bank Interest Certificate',
          isRequired: true,
          isCompleted: true,
        ),
      ],
      overallProgress: 1.0,
      createdAt: DateTime(2026, 3, 1),
      completedAt: DateTime(2026, 3, 10),
    ),
  ];

  static final List<DocumentExpiry> _expirySeed = [
    DocumentExpiry(
      id: 'expiry-001',
      clientId: 'mock-client-001',
      clientName: 'Sharma Industries Pvt Ltd',
      documentType: DocumentType.dsc,
      expiryDate: DateTime(2026, 4, 30),
      status: ExpiryStatus.expiringSoon,
    ),
    DocumentExpiry(
      id: 'expiry-002',
      clientId: 'mock-client-002',
      clientName: 'Patel Exports Ltd',
      documentType: DocumentType.gstCertificate,
      expiryDate: DateTime(2027, 3, 31),
      status: ExpiryStatus.valid,
    ),
    DocumentExpiry(
      id: 'expiry-003',
      clientId: 'mock-client-003',
      clientName: 'Reddy Tech Solutions',
      documentType: DocumentType.insurance,
      expiryDate: DateTime(2026, 2, 28),
      status: ExpiryStatus.expired,
    ),
  ];

  final List<KycRecord> _kycState = List.of(_kycSeed);
  final List<OnboardingChecklist> _checklistState = List.of(_checklistSeed);
  final List<DocumentExpiry> _expiryState = List.of(_expirySeed);

  // ---------------------------------------------------------------------------
  // KYC Records
  // ---------------------------------------------------------------------------

  @override
  Future<List<KycRecord>> getKycRecords() async => List.unmodifiable(_kycState);

  @override
  Future<KycRecord?> getKycRecordById(String id) async {
    final idx = _kycState.indexWhere((r) => r.id == id);
    return idx == -1 ? null : _kycState[idx];
  }

  @override
  Future<List<KycRecord>> getKycRecordsByStatus(KycStatus status) async =>
      List.unmodifiable(_kycState.where((r) => r.kycStatus == status).toList());

  @override
  Future<String> insertKycRecord(KycRecord record) async {
    _kycState.add(record);
    return record.id;
  }

  @override
  Future<bool> updateKycRecord(KycRecord record) async {
    final idx = _kycState.indexWhere((r) => r.id == record.id);
    if (idx == -1) return false;
    final updated = List<KycRecord>.of(_kycState)..[idx] = record;
    _kycState
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteKycRecord(String id) async {
    final before = _kycState.length;
    _kycState.removeWhere((r) => r.id == id);
    return _kycState.length < before;
  }

  // ---------------------------------------------------------------------------
  // Onboarding Checklists
  // ---------------------------------------------------------------------------

  @override
  Future<List<OnboardingChecklist>> getChecklists() async =>
      List.unmodifiable(_checklistState);

  @override
  Future<List<OnboardingChecklist>> getChecklistsByClient(
    String clientId,
  ) async => List.unmodifiable(
    _checklistState.where((c) => c.clientId == clientId).toList(),
  );

  @override
  Future<String> insertChecklist(OnboardingChecklist checklist) async {
    _checklistState.add(checklist);
    return checklist.id;
  }

  @override
  Future<bool> updateChecklist(OnboardingChecklist checklist) async {
    final idx = _checklistState.indexWhere((c) => c.id == checklist.id);
    if (idx == -1) return false;
    final updated = List<OnboardingChecklist>.of(_checklistState)
      ..[idx] = checklist;
    _checklistState
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteChecklist(String id) async {
    final before = _checklistState.length;
    _checklistState.removeWhere((c) => c.id == id);
    return _checklistState.length < before;
  }

  // ---------------------------------------------------------------------------
  // Document Expiry
  // ---------------------------------------------------------------------------

  @override
  Future<List<DocumentExpiry>> getDocumentExpiries() async =>
      List.unmodifiable(_expiryState);

  @override
  Future<List<DocumentExpiry>> getDocumentExpiriesByClient(
    String clientId,
  ) async => List.unmodifiable(
    _expiryState.where((d) => d.clientId == clientId).toList(),
  );

  @override
  Future<List<DocumentExpiry>> getDocumentExpiriesByStatus(
    ExpiryStatus status,
  ) async =>
      List.unmodifiable(_expiryState.where((d) => d.status == status).toList());

  @override
  Future<String> insertDocumentExpiry(DocumentExpiry expiry) async {
    _expiryState.add(expiry);
    return expiry.id;
  }

  @override
  Future<bool> updateDocumentExpiry(DocumentExpiry expiry) async {
    final idx = _expiryState.indexWhere((d) => d.id == expiry.id);
    if (idx == -1) return false;
    final updated = List<DocumentExpiry>.of(_expiryState)..[idx] = expiry;
    _expiryState
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteDocumentExpiry(String id) async {
    final before = _expiryState.length;
    _expiryState.removeWhere((d) => d.id == id);
    return _expiryState.length < before;
  }
}
