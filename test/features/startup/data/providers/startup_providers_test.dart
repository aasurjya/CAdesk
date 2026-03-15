import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/startup/data/providers/startup_providers.dart';

void main() {
  group('startupListProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 3 mock startups', () {
      final list = container.read(startupListProvider);
      expect(list.length, 3);
    });

    test('all startups have non-empty ids', () {
      final list = container.read(startupListProvider);
      expect(list.every((s) => s.id.isNotEmpty), isTrue);
    });

    test('all startups have non-empty names', () {
      final list = container.read(startupListProvider);
      expect(list.every((s) => s.name.isNotEmpty), isTrue);
    });
  });

  group('selectedStartupIdProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is the first startup id', () {
      final list = container.read(startupListProvider);
      final id = container.read(selectedStartupIdProvider);
      expect(id, list.first.id);
    });

    test('can be changed to second startup', () {
      final list = container.read(startupListProvider);
      container.read(selectedStartupIdProvider.notifier).select(list[1].id);
      expect(container.read(selectedStartupIdProvider), list[1].id);
    });

    test('can be changed to startup-001', () {
      container.read(selectedStartupIdProvider.notifier).select('startup-001');
      expect(container.read(selectedStartupIdProvider), 'startup-001');
    });
  });

  group('selectedStartupProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns startup matching the selected id', () {
      container.read(selectedStartupIdProvider.notifier).select('startup-001');
      final startup = container.read(selectedStartupProvider);
      expect(startup.id, 'startup-001');
    });

    test('falls back to first startup for unknown id', () {
      container.read(selectedStartupIdProvider.notifier).select('unknown-id');
      final startup = container.read(selectedStartupProvider);
      final list = container.read(startupListProvider);
      expect(startup.id, list.first.id);
    });
  });

  group('startup80IACDeductionProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns non-negative deduction amount', () {
      final deduction = container.read(startup80IACDeductionProvider);
      expect(deduction, greaterThanOrEqualTo(0));
    });
  });

  group('startupAngelTaxProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns computation for startup with funding (startup-001)', () {
      container.read(selectedStartupIdProvider.notifier).select('startup-001');
      final computation = container.read(startupAngelTaxProvider);
      expect(computation, isNotNull);
    });

    test('returns null for startup with no funding (startup-002)', () {
      container.read(selectedStartupIdProvider.notifier).select('startup-002');
      final computation = container.read(startupAngelTaxProvider);
      expect(computation, isNull);
    });
  });
}
