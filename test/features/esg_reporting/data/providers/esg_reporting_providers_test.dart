import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/esg_reporting/data/providers/esg_reporting_providers.dart';
import 'package:ca_app/features/esg_reporting/domain/models/esg_disclosure.dart';
import 'package:ca_app/features/esg_reporting/domain/models/carbon_metric.dart';

void main() {
  group('ESG Reporting Providers via ProviderContainer', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    group('allEsgDisclosuresProvider', () {
      test('returns non-empty list of ESG disclosures', () {
        final disclosures = container.read(allEsgDisclosuresProvider);
        expect(disclosures, isNotEmpty);
        expect(disclosures.length, greaterThanOrEqualTo(6));
      });

      test('all entries are EsgDisclosure instances', () {
        final disclosures = container.read(allEsgDisclosuresProvider);
        for (final d in disclosures) {
          expect(d, isA<EsgDisclosure>());
        }
      });

      test('all disclosures have valid scores between 0 and 100', () {
        final disclosures = container.read(allEsgDisclosuresProvider);
        for (final d in disclosures) {
          expect(d.environmentScore, inInclusiveRange(0, 100));
          expect(d.socialScore, inInclusiveRange(0, 100));
          expect(d.governanceScore, inInclusiveRange(0, 100));
        }
      });
    });

    group('allCarbonMetricsProvider', () {
      test('returns non-empty list of carbon metrics', () {
        final metrics = container.read(allCarbonMetricsProvider);
        expect(metrics, isNotEmpty);
        expect(metrics.length, greaterThanOrEqualTo(8));
      });

      test('all entries are CarbonMetric instances', () {
        final metrics = container.read(allCarbonMetricsProvider);
        for (final m in metrics) {
          expect(m, isA<CarbonMetric>());
        }
      });

      test('all metrics have non-empty scope descriptions', () {
        final metrics = container.read(allCarbonMetricsProvider);
        for (final m in metrics) {
          expect(m.scope, isNotEmpty);
        }
      });
    });

    group('selectedEsgStatusProvider', () {
      test('initial state is null', () {
        expect(container.read(selectedEsgStatusProvider), isNull);
      });

      test('can be set to Filed status', () {
        container.read(selectedEsgStatusProvider.notifier).update('Filed');
        expect(container.read(selectedEsgStatusProvider), 'Filed');
      });

      test('can be set to Draft status', () {
        container.read(selectedEsgStatusProvider.notifier).update('Draft');
        expect(container.read(selectedEsgStatusProvider), 'Draft');
      });

      test('can be cleared back to null', () {
        container.read(selectedEsgStatusProvider.notifier).update('Published');
        container.read(selectedEsgStatusProvider.notifier).update(null);
        expect(container.read(selectedEsgStatusProvider), isNull);
      });
    });

    group('filteredEsgDisclosuresProvider', () {
      test('returns all disclosures when no filter is set', () {
        final all = container.read(allEsgDisclosuresProvider);
        final filtered = container.read(filteredEsgDisclosuresProvider);
        expect(filtered.length, all.length);
      });

      test('filters to Filed disclosures only', () {
        container.read(selectedEsgStatusProvider.notifier).update('Filed');
        final filtered = container.read(filteredEsgDisclosuresProvider);
        expect(filtered, isNotEmpty);
        expect(filtered.every((d) => d.status == 'Filed'), isTrue);
      });

      test('filters to Published disclosures only', () {
        container.read(selectedEsgStatusProvider.notifier).update('Published');
        final filtered = container.read(filteredEsgDisclosuresProvider);
        expect(filtered, isNotEmpty);
        expect(filtered.every((d) => d.status == 'Published'), isTrue);
      });

      test('filters to Draft disclosures only', () {
        container.read(selectedEsgStatusProvider.notifier).update('Draft');
        final filtered = container.read(filteredEsgDisclosuresProvider);
        expect(filtered, isNotEmpty);
        expect(filtered.every((d) => d.status == 'Draft'), isTrue);
      });

      test('returns empty for non-existent status', () {
        container
            .read(selectedEsgStatusProvider.notifier)
            .update('NonExistentStatus99');
        final filtered = container.read(filteredEsgDisclosuresProvider);
        expect(filtered, isEmpty);
      });

      test('Under Review disclosures are filtered correctly', () {
        container
            .read(selectedEsgStatusProvider.notifier)
            .update('Under Review');
        final filtered = container.read(filteredEsgDisclosuresProvider);
        expect(filtered, isNotEmpty);
        expect(filtered.every((d) => d.status == 'Under Review'), isTrue);
      });

      test('filtered disclosures have valid overall scores', () {
        container.read(selectedEsgStatusProvider.notifier).update('Filed');
        final filtered = container.read(filteredEsgDisclosuresProvider);
        for (final d in filtered) {
          expect(d.overallScore, greaterThan(0));
          expect(d.overallScore, lessThanOrEqualTo(100));
        }
      });
    });
  });
}
