import 'package:ca_app/features/e_verification/domain/models/verification_request.dart';
import 'package:ca_app/features/e_verification/domain/models/verification_status.dart';
import 'package:ca_app/features/e_verification/domain/models/signing_request.dart';
import 'package:ca_app/features/e_verification/domain/repositories/e_verification_repository.dart';

/// In-memory mock implementation of [EVerificationRepository].
///
/// Seeded with realistic sample data for development and testing.
/// All state mutations return new lists (immutable patterns).
class MockEVerificationRepository implements EVerificationRepository {
  static final List<VerificationRequest> _seedVerificationRequests = [
    VerificationRequest(
      id: 'vreq-001',
      clientName: 'Rahul Sharma',
      pan: 'ABCDE1234F',
      itrType: 'ITR-1',
      assessmentYear: '2025-26',
      filingDate: DateTime(2026, 2, 28),
      deadlineDate: DateTime(2026, 3, 30),
      status: VerificationStatus.pending,
    ),
    VerificationRequest(
      id: 'vreq-002',
      clientName: 'Priya Verma',
      pan: 'PQRST5678A',
      itrType: 'ITR-4',
      assessmentYear: '2025-26',
      filingDate: DateTime(2026, 3, 1),
      deadlineDate: DateTime(2026, 3, 31),
      status: VerificationStatus.verifiedEvc,
      acknowledgementNumber: 'ACK202612345',
    ),
    VerificationRequest(
      id: 'vreq-003',
      clientName: 'Suresh Mehta',
      pan: 'LMNOP9012B',
      itrType: 'ITR-3',
      assessmentYear: '2025-26',
      filingDate: DateTime(2026, 1, 20),
      deadlineDate: DateTime(2026, 2, 19),
      status: VerificationStatus.expired,
    ),
  ];

  static final List<SigningRequest> _seedSigningRequests = [
    SigningRequest(
      requestId: 'sreq-001',
      documentHash:
          'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2',
      documentType: DocumentType.itrV,
      signerPan: 'ABCDE1234F',
      signerName: 'Rahul Sharma',
      status: SigningStatus.pending,
    ),
    SigningRequest(
      requestId: 'sreq-002',
      documentHash:
          'b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3',
      documentType: DocumentType.gstReturn,
      signerPan: 'PQRST5678A',
      signerName: 'Priya Verma',
      status: SigningStatus.signed,
      signedAt: DateTime(2026, 3, 11, 14, 30),
    ),
    SigningRequest(
      requestId: 'sreq-003',
      documentHash:
          'c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4',
      documentType: DocumentType.auditReport,
      signerPan: 'LMNOP9012B',
      signerName: 'Suresh Mehta',
      status: SigningStatus.inProgress,
    ),
  ];

  final List<VerificationRequest> _verificationRequests = List.of(
    _seedVerificationRequests,
  );
  final List<SigningRequest> _signingRequests = List.of(_seedSigningRequests);

  @override
  Future<String> insertVerificationRequest(VerificationRequest request) async {
    _verificationRequests.add(request);
    return request.id;
  }

  @override
  Future<List<VerificationRequest>> getAllVerificationRequests() async =>
      List.unmodifiable(_verificationRequests);

  @override
  Future<List<VerificationRequest>> getVerificationRequestsByStatus(
    VerificationStatus status,
  ) async => List.unmodifiable(
    _verificationRequests.where((r) => r.status == status).toList(),
  );

  @override
  Future<bool> updateVerificationRequest(VerificationRequest request) async {
    final idx = _verificationRequests.indexWhere((r) => r.id == request.id);
    if (idx == -1) return false;
    final updated = List<VerificationRequest>.of(_verificationRequests)
      ..[idx] = request;
    _verificationRequests
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteVerificationRequest(String id) async {
    final before = _verificationRequests.length;
    _verificationRequests.removeWhere((r) => r.id == id);
    return _verificationRequests.length < before;
  }

  @override
  Future<String> insertSigningRequest(SigningRequest request) async {
    _signingRequests.add(request);
    return request.requestId;
  }

  @override
  Future<List<SigningRequest>> getAllSigningRequests() async =>
      List.unmodifiable(_signingRequests);

  @override
  Future<List<SigningRequest>> getSigningRequestsByStatus(
    SigningStatus status,
  ) async => List.unmodifiable(
    _signingRequests.where((r) => r.status == status).toList(),
  );

  @override
  Future<bool> updateSigningRequest(SigningRequest request) async {
    final idx = _signingRequests.indexWhere(
      (r) => r.requestId == request.requestId,
    );
    if (idx == -1) return false;
    final updated = List<SigningRequest>.of(_signingRequests)..[idx] = request;
    _signingRequests
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteSigningRequest(String requestId) async {
    final before = _signingRequests.length;
    _signingRequests.removeWhere((r) => r.requestId == requestId);
    return _signingRequests.length < before;
  }
}
