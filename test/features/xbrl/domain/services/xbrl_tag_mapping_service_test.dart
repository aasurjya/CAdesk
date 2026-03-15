import 'package:ca_app/features/xbrl/domain/services/xbrl_tag_mapping_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = XbrlTagMappingService.instance;

  ScheduleIIIBalanceSheet makeBalanceSheet({
    int cashAndCashEquivalents = 1000000,
    int tradeReceivables = 2000000,
    int propertyPlantAndEquipment = 5000000,
    int inventories = 1500000,
    int otherCurrentAssets = 500000,
    int otherNonCurrentAssets = 200000,
    int totalAssets = 10200000,
    int shareCapital = 2000000,
    int retainedEarnings = 3000000,
    int otherReserves = 1000000,
    int longTermBorrowings = 2000000,
    int shortTermBorrowings = 1000000,
    int tradePayables = 800000,
    int otherCurrentLiabilities = 200000,
    int otherNonCurrentLiabilities = 200000,
    int totalEquityAndLiabilities = 10200000,
  }) {
    return ScheduleIIIBalanceSheet(
      cashAndCashEquivalents: cashAndCashEquivalents,
      tradeReceivables: tradeReceivables,
      propertyPlantAndEquipment: propertyPlantAndEquipment,
      inventories: inventories,
      otherCurrentAssets: otherCurrentAssets,
      otherNonCurrentAssets: otherNonCurrentAssets,
      totalAssets: totalAssets,
      shareCapital: shareCapital,
      retainedEarnings: retainedEarnings,
      otherReserves: otherReserves,
      longTermBorrowings: longTermBorrowings,
      shortTermBorrowings: shortTermBorrowings,
      tradePayables: tradePayables,
      otherCurrentLiabilities: otherCurrentLiabilities,
      otherNonCurrentLiabilities: otherNonCurrentLiabilities,
      totalEquityAndLiabilities: totalEquityAndLiabilities,
    );
  }

  PnlStatement makePnl() {
    return const PnlStatement(
      revenue: 10000000,
      costOfGoodsSold: 6000000,
      grossProfit: 4000000,
      operatingExpenses: 1500000,
      operatingProfit: 2500000,
      otherIncome: 200000,
      profitBeforeTax: 2700000,
      taxExpense: 810000,
      profitAfterTax: 1890000,
      basicEarningsPerShare: 189,
      dilutedEarningsPerShare: 185,
      depreciation: 400000,
      financeCharges: 200000,
    );
  }

  CashFlowStatement makeCashFlow() {
    return const CashFlowStatement(
      operatingActivities: 3000000,
      investingActivities: -1500000,
      financingActivities: -500000,
      netCashChange: 1000000,
      openingCash: 500000,
      closingCash: 1500000,
    );
  }

  group('XbrlTagMappingService.instance', () {
    test('singleton returns same instance', () {
      expect(
        identical(XbrlTagMappingService.instance, service),
        isTrue,
      );
    });
  });

  group('XbrlTagMappingService.mapBalanceSheetToXbrl', () {
    test('returns list of XBRL facts', () {
      final bs = makeBalanceSheet();
      final facts = service.mapBalanceSheetToXbrl(bs, contextId: 'ctx1');

      expect(facts, isNotEmpty);
    });

    test('cash and cash equivalents is correctly mapped', () {
      final bs = makeBalanceSheet(cashAndCashEquivalents: 1000000);
      final facts = service.mapBalanceSheetToXbrl(bs, contextId: 'ctx1');

      final cashFact = facts.firstWhere(
        (f) => f.elementName == 'in-gaap:CashAndCashEquivalents',
      );

      expect(cashFact.contextRef, 'ctx1');
      expect(cashFact.unitRef, 'INR');
      expect(cashFact.value, '10000.00'); // 1000000 paise = Rs 10000
      expect(cashFact.decimals, 0);
    });

    test('trade receivables is correctly mapped', () {
      final bs = makeBalanceSheet(tradeReceivables: 2000000);
      final facts = service.mapBalanceSheetToXbrl(bs, contextId: 'ctx1');

      final fact = facts.firstWhere(
        (f) => f.elementName == 'in-gaap:TradeReceivables',
      );
      expect(fact.value, '20000.00'); // 2000000 paise = Rs 20000
    });

    test('total assets is correctly mapped', () {
      final bs = makeBalanceSheet(totalAssets: 10200000);
      final facts = service.mapBalanceSheetToXbrl(bs, contextId: 'ctx1');

      final fact = facts.firstWhere(
        (f) => f.elementName == 'in-gaap:Assets',
      );
      expect(fact.value, '102000.00');
    });

    test('share capital is correctly mapped', () {
      final bs = makeBalanceSheet(shareCapital: 2000000);
      final facts = service.mapBalanceSheetToXbrl(bs, contextId: 'ctx1');

      final fact = facts.firstWhere(
        (f) => f.elementName == 'in-gaap:ShareCapital',
      );
      expect(fact.value, '20000.00');
    });

    test('equity and liabilities total is correctly mapped', () {
      final bs = makeBalanceSheet(totalEquityAndLiabilities: 10200000);
      final facts = service.mapBalanceSheetToXbrl(bs, contextId: 'ctx1');

      final fact = facts.firstWhere(
        (f) => f.elementName == 'in-gaap:EquityAndLiabilities',
      );
      expect(fact.value, '102000.00');
    });

    test('all facts use provided contextId', () {
      final bs = makeBalanceSheet();
      final facts = service.mapBalanceSheetToXbrl(bs, contextId: 'instant-2025-03-31');

      for (final fact in facts) {
        expect(fact.contextRef, 'instant-2025-03-31');
      }
    });

    test('monetary facts have INR unit', () {
      final bs = makeBalanceSheet();
      final facts = service.mapBalanceSheetToXbrl(bs, contextId: 'ctx1');

      for (final fact in facts) {
        expect(fact.unitRef, 'INR');
      }
    });

    test('all facts have decimals = 0', () {
      final bs = makeBalanceSheet();
      final facts = service.mapBalanceSheetToXbrl(bs, contextId: 'ctx1');

      for (final fact in facts) {
        expect(fact.decimals, 0);
      }
    });
  });

  group('XbrlTagMappingService.mapPnlToXbrl', () {
    test('returns list of XBRL facts', () {
      final pnl = makePnl();
      final facts = service.mapPnlToXbrl(pnl, contextId: 'dur1');

      expect(facts, isNotEmpty);
    });

    test('revenue is correctly mapped', () {
      final pnl = makePnl();
      final facts = service.mapPnlToXbrl(pnl, contextId: 'dur1');

      final fact = facts.firstWhere(
        (f) => f.elementName == 'in-gaap:Revenue',
      );
      expect(fact.value, '100000.00'); // 10000000 paise = Rs 100000
      expect(fact.unitRef, 'INR');
    });

    test('profit after tax is correctly mapped', () {
      final pnl = makePnl();
      final facts = service.mapPnlToXbrl(pnl, contextId: 'dur1');

      final fact = facts.firstWhere(
        (f) => f.elementName == 'in-gaap:ProfitAfterTax',
      );
      expect(fact.value, '18900.00'); // 1890000 paise = Rs 18900
    });

    test('basic EPS is correctly mapped without unit', () {
      final pnl = makePnl();
      final facts = service.mapPnlToXbrl(pnl, contextId: 'dur1');

      final fact = facts.firstWhere(
        (f) => f.elementName == 'in-gaap:BasicEarningsPerShare',
      );
      expect(fact.value, '1.89'); // 189 paise = Rs 1.89
      expect(fact.unitRef, isNull);
      expect(fact.decimals, 2);
    });

    test('diluted EPS is correctly mapped without unit', () {
      final pnl = makePnl();
      final facts = service.mapPnlToXbrl(pnl, contextId: 'dur1');

      final fact = facts.firstWhere(
        (f) => f.elementName == 'in-gaap:DilutedEarningsPerShare',
      );
      expect(fact.value, '1.85'); // 185 paise = Rs 1.85
      expect(fact.unitRef, isNull);
    });

    test('depreciation is correctly mapped', () {
      final pnl = makePnl();
      final facts = service.mapPnlToXbrl(pnl, contextId: 'dur1');

      final fact = facts.firstWhere(
        (f) => f.elementName == 'in-gaap:Depreciation',
      );
      expect(fact.value, '4000.00'); // 400000 paise = Rs 4000
    });
  });

  group('XbrlTagMappingService.mapCashFlowToXbrl', () {
    test('returns list of XBRL facts', () {
      final cf = makeCashFlow();
      final facts = service.mapCashFlowToXbrl(cf, contextId: 'dur1');

      expect(facts, hasLength(6));
    });

    test('operating activities is correctly mapped', () {
      final cf = makeCashFlow();
      final facts = service.mapCashFlowToXbrl(cf, contextId: 'dur1');

      final fact = facts.firstWhere(
        (f) => f.elementName == 'in-gaap:CashFlowFromOperatingActivities',
      );
      expect(fact.value, '30000.00'); // 3000000 paise = Rs 30000
    });

    test('investing activities handles negative value', () {
      final cf = makeCashFlow();
      final facts = service.mapCashFlowToXbrl(cf, contextId: 'dur1');

      final fact = facts.firstWhere(
        (f) => f.elementName == 'in-gaap:CashFlowFromInvestingActivities',
      );
      expect(fact.value, '-15000.00'); // -1500000 paise = -Rs 15000
    });

    test('opening and closing cash are correctly mapped', () {
      final cf = makeCashFlow();
      final facts = service.mapCashFlowToXbrl(cf, contextId: 'dur1');

      final opening = facts.firstWhere(
        (f) => f.elementName ==
            'in-gaap:CashAndCashEquivalentsAtBeginningOfPeriod',
      );
      final closing = facts.firstWhere(
        (f) =>
            f.elementName == 'in-gaap:CashAndCashEquivalentsAtEndOfPeriod',
      );

      expect(opening.value, '5000.00');  // 500000 paise = Rs 5000
      expect(closing.value, '15000.00'); // 1500000 paise = Rs 15000
    });

    test('all cash flow facts have INR unit', () {
      final cf = makeCashFlow();
      final facts = service.mapCashFlowToXbrl(cf, contextId: 'dur1');

      for (final fact in facts) {
        expect(fact.unitRef, 'INR');
      }
    });
  });

  group('ScheduleIIIBalanceSheet', () {
    test('copyWith creates new instance preserving unchanged fields', () {
      final original = makeBalanceSheet();
      final updated = original.copyWith(cashAndCashEquivalents: 9999999);

      expect(updated.cashAndCashEquivalents, 9999999);
      expect(updated.tradeReceivables, original.tradeReceivables);
    });

    test('equality — same fields are equal', () {
      final a = makeBalanceSheet();
      final b = makeBalanceSheet();
      expect(a, equals(b));
    });

    test('inequality — different cash values', () {
      final a = makeBalanceSheet(cashAndCashEquivalents: 1000000);
      final b = makeBalanceSheet(cashAndCashEquivalents: 2000000);
      expect(a, isNot(equals(b)));
    });
  });

  group('PnlStatement', () {
    test('copyWith creates new instance with updated field', () {
      final original = makePnl();
      final updated = original.copyWith(revenue: 99999999);

      expect(updated.revenue, 99999999);
      expect(updated.costOfGoodsSold, original.costOfGoodsSold);
    });

    test('equality — same fields are equal', () {
      final a = makePnl();
      final b = makePnl();
      expect(a, equals(b));
    });
  });

  group('CashFlowStatement', () {
    test('copyWith creates new instance with updated field', () {
      final original = makeCashFlow();
      final updated = original.copyWith(operatingActivities: 9999999);

      expect(updated.operatingActivities, 9999999);
      expect(updated.investingActivities, original.investingActivities);
    });

    test('equality — same fields are equal', () {
      final a = makeCashFlow();
      final b = makeCashFlow();
      expect(a, equals(b));
    });
  });
}
