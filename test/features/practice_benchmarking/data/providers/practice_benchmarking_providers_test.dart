import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/practice_benchmarking/data/providers/practice_benchmarking_providers.dart';

void main() {
  group('allBenchmarkMetricsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 15 mock benchmark metrics', () {
      final metrics = container.read(allBenchmarkMetricsProvider);
      expect(metrics.length, 15);
    });

    test('all metrics have non-empty ids', () {
      final metrics = container.read(allBenchmarkMetricsProvider);
      expect(metrics.every((m) => m.id.isNotEmpty), isTrue);
    });

    test('list is unmodifiable', () {
      final metrics = container.read(allBenchmarkMetricsProvider);
      expect(() => (metrics as dynamic).add(null), throwsA(isA<Error>()));
    });

    test('all metrics have non-empty categories', () {
      final metrics = container.read(allBenchmarkMetricsProvider);
      expect(metrics.every((m) => m.category.isNotEmpty), isTrue);
    });
  });

  group('allGrowthScoresProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 6 mock growth scores', () {
      final scores = container.read(allGrowthScoresProvider);
      expect(scores.length, 6);
    });

    test('all scores have non-empty ids', () {
      final scores = container.read(allGrowthScoresProvider);
      expect(scores.every((s) => s.id.isNotEmpty), isTrue);
    });

    test('all scores are between 0 and 100', () {
      final scores = container.read(allGrowthScoresProvider);
      expect(scores.every((s) => s.score >= 0 && s.score <= 100), isTrue);
    });
  });

  group('SelectedBenchmarkCategoryNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(selectedBenchmarkCategoryProvider), isNull);
    });

    test('can be set to Financial', () {
      container
          .read(selectedBenchmarkCategoryProvider.notifier)
          .select('Financial');
      expect(container.read(selectedBenchmarkCategoryProvider), 'Financial');
    });

    test('can be reset to null', () {
      container.read(selectedBenchmarkCategoryProvider.notifier).select('Team');
      container.read(selectedBenchmarkCategoryProvider.notifier).select(null);
      expect(container.read(selectedBenchmarkCategoryProvider), isNull);
    });
  });

  group('filteredBenchmarkMetricsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns all metrics when no filter', () {
      final all = container.read(allBenchmarkMetricsProvider);
      final filtered = container.read(filteredBenchmarkMetricsProvider);
      expect(filtered.length, all.length);
    });

    test('Financial filter returns only Financial metrics', () {
      container
          .read(selectedBenchmarkCategoryProvider.notifier)
          .select('Financial');
      final filtered = container.read(filteredBenchmarkMetricsProvider);
      expect(filtered.every((m) => m.category == 'Financial'), isTrue);
    });

    test('filtered is a subset of all', () {
      container
          .read(selectedBenchmarkCategoryProvider.notifier)
          .select('Technology');
      final all = container.read(allBenchmarkMetricsProvider);
      final filtered = container.read(filteredBenchmarkMetricsProvider);
      expect(filtered.length, lessThanOrEqualTo(all.length));
    });
  });

  group('overallGrowthScoreProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns the overall growth score entry', () {
      final score = container.read(overallGrowthScoreProvider);
      expect(score.id, 'gs-overall');
    });

    test('overall score is between 0 and 100', () {
      final score = container.read(overallGrowthScoreProvider);
      expect(score.score, greaterThanOrEqualTo(0));
      expect(score.score, lessThanOrEqualTo(100));
    });
  });

  group('dimensionGrowthScoresProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 5 dimension scores (all except overall)', () {
      final dimensions = container.read(dimensionGrowthScoresProvider);
      expect(dimensions.length, 5);
    });

    test('does not include the overall composite entry', () {
      final dimensions = container.read(dimensionGrowthScoresProvider);
      expect(dimensions.every((s) => s.id != 'gs-overall'), isTrue);
    });
  });
}
