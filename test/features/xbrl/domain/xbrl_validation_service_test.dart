import 'package:ca_app/features/xbrl/domain/models/xbrl_context.dart';
import 'package:ca_app/features/xbrl/domain/models/xbrl_document.dart';
import 'package:ca_app/features/xbrl/domain/models/xbrl_fact.dart';
import 'package:ca_app/features/xbrl/domain/services/xbrl_document_generator.dart';
import 'package:ca_app/features/xbrl/domain/services/xbrl_tag_mapping_service.dart';
import 'package:ca_app/features/xbrl/domain/services/xbrl_validation_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('XbrlValidationService', () {
    late XbrlDocument validDocument;

    setUp(() {
      final input = XbrlTagMappingInput(
        instanceDocumentId: 'DOC-2024-001',
        companyName: 'Test Company Private Limited',
        cin: 'U01234MH2020PLC123456',
        reportingPeriodStart: DateTime(2023, 4, 1),
        reportingPeriodEnd: DateTime(2024, 3, 31),
        balanceSheet: const ScheduleIIIBalanceSheet(
          cashAndCashEquivalents: 500000000,
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
        ),
        pnl: const PnlStatement(
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
        ),
        cashFlow: const CashFlowStatement(
          operatingActivities: 250000000,
          investingActivities: -500000000,
          financingActivities: 200000000,
          netCashChange: -50000000,
          openingCash: 550000000,
          closingCash: 500000000,
        ),
      );
      validDocument = XbrlDocumentGenerator.instance.generate(input);
    });

    group('validate', () {
      test('returns empty list for fully valid document', () {
        final errors = XbrlValidationService.instance.validate(validDocument);
        expect(errors, isEmpty);
      });

      test('returns error when mandatory element Revenue is missing', () {
        final missingRevenueFacts = validDocument.facts
            .where((f) => f.elementName != 'in-gaap:Revenue')
            .toList();
        final docWithoutRevenue = validDocument.copyWith(
          facts: missingRevenueFacts,
        );

        final errors = XbrlValidationService.instance.validate(
          docWithoutRevenue,
        );

        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.field.contains('Revenue')), isTrue);
      });

      test(
        'returns error when mandatory element CashAndCashEquivalents is missing',
        () {
          final facts = validDocument.facts
              .where((f) => f.elementName != 'in-gaap:CashAndCashEquivalents')
              .toList();
          final docWithoutCash = validDocument.copyWith(facts: facts);

          final errors = XbrlValidationService.instance.validate(
            docWithoutCash,
          );

          expect(
            errors.any((e) => e.field.contains('CashAndCashEquivalents')),
            isTrue,
          );
        },
      );

      test(
        'returns error when mandatory element ProfitBeforeTax is missing',
        () {
          final facts = validDocument.facts
              .where((f) => f.elementName != 'in-gaap:ProfitBeforeTax')
              .toList();
          final doc = validDocument.copyWith(facts: facts);

          final errors = XbrlValidationService.instance.validate(doc);

          expect(
            errors.any((e) => e.field.contains('ProfitBeforeTax')),
            isTrue,
          );
        },
      );

      test('returns error when contexts list is empty', () {
        final docNoContexts = validDocument.copyWith(contexts: const []);

        final errors = XbrlValidationService.instance.validate(docNoContexts);

        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.field.contains('contexts')), isTrue);
      });

      test('returns error when fact references non-existent context', () {
        const orphanFact = XbrlFact(
          elementName: 'in-gaap:Revenue',
          contextRef: 'NON-EXISTENT-CONTEXT',
          unitRef: 'INR',
          value: '1000000.00',
          decimals: 0,
        );
        final facts = [...validDocument.facts, orphanFact];
        final docWithOrphanFact = validDocument.copyWith(facts: facts);

        final errors = XbrlValidationService.instance.validate(
          docWithOrphanFact,
        );

        expect(errors, isNotEmpty);
        expect(
          errors.any((e) => e.message.contains('NON-EXISTENT-CONTEXT')),
          isTrue,
        );
      });

      test('returns error when monetary fact references non-existent unit', () {
        final durationContext = validDocument.contexts.firstWhere(
          (c) => c.periodType == XbrlPeriodType.duration,
        );
        final facts = [
          ...validDocument.facts.where(
            (f) => f.elementName != 'in-gaap:Revenue',
          ),
          XbrlFact(
            elementName: 'in-gaap:Revenue',
            contextRef: durationContext.contextId,
            unitRef: 'USD',
            value: '1000000.00',
            decimals: 0,
          ),
        ];
        final docWithBadUnit = validDocument.copyWith(facts: facts);

        final errors = XbrlValidationService.instance.validate(docWithBadUnit);

        expect(errors.any((e) => e.message.contains('USD')), isTrue);
      });

      test('returns error when units list is empty', () {
        final docNoUnits = validDocument.copyWith(units: const []);

        final errors = XbrlValidationService.instance.validate(docNoUnits);

        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.field.contains('units')), isTrue);
      });

      test('returns error when company name is empty', () {
        final docNoName = validDocument.copyWith(companyName: '');

        final errors = XbrlValidationService.instance.validate(docNoName);

        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.field == 'companyName'), isTrue);
      });

      test('returns error when CIN is empty', () {
        final docNoCin = validDocument.copyWith(cin: '');

        final errors = XbrlValidationService.instance.validate(docNoCin);

        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.field == 'cin'), isTrue);
      });

      test('returns error when schemaRef is empty', () {
        final docNoSchema = validDocument.copyWith(schemaRef: '');

        final errors = XbrlValidationService.instance.validate(docNoSchema);

        expect(errors, isNotEmpty);
        expect(errors.any((e) => e.field == 'schemaRef'), isTrue);
      });
    });

    group('XbrlValidationError model', () {
      test('equality and hashCode', () {
        const a = XbrlValidationError(
          field: 'in-gaap:Revenue',
          message: 'Mandatory element missing',
          severity: XbrlValidationSeverity.error,
        );
        const b = XbrlValidationError(
          field: 'in-gaap:Revenue',
          message: 'Mandatory element missing',
          severity: XbrlValidationSeverity.error,
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('toString includes field and message', () {
        const error = XbrlValidationError(
          field: 'in-gaap:Revenue',
          message: 'Mandatory element missing',
          severity: XbrlValidationSeverity.error,
        );
        expect(error.toString(), contains('in-gaap:Revenue'));
        expect(error.toString(), contains('Mandatory element missing'));
      });

      test('copyWith changes severity', () {
        const original = XbrlValidationError(
          field: 'contexts',
          message: 'No contexts defined',
          severity: XbrlValidationSeverity.error,
        );
        final updated = original.copyWith(
          severity: XbrlValidationSeverity.warning,
        );
        expect(updated.severity, XbrlValidationSeverity.warning);
        expect(updated.field, 'contexts');
      });
    });

    group('singleton pattern', () {
      test('returns the same instance', () {
        final a = XbrlValidationService.instance;
        final b = XbrlValidationService.instance;
        expect(identical(a, b), isTrue);
      });
    });
  });

  group('Full round-trip: generate and validate', () {
    test('generated document passes validation', () {
      final input = XbrlTagMappingInput(
        instanceDocumentId: 'RT-2024-001',
        companyName: 'Round Trip Pvt Ltd',
        cin: 'U56789DL2018PTC098765',
        reportingPeriodStart: DateTime(2023, 4, 1),
        reportingPeriodEnd: DateTime(2024, 3, 31),
        balanceSheet: const ScheduleIIIBalanceSheet(
          cashAndCashEquivalents: 100000000,
          tradeReceivables: 50000000,
          propertyPlantAndEquipment: 200000000,
          totalAssets: 350000000,
          shareCapital: 200000000,
          retainedEarnings: 100000000,
          shortTermBorrowings: 50000000,
          tradePayables: 0,
          totalEquityAndLiabilities: 350000000,
          inventories: 0,
          otherCurrentAssets: 0,
          longTermBorrowings: 0,
          otherCurrentLiabilities: 0,
          otherNonCurrentAssets: 0,
          otherNonCurrentLiabilities: 0,
          otherReserves: 0,
        ),
        pnl: const PnlStatement(
          revenue: 500000000,
          costOfGoodsSold: 300000000,
          grossProfit: 200000000,
          operatingExpenses: 100000000,
          operatingProfit: 100000000,
          otherIncome: 5000000,
          profitBeforeTax: 105000000,
          taxExpense: 31500000,
          profitAfterTax: 73500000,
          basicEarningsPerShare: 735,
          dilutedEarningsPerShare: 700,
          depreciation: 0,
          financeCharges: 0,
        ),
        cashFlow: const CashFlowStatement(
          operatingActivities: 120000000,
          investingActivities: -200000000,
          financingActivities: 80000000,
          netCashChange: 0,
          openingCash: 100000000,
          closingCash: 100000000,
        ),
      );

      final doc = XbrlDocumentGenerator.instance.generate(input);
      final errors = XbrlValidationService.instance.validate(doc);

      expect(errors, isEmpty);
    });
  });
}
