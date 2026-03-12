import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/accounts/domain/models/balance_sheet/cash_flow_statement.dart';
import 'package:ca_app/features/accounts/domain/models/balance_sheet/schedule_iii_balance_sheet.dart';
import 'package:ca_app/features/accounts/domain/models/balance_sheet/schedule_iii_equity.dart';
import 'package:ca_app/features/accounts/domain/models/balance_sheet/schedule_iii_assets.dart';
import 'package:ca_app/features/accounts/domain/services/cash_flow_service.dart';

void main() {
  group('CashFlowService', () {
    ScheduleIIIBalanceSheet makeBS({
      int shareCapital = 0,
      int reserves = 0,
      int longTermBorrowings = 0,
      int tradePayables = 0,
      int otherCurrentLiabilities = 0,
      int fixedAssets = 0,
      int investments = 0,
      int inventories = 0,
      int tradeReceivables = 0,
      int cashAndCashEquivalents = 0,
      int otherCurrentAssets = 0,
      int financialYear = 2025,
    }) {
      return ScheduleIIIBalanceSheet(
        financialYear: financialYear,
        equity: ScheduleIIIEquity(
          shareCapital: shareCapital,
          reservesAndSurplus: reserves,
          longTermBorrowings: longTermBorrowings,
          tradePayables: tradePayables,
          otherCurrentLiabilities: otherCurrentLiabilities,
        ),
        assets: ScheduleIIIAssets(
          fixedAssets: fixedAssets,
          investments: investments,
          inventories: inventories,
          tradeReceivables: tradeReceivables,
          cashAndCashEquivalents: cashAndCashEquivalents,
          otherCurrentAssets: otherCurrentAssets,
        ),
        notes: const [],
      );
    }

    group('computeCashFlow', () {
      test(
        'increase in trade payables is a cash inflow in operating activities',
        () {
          final previous = makeBS(
            shareCapital: 1000000,
            cashAndCashEquivalents: 1000000,
          );
          final current = makeBS(
            shareCapital: 1000000,
            tradePayables: 200000,
            cashAndCashEquivalents: 1200000,
          );

          final result = CashFlowService.computeCashFlow(
            current: current,
            previous: previous,
          );

          expect(result.operatingActivitiesTotal, greaterThanOrEqualTo(0));
        },
      );

      test(
        'increase in fixed assets is a cash outflow in investing activities',
        () {
          final previous = makeBS(
            shareCapital: 1000000,
            cashAndCashEquivalents: 1000000,
          );
          final current = makeBS(
            shareCapital: 1000000,
            fixedAssets: 300000,
            cashAndCashEquivalents: 700000,
          );

          final result = CashFlowService.computeCashFlow(
            current: current,
            previous: previous,
          );

          // Increase in fixed assets = investing outflow
          expect(result.investingActivitiesTotal, lessThanOrEqualTo(0));
        },
      );

      test('increase in long-term borrowings is a financing inflow', () {
        final previous = makeBS(
          shareCapital: 1000000,
          cashAndCashEquivalents: 1000000,
        );
        final current = makeBS(
          shareCapital: 1000000,
          longTermBorrowings: 500000,
          cashAndCashEquivalents: 1500000,
        );

        final result = CashFlowService.computeCashFlow(
          current: current,
          previous: previous,
        );

        expect(result.financingActivitiesTotal, greaterThan(0));
      });

      test('net change in cash equals closing minus opening cash', () {
        final previous = makeBS(
          shareCapital: 1000000,
          cashAndCashEquivalents: 500000,
        );
        final current = makeBS(
          shareCapital: 1000000,
          longTermBorrowings: 300000,
          cashAndCashEquivalents: 800000,
        );

        final result = CashFlowService.computeCashFlow(
          current: current,
          previous: previous,
        );

        expect(result.netChangeInCash, equals(300000));
        expect(result.openingCashPaise, equals(500000));
        expect(result.closingCashPaise, equals(800000));
      });

      test('total activities sum equals net change in cash', () {
        final previous = makeBS(
          shareCapital: 2000000,
          cashAndCashEquivalents: 1000000,
          tradeReceivables: 500000,
        );
        final current = makeBS(
          shareCapital: 2000000,
          longTermBorrowings: 500000,
          fixedAssets: 400000,
          cashAndCashEquivalents: 1100000,
          tradeReceivables: 500000,
        );

        final result = CashFlowService.computeCashFlow(
          current: current,
          previous: previous,
        );

        final sumOfActivities =
            result.operatingActivitiesTotal +
            result.investingActivitiesTotal +
            result.financingActivitiesTotal;

        expect(sumOfActivities, equals(result.netChangeInCash));
      });

      test('identical balance sheets produce zero net change in cash', () {
        final bs = makeBS(
          shareCapital: 1000000,
          cashAndCashEquivalents: 1000000,
        );

        final result = CashFlowService.computeCashFlow(
          current: bs,
          previous: bs,
        );

        expect(result.netChangeInCash, equals(0));
      });
    });

    group('CashFlowStatement model', () {
      test('copyWith returns new instance', () {
        const original = CashFlowStatement(
          financialYear: 2025,
          operatingActivitiesTotal: 100000,
          investingActivitiesTotal: -50000,
          financingActivitiesTotal: 200000,
          netChangeInCash: 250000,
          openingCashPaise: 500000,
          closingCashPaise: 750000,
          operatingLineItems: [],
          investingLineItems: [],
          financingLineItems: [],
        );

        final updated = original.copyWith(financialYear: 2026);
        expect(updated.financialYear, equals(2026));
        expect(original.financialYear, equals(2025));
      });

      test('equality and hashCode are value-based', () {
        const a = CashFlowStatement(
          financialYear: 2025,
          operatingActivitiesTotal: 100000,
          investingActivitiesTotal: -50000,
          financingActivitiesTotal: 200000,
          netChangeInCash: 250000,
          openingCashPaise: 500000,
          closingCashPaise: 750000,
          operatingLineItems: [],
          investingLineItems: [],
          financingLineItems: [],
        );
        const b = CashFlowStatement(
          financialYear: 2025,
          operatingActivitiesTotal: 100000,
          investingActivitiesTotal: -50000,
          financingActivitiesTotal: 200000,
          netChangeInCash: 250000,
          openingCashPaise: 500000,
          closingCashPaise: 750000,
          operatingLineItems: [],
          investingLineItems: [],
          financingLineItems: [],
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });
    });
  });
}
