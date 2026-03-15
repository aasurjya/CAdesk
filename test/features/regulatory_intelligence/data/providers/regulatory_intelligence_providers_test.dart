import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/regulatory_intelligence/data/providers/regulatory_intelligence_providers.dart';

void main() {
  group('allCircularsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 10 mock circulars', () {
      final circulars = container.read(allCircularsProvider);
      expect(circulars.length, 10);
    });

    test('all circulars have non-empty ids', () {
      final circulars = container.read(allCircularsProvider);
      expect(circulars.every((c) => c.id.isNotEmpty), isTrue);
    });

    test('list is unmodifiable', () {
      final circulars = container.read(allCircularsProvider);
      expect(() => (circulars as dynamic).add(null), throwsA(isA<Error>()));
    });
  });

  group('allImpactAlertsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 12 mock client impact alerts', () {
      final alerts = container.read(allImpactAlertsProvider);
      expect(alerts.length, 12);
    });

    test('all alerts have non-empty ids', () {
      final alerts = container.read(allImpactAlertsProvider);
      expect(alerts.every((a) => a.id.isNotEmpty), isTrue);
    });
  });

  group('SelectedCategoryNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(selectedCategoryProvider), isNull);
    });

    test('can be set to Income Tax', () {
      container.read(selectedCategoryProvider.notifier).select('Income Tax');
      expect(container.read(selectedCategoryProvider), 'Income Tax');
    });

    test('can be reset to null', () {
      container.read(selectedCategoryProvider.notifier).select('GST');
      container.read(selectedCategoryProvider.notifier).select(null);
      expect(container.read(selectedCategoryProvider), isNull);
    });
  });

  group('SelectedUrgencyNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(selectedUrgencyProvider), isNull);
    });

    test('can be set to Urgent', () {
      container.read(selectedUrgencyProvider.notifier).select('Urgent');
      expect(container.read(selectedUrgencyProvider), 'Urgent');
    });
  });

  group('filteredCircularsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns all circulars when no filter', () {
      final all = container.read(allCircularsProvider);
      final filtered = container.read(filteredCircularsProvider);
      expect(filtered.length, all.length);
    });

    test('GST filter returns only GST circulars', () {
      container.read(selectedCategoryProvider.notifier).select('GST');
      final filtered = container.read(filteredCircularsProvider);
      expect(filtered.every((c) => c.category == 'GST'), isTrue);
    });

    test('filtered result is subset of all', () {
      container
          .read(selectedCategoryProvider.notifier)
          .select('Income Tax');
      final all = container.read(allCircularsProvider);
      final filtered = container.read(filteredCircularsProvider);
      expect(filtered.length, lessThanOrEqualTo(all.length));
    });
  });

  group('filteredAlertsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns all alerts when no filter', () {
      final all = container.read(allImpactAlertsProvider);
      final filtered = container.read(filteredAlertsProvider);
      expect(filtered.length, all.length);
    });

    test('Urgent filter returns only urgent alerts', () {
      container.read(selectedUrgencyProvider.notifier).select('Urgent');
      final filtered = container.read(filteredAlertsProvider);
      expect(filtered.every((a) => a.urgency == 'Urgent'), isTrue);
    });
  });

  group('alertsForCircularProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns alerts for a known circular id', () {
      final alerts = container.read(alertsForCircularProvider('rc-001'));
      expect(alerts, isNotEmpty);
    });

    test('all returned alerts match the circular id', () {
      final alerts = container.read(alertsForCircularProvider('rc-007'));
      expect(alerts.every((a) => a.circularId == 'rc-007'), isTrue);
    });

    test('returns empty for unknown circular id', () {
      final alerts = container.read(alertsForCircularProvider('rc-999'));
      expect(alerts, isEmpty);
    });
  });
}
