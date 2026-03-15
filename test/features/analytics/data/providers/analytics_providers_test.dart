import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/analytics/data/providers/analytics_providers.dart';
import 'package:ca_app/features/analytics/domain/models/kpi_metric.dart';
import 'package:ca_app/features/analytics/domain/models/aging_receivable.dart';

void main() {
  group('Analytics Providers via ProviderContainer', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    group('analyticsPeriodProvider', () {
      test('initial state is thisMonth', () {
        expect(
          container.read(analyticsPeriodProvider),
          AnalyticsPeriod.thisMonth,
        );
      });

      test('can be updated to a different period', () {
        container
            .read(analyticsPeriodProvider.notifier)
            .update(AnalyticsPeriod.thisYear);
        expect(
          container.read(analyticsPeriodProvider),
          AnalyticsPeriod.thisYear,
        );
      });

      test('all period labels are non-empty', () {
        for (final p in AnalyticsPeriod.values) {
          expect(p.label, isNotEmpty);
        }
      });
    });

    group('kpiMetricsProvider', () {
      test('returns non-empty list of KPI metrics', () {
        final kpis = container.read(kpiMetricsProvider);
        expect(kpis, isNotEmpty);
        expect(kpis.length, greaterThanOrEqualTo(12));
      });

      test('notifier update replaces state', () {
        final original = container.read(kpiMetricsProvider);
        final subset = original.take(3).toList();
        container.read(kpiMetricsProvider.notifier).update(subset);
        expect(container.read(kpiMetricsProvider).length, 3);
      });
    });

    group('kpisByCategoryProvider', () {
      test('returns KPIs filtered to firm category', () {
        final firmKpis = container.read(
          kpisByCategoryProvider(KpiCategory.firm),
        );
        expect(firmKpis, isNotEmpty);
        expect(
          firmKpis.every((k) => k.category == KpiCategory.firm),
          isTrue,
        );
      });

      test('returns KPIs filtered to compliance category', () {
        final complianceKpis = container.read(
          kpisByCategoryProvider(KpiCategory.compliance),
        );
        expect(complianceKpis, isNotEmpty);
        expect(
          complianceKpis.every((k) => k.category == KpiCategory.compliance),
          isTrue,
        );
      });
    });

    group('revenueDataProvider', () {
      test('returns non-empty list of revenue data', () {
        final revenue = container.read(revenueDataProvider);
        expect(revenue, isNotEmpty);
        expect(revenue.length, greaterThanOrEqualTo(15));
      });

      test('notifier update replaces state', () {
        final original = container.read(revenueDataProvider);
        final subset = original.take(5).toList();
        container.read(revenueDataProvider.notifier).update(subset);
        expect(container.read(revenueDataProvider).length, 5);
      });
    });

    group('totalRevenueProvider', () {
      test('returns positive total revenue', () {
        final total = container.read(totalRevenueProvider);
        expect(total, greaterThan(0));
      });

      test('matches sum of all revenue records', () {
        final records = container.read(revenueDataProvider);
        final expected = records.fold<double>(0, (s, r) => s + r.amount);
        expect(container.read(totalRevenueProvider), closeTo(expected, 0.001));
      });
    });

    group('revenueByServiceProvider', () {
      test('returns non-empty map', () {
        final byService = container.read(revenueByServiceProvider);
        expect(byService, isNotEmpty);
      });

      test('all service type amounts are positive', () {
        final byService = container.read(revenueByServiceProvider);
        for (final entry in byService.entries) {
          expect(entry.value, greaterThan(0));
        }
      });

      test('sum of service revenue equals total revenue', () {
        final byService = container.read(revenueByServiceProvider);
        final summed = byService.values.fold<double>(0, (s, v) => s + v);
        expect(
          summed,
          closeTo(container.read(totalRevenueProvider), 0.001),
        );
      });
    });

    group('agingReceivablesProvider', () {
      test('returns non-empty list of aging receivables', () {
        final receivables = container.read(agingReceivablesProvider);
        expect(receivables, isNotEmpty);
        expect(receivables.length, greaterThanOrEqualTo(10));
      });
    });

    group('totalReceivablesProvider (analytics)', () {
      test('returns positive total receivables', () {
        final total = container.read(totalReceivablesProvider);
        expect(total, greaterThan(0));
      });

      test('matches sum of all receivable amounts', () {
        final records = container.read(agingReceivablesProvider);
        final expected = records.fold<double>(0, (s, r) => s + r.amount);
        expect(container.read(totalReceivablesProvider), closeTo(expected, 0.001));
      });
    });

    group('receivablesByBucketProvider', () {
      test('returns non-empty map keyed by AgingBucket', () {
        final byBucket = container.read(receivablesByBucketProvider);
        expect(byBucket, isNotEmpty);
      });

      test('sum of bucket amounts equals total receivables', () {
        final byBucket = container.read(receivablesByBucketProvider);
        final summed = byBucket.values.fold<double>(0, (s, v) => s + v);
        expect(
          summed,
          closeTo(container.read(totalReceivablesProvider), 0.001),
        );
      });

      test('all AgingBucket enum values are represented', () {
        final byBucket = container.read(receivablesByBucketProvider);
        for (final bucket in AgingBucket.values) {
          expect(byBucket.containsKey(bucket), isTrue);
        }
      });
    });

    group('growthOpportunitiesProvider', () {
      test('returns non-empty list', () {
        final opps = container.read(growthOpportunitiesProvider);
        expect(opps, isNotEmpty);
      });
    });

    group('topGrowthOpportunitiesProvider', () {
      test('returns at most 4 opportunities', () {
        final top = container.read(topGrowthOpportunitiesProvider);
        expect(top.length, lessThanOrEqualTo(4));
      });

      test('opportunities are sorted by estimated fee descending', () {
        final top = container.read(topGrowthOpportunitiesProvider);
        for (int i = 0; i < top.length - 1; i++) {
          expect(top[i].estimatedFee, greaterThanOrEqualTo(top[i + 1].estimatedFee));
        }
      });
    });

    group('revenueBreakdownProvider', () {
      test('returns 6 monthly breakdown records', () {
        final breakdown = container.read(revenueBreakdownProvider);
        expect(breakdown.length, 6);
      });

      test('all total revenue values are positive', () {
        final breakdown = container.read(revenueBreakdownProvider);
        for (final b in breakdown) {
          expect(b.totalRevenue, greaterThan(0));
        }
      });
    });

    group('clientHealthDistributionProvider', () {
      test('total equals sum of healthy + attention + critical', () {
        final dist = container.read(clientHealthDistributionProvider);
        expect(dist.total, dist.healthy + dist.attention + dist.critical);
      });

      test('percentages are computed correctly', () {
        final dist = container.read(clientHealthDistributionProvider);
        if (dist.total > 0) {
          expect(
            dist.healthyPercent,
            closeTo(dist.healthy / dist.total * 100, 0.001),
          );
        }
      });
    });
  });
}
