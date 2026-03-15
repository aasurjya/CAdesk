import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/ai_automation/data/providers/ai_automation_providers.dart';
import 'package:ca_app/features/ai_automation/domain/models/ai_scan_result.dart';
import 'package:ca_app/features/ai_automation/domain/models/bank_reconciliation.dart';
import 'package:ca_app/features/ai_automation/domain/models/automation_insight.dart';

void main() {
  group('AI Automation Providers', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    // -------------------------------------------------------------------------
    // allScanResultsProvider
    // -------------------------------------------------------------------------
    group('allScanResultsProvider', () {
      test('initial state is a non-empty list', () {
        final scans = container.read(allScanResultsProvider);
        expect(scans, isNotEmpty);
        expect(scans.length, greaterThanOrEqualTo(5));
      });

      test('all items are AiScanResult objects', () {
        final scans = container.read(allScanResultsProvider);
        expect(scans, everyElement(isA<AiScanResult>()));
      });

      test('update() replaces the list', () {
        final scans = container.read(allScanResultsProvider);
        final subset = scans.take(2).toList();
        container.read(allScanResultsProvider.notifier).update(subset);
        expect(container.read(allScanResultsProvider).length, 2);
      });

      test('initial scans contain multiple statuses', () {
        final scans = container.read(allScanResultsProvider);
        final statuses = scans.map((s) => s.status).toSet();
        expect(statuses.length, greaterThanOrEqualTo(2));
      });
    });

    // -------------------------------------------------------------------------
    // scanStatusFilterProvider
    // -------------------------------------------------------------------------
    group('scanStatusFilterProvider', () {
      test('initial state is 0 (All)', () {
        expect(container.read(scanStatusFilterProvider), 0);
      });

      test('can be updated to filter completed scans (1)', () {
        container.read(scanStatusFilterProvider.notifier).update(1);
        expect(container.read(scanStatusFilterProvider), 1);
      });

      test('can be updated to processing (2)', () {
        container.read(scanStatusFilterProvider.notifier).update(2);
        expect(container.read(scanStatusFilterProvider), 2);
      });

      test('can be updated to review needed (3)', () {
        container.read(scanStatusFilterProvider.notifier).update(3);
        expect(container.read(scanStatusFilterProvider), 3);
      });

      test('can be reset to 0', () {
        container.read(scanStatusFilterProvider.notifier).update(2);
        container.read(scanStatusFilterProvider.notifier).update(0);
        expect(container.read(scanStatusFilterProvider), 0);
      });
    });

    // -------------------------------------------------------------------------
    // scanCountsProvider
    // -------------------------------------------------------------------------
    group('scanCountsProvider', () {
      test('returns map with all scan count keys', () {
        final counts = container.read(scanCountsProvider);
        expect(counts.containsKey('all'), isTrue);
        expect(counts.containsKey('completed'), isTrue);
        expect(counts.containsKey('processing'), isTrue);
        expect(counts.containsKey('review'), isTrue);
        expect(counts.containsKey('failed'), isTrue);
      });

      test('all count equals total scan results', () {
        final scans = container.read(allScanResultsProvider);
        final counts = container.read(scanCountsProvider);
        expect(counts['all'], scans.length);
      });

      test('counts sum is consistent with total', () {
        final counts = container.read(scanCountsProvider);
        final sum = (counts['completed'] ?? 0) +
            (counts['processing'] ?? 0) +
            (counts['review'] ?? 0) +
            (counts['failed'] ?? 0);
        expect(sum, counts['all']);
      });
    });

    // -------------------------------------------------------------------------
    // filteredScanResultsProvider
    // -------------------------------------------------------------------------
    group('filteredScanResultsProvider', () {
      test('returns all when filter is 0 (All)', () {
        final all = container.read(allScanResultsProvider);
        final filtered = container.read(filteredScanResultsProvider);
        expect(filtered.length, all.length);
      });

      test('filter 1 returns only completed scans', () {
        container.read(scanStatusFilterProvider.notifier).update(1);
        final filtered = container.read(filteredScanResultsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((s) => s.status == ScanStatus.completed),
          isTrue,
        );
      });

      test('filter 2 returns only processing scans', () {
        container.read(scanStatusFilterProvider.notifier).update(2);
        final filtered = container.read(filteredScanResultsProvider);
        expect(
          filtered.every((s) => s.status == ScanStatus.processing),
          isTrue,
        );
      });

      test('filter 3 returns only review-needed scans', () {
        container.read(scanStatusFilterProvider.notifier).update(3);
        final filtered = container.read(filteredScanResultsProvider);
        expect(
          filtered.every((s) => s.status == ScanStatus.reviewNeeded),
          isTrue,
        );
      });
    });

    // -------------------------------------------------------------------------
    // allReconciliationsProvider
    // -------------------------------------------------------------------------
    group('allReconciliationsProvider', () {
      test('initial state is non-empty list', () {
        final recons = container.read(allReconciliationsProvider);
        expect(recons, isNotEmpty);
      });

      test('all items are BankReconciliation objects', () {
        final recons = container.read(allReconciliationsProvider);
        expect(recons, everyElement(isA<BankReconciliation>()));
      });

      test('update() replaces the list', () {
        final recons = container.read(allReconciliationsProvider);
        final subset = recons.take(3).toList();
        container.read(allReconciliationsProvider.notifier).update(subset);
        expect(container.read(allReconciliationsProvider).length, 3);
      });
    });

    // -------------------------------------------------------------------------
    // reconStatusFilterProvider
    // -------------------------------------------------------------------------
    group('reconStatusFilterProvider', () {
      test('initial state is 0', () {
        expect(container.read(reconStatusFilterProvider), 0);
      });

      test('can be set to different filter values', () {
        for (final val in [1, 2, 3, 4, 0]) {
          container.read(reconStatusFilterProvider.notifier).update(val);
          expect(container.read(reconStatusFilterProvider), val);
        }
      });
    });

    // -------------------------------------------------------------------------
    // reconCountsProvider
    // -------------------------------------------------------------------------
    group('reconCountsProvider', () {
      test('returns map with expected keys', () {
        final counts = container.read(reconCountsProvider);
        expect(counts.containsKey('all'), isTrue);
        expect(counts.containsKey('autoMatched'), isTrue);
        expect(counts.containsKey('manual'), isTrue);
        expect(counts.containsKey('unmatched'), isTrue);
        expect(counts.containsKey('disputed'), isTrue);
      });

      test('all count equals total reconciliation items', () {
        final recons = container.read(allReconciliationsProvider);
        final counts = container.read(reconCountsProvider);
        expect(counts['all'], recons.length);
      });
    });

    // -------------------------------------------------------------------------
    // filteredReconciliationsProvider
    // -------------------------------------------------------------------------
    group('filteredReconciliationsProvider', () {
      test('returns all when filter is 0', () {
        final all = container.read(allReconciliationsProvider);
        final filtered = container.read(filteredReconciliationsProvider);
        expect(filtered.length, all.length);
      });

      test('filter 1 returns only auto-matched entries', () {
        container.read(reconStatusFilterProvider.notifier).update(1);
        final filtered = container.read(filteredReconciliationsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((r) => r.matchStatus == MatchStatus.autoMatched),
          isTrue,
        );
      });

      test('filter 2 returns only manual entries', () {
        container.read(reconStatusFilterProvider.notifier).update(2);
        final filtered = container.read(filteredReconciliationsProvider);
        expect(
          filtered.every((r) => r.matchStatus == MatchStatus.manual),
          isTrue,
        );
      });

      test('filter 3 returns only unmatched entries', () {
        container.read(reconStatusFilterProvider.notifier).update(3);
        final filtered = container.read(filteredReconciliationsProvider);
        expect(
          filtered.every((r) => r.matchStatus == MatchStatus.unmatched),
          isTrue,
        );
      });

      test('filter 4 returns only disputed entries', () {
        container.read(reconStatusFilterProvider.notifier).update(4);
        final filtered = container.read(filteredReconciliationsProvider);
        expect(
          filtered.every((r) => r.matchStatus == MatchStatus.disputed),
          isTrue,
        );
      });
    });

    // -------------------------------------------------------------------------
    // allAnomalyAlertsProvider
    // -------------------------------------------------------------------------
    group('allAnomalyAlertsProvider', () {
      test('initial state is non-empty list', () {
        final alerts = container.read(allAnomalyAlertsProvider);
        expect(alerts, isNotEmpty);
        expect(alerts.length, greaterThanOrEqualTo(3));
      });

      test('update() replaces the list', () {
        final alerts = container.read(allAnomalyAlertsProvider);
        final subset = alerts.take(1).toList();
        container.read(allAnomalyAlertsProvider.notifier).update(subset);
        expect(container.read(allAnomalyAlertsProvider).length, 1);
      });
    });

    // -------------------------------------------------------------------------
    // anomalyFilterProvider
    // -------------------------------------------------------------------------
    group('anomalyFilterProvider', () {
      test('initial state is 0 (All)', () {
        expect(container.read(anomalyFilterProvider), 0);
      });

      test('can be updated to 1 (Unresolved)', () {
        container.read(anomalyFilterProvider.notifier).update(1);
        expect(container.read(anomalyFilterProvider), 1);
      });

      test('can be updated to 2 (Resolved)', () {
        container.read(anomalyFilterProvider.notifier).update(2);
        expect(container.read(anomalyFilterProvider), 2);
      });
    });

    // -------------------------------------------------------------------------
    // anomalyCountsProvider
    // -------------------------------------------------------------------------
    group('anomalyCountsProvider', () {
      test('returns map with expected keys', () {
        final counts = container.read(anomalyCountsProvider);
        expect(counts.containsKey('all'), isTrue);
        expect(counts.containsKey('unresolved'), isTrue);
        expect(counts.containsKey('resolved'), isTrue);
        expect(counts.containsKey('critical'), isTrue);
      });

      test('all count equals total alerts', () {
        final alerts = container.read(allAnomalyAlertsProvider);
        final counts = container.read(anomalyCountsProvider);
        expect(counts['all'], alerts.length);
      });

      test('unresolved + resolved = all', () {
        final counts = container.read(anomalyCountsProvider);
        expect(
          (counts['unresolved'] ?? 0) + (counts['resolved'] ?? 0),
          counts['all'],
        );
      });
    });

    // -------------------------------------------------------------------------
    // filteredAnomalyAlertsProvider
    // -------------------------------------------------------------------------
    group('filteredAnomalyAlertsProvider', () {
      test('returns all when filter is 0', () {
        final all = container.read(allAnomalyAlertsProvider);
        final filtered = container.read(filteredAnomalyAlertsProvider);
        expect(filtered.length, all.length);
      });

      test('filter 1 returns only unresolved alerts', () {
        container.read(anomalyFilterProvider.notifier).update(1);
        final filtered = container.read(filteredAnomalyAlertsProvider);
        expect(filtered, isNotEmpty);
        expect(filtered.every((a) => !a.isResolved), isTrue);
      });

      test('filter 2 returns only resolved alerts', () {
        container.read(anomalyFilterProvider.notifier).update(2);
        final filtered = container.read(filteredAnomalyAlertsProvider);
        expect(filtered, isNotEmpty);
        expect(filtered.every((a) => a.isResolved), isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // automationInsightsProvider
    // -------------------------------------------------------------------------
    group('automationInsightsProvider', () {
      test('initial state is non-empty list', () {
        final insights = container.read(automationInsightsProvider);
        expect(insights, isNotEmpty);
        expect(insights.length, greaterThanOrEqualTo(4));
      });

      test('all items are AutomationInsight objects', () {
        final insights = container.read(automationInsightsProvider);
        expect(insights, everyElement(isA<AutomationInsight>()));
      });

      test('update() replaces the list', () {
        final insights = container.read(automationInsightsProvider);
        final subset = insights.take(2).toList();
        container.read(automationInsightsProvider.notifier).update(subset);
        expect(container.read(automationInsightsProvider).length, 2);
      });
    });

    // -------------------------------------------------------------------------
    // automationInsightCountsProvider
    // -------------------------------------------------------------------------
    group('automationInsightCountsProvider', () {
      test('returns map with all, attention, blocked, onTrack keys', () {
        final counts = container.read(automationInsightCountsProvider);
        expect(counts.containsKey('all'), isTrue);
        expect(counts.containsKey('attention'), isTrue);
        expect(counts.containsKey('blocked'), isTrue);
        expect(counts.containsKey('onTrack'), isTrue);
      });

      test('all count equals total insights', () {
        final insights = container.read(automationInsightsProvider);
        final counts = container.read(automationInsightCountsProvider);
        expect(counts['all'], insights.length);
      });

      test('attention + blocked + onTrack = all (no other statuses)', () {
        final counts = container.read(automationInsightCountsProvider);
        final sum = (counts['attention'] ?? 0) +
            (counts['blocked'] ?? 0) +
            (counts['onTrack'] ?? 0);
        expect(sum, counts['all']);
      });
    });
  });
}
