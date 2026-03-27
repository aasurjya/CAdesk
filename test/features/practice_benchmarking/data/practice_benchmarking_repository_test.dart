import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/practice_benchmarking/domain/models/benchmark_metric.dart';
import 'package:ca_app/features/practice_benchmarking/domain/models/growth_score.dart';
import 'package:ca_app/features/practice_benchmarking/data/repositories/mock_practice_benchmarking_repository.dart';

void main() {
  group('MockPracticeBenchmarkingRepository', () {
    late MockPracticeBenchmarkingRepository repo;

    setUp(() {
      repo = MockPracticeBenchmarkingRepository();
    });

    // -------------------------------------------------------------------------
    // BenchmarkMetric
    // -------------------------------------------------------------------------

    group('BenchmarkMetrics', () {
      test('getBenchmarkMetrics returns at least 3 seed items', () async {
        final metrics = await repo.getBenchmarkMetrics();
        expect(metrics.length, greaterThanOrEqualTo(3));
      });

      test('getBenchmarkMetricById returns matching metric', () async {
        final all = await repo.getBenchmarkMetrics();
        final first = all.first;
        final found = await repo.getBenchmarkMetricById(first.id);
        expect(found?.id, first.id);
      });

      test('getBenchmarkMetricById returns null for unknown id', () async {
        final found = await repo.getBenchmarkMetricById('no-such-id');
        expect(found, isNull);
      });

      test('getBenchmarkMetricsByCategory filters correctly', () async {
        final all = await repo.getBenchmarkMetrics();
        final category = all.first.category;
        final filtered = await repo.getBenchmarkMetricsByCategory(category);
        expect(filtered.every((m) => m.category == category), isTrue);
      });

      test('insertBenchmarkMetric adds metric and returns id', () async {
        const metric = BenchmarkMetric(
          id: 'metric-new-001',
          metricName: 'Revenue per Client',
          category: 'Financial',
          yourValue: 50000.0,
          peerMedian: 45000.0,
          topQuartile: 70000.0,
          unit: '₹L',
          trend: 'Up',
          trendPercent: 5.0,
        );
        final id = await repo.insertBenchmarkMetric(metric);
        expect(id, metric.id);

        final all = await repo.getBenchmarkMetrics();
        expect(all.any((m) => m.id == 'metric-new-001'), isTrue);
      });

      test('updateBenchmarkMetric updates existing metric', () async {
        final all = await repo.getBenchmarkMetrics();
        final first = all.first;
        final updated = first.copyWith(yourValue: 999.0);
        final success = await repo.updateBenchmarkMetric(updated);
        expect(success, isTrue);

        final found = await repo.getBenchmarkMetricById(first.id);
        expect(found?.yourValue, 999.0);
      });

      test('updateBenchmarkMetric returns false for non-existent', () async {
        const ghost = BenchmarkMetric(
          id: 'ghost-id',
          metricName: 'Ghost',
          category: 'X',
          yourValue: 0,
          peerMedian: 0,
          topQuartile: 0,
          unit: '%',
          trend: 'Stable',
          trendPercent: 0,
        );
        final success = await repo.updateBenchmarkMetric(ghost);
        expect(success, isFalse);
      });

      test('deleteBenchmarkMetric removes metric', () async {
        final all = await repo.getBenchmarkMetrics();
        final first = all.first;
        final success = await repo.deleteBenchmarkMetric(first.id);
        expect(success, isTrue);

        final found = await repo.getBenchmarkMetricById(first.id);
        expect(found, isNull);
      });

      test('deleteBenchmarkMetric returns false for unknown id', () async {
        final success = await repo.deleteBenchmarkMetric('no-such-id');
        expect(success, isFalse);
      });
    });

    // -------------------------------------------------------------------------
    // GrowthScore
    // -------------------------------------------------------------------------

    group('GrowthScores', () {
      test('getGrowthScores returns at least 3 seed items', () async {
        final scores = await repo.getGrowthScores();
        expect(scores.length, greaterThanOrEqualTo(3));
      });

      test('getGrowthScoreById returns matching score', () async {
        final all = await repo.getGrowthScores();
        final first = all.first;
        final found = await repo.getGrowthScoreById(first.id);
        expect(found?.id, first.id);
      });

      test('getGrowthScoreById returns null for unknown id', () async {
        final found = await repo.getGrowthScoreById('no-such-id');
        expect(found, isNull);
      });

      test('insertGrowthScore adds score', () async {
        const score = GrowthScore(
          id: 'score-new-001',
          dimension: 'Revenue Growth',
          score: 78.5,
          peerAverage: 65.0,
          grade: 'B+',
          insight: 'Above average revenue growth',
          recommendations: ['Expand services', 'Hire more staff'],
        );
        final id = await repo.insertGrowthScore(score);
        expect(id, score.id);
      });

      test('updateGrowthScore updates existing score', () async {
        final all = await repo.getGrowthScores();
        final first = all.first;
        final updated = first.copyWith(score: 90.0);
        final success = await repo.updateGrowthScore(updated);
        expect(success, isTrue);
      });

      test('updateGrowthScore returns false for non-existent', () async {
        const ghost = GrowthScore(
          id: 'ghost-id',
          dimension: 'Ghost',
          score: 0,
          peerAverage: 0,
          grade: 'D',
          insight: '',
          recommendations: [],
        );
        final success = await repo.updateGrowthScore(ghost);
        expect(success, isFalse);
      });

      test('deleteGrowthScore removes score', () async {
        final all = await repo.getGrowthScores();
        final first = all.first;
        final success = await repo.deleteGrowthScore(first.id);
        expect(success, isTrue);
      });

      test('deleteGrowthScore returns false for unknown id', () async {
        final success = await repo.deleteGrowthScore('no-such-id');
        expect(success, isFalse);
      });
    });
  });
}
