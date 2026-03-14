import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/faceless_assessment/domain/models/e_proceeding.dart';
import 'package:ca_app/features/faceless_assessment/domain/models/hearing_schedule.dart';
import 'package:ca_app/features/faceless_assessment/domain/models/itr_u_filing.dart';
import 'package:ca_app/features/faceless_assessment/data/repositories/mock_faceless_assessment_repository.dart';

void main() {
  group('MockFacelessAssessmentRepository', () {
    late MockFacelessAssessmentRepository repo;

    setUp(() {
      repo = MockFacelessAssessmentRepository();
    });

    // -----------------------------------------------------------------------
    // EProceeding tests
    // -----------------------------------------------------------------------

    group('getProceedings', () {
      test('returns seeded proceedings', () async {
        final results = await repo.getProceedings();
        expect(results, isNotEmpty);
      });

      test('returns unmodifiable list', () async {
        final results = await repo.getProceedings();
        expect(() => results.add(results.first), throwsUnsupportedError);
      });
    });

    group('getProceedingsByClient', () {
      test('returns proceedings for mock-client-001', () async {
        final results = await repo.getProceedingsByClient('mock-client-001');
        expect(results.every((p) => p.clientId == 'mock-client-001'), isTrue);
      });

      test('returns empty for unknown client', () async {
        final results = await repo.getProceedingsByClient('no-such-client');
        expect(results, isEmpty);
      });
    });

    group('insertProceeding', () {
      test('inserts and returns id', () async {
        final proceeding = EProceeding(
          id: 'test-proc-001',
          clientId: 'new-client',
          clientName: 'Test Client',
          pan: 'AAAAA1234A',
          assessmentYear: 'AY 2024-25',
          proceedingType: ProceedingType.scrutiny143_3,
          noticeDate: DateTime(2026, 1, 1),
          responseDeadline: DateTime(2026, 4, 1),
          status: ProceedingStatus.noticeReceived,
          nfacReferenceNumber: 'NFAC/TEST/001',
        );
        final id = await repo.insertProceeding(proceeding);
        expect(id, equals('test-proc-001'));
      });

      test('inserted proceeding is retrievable', () async {
        final proceeding = EProceeding(
          id: 'test-proc-002',
          clientId: 'insert-client',
          clientName: 'Insert Client',
          pan: 'BBBBB5678B',
          assessmentYear: 'AY 2024-25',
          proceedingType: ProceedingType.penalty,
          noticeDate: DateTime(2026, 1, 1),
          responseDeadline: DateTime(2026, 4, 1),
          status: ProceedingStatus.noticeReceived,
          nfacReferenceNumber: 'NFAC/TEST/002',
        );
        await repo.insertProceeding(proceeding);
        final results = await repo.getProceedingsByClient('insert-client');
        expect(results.any((p) => p.id == 'test-proc-002'), isTrue);
      });
    });

    group('updateProceeding', () {
      test('updates status and returns true', () async {
        final all = await repo.getProceedings();
        final original = all.first;
        final updated = original.copyWith(
          status: ProceedingStatus.responseSubmitted,
        );
        final success = await repo.updateProceeding(updated);
        expect(success, isTrue);

        final after = await repo.getProceedings();
        final found = after.firstWhere((p) => p.id == original.id);
        expect(found.status, ProceedingStatus.responseSubmitted);
      });

      test('returns false for non-existent id', () async {
        final ghost = EProceeding(
          id: 'no-such-id',
          clientId: 'x',
          clientName: 'X',
          pan: 'XXXXX9999X',
          assessmentYear: 'AY 2020-21',
          proceedingType: ProceedingType.penalty,
          noticeDate: DateTime(2026, 1, 1),
          responseDeadline: DateTime(2026, 4, 1),
          status: ProceedingStatus.noticeReceived,
          nfacReferenceNumber: 'NFAC/GHOST/001',
        );
        final success = await repo.updateProceeding(ghost);
        expect(success, isFalse);
      });
    });

    group('deleteProceeding', () {
      test('deletes seeded proceeding and returns true', () async {
        final all = await repo.getProceedings();
        final id = all.first.id;
        final success = await repo.deleteProceeding(id);
        expect(success, isTrue);
        final after = await repo.getProceedings();
        expect(after.any((p) => p.id == id), isFalse);
      });

      test('returns false for non-existent id', () async {
        final success = await repo.deleteProceeding('no-such-id-xyz');
        expect(success, isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // HearingSchedule tests
    // -----------------------------------------------------------------------

    group('getHearings', () {
      test('returns seeded hearings', () async {
        final results = await repo.getHearings();
        expect(results, isNotEmpty);
      });
    });

    group('getHearingsByProceeding', () {
      test('returns hearings for known proceeding', () async {
        final all = await repo.getHearings();
        final pid = all.first.proceedingId;
        final results = await repo.getHearingsByProceeding(pid);
        expect(results.every((h) => h.proceedingId == pid), isTrue);
      });

      test('returns empty for unknown proceeding', () async {
        final results = await repo.getHearingsByProceeding('no-such-id');
        expect(results, isEmpty);
      });
    });

    group('insertHearing', () {
      test('inserts and returns id', () async {
        final hearing = HearingSchedule(
          id: 'test-hs-001',
          proceedingId: 'ep-test',
          clientName: 'Test Hearing Client',
          hearingDate: DateTime(2026, 5, 1),
          hearingTime: '10:00 AM',
          platform: HearingPlatform.nfacPortal,
          agenda: 'Test agenda',
          documentsToSubmit: ['Doc A'],
          representativeName: 'CA Test',
          status: HearingStatus.scheduled,
        );
        final id = await repo.insertHearing(hearing);
        expect(id, equals('test-hs-001'));
      });
    });

    // -----------------------------------------------------------------------
    // ItrUFiling tests
    // -----------------------------------------------------------------------

    group('getItrUFilings', () {
      test('returns seeded ITR-U filings', () async {
        final results = await repo.getItrUFilings();
        expect(results, isNotEmpty);
      });
    });

    group('getItrUFilingsByClient', () {
      test('returns filings for known client', () async {
        final all = await repo.getItrUFilings();
        final clientId = all.first.clientId;
        final results = await repo.getItrUFilingsByClient(clientId);
        expect(results.every((f) => f.clientId == clientId), isTrue);
      });

      test('returns empty for unknown client', () async {
        final results = await repo.getItrUFilingsByClient('no-such-client');
        expect(results, isEmpty);
      });
    });

    group('insertItrUFiling', () {
      test('inserts and returns id', () async {
        final filing = ItrUFiling(
          id: 'test-iu-001',
          clientId: 'new-client-iu',
          clientName: 'ITR-U Test Client',
          pan: 'CCCCC1111C',
          originalAssessmentYear: 'AY 2024-25',
          originalFilingDate: DateTime(2024, 7, 31),
          updateReason: UpdateReason.incomeNotReported,
          additionalTax: 50000,
          penaltyPercentage: 25,
          penaltyAmount: 12500,
          totalPayable: 62500,
          status: ItrUStatus.draft,
          filingDeadline: DateTime(2026, 12, 31),
        );
        final id = await repo.insertItrUFiling(filing);
        expect(id, equals('test-iu-001'));
      });
    });

    group('updateItrUFiling', () {
      test('updates status and returns true', () async {
        final all = await repo.getItrUFilings();
        final original = all.first;
        final updated = original.copyWith(status: ItrUStatus.filed);
        final success = await repo.updateItrUFiling(updated);
        expect(success, isTrue);

        final after = await repo.getItrUFilings();
        final found = after.firstWhere((f) => f.id == original.id);
        expect(found.status, ItrUStatus.filed);
      });

      test('returns false for non-existent id', () async {
        final ghost = ItrUFiling(
          id: 'no-such-filing',
          clientId: 'x',
          clientName: 'X',
          pan: 'XXXXX0000X',
          originalAssessmentYear: 'AY 2020-21',
          originalFilingDate: DateTime(2020, 7, 31),
          updateReason: UpdateReason.other,
          additionalTax: 0,
          penaltyPercentage: 0,
          penaltyAmount: 0,
          totalPayable: 0,
          status: ItrUStatus.draft,
          filingDeadline: DateTime(2025, 12, 31),
        );
        final success = await repo.updateItrUFiling(ghost);
        expect(success, isFalse);
      });
    });
  });
}
