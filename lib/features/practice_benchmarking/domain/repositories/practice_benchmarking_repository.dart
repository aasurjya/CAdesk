import 'package:ca_app/features/practice_benchmarking/domain/models/benchmark_metric.dart';
import 'package:ca_app/features/practice_benchmarking/domain/models/growth_score.dart';

/// Abstract contract for practice benchmarking data operations.
///
/// Covers benchmark metrics and growth scores.
abstract class PracticeBenchmarkingRepository {
  // ---------------------------------------------------------------------------
  // BenchmarkMetric
  // ---------------------------------------------------------------------------

  /// Returns all benchmark metrics.
  Future<List<BenchmarkMetric>> getBenchmarkMetrics();

  /// Returns the metric for [id], or null if not found.
  Future<BenchmarkMetric?> getBenchmarkMetricById(String id);

  /// Returns all metrics matching [category].
  Future<List<BenchmarkMetric>> getBenchmarkMetricsByCategory(String category);

  /// Inserts a new [BenchmarkMetric] and returns its ID.
  Future<String> insertBenchmarkMetric(BenchmarkMetric metric);

  /// Updates an existing [BenchmarkMetric]. Returns true on success.
  Future<bool> updateBenchmarkMetric(BenchmarkMetric metric);

  /// Deletes the metric identified by [id]. Returns true on success.
  Future<bool> deleteBenchmarkMetric(String id);

  // ---------------------------------------------------------------------------
  // GrowthScore
  // ---------------------------------------------------------------------------

  /// Returns all growth scores.
  Future<List<GrowthScore>> getGrowthScores();

  /// Returns the growth score for [id], or null if not found.
  Future<GrowthScore?> getGrowthScoreById(String id);

  /// Inserts a new [GrowthScore] and returns its ID.
  Future<String> insertGrowthScore(GrowthScore score);

  /// Updates an existing [GrowthScore]. Returns true on success.
  Future<bool> updateGrowthScore(GrowthScore score);

  /// Deletes the growth score identified by [id]. Returns true on success.
  Future<bool> deleteGrowthScore(String id);
}
