import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/assessment/data/providers/assessment_providers.dart';
import 'package:ca_app/features/assessment/domain/models/assessment_order.dart';

void main() {
  group('Assessment Providers via ProviderContainer', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    group('InterestCalculator234', () {
      test('section234A: returns zero when no net tax due', () {
        final result = InterestCalculator234.section234A(
          taxPayable: 100000,
          advanceTaxPaid: 80000,
          tdsCredited: 20000,
          monthsLate: 3,
        );
        expect(result, 0);
      });

      test('section234A: computes 1% per month on net tax due', () {
        final result = InterestCalculator234.section234A(
          taxPayable: 100000,
          advanceTaxPaid: 0,
          tdsCredited: 0,
          monthsLate: 3,
        );
        expect(result, closeTo(3000, 0.001));
      });

      test('section234B: returns zero when advance tax >= 90% threshold', () {
        final result = InterestCalculator234.section234B(
          assessedTax: 100000,
          advanceTaxPaid: 95000,
          tdsCredited: 0,
          months: 4,
        );
        expect(result, 0);
      });

      test('section234B: computes interest on shortfall', () {
        final result = InterestCalculator234.section234B(
          assessedTax: 100000,
          advanceTaxPaid: 0,
          tdsCredited: 0,
          months: 4,
        );
        // shortfall = 100000, 1% * 4 months = 4000
        expect(result, closeTo(4000, 0.001));
      });

      test('section244A: computes 0.5% per month refund interest', () {
        final result = InterestCalculator234.section244A(
          refundAmount: 50000,
          months: 6,
        );
        expect(result, closeTo(1500, 0.001));
      });

      test('computeAll: returns non-negative demand and refund', () {
        final summary = InterestCalculator234.computeAll(
          taxPayable: 200000,
          advanceTaxPaid: 150000,
          tdsCredited: 30000,
          advanceTaxByJun15: 20000,
          advanceTaxBySep15: 60000,
          advanceTaxByDec15: 120000,
          monthsLateFor234A: 2,
          monthsFor234B: 6,
        );
        expect(summary.netDemand, greaterThanOrEqualTo(0));
        expect(summary.refund, greaterThanOrEqualTo(0));
        // demand and refund cannot both be positive
        expect(summary.netDemand * summary.refund, 0);
      });
    });

    group('assessmentOrdersProvider', () {
      test('returns non-empty list of assessment orders', () {
        final orders = container.read(assessmentOrdersProvider);
        expect(orders, isNotEmpty);
        expect(orders.length, greaterThanOrEqualTo(8));
      });

      test('list is unmodifiable', () {
        final orders = container.read(assessmentOrdersProvider);
        expect(
          () => (orders as dynamic).add(orders.first),
          throwsA(isA<Error>()),
        );
      });
    });

    group('interestCalculationsProvider', () {
      test('returns non-empty list of interest calculations', () {
        final calcs = container.read(interestCalculationsProvider);
        expect(calcs, isNotEmpty);
        expect(calcs.length, greaterThanOrEqualTo(10));
      });
    });

    group('assessmentSectionFilterProvider', () {
      test('initial state is null', () {
        expect(container.read(assessmentSectionFilterProvider), isNull);
      });

      test('can be updated to a section', () {
        container
            .read(assessmentSectionFilterProvider.notifier)
            .update(AssessmentSection.section143_1);
        expect(
          container.read(assessmentSectionFilterProvider),
          AssessmentSection.section143_1,
        );
      });

      test('can be cleared back to null', () {
        container
            .read(assessmentSectionFilterProvider.notifier)
            .update(AssessmentSection.section147);
        container
            .read(assessmentSectionFilterProvider.notifier)
            .update(null);
        expect(container.read(assessmentSectionFilterProvider), isNull);
      });
    });

    group('assessmentStatusFilterProvider', () {
      test('initial state is null', () {
        expect(container.read(assessmentStatusFilterProvider), isNull);
      });

      test('can be set to a verification status', () {
        container
            .read(assessmentStatusFilterProvider.notifier)
            .update(VerificationStatus.disputed);
        expect(
          container.read(assessmentStatusFilterProvider),
          VerificationStatus.disputed,
        );
      });
    });

    group('assessmentYearFilterProvider', () {
      test('initial state is null', () {
        expect(container.read(assessmentYearFilterProvider), isNull);
      });

      test('can be set to a year string', () {
        container
            .read(assessmentYearFilterProvider.notifier)
            .update('AY 2022-23');
        expect(container.read(assessmentYearFilterProvider), 'AY 2022-23');
      });
    });

    group('filteredOrdersProvider', () {
      test('returns all orders when no filters are set', () {
        final all = container.read(assessmentOrdersProvider);
        final filtered = container.read(filteredOrdersProvider);
        expect(filtered.length, all.length);
      });

      test('filters by section', () {
        container
            .read(assessmentSectionFilterProvider.notifier)
            .update(AssessmentSection.section143_1);
        final filtered = container.read(filteredOrdersProvider);
        expect(
          filtered.every((o) => o.section == AssessmentSection.section143_1),
          isTrue,
        );
      });

      test('filters by verification status', () {
        container
            .read(assessmentStatusFilterProvider.notifier)
            .update(VerificationStatus.disputed);
        final filtered = container.read(filteredOrdersProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every(
            (o) => o.verificationStatus == VerificationStatus.disputed,
          ),
          isTrue,
        );
      });

      test('filters by assessment year', () {
        container
            .read(assessmentYearFilterProvider.notifier)
            .update('AY 2022-23');
        final filtered = container.read(filteredOrdersProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((o) => o.assessmentYear == 'AY 2022-23'),
          isTrue,
        );
      });
    });

    group('assessmentSummaryProvider', () {
      test('ordersWithErrors matches orders where hasErrors is true', () {
        final summary = container.read(assessmentSummaryProvider);
        final expected = container
            .read(assessmentOrdersProvider)
            .where((o) => o.hasErrors)
            .length;
        expect(summary.ordersWithErrors, expected);
      });

      test('totalDemand is non-negative', () {
        final summary = container.read(assessmentSummaryProvider);
        expect(summary.totalDemand, greaterThanOrEqualTo(0));
      });

      test('summary fields are all non-negative', () {
        final summary = container.read(assessmentSummaryProvider);
        expect(summary.ordersWithErrors, greaterThanOrEqualTo(0));
        expect(summary.pendingVerification, greaterThanOrEqualTo(0));
        expect(summary.interestErrors, greaterThanOrEqualTo(0));
      });
    });
  });
}
