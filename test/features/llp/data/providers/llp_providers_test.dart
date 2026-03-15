import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/llp/data/providers/llp_providers.dart';

void main() {
  group('LlpListNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state has 3 mock LLPs', () {
      final list = container.read(llpListProvider);
      expect(list.length, 3);
    });

    test('all LLPs have non-empty ids', () {
      final list = container.read(llpListProvider);
      expect(list.every((l) => l.id.isNotEmpty), isTrue);
    });

    test('all LLPs have valid LLPINs', () {
      final list = container.read(llpListProvider);
      expect(list.every((l) => l.llpin.isNotEmpty), isTrue);
    });
  });

  group('SelectedLlpIdNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is first LLP id', () {
      final firstId = container.read(llpListProvider).first.id;
      expect(container.read(selectedLlpIdProvider), firstId);
    });

    test('can select a different LLP', () {
      container.read(selectedLlpIdProvider.notifier).select('llp-002');
      expect(container.read(selectedLlpIdProvider), 'llp-002');
    });

    test('can select llp-003', () {
      container.read(selectedLlpIdProvider.notifier).select('llp-003');
      expect(container.read(selectedLlpIdProvider), 'llp-003');
    });
  });

  group('selectedLlpProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns LLP matching selected id', () {
      container.read(selectedLlpIdProvider.notifier).select('llp-002');
      final llp = container.read(selectedLlpProvider);
      expect(llp.id, 'llp-002');
    });

    test('falls back to first LLP for unknown id', () {
      container.read(selectedLlpIdProvider.notifier).select('nonexistent');
      final llp = container.read(selectedLlpProvider);
      expect(llp.id, container.read(llpListProvider).first.id);
    });
  });

  group('llpForm11PenaltyProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns null when selected LLP form11 is not overdue', () {
      // llp-001 has form11Status filed
      container.read(selectedLlpIdProvider.notifier).select('llp-001');
      final penalty = container.read(llpForm11PenaltyProvider);
      expect(penalty, isNull);
    });

    test('returns penalty for overdue LLP (llp-002)', () {
      container.read(selectedLlpIdProvider.notifier).select('llp-002');
      final penalty = container.read(llpForm11PenaltyProvider);
      expect(penalty, isNotNull);
      expect(penalty!.formType, 'Form-11');
    });
  });

  group('llpForm8PenaltyProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns null when form8 is not overdue (llp-001)', () {
      container.read(selectedLlpIdProvider.notifier).select('llp-001');
      final penalty = container.read(llpForm8PenaltyProvider);
      expect(penalty, isNull);
    });
  });

  group('llpTotalPenaltyProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 0 when no overdue forms for llp-001', () {
      container.read(selectedLlpIdProvider.notifier).select('llp-001');
      final total = container.read(llpTotalPenaltyProvider);
      expect(total, 0);
    });

    test('returns positive penalty for llp-002 overdue LLP', () {
      container.read(selectedLlpIdProvider.notifier).select('llp-002');
      final total = container.read(llpTotalPenaltyProvider);
      expect(total, greaterThan(0));
    });
  });

  group('llpOverdueCountProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns non-negative overdue count', () {
      final count = container.read(llpOverdueCountProvider);
      expect(count, greaterThanOrEqualTo(0));
    });

    test('counts overdue form8 and form11 filings', () {
      // llp-002 has both form8 and form11 as overdue = 2
      final count = container.read(llpOverdueCountProvider);
      expect(count, greaterThanOrEqualTo(2));
    });
  });
}
