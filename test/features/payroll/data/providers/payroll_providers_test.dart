import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/payroll/data/providers/payroll_providers.dart';
import 'package:ca_app/features/payroll/data/providers/payroll_repository_providers.dart';
import 'package:ca_app/features/payroll/data/repositories/mock_payroll_repository.dart';
import 'package:ca_app/features/payroll/domain/models/payroll_month.dart';

ProviderContainer _makeContainer() {
  return ProviderContainer(
    overrides: [
      payrollRepositoryProvider.overrideWithValue(MockPayrollRepository()),
    ],
  );
}

void main() {
  group('employeesProvider', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('loads 12 mock employees', () async {
      final employees = await container.read(employeesProvider.future);
      expect(employees.length, 12);
    });

    test('all employees have non-empty ids', () async {
      final employees = await container.read(employeesProvider.future);
      expect(employees.every((e) => e.id.isNotEmpty), isTrue);
    });

    test('all employees have positive gross salary', () async {
      final employees = await container.read(employeesProvider.future);
      expect(employees.every((e) => e.grossSalary > 0), isTrue);
    });
  });

  group('payrollMonthsProvider', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('returns 24 payroll month records (12 employees × 2 months)', () {
      final months = container.read(payrollMonthsProvider);
      expect(months.length, 24);
    });

    test('all records have non-empty ids', () {
      final months = container.read(payrollMonthsProvider);
      expect(months.every((m) => m.id.isNotEmpty), isTrue);
    });
  });

  group('statutoryReturnsProvider', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('returns 8 statutory returns', () {
      final returns = container.read(statutoryReturnsProvider);
      expect(returns.length, 8);
    });

    test('list is unmodifiable', () {
      final returns = container.read(statutoryReturnsProvider);
      expect(() => (returns as dynamic).add(null), throwsA(isA<Error>()));
    });
  });

  group('PayrollPeriodNotifier', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('initial period is Mar 2026', () {
      final period = container.read(payrollSelectedPeriodProvider);
      expect(period.month, 3);
      expect(period.year, 2026);
    });

    test('can switch to Feb 2026', () {
      container
          .read(payrollSelectedPeriodProvider.notifier)
          .update((month: 2, year: 2026));
      final period = container.read(payrollSelectedPeriodProvider);
      expect(period.month, 2);
      expect(period.year, 2026);
    });
  });

  group('filteredPayrollMonthsProvider', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('returns 12 records for Mar 2026 (default)', () {
      final filtered = container.read(filteredPayrollMonthsProvider);
      expect(filtered.length, 12);
    });

    test('all records in Mar 2026 have month == 3', () {
      final filtered = container.read(filteredPayrollMonthsProvider);
      expect(filtered.every((r) => r.month == 3), isTrue);
    });

    test('switching to Feb 2026 returns 12 disbursed records', () {
      container
          .read(payrollSelectedPeriodProvider.notifier)
          .update((month: 2, year: 2026));
      final filtered = container.read(filteredPayrollMonthsProvider);
      expect(filtered.length, 12);
      expect(
        filtered.every((r) => r.status == PayrollStatus.disbursed),
        isTrue,
      );
    });
  });

  group('payrollSummaryProvider', () {
    late ProviderContainer container;

    setUp(() => container = _makeContainer());
    tearDown(() => container.dispose());

    test('totalGrossPayout is positive', () {
      final summary = container.read(payrollSummaryProvider);
      expect(summary.totalGrossPayout, greaterThan(0));
    });

    test('pendingStatutoryReturns is non-negative', () {
      final summary = container.read(payrollSummaryProvider);
      expect(summary.pendingStatutoryReturns, greaterThanOrEqualTo(0));
    });
  });
}
