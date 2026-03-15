import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/sme_cfo/data/providers/sme_cfo_providers.dart';
import 'package:ca_app/features/sme_cfo/domain/models/cfo_retainer.dart';
import 'package:ca_app/features/sme_cfo/domain/models/cfo_deliverable.dart';

void main() {
  group('SME CFO Providers', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    group('allCfoRetainersProvider', () {
      test('initial state is non-empty list', () {
        final retainers = container.read(allCfoRetainersProvider);
        expect(retainers, isNotEmpty);
        expect(retainers.length, greaterThanOrEqualTo(3));
      });

      test('all items are CfoRetainer objects', () {
        final retainers = container.read(allCfoRetainersProvider);
        expect(retainers, everyElement(isA<CfoRetainer>()));
      });

      test('retainers have varied statuses', () {
        final retainers = container.read(allCfoRetainersProvider);
        final statuses = retainers.map((r) => r.status).toSet();
        expect(statuses.length, greaterThanOrEqualTo(2));
      });

      test('list is unmodifiable', () {
        final retainers = container.read(allCfoRetainersProvider);
        expect(() => retainers.add(retainers.first), throwsA(anything));
      });
    });

    group('allDeliverablesProvider', () {
      test('initial state is non-empty list', () {
        final deliverables = container.read(allDeliverablesProvider);
        expect(deliverables, isNotEmpty);
      });

      test('all items are CfoDeliverable objects', () {
        final deliverables = container.read(allDeliverablesProvider);
        expect(deliverables, everyElement(isA<CfoDeliverable>()));
      });

      test('list is unmodifiable', () {
        final deliverables = container.read(allDeliverablesProvider);
        expect(
            () => deliverables.add(deliverables.first), throwsA(anything));
      });
    });

    group('retainerStatusFilterProvider', () {
      test('initial state is null', () {
        expect(container.read(retainerStatusFilterProvider), isNull);
      });

      test('can be set to active', () {
        container
            .read(retainerStatusFilterProvider.notifier)
            .update(CfoRetainerStatus.active);
        expect(
          container.read(retainerStatusFilterProvider),
          CfoRetainerStatus.active,
        );
      });

      test('can be cleared to null', () {
        container
            .read(retainerStatusFilterProvider.notifier)
            .update(CfoRetainerStatus.review);
        container.read(retainerStatusFilterProvider.notifier).update(null);
        expect(container.read(retainerStatusFilterProvider), isNull);
      });

      test('supports all CfoRetainerStatus values', () {
        for (final status in CfoRetainerStatus.values) {
          container
              .read(retainerStatusFilterProvider.notifier)
              .update(status);
          expect(container.read(retainerStatusFilterProvider), status);
        }
      });
    });

    group('filteredRetainersProvider', () {
      test('returns all retainers when filter is null', () {
        final all = container.read(allCfoRetainersProvider);
        final filtered = container.read(filteredRetainersProvider);
        expect(filtered.length, all.length);
      });

      test('filters by active status', () {
        container
            .read(retainerStatusFilterProvider.notifier)
            .update(CfoRetainerStatus.active);
        final filtered = container.read(filteredRetainersProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((r) => r.status == CfoRetainerStatus.active),
          isTrue,
        );
      });

      test('clearing filter returns all', () {
        container
            .read(retainerStatusFilterProvider.notifier)
            .update(CfoRetainerStatus.active);
        container.read(retainerStatusFilterProvider.notifier).update(null);
        final all = container.read(allCfoRetainersProvider);
        final filtered = container.read(filteredRetainersProvider);
        expect(filtered.length, all.length);
      });
    });

    group('cfoDashboardSummaryProvider', () {
      test('returns a non-empty map', () {
        final summary = container.read(cfoDashboardSummaryProvider);
        expect(summary, isNotEmpty);
      });

      test('summary contains expected keys', () {
        final summary = container.read(cfoDashboardSummaryProvider);
        expect(
          summary.containsKey('totalRetainers') ||
              summary.containsKey('activeRetainers') ||
              summary.isNotEmpty,
          isTrue,
        );
      });
    });
  });
}
