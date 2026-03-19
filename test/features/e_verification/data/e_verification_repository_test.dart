import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/e_verification/data/repositories/mock_e_verification_repository.dart';
import 'package:ca_app/features/e_verification/domain/models/verification_request.dart';
import 'package:ca_app/features/e_verification/domain/models/verification_status.dart';
import 'package:ca_app/features/e_verification/domain/models/signing_request.dart';

void main() {
  late MockEVerificationRepository repo;

  setUp(() {
    repo = MockEVerificationRepository();
  });

  group('MockEVerificationRepository - VerificationRequest', () {
    test('getAllVerificationRequests returns non-empty seeded list', () async {
      final requests = await repo.getAllVerificationRequests();
      expect(requests, isNotEmpty);
    });

    test('getVerificationRequestsByStatus filters correctly', () async {
      final requests = await repo.getVerificationRequestsByStatus(
        VerificationStatus.pending,
      );
      for (final r in requests) {
        expect(r.status, VerificationStatus.pending);
      }
    });

    test('insertVerificationRequest adds entry and returns id', () async {
      final request = VerificationRequest(
        id: 'vreq-new-001',
        clientName: 'New Client',
        pan: 'ABCDE1234F',
        itrType: 'ITR-1',
        assessmentYear: '2025-26',
        filingDate: DateTime(2026, 1, 15),
        deadlineDate: DateTime(2026, 2, 14),
        status: VerificationStatus.pending,
      );
      final id = await repo.insertVerificationRequest(request);
      expect(id, 'vreq-new-001');

      final all = await repo.getAllVerificationRequests();
      expect(all.any((r) => r.id == 'vreq-new-001'), isTrue);
    });

    test('updateVerificationRequest updates status and returns true', () async {
      final all = await repo.getAllVerificationRequests();
      final first = all.first;
      final updated = first.copyWith(status: VerificationStatus.verifiedEvc);
      final success = await repo.updateVerificationRequest(updated);
      expect(success, isTrue);

      final refetched = await repo.getAllVerificationRequests();
      final found = refetched.firstWhere((r) => r.id == first.id);
      expect(found.status, VerificationStatus.verifiedEvc);
    });

    test(
      'updateVerificationRequest returns false for non-existent id',
      () async {
        final ghost = VerificationRequest(
          id: 'non-existent-vreq',
          clientName: 'Nobody',
          pan: 'ZZZZZ9999Z',
          itrType: 'ITR-4',
          assessmentYear: '2024-25',
          filingDate: DateTime(2025, 1, 1),
          deadlineDate: DateTime(2025, 1, 31),
          status: VerificationStatus.expired,
        );
        final success = await repo.updateVerificationRequest(ghost);
        expect(success, isFalse);
      },
    );

    test('deleteVerificationRequest removes entry and returns true', () async {
      final all = await repo.getAllVerificationRequests();
      final target = all.first;
      final deleted = await repo.deleteVerificationRequest(target.id);
      expect(deleted, isTrue);

      final remaining = await repo.getAllVerificationRequests();
      expect(remaining.any((r) => r.id == target.id), isFalse);
    });

    test(
      'deleteVerificationRequest returns false for non-existent id',
      () async {
        final deleted = await repo.deleteVerificationRequest('no-such-id');
        expect(deleted, isFalse);
      },
    );
  });

  group('MockEVerificationRepository - SigningRequest', () {
    test('getAllSigningRequests returns non-empty seeded list', () async {
      final requests = await repo.getAllSigningRequests();
      expect(requests, isNotEmpty);
    });

    test('getSigningRequestsByStatus filters correctly', () async {
      final requests = await repo.getSigningRequestsByStatus(
        SigningStatus.pending,
      );
      for (final r in requests) {
        expect(r.status, SigningStatus.pending);
      }
    });

    test('insertSigningRequest adds entry and returns id', () async {
      const request = SigningRequest(
        requestId: 'sreq-new-001',
        documentHash: 'abc123hash',
        documentType: DocumentType.itrV,
        signerPan: 'ABCDE1234F',
        signerName: 'Test Signer',
        status: SigningStatus.pending,
      );
      final id = await repo.insertSigningRequest(request);
      expect(id, 'sreq-new-001');
    });

    test('updateSigningRequest returns true on success', () async {
      final all = await repo.getAllSigningRequests();
      final first = all.first;
      final updated = first.copyWith(status: SigningStatus.signed);
      final success = await repo.updateSigningRequest(updated);
      expect(success, isTrue);
    });

    test('updateSigningRequest returns false for non-existent id', () async {
      const ghost = SigningRequest(
        requestId: 'non-existent-sreq',
        documentHash: 'deadbeef',
        documentType: DocumentType.auditReport,
        signerPan: 'ZZZZZ9999Z',
        signerName: 'Ghost',
        status: SigningStatus.failed,
      );
      final success = await repo.updateSigningRequest(ghost);
      expect(success, isFalse);
    });

    test('deleteSigningRequest removes entry and returns true', () async {
      final all = await repo.getAllSigningRequests();
      final target = all.first;
      final deleted = await repo.deleteSigningRequest(target.requestId);
      expect(deleted, isTrue);

      final remaining = await repo.getAllSigningRequests();
      expect(remaining.any((r) => r.requestId == target.requestId), isFalse);
    });

    test('deleteSigningRequest returns false for non-existent id', () async {
      final deleted = await repo.deleteSigningRequest('no-such-id');
      expect(deleted, isFalse);
    });
  });
}
