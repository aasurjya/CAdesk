import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/xbrl/data/providers/xbrl_providers.dart';
import 'package:ca_app/features/xbrl/domain/models/xbrl_filing.dart';

void main() {
  group('xbrlFilingsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 6 mock XBRL filings', () {
      final filings = container.read(xbrlFilingsProvider);
      expect(filings.length, 6);
    });

    test('all filings have non-empty ids', () {
      final filings = container.read(xbrlFilingsProvider);
      expect(filings.every((f) => f.id.isNotEmpty), isTrue);
    });
  });

  group('xbrlElementsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns non-empty elements', () {
      final elements = container.read(xbrlElementsProvider);
      expect(elements, isNotEmpty);
    });
  });

  group('XbrlStatusFilterNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(xbrlStatusFilterProvider), isNull);
    });

    test('can be set to filed', () {
      container
          .read(xbrlStatusFilterProvider.notifier)
          .update(XbrlFilingStatus.filed);
      expect(container.read(xbrlStatusFilterProvider), XbrlFilingStatus.filed);
    });

    test('can be reset to null', () {
      container
          .read(xbrlStatusFilterProvider.notifier)
          .update(XbrlFilingStatus.review);
      container.read(xbrlStatusFilterProvider.notifier).update(null);
      expect(container.read(xbrlStatusFilterProvider), isNull);
    });
  });

  group('xbrlFilteredFilingsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns all filings when no filter', () {
      final all = container.read(xbrlFilingsProvider);
      final filtered = container.read(xbrlFilteredFilingsProvider);
      expect(filtered.length, all.length);
    });

    test('filed filter returns only filed filings', () {
      container
          .read(xbrlStatusFilterProvider.notifier)
          .update(XbrlFilingStatus.filed);
      final filtered = container.read(xbrlFilteredFilingsProvider);
      expect(filtered.every((f) => f.status == XbrlFilingStatus.filed), isTrue);
    });
  });

  group('XbrlSelectedFilingNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is xbrl-003 (default)', () {
      expect(container.read(xbrlSelectedFilingIdProvider), 'xbrl-003');
    });

    test('can select a filing id', () {
      container.read(xbrlSelectedFilingIdProvider.notifier).update('xbrl-001');
      expect(container.read(xbrlSelectedFilingIdProvider), 'xbrl-001');
    });

    test('can be cleared', () {
      container.read(xbrlSelectedFilingIdProvider.notifier).update('xbrl-002');
      container.read(xbrlSelectedFilingIdProvider.notifier).update(null);
      expect(container.read(xbrlSelectedFilingIdProvider), isNull);
    });
  });

  group('xbrlElementsForFilingProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns elements for a known filing', () {
      final elements = container.read(
        xbrlElementsForFilingProvider('xbrl-003'),
      );
      expect(elements, isNotEmpty);
    });

    test('returns empty for unknown filing', () {
      final elements = container.read(
        xbrlElementsForFilingProvider('xbrl-999'),
      );
      expect(elements, isEmpty);
    });
  });
}
