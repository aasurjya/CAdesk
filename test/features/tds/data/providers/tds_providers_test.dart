import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/tds/data/providers/tds_providers.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';

void main() {
  group('tdsDeductorsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 6 mock deductors', () {
      final deductors = container.read(tdsDeductorsProvider);
      expect(deductors.length, 6);
    });

    test('all deductors have non-empty ids', () {
      final deductors = container.read(tdsDeductorsProvider);
      expect(deductors.every((d) => d.id.isNotEmpty), isTrue);
    });

    test('all deductors have non-empty TANs', () {
      final deductors = container.read(tdsDeductorsProvider);
      expect(deductors.every((d) => d.tan.isNotEmpty), isTrue);
    });

    test('list is unmodifiable', () {
      final deductors = container.read(tdsDeductorsProvider);
      expect(() => (deductors as dynamic).add(null), throwsA(isA<Error>()));
    });
  });

  group('tdsReturnsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 20 mock TDS returns', () {
      final returns = container.read(tdsReturnsProvider);
      expect(returns.length, 20);
    });

    test('all returns have non-empty ids', () {
      final returns = container.read(tdsReturnsProvider);
      expect(returns.every((r) => r.id.isNotEmpty), isTrue);
    });

    test('list is unmodifiable', () {
      final returns = container.read(tdsReturnsProvider);
      expect(() => (returns as dynamic).add(null), throwsA(isA<Error>()));
    });
  });

  group('SelectedFinancialYearNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is 2025-26', () {
      expect(container.read(selectedFinancialYearProvider), '2025-26');
    });

    test('can be updated to 2024-25', () {
      container.read(selectedFinancialYearProvider.notifier).update('2024-25');
      expect(container.read(selectedFinancialYearProvider), '2024-25');
    });
  });

  group('financialYearsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns 3 financial years', () {
      final years = container.read(financialYearsProvider);
      expect(years.length, 3);
    });

    test('contains 2025-26', () {
      final years = container.read(financialYearsProvider);
      expect(years.contains('2025-26'), isTrue);
    });
  });

  group('SelectedQuarterNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(selectedQuarterProvider), isNull);
    });

    test('can be set to Q1', () {
      container.read(selectedQuarterProvider.notifier).update(TdsQuarter.q1);
      expect(container.read(selectedQuarterProvider), TdsQuarter.q1);
    });

    test('can be reset to null', () {
      container.read(selectedQuarterProvider.notifier).update(TdsQuarter.q2);
      container.read(selectedQuarterProvider.notifier).update(null);
      expect(container.read(selectedQuarterProvider), isNull);
    });
  });

  group('SelectedFormTabNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial tab is 0 (24Q)', () {
      expect(container.read(selectedFormTabProvider), 0);
    });

    test('can switch to tab 1 (26Q)', () {
      container.read(selectedFormTabProvider.notifier).update(1);
      expect(container.read(selectedFormTabProvider), 1);
    });
  });
}
