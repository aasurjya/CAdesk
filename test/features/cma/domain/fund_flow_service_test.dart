import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/cma/domain/models/cma_balance_sheet.dart';
import 'package:ca_app/features/cma/domain/models/fund_flow_statement.dart';
import 'package:ca_app/features/cma/domain/services/fund_flow_service.dart';

void main() {
  group('FundFlowService — computeFundFlow', () {
    test('increase in long-term liabilities is a source', () {
      // Long-term liabilities go from 1,000 to 1,500 → Source of 500
      final prev = CmaBalanceSheet.empty().copyWith(
        longTermBorrowings: 100000,
        profitAfterTax: 0,
        depreciation: 0,
      );
      final curr = CmaBalanceSheet.empty().copyWith(
        longTermBorrowings: 150000,
        profitAfterTax: 0,
        depreciation: 0,
      );
      final result = FundFlowService.instance.computeFundFlow(curr, prev);
      final source = result.sourcesOfFunds.firstWhere(
        (f) => f.label == FundFlowLabel.increaseInLongTermLiabilities,
        orElse: () => const FundFlowItem(
          label: FundFlowLabel.increaseInLongTermLiabilities,
          amountPaise: 0,
        ),
      );
      expect(source.amountPaise, 50000);
    });

    test('decrease in long-term liabilities is a use', () {
      final prev = CmaBalanceSheet.empty().copyWith(
        longTermBorrowings: 150000,
        profitAfterTax: 0,
        depreciation: 0,
      );
      final curr = CmaBalanceSheet.empty().copyWith(
        longTermBorrowings: 100000,
        profitAfterTax: 0,
        depreciation: 0,
      );
      final result = FundFlowService.instance.computeFundFlow(curr, prev);
      final use = result.usesOfFunds.firstWhere(
        (f) => f.label == FundFlowLabel.decreaseInLongTermLiabilities,
        orElse: () => const FundFlowItem(
          label: FundFlowLabel.decreaseInLongTermLiabilities,
          amountPaise: 0,
        ),
      );
      expect(use.amountPaise, 50000);
    });

    test('profit after tax + depreciation is a source', () {
      final prev = CmaBalanceSheet.empty();
      final curr = CmaBalanceSheet.empty().copyWith(
        profitAfterTax: 200000,
        depreciation: 50000,
      );
      final result = FundFlowService.instance.computeFundFlow(curr, prev);
      final source = result.sourcesOfFunds.firstWhere(
        (f) => f.label == FundFlowLabel.profitAfterTaxPlusDepreciation,
      );
      expect(source.amountPaise, 250000);
    });

    test('increase in long-term assets is a use', () {
      // Fixed assets increase from 500 to 800 → Use of 300
      final prev = CmaBalanceSheet.empty().copyWith(
        netFixedAssets: 50000,
      );
      final curr = CmaBalanceSheet.empty().copyWith(
        netFixedAssets: 80000,
      );
      final result = FundFlowService.instance.computeFundFlow(curr, prev);
      final use = result.usesOfFunds.firstWhere(
        (f) => f.label == FundFlowLabel.increaseInLongTermAssets,
        orElse: () => const FundFlowItem(
          label: FundFlowLabel.increaseInLongTermAssets,
          amountPaise: 0,
        ),
      );
      expect(use.amountPaise, 30000);
    });

    test('decrease in long-term assets is a source', () {
      final prev = CmaBalanceSheet.empty().copyWith(netFixedAssets: 80000);
      final curr = CmaBalanceSheet.empty().copyWith(netFixedAssets: 50000);
      final result = FundFlowService.instance.computeFundFlow(curr, prev);
      final source = result.sourcesOfFunds.firstWhere(
        (f) => f.label == FundFlowLabel.decreaseInLongTermAssets,
        orElse: () => const FundFlowItem(
          label: FundFlowLabel.decreaseInLongTermAssets,
          amountPaise: 0,
        ),
      );
      expect(source.amountPaise, 30000);
    });

    test('dividend paid is a use', () {
      final prev = CmaBalanceSheet.empty();
      final curr = CmaBalanceSheet.empty().copyWith(dividendPaid: 100000);
      final result = FundFlowService.instance.computeFundFlow(curr, prev);
      final use = result.usesOfFunds.firstWhere(
        (f) => f.label == FundFlowLabel.dividendPaid,
        orElse: () => const FundFlowItem(
          label: FundFlowLabel.dividendPaid,
          amountPaise: 0,
        ),
      );
      expect(use.amountPaise, 100000);
    });

    test('netChange equals totalSources - totalUses', () {
      final prev = CmaBalanceSheet.empty().copyWith(
        longTermBorrowings: 100000,
        netFixedAssets: 200000,
      );
      final curr = CmaBalanceSheet.empty().copyWith(
        longTermBorrowings: 150000,
        netFixedAssets: 250000,
        profitAfterTax: 80000,
        depreciation: 20000,
      );
      final result = FundFlowService.instance.computeFundFlow(curr, prev);
      final totalSources = result.sourcesOfFunds.fold<int>(
        0,
        (sum, item) => sum + item.amountPaise,
      );
      final totalUses = result.usesOfFunds.fold<int>(
        0,
        (sum, item) => sum + item.amountPaise,
      );
      expect(result.netChange, totalSources - totalUses);
    });

    test('opening working capital flows into closing working capital', () {
      // WC = CA - CL excl bank
      final prev = CmaBalanceSheet.empty().copyWith(
        totalCurrentAssets: 300000,
        currentLiabilitiesExclBank: 100000,
      );
      final curr = CmaBalanceSheet.empty().copyWith(
        totalCurrentAssets: 400000,
        currentLiabilitiesExclBank: 120000,
      );
      final result = FundFlowService.instance.computeFundFlow(curr, prev);
      expect(result.openingWorkingCapital, 200000); // 300k - 100k
      expect(result.closingWorkingCapital, 280000); // 400k - 120k
    });

    test('result has year from current balance sheet', () {
      final prev = CmaBalanceSheet.empty();
      final curr = CmaBalanceSheet.empty().copyWith(year: 2024);
      final result = FundFlowService.instance.computeFundFlow(curr, prev);
      expect(result.year, 2024);
    });
  });

  group('FundFlowService — singleton', () {
    test('instance returns same object each time', () {
      expect(
        identical(FundFlowService.instance, FundFlowService.instance),
        isTrue,
      );
    });
  });

  group('FundFlowStatement — model', () {
    test('copyWith returns updated instance', () {
      final original = FundFlowStatement(
        year: 2023,
        sourcesOfFunds: const [],
        usesOfFunds: const [],
        netChange: 0,
        openingWorkingCapital: 0,
        closingWorkingCapital: 0,
      );
      final updated = original.copyWith(year: 2024);
      expect(updated.year, 2024);
      expect(original.year, 2023);
    });

    test('equality and hashCode', () {
      final a = FundFlowStatement(
        year: 2023,
        sourcesOfFunds: const [],
        usesOfFunds: const [],
        netChange: 500,
        openingWorkingCapital: 1000,
        closingWorkingCapital: 1500,
      );
      final b = FundFlowStatement(
        year: 2023,
        sourcesOfFunds: const [],
        usesOfFunds: const [],
        netChange: 500,
        openingWorkingCapital: 1000,
        closingWorkingCapital: 1500,
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  group('FundFlowItem — model', () {
    test('copyWith changes amount', () {
      const item = FundFlowItem(
        label: FundFlowLabel.dividendPaid,
        amountPaise: 10000,
      );
      final updated = item.copyWith(amountPaise: 20000);
      expect(updated.amountPaise, 20000);
      expect(item.amountPaise, 10000);
    });

    test('equality', () {
      const a = FundFlowItem(
        label: FundFlowLabel.profitAfterTaxPlusDepreciation,
        amountPaise: 5000,
      );
      const b = FundFlowItem(
        label: FundFlowLabel.profitAfterTaxPlusDepreciation,
        amountPaise: 5000,
      );
      expect(a, equals(b));
    });
  });
}
