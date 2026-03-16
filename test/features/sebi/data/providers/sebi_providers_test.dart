import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/sebi/data/providers/sebi_providers.dart';
import 'package:ca_app/features/sebi/domain/models/sebi_disclosure.dart';
import 'package:ca_app/features/sebi/domain/models/material_event.dart';

void main() {
  group('sebiDisclosuresProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 8 mock SEBI disclosures', () {
      final disclosures = container.read(sebiDisclosuresProvider);
      expect(disclosures.length, 8);
    });

    test('all disclosures have non-empty ids', () {
      final disclosures = container.read(sebiDisclosuresProvider);
      expect(disclosures.every((d) => d.id.isNotEmpty), isTrue);
    });

    test('list is unmodifiable', () {
      final disclosures = container.read(sebiDisclosuresProvider);
      expect(() => (disclosures as dynamic).add(null), throwsA(isA<Error>()));
    });
  });

  group('materialEventsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 5 mock material events', () {
      final events = container.read(materialEventsProvider);
      expect(events.length, 5);
    });

    test('all events have non-empty ids', () {
      final events = container.read(materialEventsProvider);
      expect(events.every((e) => e.id.isNotEmpty), isTrue);
    });
  });

  group('DisclosureStatusFilterNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(disclosureStatusFilterProvider), isNull);
    });

    test('can be set to pending', () {
      container
          .read(disclosureStatusFilterProvider.notifier)
          .update(DisclosureStatus.pending);
      expect(
        container.read(disclosureStatusFilterProvider),
        DisclosureStatus.pending,
      );
    });

    test('can be reset to null', () {
      container
          .read(disclosureStatusFilterProvider.notifier)
          .update(DisclosureStatus.overdue);
      container.read(disclosureStatusFilterProvider.notifier).update(null);
      expect(container.read(disclosureStatusFilterProvider), isNull);
    });
  });

  group('MaterialEventTypeFilterNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(materialEventTypeFilterProvider), isNull);
    });

    test('can be set to acquisition', () {
      container
          .read(materialEventTypeFilterProvider.notifier)
          .update(MaterialEventType.acquisition);
      expect(
        container.read(materialEventTypeFilterProvider),
        MaterialEventType.acquisition,
      );
    });
  });

  group('filteredDisclosuresProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns all when no filter', () {
      final all = container.read(sebiDisclosuresProvider);
      final filtered = container.read(filteredDisclosuresProvider);
      expect(filtered.length, all.length);
    });

    test('filed filter returns only filed disclosures', () {
      container
          .read(disclosureStatusFilterProvider.notifier)
          .update(DisclosureStatus.filed);
      final filtered = container.read(filteredDisclosuresProvider);
      expect(filtered.every((d) => d.status == DisclosureStatus.filed), isTrue);
    });
  });

  group('filteredMaterialEventsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns all when no filter', () {
      final all = container.read(materialEventsProvider);
      final filtered = container.read(filteredMaterialEventsProvider);
      expect(filtered.length, all.length);
    });

    test('acquisition filter returns only acquisition events', () {
      container
          .read(materialEventTypeFilterProvider.notifier)
          .update(MaterialEventType.acquisition);
      final filtered = container.read(filteredMaterialEventsProvider);
      expect(
        filtered.every((e) => e.eventType == MaterialEventType.acquisition),
        isTrue,
      );
    });
  });

  group('sebiSummaryProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('totalDisclosures is 8', () {
      final summary = container.read(sebiSummaryProvider);
      expect(summary.totalDisclosures, 8);
    });

    test('pendingDisclosures is non-negative and <= total', () {
      final summary = container.read(sebiSummaryProvider);
      expect(summary.pendingDisclosures, greaterThanOrEqualTo(0));
      expect(
        summary.pendingDisclosures,
        lessThanOrEqualTo(summary.totalDisclosures),
      );
    });

    test('overdueDisclosures is non-negative', () {
      final summary = container.read(sebiSummaryProvider);
      expect(summary.overdueDisclosures, greaterThanOrEqualTo(0));
    });

    test('undisclosedEvents and urgentEvents are non-negative', () {
      final summary = container.read(sebiSummaryProvider);
      expect(summary.undisclosedEvents, greaterThanOrEqualTo(0));
      expect(summary.urgentEvents, greaterThanOrEqualTo(0));
    });
  });
}
