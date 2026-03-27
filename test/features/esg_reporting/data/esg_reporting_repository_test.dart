import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/esg_reporting/data/repositories/mock_esg_reporting_repository.dart';
import 'package:ca_app/features/esg_reporting/domain/models/esg_disclosure.dart';
import 'package:ca_app/features/esg_reporting/domain/models/carbon_metric.dart';

void main() {
  late MockEsgReportingRepository repo;

  setUp(() {
    repo = MockEsgReportingRepository();
  });

  group('MockEsgReportingRepository - EsgDisclosure', () {
    test('getAllDisclosures returns non-empty seeded list', () async {
      final disclosures = await repo.getAllDisclosures();
      expect(disclosures, isNotEmpty);
    });

    test('getDisclosuresByStatus filters correctly', () async {
      final disclosures = await repo.getDisclosuresByStatus('Draft');
      for (final d in disclosures) {
        expect(d.status, 'Draft');
      }
    });

    test('getDisclosuresByClient filters correctly', () async {
      final disclosures = await repo.getDisclosuresByClient('mock-client-001');
      for (final d in disclosures) {
        expect(d.clientPan, 'mock-client-001');
      }
    });

    test('insertDisclosure adds entry and returns id', () async {
      const disclosure = EsgDisclosure(
        id: 'esg-new-001',
        clientName: 'New Corp Ltd',
        clientPan: 'ABCDE1234F',
        disclosureType: 'BRSR',
        reportingYear: 'FY 2024-25',
        environmentScore: 72.5,
        socialScore: 68.0,
        governanceScore: 80.0,
        overallScore: 73.5,
        status: 'Draft',
        sebiCategory: 'Listed Top 1000',
        pendingItems: ['Upload GHG data', 'Board approval'],
      );
      final id = await repo.insertDisclosure(disclosure);
      expect(id, 'esg-new-001');

      final all = await repo.getAllDisclosures();
      expect(all.any((d) => d.id == 'esg-new-001'), isTrue);
    });

    test('updateDisclosure updates status and returns true', () async {
      final all = await repo.getAllDisclosures();
      final first = all.first;
      final updated = first.copyWith(status: 'Filed');
      final success = await repo.updateDisclosure(updated);
      expect(success, isTrue);

      final refetched = await repo.getAllDisclosures();
      final found = refetched.firstWhere((d) => d.id == first.id);
      expect(found.status, 'Filed');
    });

    test('updateDisclosure returns false for non-existent id', () async {
      const ghost = EsgDisclosure(
        id: 'non-existent-esg',
        clientName: 'Ghost Corp',
        clientPan: 'ZZZZZ9999Z',
        disclosureType: 'BRSR',
        reportingYear: 'FY 2020-21',
        environmentScore: 0,
        socialScore: 0,
        governanceScore: 0,
        overallScore: 0,
        status: 'Draft',
        sebiCategory: 'Voluntary',
        pendingItems: [],
      );
      final success = await repo.updateDisclosure(ghost);
      expect(success, isFalse);
    });

    test('deleteDisclosure removes entry and returns true', () async {
      final all = await repo.getAllDisclosures();
      final target = all.first;
      final deleted = await repo.deleteDisclosure(target.id);
      expect(deleted, isTrue);

      final remaining = await repo.getAllDisclosures();
      expect(remaining.any((d) => d.id == target.id), isFalse);
    });

    test('deleteDisclosure returns false for non-existent id', () async {
      final deleted = await repo.deleteDisclosure('no-such-id');
      expect(deleted, isFalse);
    });
  });

  group('MockEsgReportingRepository - CarbonMetric', () {
    test('getAllCarbonMetrics returns non-empty seeded list', () async {
      final metrics = await repo.getAllCarbonMetrics();
      expect(metrics, isNotEmpty);
    });

    test('getCarbonMetricsByClient filters correctly', () async {
      final metrics = await repo.getCarbonMetricsByClient('Infosys Ltd');
      for (final m in metrics) {
        expect(m.clientName, 'Infosys Ltd');
      }
    });

    test('getCarbonMetricsByYear filters correctly', () async {
      final metrics = await repo.getCarbonMetricsByYear('FY 2024-25');
      for (final m in metrics) {
        expect(m.reportingYear, 'FY 2024-25');
      }
    });

    test('insertCarbonMetric adds entry and returns id', () async {
      const metric = CarbonMetric(
        id: 'carbon-new-001',
        clientName: 'New Corp Ltd',
        scope: 'Scope 1',
        emissionsTonnes: 1500.0,
        reductionTargetPercent: 30.0,
        achievedPercent: 15.0,
        reportingYear: 'FY 2024-25',
        unit: 'tCO2e',
      );
      final id = await repo.insertCarbonMetric(metric);
      expect(id, 'carbon-new-001');
    });

    test('updateCarbonMetric returns true on success', () async {
      final all = await repo.getAllCarbonMetrics();
      final first = all.first;
      final updated = first.copyWith(achievedPercent: 25.0);
      final success = await repo.updateCarbonMetric(updated);
      expect(success, isTrue);
    });

    test('updateCarbonMetric returns false for non-existent id', () async {
      const ghost = CarbonMetric(
        id: 'non-existent-carbon',
        clientName: 'Ghost',
        scope: 'Scope 3',
        emissionsTonnes: 0,
        reductionTargetPercent: 0,
        achievedPercent: 0,
        reportingYear: 'FY 2020-21',
        unit: 'tCO2e',
      );
      final success = await repo.updateCarbonMetric(ghost);
      expect(success, isFalse);
    });

    test('deleteCarbonMetric removes entry and returns true', () async {
      final all = await repo.getAllCarbonMetrics();
      final target = all.first;
      final deleted = await repo.deleteCarbonMetric(target.id);
      expect(deleted, isTrue);

      final remaining = await repo.getAllCarbonMetrics();
      expect(remaining.any((m) => m.id == target.id), isFalse);
    });

    test('deleteCarbonMetric returns false for non-existent id', () async {
      final deleted = await repo.deleteCarbonMetric('no-such-id');
      expect(deleted, isFalse);
    });
  });
}
