import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/startup_compliance/domain/models/startup_entity.dart';
import 'package:ca_app/features/startup_compliance/domain/models/startup_filing.dart';
import 'package:ca_app/features/startup_compliance/data/repositories/mock_startup_compliance_repository.dart';

void main() {
  group('MockStartupComplianceRepository', () {
    late MockStartupComplianceRepository repo;

    setUp(() {
      repo = MockStartupComplianceRepository();
    });

    // -------------------------------------------------------------------------
    // StartupEntity
    // -------------------------------------------------------------------------

    group('StartupEntities', () {
      test('getStartupEntities returns at least 3 seed items', () async {
        final entities = await repo.getStartupEntities();
        expect(entities.length, greaterThanOrEqualTo(3));
      });

      test('getStartupEntityById returns matching entity', () async {
        final all = await repo.getStartupEntities();
        final first = all.first;
        final found = await repo.getStartupEntityById(first.id);
        expect(found?.id, first.id);
      });

      test('getStartupEntityById returns null for unknown id', () async {
        final found = await repo.getStartupEntityById('no-such-id');
        expect(found, isNull);
      });

      test('getStartupEntitiesByRecognitionStatus filters correctly', () async {
        final entities = await repo.getStartupEntitiesByRecognitionStatus(
          RecognitionStatus.recognized,
        );
        expect(
          entities.every(
            (e) => e.recognitionStatus == RecognitionStatus.recognized,
          ),
          isTrue,
        );
      });

      test('insertStartupEntity adds entity and returns id', () async {
        final entity = StartupEntity(
          id: 'startup-new-001',
          entityName: 'New Tech Startup',
          dpiitNumber: 'DPIIT2026001',
          incorporationDate: DateTime(2022, 6, 1),
          sector: 'FinTech',
          turnover: 5.0,
          isBelow100Cr: true,
          section80IACStatus: Section80IACStatus.eligible,
          recognitionStatus: RecognitionStatus.recognized,
          investmentRounds: [
            InvestmentRound(
              roundName: 'Seed',
              amount: 1.5,
              date: DateTime(2024, 1, 1),
              investor: 'Angel Fund',
            ),
          ],
        );
        final id = await repo.insertStartupEntity(entity);
        expect(id, entity.id);

        final all = await repo.getStartupEntities();
        expect(all.any((e) => e.id == 'startup-new-001'), isTrue);
      });

      test('updateStartupEntity updates existing entity', () async {
        final all = await repo.getStartupEntities();
        final first = all.first;
        final updated = first.copyWith(
          section80IACStatus: Section80IACStatus.approved,
        );
        final success = await repo.updateStartupEntity(updated);
        expect(success, isTrue);

        final found = await repo.getStartupEntityById(first.id);
        expect(found?.section80IACStatus, Section80IACStatus.approved);
      });

      test('updateStartupEntity returns false for non-existent', () async {
        final ghost = StartupEntity(
          id: 'ghost-id',
          entityName: 'Ghost',
          dpiitNumber: 'GHOST000',
          incorporationDate: DateTime(2026),
          sector: 'None',
          turnover: 0,
          isBelow100Cr: true,
          section80IACStatus: Section80IACStatus.eligible,
          recognitionStatus: RecognitionStatus.pending,
          investmentRounds: const [],
        );
        final success = await repo.updateStartupEntity(ghost);
        expect(success, isFalse);
      });

      test('deleteStartupEntity removes entity', () async {
        final all = await repo.getStartupEntities();
        final first = all.first;
        final success = await repo.deleteStartupEntity(first.id);
        expect(success, isTrue);

        final found = await repo.getStartupEntityById(first.id);
        expect(found, isNull);
      });

      test('deleteStartupEntity returns false for unknown id', () async {
        final success = await repo.deleteStartupEntity('no-such-id');
        expect(success, isFalse);
      });
    });

    // -------------------------------------------------------------------------
    // StartupFiling
    // -------------------------------------------------------------------------

    group('StartupFilings', () {
      test('getStartupFilings returns at least 3 seed items', () async {
        final filings = await repo.getStartupFilings();
        expect(filings.length, greaterThanOrEqualTo(3));
      });

      test('getStartupFilingById returns matching filing', () async {
        final all = await repo.getStartupFilings();
        final first = all.first;
        final found = await repo.getStartupFilingById(first.id);
        expect(found?.id, first.id);
      });

      test('getStartupFilingById returns null for unknown id', () async {
        final found = await repo.getStartupFilingById('no-such-id');
        expect(found, isNull);
      });

      test('getStartupFilingsByStartup filters by startupId', () async {
        final all = await repo.getStartupFilings();
        final startupId = all.first.startupId;
        final filtered = await repo.getStartupFilingsByStartup(startupId);
        expect(filtered.every((f) => f.startupId == startupId), isTrue);
      });

      test('getStartupFilingsByStatus filters correctly', () async {
        final filings = await repo.getStartupFilingsByStatus(
          StartupFilingStatus.pending,
        );
        expect(
          filings.every((f) => f.status == StartupFilingStatus.pending),
          isTrue,
        );
      });

      test('insertStartupFiling adds filing and returns id', () async {
        final filing = StartupFiling(
          id: 'filing-new-001',
          startupId: 'startup-001',
          entityName: 'New Tech Startup',
          filingType: StartupFilingType.annualReturn,
          dueDate: DateTime(2026, 9, 30),
          status: StartupFilingStatus.pending,
        );
        final id = await repo.insertStartupFiling(filing);
        expect(id, filing.id);
      });

      test('updateStartupFiling updates existing filing', () async {
        final all = await repo.getStartupFilings();
        final first = all.first;
        final updated = first.copyWith(status: StartupFilingStatus.filed);
        final success = await repo.updateStartupFiling(updated);
        expect(success, isTrue);

        final found = await repo.getStartupFilingById(first.id);
        expect(found?.status, StartupFilingStatus.filed);
      });

      test('updateStartupFiling returns false for non-existent', () async {
        final ghost = StartupFiling(
          id: 'ghost-id',
          startupId: 's',
          entityName: 'Ghost',
          filingType: StartupFilingType.itr,
          dueDate: DateTime(2026),
          status: StartupFilingStatus.pending,
        );
        final success = await repo.updateStartupFiling(ghost);
        expect(success, isFalse);
      });

      test('deleteStartupFiling removes filing', () async {
        final all = await repo.getStartupFilings();
        final first = all.first;
        final success = await repo.deleteStartupFiling(first.id);
        expect(success, isTrue);
      });

      test('deleteStartupFiling returns false for unknown id', () async {
        final success = await repo.deleteStartupFiling('no-such-id');
        expect(success, isFalse);
      });
    });
  });
}
