import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/llp_compliance/domain/models/llp_entity.dart';
import 'package:ca_app/features/llp_compliance/domain/models/llp_filing.dart';
import 'package:ca_app/features/llp_compliance/data/repositories/mock_llp_compliance_repository.dart';

void main() {
  group('MockLlpComplianceRepository', () {
    late MockLlpComplianceRepository repo;

    setUp(() {
      repo = MockLlpComplianceRepository();
    });

    // -----------------------------------------------------------------------
    // LLPEntity tests
    // -----------------------------------------------------------------------

    group('getEntities', () {
      test('returns seeded entities', () async {
        final results = await repo.getEntities();
        expect(results, isNotEmpty);
      });

      test('returns unmodifiable list', () async {
        final results = await repo.getEntities();
        expect(() => results.add(results.first), throwsUnsupportedError);
      });
    });

    group('getEntityById', () {
      test('returns entity for known id', () async {
        final all = await repo.getEntities();
        final id = all.first.id;
        final result = await repo.getEntityById(id);
        expect(result, isNotNull);
        expect(result!.id, equals(id));
      });

      test('returns null for unknown id', () async {
        final result = await repo.getEntityById('no-such-id');
        expect(result, isNull);
      });
    });

    group('searchEntities', () {
      test('returns results for partial llpName match', () async {
        final all = await repo.getEntities();
        final query = all.first.llpName.substring(0, 3).toLowerCase();
        final results = await repo.searchEntities(query);
        expect(results, isNotEmpty);
      });

      test('returns empty for non-matching query', () async {
        final results = await repo.searchEntities('zzznomatchzzz');
        expect(results, isEmpty);
      });
    });

    group('insertEntity', () {
      test('inserts and returns id', () async {
        final entity = LLPEntity(
          id: 'test-llp-001',
          llpName: 'Test LLP',
          llpin: 'AAA-0001',
          incorporationDate: DateTime(2022, 1, 1),
          turnover: 2000000,
          capitalContribution: 1000000,
          isAuditRequired: false,
          designatedPartners: [
            const LLPPartner(
              name: 'Partner A',
              din: 'DIN00000001',
              email: 'a@test.com',
              isDesignated: true,
            ),
          ],
          registeredOffice: 'Mumbai, Maharashtra',
          rocJurisdiction: 'RoC Mumbai',
        );
        final id = await repo.insertEntity(entity);
        expect(id, equals('test-llp-001'));
      });

      test('inserted entity is retrievable', () async {
        final entity = LLPEntity(
          id: 'test-llp-002',
          llpName: 'Retrievable LLP',
          llpin: 'BBB-0002',
          incorporationDate: DateTime(2021, 6, 15),
          turnover: 3500000,
          capitalContribution: 1500000,
          isAuditRequired: false,
          designatedPartners: [],
          registeredOffice: 'Delhi',
          rocJurisdiction: 'RoC Delhi',
        );
        await repo.insertEntity(entity);
        final result = await repo.getEntityById('test-llp-002');
        expect(result, isNotNull);
      });
    });

    group('updateEntity', () {
      test('updates turnover and returns true', () async {
        final all = await repo.getEntities();
        final original = all.first;
        final updated = original.copyWith(turnover: 99999999);
        final success = await repo.updateEntity(updated);
        expect(success, isTrue);

        final after = await repo.getEntityById(original.id);
        expect(after?.turnover, 99999999);
      });

      test('returns false for non-existent id', () async {
        final ghost = LLPEntity(
          id: 'no-such-id',
          llpName: 'Ghost LLP',
          llpin: 'GHOST-0000',
          incorporationDate: DateTime(2020, 1, 1),
          turnover: 0,
          capitalContribution: 0,
          isAuditRequired: false,
          designatedPartners: [],
          registeredOffice: 'Unknown',
          rocJurisdiction: 'Unknown',
        );
        final success = await repo.updateEntity(ghost);
        expect(success, isFalse);
      });
    });

    group('deleteEntity', () {
      test('deletes seeded entity and returns true', () async {
        final all = await repo.getEntities();
        final id = all.first.id;
        final success = await repo.deleteEntity(id);
        expect(success, isTrue);

        final after = await repo.getEntityById(id);
        expect(after, isNull);
      });

      test('returns false for non-existent id', () async {
        final success = await repo.deleteEntity('no-such-id-xyz');
        expect(success, isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // LLPFiling tests
    // -----------------------------------------------------------------------

    group('getFilings', () {
      test('returns seeded filings', () async {
        final results = await repo.getFilings();
        expect(results, isNotEmpty);
      });
    });

    group('getFilingsByEntity', () {
      test('returns filings for known entity', () async {
        final allFilings = await repo.getFilings();
        final llpId = allFilings.first.llpId;
        final results = await repo.getFilingsByEntity(llpId);
        expect(results.every((f) => f.llpId == llpId), isTrue);
      });

      test('returns empty for unknown entity', () async {
        final results = await repo.getFilingsByEntity('no-such-entity');
        expect(results, isEmpty);
      });
    });

    group('getFilingsByStatus', () {
      test('returns only filings with matching status', () async {
        final all = await repo.getFilings();
        final status = all.first.status;
        final results = await repo.getFilingsByStatus(status);
        expect(results.every((f) => f.status == status), isTrue);
      });
    });

    group('insertFiling', () {
      test('inserts and returns id', () async {
        final filing = LLPFiling(
          id: 'test-filing-001',
          llpId: 'llp-001',
          llpName: 'Test LLP',
          formType: LLPFormType.form11,
          dueDate: DateTime(2026, 5, 30),
          status: LLPFilingStatus.pending,
          financialYear: 'FY 2025-26',
          penaltyPerDay: 100,
          maxPenalty: 100000,
          currentPenalty: 0,
        );
        final id = await repo.insertFiling(filing);
        expect(id, equals('test-filing-001'));
      });
    });

    group('updateFiling', () {
      test('marks as filed and returns true', () async {
        final all = await repo.getFilings();
        final original = all.first;
        final updated = original.copyWith(
          status: LLPFilingStatus.filed,
          filedDate: DateTime(2026, 3, 14),
        );
        final success = await repo.updateFiling(updated);
        expect(success, isTrue);

        final after = await repo.getFilings();
        final found = after.firstWhere((f) => f.id == original.id);
        expect(found.status, LLPFilingStatus.filed);
      });

      test('returns false for non-existent id', () async {
        final ghost = LLPFiling(
          id: 'no-such-filing',
          llpId: 'x',
          llpName: 'Ghost LLP',
          formType: LLPFormType.form8,
          dueDate: DateTime(2026, 10, 30),
          status: LLPFilingStatus.pending,
          financialYear: 'FY 2025-26',
          penaltyPerDay: 100,
          maxPenalty: 100000,
          currentPenalty: 0,
        );
        final success = await repo.updateFiling(ghost);
        expect(success, isFalse);
      });
    });

    group('deleteFiling', () {
      test('deletes seeded filing and returns true', () async {
        final all = await repo.getFilings();
        final id = all.first.id;
        final success = await repo.deleteFiling(id);
        expect(success, isTrue);

        final after = await repo.getFilings();
        expect(after.any((f) => f.id == id), isFalse);
      });

      test('returns false for non-existent id', () async {
        final success = await repo.deleteFiling('no-such-id-xyz');
        expect(success, isFalse);
      });
    });
  });
}
