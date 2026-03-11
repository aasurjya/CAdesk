import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/practice_benchmarking/domain/models/benchmark_metric.dart';
import 'package:ca_app/features/practice_benchmarking/domain/models/growth_score.dart';

// ---------------------------------------------------------------------------
// All benchmark metrics — 15 realistic Indian CA firm data points
// ---------------------------------------------------------------------------

final allBenchmarkMetricsProvider = Provider<List<BenchmarkMetric>>((ref) {
  return List.unmodifiable(_mockBenchmarkMetrics);
});

const _mockBenchmarkMetrics = <BenchmarkMetric>[
  BenchmarkMetric(
    id: 'bm-01',
    metricName: 'Revenue per Partner',
    category: 'Financial',
    yourValue: 82,
    peerMedian: 74,
    topQuartile: 115,
    unit: '₹L',
    trend: 'Up',
    trendPercent: 12,
  ),
  BenchmarkMetric(
    id: 'bm-02',
    metricName: 'Client Retention Rate',
    category: 'Client',
    yourValue: 87,
    peerMedian: 82,
    topQuartile: 94,
    unit: '%',
    trend: 'Stable',
    trendPercent: 0,
  ),
  BenchmarkMetric(
    id: 'bm-03',
    metricName: 'Avg Fee per Client',
    category: 'Financial',
    yourValue: 28,
    peerMedian: 22,
    topQuartile: 45,
    unit: '₹K',
    trend: 'Up',
    trendPercent: 8,
  ),
  BenchmarkMetric(
    id: 'bm-04',
    metricName: 'New Client Acquisition (monthly)',
    category: 'Client',
    yourValue: 3.2,
    peerMedian: 4.1,
    topQuartile: 8.5,
    unit: 'clients',
    trend: 'Down',
    trendPercent: 5,
  ),
  BenchmarkMetric(
    id: 'bm-05',
    metricName: 'Revenue from Advisory Services',
    category: 'Financial',
    yourValue: 34,
    peerMedian: 28,
    topQuartile: 52,
    unit: '%',
    trend: 'Up',
    trendPercent: 18,
  ),
  BenchmarkMetric(
    id: 'bm-06',
    metricName: 'Staff Utilization Rate',
    category: 'Team',
    yourValue: 72,
    peerMedian: 68,
    topQuartile: 85,
    unit: '%',
    trend: 'Down',
    trendPercent: 3,
  ),
  BenchmarkMetric(
    id: 'bm-07',
    metricName: 'Technology Spend (% of revenue)',
    category: 'Technology',
    yourValue: 4.2,
    peerMedian: 3.8,
    topQuartile: 7.1,
    unit: '%',
    trend: 'Up',
    trendPercent: 22,
  ),
  BenchmarkMetric(
    id: 'bm-08',
    metricName: 'Avg Days to Invoice',
    category: 'Operational',
    yourValue: 8,
    peerMedian: 12,
    topQuartile: 5,
    unit: 'days',
    trend: 'Stable',
    trendPercent: 0,
  ),
  BenchmarkMetric(
    id: 'bm-09',
    metricName: 'GST Return Auto-prep Rate',
    category: 'Technology',
    yourValue: 68,
    peerMedian: 55,
    topQuartile: 89,
    unit: '%',
    trend: 'Up',
    trendPercent: 15,
  ),
  BenchmarkMetric(
    id: 'bm-10',
    metricName: 'Client-to-Staff Ratio',
    category: 'Team',
    yourValue: 42,
    peerMedian: 38,
    topQuartile: 28,
    unit: 'clients',
    trend: 'Up',
    trendPercent: 5,
  ),
  BenchmarkMetric(
    id: 'bm-11',
    metricName: 'Compliance vs Advisory Split',
    category: 'Financial',
    yourValue: 34,
    peerMedian: 28,
    topQuartile: 52,
    unit: '% adv',
    trend: 'Stable',
    trendPercent: 0,
  ),
  BenchmarkMetric(
    id: 'bm-12',
    metricName: 'Avg Turnaround Time (ITR filing)',
    category: 'Operational',
    yourValue: 3.2,
    peerMedian: 4.8,
    topQuartile: 1.9,
    unit: 'days',
    trend: 'Down',
    trendPercent: 8,
  ),
  BenchmarkMetric(
    id: 'bm-13',
    metricName: 'NPS Score',
    category: 'Client',
    yourValue: 71,
    peerMedian: 65,
    topQuartile: 84,
    unit: '',
    trend: 'Up',
    trendPercent: 4,
  ),
  BenchmarkMetric(
    id: 'bm-14',
    metricName: 'Monthly Recurring Revenue %',
    category: 'Financial',
    yourValue: 58,
    peerMedian: 48,
    topQuartile: 76,
    unit: '%',
    trend: 'Up',
    trendPercent: 22,
  ),
  BenchmarkMetric(
    id: 'bm-15',
    metricName: 'Partner Leverage Ratio',
    category: 'Team',
    yourValue: 6,
    peerMedian: 5,
    topQuartile: 9,
    unit: 'ratio',
    trend: 'Stable',
    trendPercent: 0,
  ),
];

// ---------------------------------------------------------------------------
// All growth scores — 6 dimensions including overall
// ---------------------------------------------------------------------------

final allGrowthScoresProvider = Provider<List<GrowthScore>>((ref) {
  return List.unmodifiable(_mockGrowthScores);
});

const _mockGrowthScores = <GrowthScore>[
  GrowthScore(
    id: 'gs-overall',
    dimension: 'Overall Growth Score',
    score: 68,
    peerAverage: 62,
    grade: 'B',
    insight:
        'Your practice outperforms the peer group in technology and advisory mix, but client acquisition needs focused attention.',
    recommendations: [
      'Set a monthly referral target and track pipeline weekly',
      'Bundle advisory add-ons into compliance renewals',
      'Review staff utilisation weekly to avoid burnout-driven attrition',
    ],
  ),
  GrowthScore(
    id: 'gs-revenue',
    dimension: 'Revenue Growth',
    score: 74,
    peerAverage: 68,
    grade: 'B+',
    insight:
        'Advisory revenue is growing strongly — continue upselling tax planning and CFO retainer services to compliance clients.',
    recommendations: [
      'Target the top 20 compliance clients for advisory upsell conversations',
      'Introduce tiered pricing to increase revenue per engagement',
      'Launch a referral programme for high-value clients',
    ],
  ),
  GrowthScore(
    id: 'gs-client-acquisition',
    dimension: 'Client Acquisition',
    score: 52,
    peerAverage: 61,
    grade: 'C',
    insight:
        'New client monthly intake is below peer average — your lead funnel needs strengthening at the top.',
    recommendations: [
      'Activate LinkedIn content to attract inbound enquiries',
      'Partner with local industry associations for referral visibility',
      'Review and shorten your proposal-to-onboarding cycle',
    ],
  ),
  GrowthScore(
    id: 'gs-service-mix',
    dimension: 'Service Mix',
    score: 68,
    peerAverage: 62,
    grade: 'B',
    insight:
        'Your advisory-to-compliance ratio is improving but still trails the top quartile — there is significant upsell headroom.',
    recommendations: [
      'Map each compliance client to at least one advisory service opportunity',
      'Train staff on cross-selling advisory conversations',
      'Track advisory revenue as a separate KPI in monthly reviews',
    ],
  ),
  GrowthScore(
    id: 'gs-tech-adoption',
    dimension: 'Tech Adoption',
    score: 78,
    peerAverage: 58,
    grade: 'A-',
    insight:
        'Your automation investment is paying off — GST auto-prep rate and invoicing speed are clear differentiators.',
    recommendations: [
      'Extend automation to TDS reconciliation and advance tax calculations',
      'Showcase tech capabilities in client onboarding to justify premium fees',
      'Evaluate AI-assisted audit sampling to reduce turnaround time further',
    ],
  ),
  GrowthScore(
    id: 'gs-team-efficiency',
    dimension: 'Team Efficiency',
    score: 65,
    peerAverage: 63,
    grade: 'B-',
    insight:
        'Staff utilisation has dipped slightly — review workload distribution to avoid bottlenecks during filing peaks.',
    recommendations: [
      'Implement a weekly capacity review across all staff levels',
      'Cross-train junior staff on GST and TDS to reduce dependency on seniors',
      'Use time-tracking data to identify and reassign underutilised capacity',
    ],
  ),
];

// ---------------------------------------------------------------------------
// Selected category filter
// ---------------------------------------------------------------------------

class SelectedBenchmarkCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? category) => state = category;
}

final selectedBenchmarkCategoryProvider =
    NotifierProvider<SelectedBenchmarkCategoryNotifier, String?>(
        SelectedBenchmarkCategoryNotifier.new);

// ---------------------------------------------------------------------------
// Derived: filtered benchmark metrics
// ---------------------------------------------------------------------------

final filteredBenchmarkMetricsProvider = Provider<List<BenchmarkMetric>>((ref) {
  final all = ref.watch(allBenchmarkMetricsProvider);
  final cat = ref.watch(selectedBenchmarkCategoryProvider);
  if (cat == null) {
    return all;
  }
  return all.where((m) => m.category == cat).toList();
});

// ---------------------------------------------------------------------------
// Derived: overall growth score (first entry with id 'gs-overall')
// ---------------------------------------------------------------------------

final overallGrowthScoreProvider = Provider<GrowthScore>((ref) {
  final scores = ref.watch(allGrowthScoresProvider);
  return scores.firstWhere(
    (s) => s.id == 'gs-overall',
    orElse: () => scores.first,
  );
});

/// Growth scores excluding the overall composite entry.
final dimensionGrowthScoresProvider = Provider<List<GrowthScore>>((ref) {
  final scores = ref.watch(allGrowthScoresProvider);
  return scores.where((s) => s.id != 'gs-overall').toList();
});
