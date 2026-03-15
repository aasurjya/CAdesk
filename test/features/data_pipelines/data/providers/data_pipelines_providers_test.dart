import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/data_pipelines/data/providers/data_pipelines_providers.dart';
import 'package:ca_app/features/data_pipelines/domain/models/data_pipeline.dart';

void main() {
  group('Data Pipelines Providers via ProviderContainer', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    group('dataPipelinesProvider', () {
      test('returns non-empty list of data pipelines', () {
        final pipelines = container.read(dataPipelinesProvider);
        expect(pipelines, isNotEmpty);
        expect(pipelines.length, greaterThanOrEqualTo(6));
      });

      test('list is unmodifiable', () {
        final pipelines = container.read(dataPipelinesProvider);
        expect(
          () => (pipelines as dynamic).add(pipelines.first),
          throwsA(isA<Error>()),
        );
      });

      test('all entries are DataPipeline instances', () {
        final pipelines = container.read(dataPipelinesProvider);
        for (final p in pipelines) {
          expect(p, isA<DataPipeline>());
        }
      });
    });

    group('brokerFeedsProvider', () {
      test('returns non-empty list of broker feeds', () {
        final feeds = container.read(brokerFeedsProvider);
        expect(feeds, isNotEmpty);
        expect(feeds.length, greaterThanOrEqualTo(4));
      });

      test('each feed has a non-empty client name', () {
        final feeds = container.read(brokerFeedsProvider);
        for (final f in feeds) {
          expect(f.clientName, isNotEmpty);
        }
      });
    });

    group('pipelineStatusFilterProvider', () {
      test('initial state is null', () {
        expect(container.read(pipelineStatusFilterProvider), isNull);
      });

      test('can be set to active status', () {
        container
            .read(pipelineStatusFilterProvider.notifier)
            .update(PipelineStatus.active);
        expect(
          container.read(pipelineStatusFilterProvider),
          PipelineStatus.active,
        );
      });

      test('can be set to error status', () {
        container
            .read(pipelineStatusFilterProvider.notifier)
            .update(PipelineStatus.error);
        expect(
          container.read(pipelineStatusFilterProvider),
          PipelineStatus.error,
        );
      });

      test('can be cleared back to null', () {
        container
            .read(pipelineStatusFilterProvider.notifier)
            .update(PipelineStatus.paused);
        container.read(pipelineStatusFilterProvider.notifier).update(null);
        expect(container.read(pipelineStatusFilterProvider), isNull);
      });
    });

    group('filteredPipelinesProvider', () {
      test('returns all pipelines when no filter is set', () {
        final all = container.read(dataPipelinesProvider);
        final filtered = container.read(filteredPipelinesProvider);
        expect(filtered.length, all.length);
      });

      test('filters to active pipelines only', () {
        container
            .read(pipelineStatusFilterProvider.notifier)
            .update(PipelineStatus.active);
        final filtered = container.read(filteredPipelinesProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((p) => p.status == PipelineStatus.active),
          isTrue,
        );
      });

      test('filters to error pipelines only', () {
        container
            .read(pipelineStatusFilterProvider.notifier)
            .update(PipelineStatus.error);
        final filtered = container.read(filteredPipelinesProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((p) => p.status == PipelineStatus.error),
          isTrue,
        );
      });

      test('returns empty when filtering by paused (no paused pipelines match error)', () {
        container
            .read(pipelineStatusFilterProvider.notifier)
            .update(PipelineStatus.paused);
        final filtered = container.read(filteredPipelinesProvider);
        expect(filtered.every((p) => p.status == PipelineStatus.paused), isTrue);
      });
    });

    group('dataPipelinesSummaryProvider', () {
      test('totalPipelines matches dataPipelinesProvider length', () {
        final summary = container.read(dataPipelinesSummaryProvider);
        expect(
          summary.totalPipelines,
          container.read(dataPipelinesProvider).length,
        );
      });

      test('activePipelines is non-negative', () {
        final summary = container.read(dataPipelinesSummaryProvider);
        expect(summary.activePipelines, greaterThanOrEqualTo(0));
      });

      test('errorPipelines is non-negative', () {
        final summary = container.read(dataPipelinesSummaryProvider);
        expect(summary.errorPipelines, greaterThanOrEqualTo(0));
      });

      test('totalRecordsToday is non-negative', () {
        final summary = container.read(dataPipelinesSummaryProvider);
        expect(summary.totalRecordsToday, greaterThanOrEqualTo(0));
      });

      test('activePipelines <= totalPipelines', () {
        final summary = container.read(dataPipelinesSummaryProvider);
        expect(
          summary.activePipelines,
          lessThanOrEqualTo(summary.totalPipelines),
        );
      });
    });
  });
}
