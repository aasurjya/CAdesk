import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/xbrl/data/repositories/mock_xbrl_repository.dart';
import 'package:ca_app/features/xbrl/domain/models/xbrl_filing.dart';

void main() {
  group('MockXbrlRepository', () {
    late MockXbrlRepository repo;

    setUp(() {
      repo = MockXbrlRepository();
    });

    group('getAllFilings', () {
      test('returns seeded filings', () async {
        final result = await repo.getAllFilings();
        expect(result, hasLength(3));
      });

      test('returns a typed list', () async {
        final result = await repo.getAllFilings();
        expect(result, isA<List<XbrlFiling>>());
      });
    });

    group('getFilingsByCompany', () {
      test('filters by companyId', () async {
        final result = await repo.getFilingsByCompany('comp-001');
        expect(result, hasLength(1));
        expect(result.first.companyId, 'comp-001');
      });

      test('returns empty for unknown company', () async {
        final result = await repo.getFilingsByCompany('comp-unknown');
        expect(result, isEmpty);
      });
    });

    group('getFilingById', () {
      test('returns filing for valid id', () async {
        final result = await repo.getFilingById('xbrl-mock-001');
        expect(result, isNotNull);
        expect(result!.id, 'xbrl-mock-001');
      });

      test('returns null for unknown id', () async {
        final result = await repo.getFilingById('xbrl-does-not-exist');
        expect(result, isNull);
      });
    });

    group('insertFiling', () {
      test('inserts filing and returns its id', () async {
        const filing = XbrlFiling(
          id: 'xbrl-new-001',
          companyId: 'comp-new',
          companyName: 'New Corp',
          cin: 'U12345MH2020PLC000001',
          financialYear: '2024-25',
          reportType: XbrlReportType.standalone,
          taxonomyVersion: '2023',
          status: XbrlFilingStatus.notStarted,
          totalTags: 400,
          completedTags: 0,
          validationErrors: 0,
          validationWarnings: 0,
        );
        final id = await repo.insertFiling(filing);
        expect(id, 'xbrl-new-001');

        final all = await repo.getAllFilings();
        expect(all.any((f) => f.id == 'xbrl-new-001'), isTrue);
      });
    });

    group('updateFiling', () {
      test('updates existing filing', () async {
        final all = await repo.getAllFilings();
        final existing = all.first;
        final updated = existing.copyWith(status: XbrlFilingStatus.review);

        final result = await repo.updateFiling(updated);
        expect(result, isTrue);

        final fetched = await repo.getFilingById(existing.id);
        expect(fetched!.status, XbrlFilingStatus.review);
      });

      test('returns false for unknown filing', () async {
        const filing = XbrlFiling(
          id: 'xbrl-does-not-exist',
          companyId: 'c',
          companyName: 'C',
          cin: 'L00000XX0000XXX000000',
          financialYear: '2024-25',
          reportType: XbrlReportType.standalone,
          taxonomyVersion: '2023',
          status: XbrlFilingStatus.notStarted,
          totalTags: 0,
          completedTags: 0,
          validationErrors: 0,
          validationWarnings: 0,
        );
        final result = await repo.updateFiling(filing);
        expect(result, isFalse);
      });
    });

    group('deleteFiling', () {
      test('deletes existing filing', () async {
        final before = await repo.getAllFilings();
        final id = before.first.id;

        final result = await repo.deleteFiling(id);
        expect(result, isTrue);

        final after = await repo.getAllFilings();
        expect(after.any((f) => f.id == id), isFalse);
      });

      test('returns false for unknown id', () async {
        final result = await repo.deleteFiling('xbrl-does-not-exist');
        expect(result, isFalse);
      });
    });
  });
}
