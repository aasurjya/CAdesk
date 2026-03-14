import 'package:ca_app/features/practice_benchmarking/domain/models/benchmark_metric.dart';
import 'package:ca_app/features/practice_benchmarking/domain/models/growth_score.dart';
import 'package:ca_app/features/practice_benchmarking/domain/repositories/practice_benchmarking_repository.dart';

/// In-memory mock implementation of [PracticeBenchmarkingRepository].
///
/// Seeded with realistic sample data for development and testing.
class MockPracticeBenchmarkingRepository
    implements PracticeBenchmarkingRepository {
  static const List<BenchmarkMetric> _metricSeed = [
    BenchmarkMetric(
      id: 'metric-001',
      metricName: 'Revenue per Partner',
      category: 'Financial',
      yourValue: 4200000.0,
      peerMedian: 3800000.0,
      topQuartile: 6500000.0,
      unit: '₹L',
      trend: 'Up',
      trendPercent: 8.5,
    ),
    BenchmarkMetric(
      id: 'metric-002',
      metricName: 'Client Retention Rate',
      category: 'Client',
      yourValue: 88.0,
      peerMedian: 82.0,
      topQuartile: 95.0,
      unit: '%',
      trend: 'Stable',
      trendPercent: 0.5,
    ),
    BenchmarkMetric(
      id: 'metric-003',
      metricName: 'Average Days to File',
      category: 'Operational',
      yourValue: 12.0,
      peerMedian: 18.0,
      topQuartile: 7.0,
      unit: 'days',
      trend: 'Down',
      trendPercent: -15.0,
    ),
  ];

  static const List<GrowthScore> _scoreSeed = [
    GrowthScore(
      id: 'score-001',
      dimension: 'Revenue Growth',
      score: 72.0,
      peerAverage: 65.0,
      grade: 'B+',
      insight: 'Above-average revenue growth driven by GST advisory services.',
      recommendations: [
        'Expand direct tax advisory services',
        'Offer virtual CFO packages',
        'Introduce subscription billing',
      ],
    ),
    GrowthScore(
      id: 'score-002',
      dimension: 'Client Acquisition',
      score: 58.0,
      peerAverage: 60.0,
      grade: 'B-',
      insight: 'Client acquisition slightly below peer average.',
      recommendations: [
        'Increase digital marketing presence',
        'Offer referral incentives',
      ],
    ),
    GrowthScore(
      id: 'score-003',
      dimension: 'Tech Adoption',
      score: 85.0,
      peerAverage: 55.0,
      grade: 'A',
      insight: 'Strong technology adoption significantly ahead of peers.',
      recommendations: [
        'Evaluate AI-driven audit tools',
        'Automate routine compliance reminders',
      ],
    ),
  ];

  final List<BenchmarkMetric> _metricState = List.of(_metricSeed);
  final List<GrowthScore> _scoreState = List.of(_scoreSeed);

  // ---------------------------------------------------------------------------
  // BenchmarkMetric
  // ---------------------------------------------------------------------------

  @override
  Future<List<BenchmarkMetric>> getBenchmarkMetrics() async =>
      List.unmodifiable(_metricState);

  @override
  Future<BenchmarkMetric?> getBenchmarkMetricById(String id) async {
    final idx = _metricState.indexWhere((m) => m.id == id);
    return idx == -1 ? null : _metricState[idx];
  }

  @override
  Future<List<BenchmarkMetric>> getBenchmarkMetricsByCategory(
    String category,
  ) async => List.unmodifiable(
    _metricState.where((m) => m.category == category).toList(),
  );

  @override
  Future<String> insertBenchmarkMetric(BenchmarkMetric metric) async {
    _metricState.add(metric);
    return metric.id;
  }

  @override
  Future<bool> updateBenchmarkMetric(BenchmarkMetric metric) async {
    final idx = _metricState.indexWhere((m) => m.id == metric.id);
    if (idx == -1) return false;
    final updated = List<BenchmarkMetric>.of(_metricState)..[idx] = metric;
    _metricState
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteBenchmarkMetric(String id) async {
    final before = _metricState.length;
    _metricState.removeWhere((m) => m.id == id);
    return _metricState.length < before;
  }

  // ---------------------------------------------------------------------------
  // GrowthScore
  // ---------------------------------------------------------------------------

  @override
  Future<List<GrowthScore>> getGrowthScores() async =>
      List.unmodifiable(_scoreState);

  @override
  Future<GrowthScore?> getGrowthScoreById(String id) async {
    final idx = _scoreState.indexWhere((s) => s.id == id);
    return idx == -1 ? null : _scoreState[idx];
  }

  @override
  Future<String> insertGrowthScore(GrowthScore score) async {
    _scoreState.add(score);
    return score.id;
  }

  @override
  Future<bool> updateGrowthScore(GrowthScore score) async {
    final idx = _scoreState.indexWhere((s) => s.id == score.id);
    if (idx == -1) return false;
    final updated = List<GrowthScore>.of(_scoreState)..[idx] = score;
    _scoreState
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteGrowthScore(String id) async {
    final before = _scoreState.length;
    _scoreState.removeWhere((s) => s.id == id);
    return _scoreState.length < before;
  }
}
