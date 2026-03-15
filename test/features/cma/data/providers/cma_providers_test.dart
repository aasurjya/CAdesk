import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/cma/data/providers/cma_providers.dart';
import 'package:ca_app/features/cma/domain/models/cma_report.dart';

void main() {
  group('CMA Providers via ProviderContainer', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    group('CmaCalculator', () {
      test('emi: zero tenure returns zero', () {
        expect(CmaCalculator.emi(principal: 100000, annualRatePercent: 10, tenureMonths: 0), 0);
      });

      test('emi: zero rate returns principal / tenure', () {
        expect(
          CmaCalculator.emi(principal: 120000, annualRatePercent: 0, tenureMonths: 12),
          closeTo(10000, 0.001),
        );
      });

      test('emi: standard 10% p.a. on 120000 for 12 months is reasonable', () {
        final e = CmaCalculator.emi(
          principal: 120000,
          annualRatePercent: 10,
          tenureMonths: 12,
        );
        expect(e, greaterThan(10000));
        expect(e, lessThan(12000));
      });

      test('totalInterest: returns positive value for non-zero rate', () {
        final interest = CmaCalculator.totalInterest(
          principal: 1000000,
          annualRatePercent: 9,
          tenureMonths: 60,
        );
        expect(interest, greaterThan(0));
      });

      test('mpbf: negative working capital gap returns zero', () {
        final result = CmaCalculator.mpbf(
          currentAssets: 100000,
          currentLiabilities: 200000,
          existingBankBorrowings: 0,
        );
        expect(result, 0);
      });

      test('mpbf: computes 75% of working capital gap', () {
        final result = CmaCalculator.mpbf(
          currentAssets: 400000,
          currentLiabilities: 200000,
          existingBankBorrowings: 0,
        );
        // WCG = 400000 - 200000 = 200000; MPBF = 75% = 150000
        expect(result, closeTo(150000, 0.001));
      });

      test('dscrStatus: >= 1.5 returns Excellent', () {
        expect(CmaCalculator.dscrStatus(1.5), 'Excellent');
      });

      test('dscrStatus: between 1.25 and 1.5 returns Acceptable', () {
        expect(CmaCalculator.dscrStatus(1.3), 'Acceptable');
      });

      test('dscrStatus: < 1.0 returns Poor', () {
        expect(CmaCalculator.dscrStatus(0.8), 'Poor');
      });

      test('npv: positive returns for profitable project are positive', () {
        // 40000 + 50000 + 60000 discounted at 10% > 120000 investment
        final n = CmaCalculator.npv(
          initialInvestment: 120000,
          annualCashFlows: [40000, 50000, 60000],
          discountRatePercent: 10,
        );
        expect(n, greaterThan(0));
      });

      test('amortizationSchedule: length equals tenureMonths', () {
        final schedule = CmaCalculator.amortizationSchedule(
          principal: 500000,
          annualRatePercent: 9,
          tenureMonths: 12,
        );
        expect(schedule.length, 12);
      });
    });

    group('cmaReportsProvider', () {
      test('returns non-empty list of CMA reports', () {
        final reports = container.read(cmaReportsProvider);
        expect(reports, isNotEmpty);
        expect(reports.length, greaterThanOrEqualTo(6));
      });

      test('list is unmodifiable', () {
        final reports = container.read(cmaReportsProvider);
        expect(
          () => (reports as dynamic).add(reports.first),
          throwsA(isA<Error>()),
        );
      });
    });

    group('loanCalculatorsProvider', () {
      test('returns non-empty list of loan calculators', () {
        final loans = container.read(loanCalculatorsProvider);
        expect(loans, isNotEmpty);
        expect(loans.length, greaterThanOrEqualTo(4));
      });

      test('all loans have positive EMI values', () {
        final loans = container.read(loanCalculatorsProvider);
        for (final loan in loans) {
          expect(loan.emi, greaterThan(0));
        }
      });
    });

    group('cmaStatusFilterProvider', () {
      test('initial state is null', () {
        expect(container.read(cmaStatusFilterProvider), isNull);
      });

      test('can be set to a status', () {
        container
            .read(cmaStatusFilterProvider.notifier)
            .update(CmaReportStatus.approved);
        expect(
          container.read(cmaStatusFilterProvider),
          CmaReportStatus.approved,
        );
      });

      test('can be cleared back to null', () {
        container
            .read(cmaStatusFilterProvider.notifier)
            .update(CmaReportStatus.rejected);
        container.read(cmaStatusFilterProvider.notifier).update(null);
        expect(container.read(cmaStatusFilterProvider), isNull);
      });
    });

    group('cmaFilteredReportsProvider', () {
      test('returns all reports when no filter is set', () {
        final all = container.read(cmaReportsProvider);
        final filtered = container.read(cmaFilteredReportsProvider);
        expect(filtered.length, all.length);
      });

      test('filters to approved reports only', () {
        container
            .read(cmaStatusFilterProvider.notifier)
            .update(CmaReportStatus.approved);
        final filtered = container.read(cmaFilteredReportsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((r) => r.status == CmaReportStatus.approved),
          isTrue,
        );
      });

      test('filters to submitted reports only', () {
        container
            .read(cmaStatusFilterProvider.notifier)
            .update(CmaReportStatus.submitted);
        final filtered = container.read(cmaFilteredReportsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((r) => r.status == CmaReportStatus.submitted),
          isTrue,
        );
      });
    });

    group('cmaSummaryProvider', () {
      test('totalReports matches number of reports', () {
        final summary = container.read(cmaSummaryProvider);
        expect(
          summary.totalReports,
          container.read(cmaReportsProvider).length,
        );
      });

      test('pendingReports matches submitted count', () {
        final summary = container.read(cmaSummaryProvider);
        final expected = container
            .read(cmaReportsProvider)
            .where((r) => r.status == CmaReportStatus.submitted)
            .length;
        expect(summary.pendingReports, expected);
      });

      test('totalMonthlyEmi is positive', () {
        final summary = container.read(cmaSummaryProvider);
        expect(summary.totalMonthlyEmi, greaterThan(0));
      });

      test('totalSanctioned is non-negative', () {
        final summary = container.read(cmaSummaryProvider);
        expect(summary.totalSanctioned, greaterThanOrEqualTo(0));
      });
    });
  });
}
