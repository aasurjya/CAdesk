import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/virtual_cfo/data/repositories/mock_virtual_cfo_repository.dart';
import 'package:ca_app/features/virtual_cfo/domain/models/cfo_scenario.dart';
import 'package:ca_app/features/virtual_cfo/domain/models/mis_report.dart';

void main() {
  group('MockVirtualCfoRepository', () {
    late MockVirtualCfoRepository repo;

    setUp(() {
      repo = MockVirtualCfoRepository();
    });

    // ── MIS Reports ──────────────────────────────────────────────────────────

    group('getAllReports', () {
      test('returns seeded reports', () async {
        final result = await repo.getAllReports();
        expect(result, isNotEmpty);
      });

      test('returns a typed list', () async {
        final result = await repo.getAllReports();
        expect(result, isA<List<MisReport>>());
      });
    });

    group('getReportsByClient', () {
      test('filters by clientName', () async {
        final result = await repo.getReportsByClient(
          'Apex Manufacturing Pvt Ltd',
        );
        expect(result, isNotEmpty);
        for (final r in result) {
          expect(r.clientName, 'Apex Manufacturing Pvt Ltd');
        }
      });

      test('returns empty for unknown client', () async {
        final result = await repo.getReportsByClient('Unknown Client');
        expect(result, isEmpty);
      });
    });

    group('insertReport', () {
      test('inserts and returns id', () async {
        const report = MisReport(
          id: 'mis-new-001',
          clientName: 'New Client',
          reportType: 'KPI Dashboard',
          period: 'Mar 2026',
          revenue: 10.0,
          expenses: 8.0,
          netProfit: 2.0,
          ebitdaMarginPercent: 20.0,
          cashBalance: 3.0,
          status: 'Draft',
          keyHighlights: ['Test highlight'],
        );
        final id = await repo.insertReport(report);
        expect(id, 'mis-new-001');

        final all = await repo.getAllReports();
        expect(all.any((r) => r.id == 'mis-new-001'), isTrue);
      });
    });

    group('updateReport', () {
      test('updates existing report', () async {
        final all = await repo.getAllReports();
        final existing = all.first;
        final updated = existing.copyWith(status: 'Delivered');

        final result = await repo.updateReport(updated);
        expect(result, isTrue);

        final fetched = await repo.getAllReports();
        final found = fetched.firstWhere((r) => r.id == existing.id);
        expect(found.status, 'Delivered');
      });

      test('returns false for unknown report', () async {
        const report = MisReport(
          id: 'mis-does-not-exist',
          clientName: 'X',
          reportType: 'Y',
          period: 'Z',
          revenue: 0,
          expenses: 0,
          netProfit: 0,
          ebitdaMarginPercent: 0,
          cashBalance: 0,
          status: 'Draft',
          keyHighlights: [],
        );
        final result = await repo.updateReport(report);
        expect(result, isFalse);
      });
    });

    group('deleteReport', () {
      test('deletes existing report', () async {
        final all = await repo.getAllReports();
        final id = all.first.id;

        final result = await repo.deleteReport(id);
        expect(result, isTrue);

        final after = await repo.getAllReports();
        expect(after.any((r) => r.id == id), isFalse);
      });

      test('returns false for unknown id', () async {
        final result = await repo.deleteReport('unknown-id');
        expect(result, isFalse);
      });
    });

    // ── CFO Scenarios ────────────────────────────────────────────────────────

    group('getAllScenarios', () {
      test('returns seeded scenarios', () async {
        final result = await repo.getAllScenarios();
        expect(result, isNotEmpty);
      });
    });

    group('getScenariosByClient', () {
      test('filters by clientName', () async {
        final result = await repo.getScenariosByClient(
          'Apex Manufacturing Pvt Ltd',
        );
        expect(result, isNotEmpty);
        for (final s in result) {
          expect(s.clientName, 'Apex Manufacturing Pvt Ltd');
        }
      });

      test('returns empty for unknown client', () async {
        final result = await repo.getScenariosByClient('Unknown');
        expect(result, isEmpty);
      });
    });

    group('insertScenario', () {
      test('inserts and returns id', () async {
        const scenario = CfoScenario(
          id: 'scen-new-001',
          clientName: 'New Client',
          scenarioName: 'Base Case',
          category: 'Revenue',
          baselineValue: 20.0,
          projectedValue: 22.0,
          impactPercent: 10.0,
          timeHorizon: 'FY27',
          assumption: 'Steady growth',
        );
        final id = await repo.insertScenario(scenario);
        expect(id, 'scen-new-001');

        final all = await repo.getAllScenarios();
        expect(all.any((s) => s.id == 'scen-new-001'), isTrue);
      });
    });

    group('updateScenario', () {
      test('updates existing scenario', () async {
        final all = await repo.getAllScenarios();
        final existing = all.first;
        final updated = existing.copyWith(impactPercent: 25.0);

        final result = await repo.updateScenario(updated);
        expect(result, isTrue);

        final fetched = await repo.getAllScenarios();
        final found = fetched.firstWhere((s) => s.id == existing.id);
        expect(found.impactPercent, 25.0);
      });

      test('returns false for unknown scenario', () async {
        const scenario = CfoScenario(
          id: 'scen-does-not-exist',
          clientName: 'X',
          scenarioName: 'Y',
          category: 'Z',
          baselineValue: 0,
          projectedValue: 0,
          impactPercent: 0,
          timeHorizon: 'FY27',
          assumption: 'A',
        );
        final result = await repo.updateScenario(scenario);
        expect(result, isFalse);
      });
    });
  });
}
