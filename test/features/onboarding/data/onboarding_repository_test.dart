import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/onboarding/domain/models/document_expiry.dart';
import 'package:ca_app/features/onboarding/domain/models/kyc_record.dart';
import 'package:ca_app/features/onboarding/domain/models/onboarding_checklist.dart';
import 'package:ca_app/features/onboarding/data/repositories/mock_onboarding_repository.dart';

void main() {
  group('MockOnboardingRepository', () {
    late MockOnboardingRepository repo;

    setUp(() {
      repo = MockOnboardingRepository();
    });

    // -------------------------------------------------------------------------
    // KYC Records
    // -------------------------------------------------------------------------

    group('KYC Records', () {
      test('getKycRecords returns 3 seed items', () async {
        final records = await repo.getKycRecords();
        expect(records.length, greaterThanOrEqualTo(3));
      });

      test('getKycRecordById returns matching record', () async {
        final all = await repo.getKycRecords();
        final first = all.first;
        final found = await repo.getKycRecordById(first.id);
        expect(found?.id, first.id);
      });

      test('getKycRecordById returns null for unknown id', () async {
        final found = await repo.getKycRecordById('non-existent-id');
        expect(found, isNull);
      });

      test('insertKycRecord adds record and returns id', () async {
        final record = KycRecord(
          id: 'kyc-new-001',
          clientId: 'client-new',
          clientName: 'New Client',
          kycStatus: KycStatus.pending,
          aadhaarVerified: false,
          panVerified: false,
          ckycKin: 'KIN000',
          submittedAt: DateTime(2026, 1, 1),
          remarks: 'Test remarks',
        );
        final id = await repo.insertKycRecord(record);
        expect(id, record.id);

        final all = await repo.getKycRecords();
        expect(all.any((r) => r.id == 'kyc-new-001'), isTrue);
      });

      test('updateKycRecord updates existing record', () async {
        final all = await repo.getKycRecords();
        final first = all.first;
        final updated = first.copyWith(kycStatus: KycStatus.verified);
        final success = await repo.updateKycRecord(updated);
        expect(success, isTrue);

        final found = await repo.getKycRecordById(first.id);
        expect(found?.kycStatus, KycStatus.verified);
      });

      test('updateKycRecord returns false for non-existent record', () async {
        final ghost = KycRecord(
          id: 'ghost-id',
          clientId: 'c',
          clientName: 'Ghost',
          kycStatus: KycStatus.pending,
          aadhaarVerified: false,
          panVerified: false,
          ckycKin: '',
          submittedAt: DateTime(2026),
          remarks: '',
        );
        final success = await repo.updateKycRecord(ghost);
        expect(success, isFalse);
      });

      test('deleteKycRecord removes record', () async {
        final all = await repo.getKycRecords();
        final first = all.first;
        final success = await repo.deleteKycRecord(first.id);
        expect(success, isTrue);

        final found = await repo.getKycRecordById(first.id);
        expect(found, isNull);
      });

      test('deleteKycRecord returns false for non-existent id', () async {
        final success = await repo.deleteKycRecord('no-such-id');
        expect(success, isFalse);
      });

      test('getKycRecordsByStatus filters correctly', () async {
        final records = await repo.getKycRecordsByStatus(KycStatus.pending);
        expect(records.every((r) => r.kycStatus == KycStatus.pending), isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // Onboarding Checklists
    // -------------------------------------------------------------------------

    group('Onboarding Checklists', () {
      test('getChecklists returns seed items', () async {
        final checklists = await repo.getChecklists();
        expect(checklists.length, greaterThanOrEqualTo(3));
      });

      test('getChecklistsByClient filters by clientId', () async {
        final all = await repo.getChecklists();
        final first = all.first;
        final filtered = await repo.getChecklistsByClient(first.clientId);
        expect(filtered.every((c) => c.clientId == first.clientId), isTrue);
      });

      test('getChecklistsByClient returns empty for unknown client', () async {
        final result = await repo.getChecklistsByClient('unknown-client');
        expect(result, isEmpty);
      });

      test('insertChecklist adds and returns id', () async {
        final checklist = OnboardingChecklist(
          id: 'checklist-new-001',
          clientId: 'client-new',
          clientName: 'New Client',
          serviceType: 'GST',
          items: const [],
          overallProgress: 0.0,
          createdAt: DateTime(2026, 1, 1),
        );
        final id = await repo.insertChecklist(checklist);
        expect(id, checklist.id);

        final all = await repo.getChecklists();
        expect(all.any((c) => c.id == 'checklist-new-001'), isTrue);
      });

      test('updateChecklist updates existing record', () async {
        final all = await repo.getChecklists();
        final first = all.first;
        final updated = first.copyWith(overallProgress: 0.99);
        final success = await repo.updateChecklist(updated);
        expect(success, isTrue);
      });

      test('updateChecklist returns false for non-existent', () async {
        final ghost = OnboardingChecklist(
          id: 'ghost-id',
          clientId: 'c',
          clientName: 'Ghost',
          serviceType: 'ITR',
          items: const [],
          overallProgress: 0.0,
          createdAt: DateTime(2026),
        );
        final success = await repo.updateChecklist(ghost);
        expect(success, isFalse);
      });

      test('deleteChecklist removes record', () async {
        final all = await repo.getChecklists();
        final first = all.first;
        final before = all.length;
        final success = await repo.deleteChecklist(first.id);
        expect(success, isTrue);

        final after = await repo.getChecklists();
        expect(after.length, before - 1);
      });
    });

    // -------------------------------------------------------------------------
    // Document Expiry
    // -------------------------------------------------------------------------

    group('Document Expiry', () {
      test('getDocumentExpiries returns seed items', () async {
        final items = await repo.getDocumentExpiries();
        expect(items.length, greaterThanOrEqualTo(3));
      });

      test('getDocumentExpiriesByClient filters by clientId', () async {
        final all = await repo.getDocumentExpiries();
        final first = all.first;
        final filtered = await repo.getDocumentExpiriesByClient(first.clientId);
        expect(filtered.every((d) => d.clientId == first.clientId), isTrue);
      });

      test('insertDocumentExpiry adds record', () async {
        final expiry = DocumentExpiry(
          id: 'expiry-new-001',
          clientId: 'client-new',
          clientName: 'New Client',
          documentType: DocumentType.dsc,
          expiryDate: DateTime(2027, 1, 1),
          status: ExpiryStatus.valid,
        );
        final id = await repo.insertDocumentExpiry(expiry);
        expect(id, expiry.id);
      });

      test('updateDocumentExpiry updates status', () async {
        final all = await repo.getDocumentExpiries();
        final first = all.first;
        final updated = first.copyWith(status: ExpiryStatus.expired);
        final success = await repo.updateDocumentExpiry(updated);
        expect(success, isTrue);
      });

      test('deleteDocumentExpiry removes record', () async {
        final all = await repo.getDocumentExpiries();
        final first = all.first;
        final success = await repo.deleteDocumentExpiry(first.id);
        expect(success, isTrue);
      });

      test('getDocumentExpiriesByStatus filters correctly', () async {
        final all = await repo.getDocumentExpiries();
        final status = all.first.status;
        final filtered = await repo.getDocumentExpiriesByStatus(status);
        expect(filtered.every((d) => d.status == status), isTrue);
      });
    });
  });
}
