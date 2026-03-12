import 'package:ca_app/features/xbrl/domain/models/xbrl_context.dart';
import 'package:ca_app/features/xbrl/domain/models/xbrl_fact.dart';
import 'package:ca_app/features/xbrl/domain/models/xbrl_taxonomy_element.dart';
import 'package:ca_app/features/xbrl/domain/services/xbrl_tag_mapping_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('XbrlTagMappingService', () {
    group('mapBalanceSheetToXbrl', () {
      test('maps cash and cash equivalents correctly', () {
        const bs = ScheduleIIIBalanceSheet(
          cashAndCashEquivalents: 500000000, // 5,000,000 INR in paise
          tradeReceivables: 200000000,
          propertyPlantAndEquipment: 1000000000,
          totalAssets: 1700000000,
          shareCapital: 500000000,
          retainedEarnings: 700000000,
          shortTermBorrowings: 300000000,
          tradePayables: 200000000,
          totalEquityAndLiabilities: 1700000000,
          inventories: 0,
          otherCurrentAssets: 0,
          longTermBorrowings: 0,
          otherCurrentLiabilities: 0,
          otherNonCurrentAssets: 0,
          otherNonCurrentLiabilities: 0,
          otherReserves: 0,
        );
        const contextId = 'I-2024';

        final facts = XbrlTagMappingService.instance.mapBalanceSheetToXbrl(
          bs,
          contextId: contextId,
        );

        expect(facts, isNotEmpty);
        final cashFact = facts.firstWhere(
          (f) => f.elementName == 'in-gaap:CashAndCashEquivalents',
        );
        // 500000000 paise = 5000000 INR (divide by 100)
        expect(cashFact.value, '5000000.00');
        expect(cashFact.contextRef, contextId);
        expect(cashFact.unitRef, 'INR');
        expect(cashFact.decimals, 0);
      });

      test('maps trade receivables correctly', () {
        const bs = ScheduleIIIBalanceSheet(
          cashAndCashEquivalents: 0,
          tradeReceivables: 150000000, // 1,500,000 INR
          propertyPlantAndEquipment: 0,
          totalAssets: 150000000,
          shareCapital: 150000000,
          retainedEarnings: 0,
          shortTermBorrowings: 0,
          tradePayables: 0,
          totalEquityAndLiabilities: 150000000,
          inventories: 0,
          otherCurrentAssets: 0,
          longTermBorrowings: 0,
          otherCurrentLiabilities: 0,
          otherNonCurrentAssets: 0,
          otherNonCurrentLiabilities: 0,
          otherReserves: 0,
        );

        final facts = XbrlTagMappingService.instance.mapBalanceSheetToXbrl(
          bs,
          contextId: 'I-2024',
        );

        final receivablesFact = facts.firstWhere(
          (f) => f.elementName == 'in-gaap:TradeReceivables',
        );
        expect(receivablesFact.value, '1500000.00');
      });

      test('maps property plant and equipment correctly', () {
        const bs = ScheduleIIIBalanceSheet(
          cashAndCashEquivalents: 0,
          tradeReceivables: 0,
          propertyPlantAndEquipment: 2500000000, // 25,000,000 INR
          totalAssets: 2500000000,
          shareCapital: 2500000000,
          retainedEarnings: 0,
          shortTermBorrowings: 0,
          tradePayables: 0,
          totalEquityAndLiabilities: 2500000000,
          inventories: 0,
          otherCurrentAssets: 0,
          longTermBorrowings: 0,
          otherCurrentLiabilities: 0,
          otherNonCurrentAssets: 0,
          otherNonCurrentLiabilities: 0,
          otherReserves: 0,
        );

        final facts = XbrlTagMappingService.instance.mapBalanceSheetToXbrl(
          bs,
          contextId: 'I-2024',
        );

        final ppeFact = facts.firstWhere(
          (f) => f.elementName == 'in-gaap:PropertyPlantAndEquipment',
        );
        expect(ppeFact.value, '25000000.00');
      });

      test('all monetary facts use INR unit', () {
        const bs = ScheduleIIIBalanceSheet(
          cashAndCashEquivalents: 100000000,
          tradeReceivables: 100000000,
          propertyPlantAndEquipment: 100000000,
          totalAssets: 300000000,
          shareCapital: 300000000,
          retainedEarnings: 0,
          shortTermBorrowings: 0,
          tradePayables: 0,
          totalEquityAndLiabilities: 300000000,
          inventories: 0,
          otherCurrentAssets: 0,
          longTermBorrowings: 0,
          otherCurrentLiabilities: 0,
          otherNonCurrentAssets: 0,
          otherNonCurrentLiabilities: 0,
          otherReserves: 0,
        );

        final facts = XbrlTagMappingService.instance.mapBalanceSheetToXbrl(
          bs,
          contextId: 'I-2024',
        );

        for (final fact in facts) {
          if (fact.unitRef != null) {
            expect(fact.unitRef, 'INR');
          }
        }
      });
    });

    group('mapPnlToXbrl', () {
      test('maps revenue correctly', () {
        const pnl = PnlStatement(
          revenue: 1000000000, // 10,000,000 INR
          costOfGoodsSold: 600000000,
          grossProfit: 400000000,
          operatingExpenses: 200000000,
          operatingProfit: 200000000,
          otherIncome: 10000000,
          profitBeforeTax: 210000000,
          taxExpense: 63000000,
          profitAfterTax: 147000000,
          basicEarningsPerShare: 1470, // in paise (14.70 INR per share)
          dilutedEarningsPerShare: 1450,
          depreciation: 0,
          financeCharges: 0,
        );

        final facts = XbrlTagMappingService.instance.mapPnlToXbrl(
          pnl,
          contextId: 'D-2024',
        );

        final revenueFact = facts.firstWhere(
          (f) => f.elementName == 'in-gaap:Revenue',
        );
        expect(revenueFact.value, '10000000.00');
        expect(revenueFact.contextRef, 'D-2024');
        expect(revenueFact.unitRef, 'INR');
      });

      test('maps profit before tax correctly', () {
        const pnl = PnlStatement(
          revenue: 1000000000,
          costOfGoodsSold: 600000000,
          grossProfit: 400000000,
          operatingExpenses: 200000000,
          operatingProfit: 200000000,
          otherIncome: 10000000,
          profitBeforeTax: 210000000,
          taxExpense: 63000000,
          profitAfterTax: 147000000,
          basicEarningsPerShare: 1470,
          dilutedEarningsPerShare: 1450,
          depreciation: 0,
          financeCharges: 0,
        );

        final facts = XbrlTagMappingService.instance.mapPnlToXbrl(
          pnl,
          contextId: 'D-2024',
        );

        final pbtFact = facts.firstWhere(
          (f) => f.elementName == 'in-gaap:ProfitBeforeTax',
        );
        expect(pbtFact.value, '2100000.00');
      });

      test('maps EPS as decimal (not monetary) without unit', () {
        const pnl = PnlStatement(
          revenue: 0,
          costOfGoodsSold: 0,
          grossProfit: 0,
          operatingExpenses: 0,
          operatingProfit: 0,
          otherIncome: 0,
          profitBeforeTax: 0,
          taxExpense: 0,
          profitAfterTax: 0,
          basicEarningsPerShare: 1470, // 14.70 INR
          dilutedEarningsPerShare: 1450,
          depreciation: 0,
          financeCharges: 0,
        );

        final facts = XbrlTagMappingService.instance.mapPnlToXbrl(
          pnl,
          contextId: 'D-2024',
        );

        final epsFact = facts.firstWhere(
          (f) => f.elementName == 'in-gaap:BasicEarningsPerShare',
        );
        // EPS has no unitRef (decimal type)
        expect(epsFact.unitRef, isNull);
        expect(epsFact.value, '14.70');
      });
    });

    group('mapCashFlowToXbrl', () {
      test('maps operating cash flow correctly', () {
        const cf = CashFlowStatement(
          operatingActivities: 250000000, // 2,500,000 INR
          investingActivities: -500000000,
          financingActivities: 200000000,
          netCashChange: -50000000,
          openingCash: 300000000,
          closingCash: 250000000,
        );

        final facts = XbrlTagMappingService.instance.mapCashFlowToXbrl(
          cf,
          contextId: 'D-2024',
        );

        final opCashFact = facts.firstWhere(
          (f) => f.elementName == 'in-gaap:CashFlowFromOperatingActivities',
        );
        expect(opCashFact.value, '2500000.00');
        expect(opCashFact.unitRef, 'INR');
      });

      test('maps negative investing activities correctly', () {
        const cf = CashFlowStatement(
          operatingActivities: 0,
          investingActivities: -500000000, // -5,000,000 INR
          financingActivities: 0,
          netCashChange: -500000000,
          openingCash: 500000000,
          closingCash: 0,
        );

        final facts = XbrlTagMappingService.instance.mapCashFlowToXbrl(
          cf,
          contextId: 'D-2024',
        );

        final investFact = facts.firstWhere(
          (f) => f.elementName == 'in-gaap:CashFlowFromInvestingActivities',
        );
        expect(investFact.value, '-5000000.00');
      });
    });

    group('singleton pattern', () {
      test('returns the same instance', () {
        final a = XbrlTagMappingService.instance;
        final b = XbrlTagMappingService.instance;
        expect(identical(a, b), isTrue);
      });
    });
  });

  group('ScheduleIIIBalanceSheet', () {
    test('equality and hashCode', () {
      const a = ScheduleIIIBalanceSheet(
        cashAndCashEquivalents: 100,
        tradeReceivables: 200,
        propertyPlantAndEquipment: 300,
        totalAssets: 600,
        shareCapital: 600,
        retainedEarnings: 0,
        shortTermBorrowings: 0,
        tradePayables: 0,
        totalEquityAndLiabilities: 600,
        inventories: 0,
        otherCurrentAssets: 0,
        longTermBorrowings: 0,
        otherCurrentLiabilities: 0,
        otherNonCurrentAssets: 0,
        otherNonCurrentLiabilities: 0,
        otherReserves: 0,
      );
      const b = ScheduleIIIBalanceSheet(
        cashAndCashEquivalents: 100,
        tradeReceivables: 200,
        propertyPlantAndEquipment: 300,
        totalAssets: 600,
        shareCapital: 600,
        retainedEarnings: 0,
        shortTermBorrowings: 0,
        tradePayables: 0,
        totalEquityAndLiabilities: 600,
        inventories: 0,
        otherCurrentAssets: 0,
        longTermBorrowings: 0,
        otherCurrentLiabilities: 0,
        otherNonCurrentAssets: 0,
        otherNonCurrentLiabilities: 0,
        otherReserves: 0,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith changes specified field', () {
      const original = ScheduleIIIBalanceSheet(
        cashAndCashEquivalents: 100,
        tradeReceivables: 200,
        propertyPlantAndEquipment: 300,
        totalAssets: 600,
        shareCapital: 600,
        retainedEarnings: 0,
        shortTermBorrowings: 0,
        tradePayables: 0,
        totalEquityAndLiabilities: 600,
        inventories: 0,
        otherCurrentAssets: 0,
        longTermBorrowings: 0,
        otherCurrentLiabilities: 0,
        otherNonCurrentAssets: 0,
        otherNonCurrentLiabilities: 0,
        otherReserves: 0,
      );
      final updated = original.copyWith(cashAndCashEquivalents: 999);
      expect(updated.cashAndCashEquivalents, 999);
      expect(updated.tradeReceivables, 200);
    });
  });

  group('PnlStatement', () {
    test('equality and hashCode', () {
      const a = PnlStatement(
        revenue: 1000,
        costOfGoodsSold: 500,
        grossProfit: 500,
        operatingExpenses: 100,
        operatingProfit: 400,
        otherIncome: 50,
        profitBeforeTax: 450,
        taxExpense: 135,
        profitAfterTax: 315,
        basicEarningsPerShare: 315,
        dilutedEarningsPerShare: 300,
        depreciation: 0,
        financeCharges: 0,
      );
      const b = PnlStatement(
        revenue: 1000,
        costOfGoodsSold: 500,
        grossProfit: 500,
        operatingExpenses: 100,
        operatingProfit: 400,
        otherIncome: 50,
        profitBeforeTax: 450,
        taxExpense: 135,
        profitAfterTax: 315,
        basicEarningsPerShare: 315,
        dilutedEarningsPerShare: 300,
        depreciation: 0,
        financeCharges: 0,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('CashFlowStatement', () {
    test('equality and hashCode', () {
      const a = CashFlowStatement(
        operatingActivities: 100,
        investingActivities: -200,
        financingActivities: 50,
        netCashChange: -50,
        openingCash: 300,
        closingCash: 250,
      );
      const b = CashFlowStatement(
        operatingActivities: 100,
        investingActivities: -200,
        financingActivities: 50,
        netCashChange: -50,
        openingCash: 300,
        closingCash: 250,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('XbrlFact model', () {
    test('equality and hashCode', () {
      const a = XbrlFact(
        elementName: 'in-gaap:CashAndCashEquivalents',
        contextRef: 'I-2024',
        unitRef: 'INR',
        value: '5000000.00',
        decimals: 0,
      );
      const b = XbrlFact(
        elementName: 'in-gaap:CashAndCashEquivalents',
        contextRef: 'I-2024',
        unitRef: 'INR',
        value: '5000000.00',
        decimals: 0,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith', () {
      const original = XbrlFact(
        elementName: 'in-gaap:Revenue',
        contextRef: 'D-2024',
        unitRef: 'INR',
        value: '10000000.00',
        decimals: 0,
      );
      final updated = original.copyWith(value: '20000000.00');
      expect(updated.value, '20000000.00');
      expect(updated.elementName, 'in-gaap:Revenue');
    });
  });

  group('XbrlContext model', () {
    test('equality and hashCode for instant context', () {
      const a = XbrlContext(
        contextId: 'I-2024',
        entity: 'U01234MH2020PLC123456',
        scheme: 'http://www.mca.gov.in',
        periodType: XbrlPeriodType.instant,
        periodEnd: '2024-03-31',
      );
      const b = XbrlContext(
        contextId: 'I-2024',
        entity: 'U01234MH2020PLC123456',
        scheme: 'http://www.mca.gov.in',
        periodType: XbrlPeriodType.instant,
        periodEnd: '2024-03-31',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equality for duration context', () {
      const a = XbrlContext(
        contextId: 'D-2024',
        entity: 'U01234MH2020PLC123456',
        scheme: 'http://www.mca.gov.in',
        periodType: XbrlPeriodType.duration,
        periodStart: '2023-04-01',
        periodEnd: '2024-03-31',
      );
      const b = XbrlContext(
        contextId: 'D-2024',
        entity: 'U01234MH2020PLC123456',
        scheme: 'http://www.mca.gov.in',
        periodType: XbrlPeriodType.duration,
        periodStart: '2023-04-01',
        periodEnd: '2024-03-31',
      );
      expect(a, equals(b));
    });

    test('copyWith changes contextId', () {
      const original = XbrlContext(
        contextId: 'I-2024',
        entity: 'U01234MH2020PLC123456',
        scheme: 'http://www.mca.gov.in',
        periodType: XbrlPeriodType.instant,
        periodEnd: '2024-03-31',
      );
      final updated = original.copyWith(contextId: 'I-2025');
      expect(updated.contextId, 'I-2025');
      expect(updated.entity, original.entity);
    });
  });

  group('XbrlTaxonomyElement model', () {
    test('equality and hashCode', () {
      const a = XbrlTaxonomyElement(
        elementName: 'CashAndCashEquivalents',
        namespace: 'in-gaap',
        dataType: XbrlDataType.monetaryItemType,
        periodType: XbrlPeriodType.instant,
        balance: XbrlBalance.debit,
        isAbstract: false,
      );
      const b = XbrlTaxonomyElement(
        elementName: 'CashAndCashEquivalents',
        namespace: 'in-gaap',
        dataType: XbrlDataType.monetaryItemType,
        periodType: XbrlPeriodType.instant,
        balance: XbrlBalance.debit,
        isAbstract: false,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('qualified name returns namespace:elementName', () {
      const element = XbrlTaxonomyElement(
        elementName: 'Revenue',
        namespace: 'in-gaap',
        dataType: XbrlDataType.monetaryItemType,
        periodType: XbrlPeriodType.duration,
        balance: XbrlBalance.credit,
        isAbstract: false,
      );
      expect(element.qualifiedName, 'in-gaap:Revenue');
    });
  });
}
