import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/features/practice_benchmarking/domain/models/benchmark_metric.dart';
import 'package:ca_app/features/practice_benchmarking/domain/models/growth_score.dart';
import 'package:ca_app/features/practice_benchmarking/domain/repositories/practice_benchmarking_repository.dart';

/// Real implementation of [PracticeBenchmarkingRepository] backed by Supabase.
class PracticeBenchmarkingRepositoryImpl
    implements PracticeBenchmarkingRepository {
  const PracticeBenchmarkingRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const _metricsTable = 'benchmark_metrics';
  static const _scoresTable = 'growth_scores';

  // ---------------------------------------------------------------------------
  // BenchmarkMetric
  // ---------------------------------------------------------------------------

  @override
  Future<List<BenchmarkMetric>> getBenchmarkMetrics() async {
    final response = await _client.from(_metricsTable).select();
    return List<Map<String, dynamic>>.from(
      response,
    ).map(_metricFromJson).toList();
  }

  @override
  Future<BenchmarkMetric?> getBenchmarkMetricById(String id) async {
    final response = await _client
        .from(_metricsTable)
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return _metricFromJson(response);
  }

  @override
  Future<List<BenchmarkMetric>> getBenchmarkMetricsByCategory(
    String category,
  ) async {
    final response = await _client
        .from(_metricsTable)
        .select()
        .eq('category', category);
    return List<Map<String, dynamic>>.from(
      response,
    ).map(_metricFromJson).toList();
  }

  @override
  Future<String> insertBenchmarkMetric(BenchmarkMetric metric) async {
    final response = await _client
        .from(_metricsTable)
        .insert(_metricToJson(metric))
        .select()
        .single();
    return response['id'] as String;
  }

  @override
  Future<bool> updateBenchmarkMetric(BenchmarkMetric metric) async {
    await _client
        .from(_metricsTable)
        .update(_metricToJson(metric))
        .eq('id', metric.id);
    return true;
  }

  @override
  Future<bool> deleteBenchmarkMetric(String id) async {
    await _client.from(_metricsTable).delete().eq('id', id);
    return true;
  }

  // ---------------------------------------------------------------------------
  // GrowthScore
  // ---------------------------------------------------------------------------

  @override
  Future<List<GrowthScore>> getGrowthScores() async {
    final response = await _client.from(_scoresTable).select();
    return List<Map<String, dynamic>>.from(
      response,
    ).map(_scoreFromJson).toList();
  }

  @override
  Future<GrowthScore?> getGrowthScoreById(String id) async {
    final response = await _client
        .from(_scoresTable)
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return _scoreFromJson(response);
  }

  @override
  Future<String> insertGrowthScore(GrowthScore score) async {
    final response = await _client
        .from(_scoresTable)
        .insert(_scoreToJson(score))
        .select()
        .single();
    return response['id'] as String;
  }

  @override
  Future<bool> updateGrowthScore(GrowthScore score) async {
    await _client
        .from(_scoresTable)
        .update(_scoreToJson(score))
        .eq('id', score.id);
    return true;
  }

  @override
  Future<bool> deleteGrowthScore(String id) async {
    await _client.from(_scoresTable).delete().eq('id', id);
    return true;
  }

  // ---------------------------------------------------------------------------
  // Mappers
  // ---------------------------------------------------------------------------

  BenchmarkMetric _metricFromJson(Map<String, dynamic> j) => BenchmarkMetric(
    id: j['id'] as String,
    metricName: j['metric_name'] as String,
    category: j['category'] as String,
    yourValue: (j['your_value'] as num).toDouble(),
    peerMedian: (j['peer_median'] as num).toDouble(),
    topQuartile: (j['top_quartile'] as num).toDouble(),
    unit: j['unit'] as String,
    trend: j['trend'] as String,
    trendPercent: (j['trend_percent'] as num).toDouble(),
  );

  Map<String, dynamic> _metricToJson(BenchmarkMetric m) => {
    'id': m.id,
    'metric_name': m.metricName,
    'category': m.category,
    'your_value': m.yourValue,
    'peer_median': m.peerMedian,
    'top_quartile': m.topQuartile,
    'unit': m.unit,
    'trend': m.trend,
    'trend_percent': m.trendPercent,
  };

  GrowthScore _scoreFromJson(Map<String, dynamic> j) => GrowthScore(
    id: j['id'] as String,
    dimension: j['dimension'] as String,
    score: (j['score'] as num).toDouble(),
    peerAverage: (j['peer_average'] as num).toDouble(),
    grade: j['grade'] as String,
    insight: j['insight'] as String,
    recommendations: List<String>.from(j['recommendations'] as List),
  );

  Map<String, dynamic> _scoreToJson(GrowthScore s) => {
    'id': s.id,
    'dimension': s.dimension,
    'score': s.score,
    'peer_average': s.peerAverage,
    'grade': s.grade,
    'insight': s.insight,
    'recommendations': s.recommendations,
  };
}
