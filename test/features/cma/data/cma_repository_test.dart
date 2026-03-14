import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/cma/domain/models/cma_report.dart';
import 'package:ca_app/features/cma/data/repositories/mock_cma_repository.dart';

void main() {
  group('MockCmaRepository', () {
    late MockCmaRepository repo;

    setUp(() {
      repo = MockCmaRepository();
    });

    group('getReportsByClient', () {
      test('returns seeded reports for mock-client-001', () async {
        final results = await repo.getReportsByClient('mock-client-001');
        expect(results, isNotEmpty);
        expect(results.every((r) => r.clientId == 'mock-client-001'), isTrue);
      });

      test('returns empty list for unknown client', () async {
        final results = await repo.getReportsByClient('unknown');
        expect(results, isEmpty);
      });
    });

    group('getReportById', () {
      test('returns report for valid ID', () async {
        final report = await repo.getReportById('mock-cma-001');
        expect(report, isNotNull);
        expect(report!.id, 'mock-cma-001');
      });

      test('returns null for unknown ID', () async {
        final report = await repo.getReportById('no-such-id');
        expect(report, isNull);
      });
    });

    group('insertReport', () {
      test('inserts and returns new report ID', () async {
        final newReport = CmaReport(
          id: 'new-cma-001',
          clientId: 'client-z',
          clientName: 'Client Z',
          bankName: 'State Bank of India',
          loanPurpose: 'Working Capital',
          projectionYears: 3,
          status: CmaReportStatus.draft,
          preparedDate: DateTime(2026, 3, 1),
          requestedAmount: 5000000,
          projections: const [],
        );
        final id = await repo.insertReport(newReport);
        expect(id, 'new-cma-001');

        final fetched = await repo.getReportById('new-cma-001');
        expect(fetched, isNotNull);
        expect(fetched!.bankName, 'State Bank of India');
      });
    });

    group('updateReport', () {
      test('updates existing report and returns true', () async {
        final existing = await repo.getReportById('mock-cma-001');
        expect(existing, isNotNull);

        final updated = existing!.copyWith(status: CmaReportStatus.submitted);
        final success = await repo.updateReport(updated);
        expect(success, isTrue);

        final fetched = await repo.getReportById('mock-cma-001');
        expect(fetched!.status, CmaReportStatus.submitted);
      });

      test('returns false for non-existent report', () async {
        final ghost = CmaReport(
          id: 'ghost-cma',
          clientId: 'c',
          clientName: 'Ghost',
          bankName: 'Ghost Bank',
          loanPurpose: 'Ghost',
          projectionYears: 1,
          status: CmaReportStatus.draft,
          preparedDate: DateTime(2026, 1, 1),
          requestedAmount: 0,
          projections: const [],
        );
        final success = await repo.updateReport(ghost);
        expect(success, isFalse);
      });
    });

    group('deleteReport', () {
      test('deletes report and returns true', () async {
        final id = await repo.insertReport(
          CmaReport(
            id: 'to-delete-cma',
            clientId: 'client-del',
            clientName: 'Del Client',
            bankName: 'Del Bank',
            loanPurpose: 'Term Loan',
            projectionYears: 2,
            status: CmaReportStatus.draft,
            preparedDate: DateTime(2025, 1, 1),
            requestedAmount: 1000000,
            projections: const [],
          ),
        );

        final success = await repo.deleteReport(id);
        expect(success, isTrue);

        final fetched = await repo.getReportById(id);
        expect(fetched, isNull);
      });

      test('returns false for non-existent report ID', () async {
        final success = await repo.deleteReport('no-such-cma');
        expect(success, isFalse);
      });
    });

    group('getAllReports', () {
      test('returns all seeded reports', () async {
        final all = await repo.getAllReports();
        expect(all.length, greaterThanOrEqualTo(3));
      });

      test('result is unmodifiable', () async {
        final all = await repo.getAllReports();
        expect(() => (all as dynamic).add(all.first), throwsA(isA<Error>()));
      });
    });
  });
}
