import 'package:ca_app/features/xbrl/domain/models/xbrl_context.dart';
import 'package:ca_app/features/xbrl/domain/models/xbrl_document.dart';
import 'package:ca_app/features/xbrl/domain/models/xbrl_fact.dart';
import 'package:ca_app/features/xbrl/domain/models/xbrl_taxonomy.dart';
import 'package:ca_app/features/xbrl/domain/models/xbrl_taxonomy_element.dart';
import 'package:ca_app/features/xbrl/domain/models/xbrl_unit.dart';
import 'package:ca_app/features/xbrl/domain/services/xbrl_document_generator.dart';
import 'package:ca_app/features/xbrl/domain/services/xbrl_tag_mapping_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('XbrlDocumentGenerator', () {
    late XbrlTagMappingInput sampleInput;

    setUp(() {
      sampleInput = XbrlTagMappingInput(
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
    });

    group('generate', () {
      test('returns XbrlDocument with correct company info', () {
        final doc = XbrlDocumentGenerator.instance.generate(sampleInput);

        expect(doc.instanceDocumentId, 'DOC-2024-001');
        expect(doc.companyName, 'Test Company Private Limited');
        expect(doc.cin, 'U01234MH2020PLC123456');
      });

      test('returns document with reporting period', () {
        final doc = XbrlDocumentGenerator.instance.generate(sampleInput);

        expect(doc.reportingPeriodStart, DateTime(2023, 4, 1));
        expect(doc.reportingPeriodEnd, DateTime(2024, 3, 31));
      });

      test('contains instant and duration contexts', () {
        final doc = XbrlDocumentGenerator.instance.generate(sampleInput);

        expect(doc.contexts, isNotEmpty);
        final instantContext = doc.contexts.firstWhere(
          (c) => c.periodType == XbrlPeriodType.instant,
        );
        final durationContext = doc.contexts.firstWhere(
          (c) => c.periodType == XbrlPeriodType.duration,
        );
        expect(instantContext.entity, 'U01234MH2020PLC123456');
        expect(durationContext.entity, 'U01234MH2020PLC123456');
        expect(durationContext.periodStart, '2023-04-01');
        expect(durationContext.periodEnd, '2024-03-31');
        expect(instantContext.periodEnd, '2024-03-31');
      });

      test('contains INR unit', () {
        final doc = XbrlDocumentGenerator.instance.generate(sampleInput);

        expect(doc.units, isNotEmpty);
        final inrUnit = doc.units.firstWhere((u) => u.unitId == 'INR');
        expect(inrUnit.measure, 'iso4217:INR');
      });

      test('contains facts from all three statements', () {
        final doc = XbrlDocumentGenerator.instance.generate(sampleInput);

        expect(doc.facts, isNotEmpty);
        // Balance sheet facts
        expect(
          doc.facts.any(
            (f) => f.elementName == 'in-gaap:CashAndCashEquivalents',
          ),
          isTrue,
        );
        // P&L facts
        expect(
          doc.facts.any((f) => f.elementName == 'in-gaap:Revenue'),
          isTrue,
        );
        // Cash flow facts
        expect(
          doc.facts.any(
            (f) => f.elementName == 'in-gaap:CashFlowFromOperatingActivities',
          ),
          isTrue,
        );
      });

      test('sets MCA taxonomy schema ref', () {
        final doc = XbrlDocumentGenerator.instance.generate(sampleInput);

        expect(doc.schemaRef, contains('mca.gov.in'));
      });
    });

    group('generateXml', () {
      test('produces valid XML header', () {
        final doc = XbrlDocumentGenerator.instance.generate(sampleInput);
        final xml = XbrlDocumentGenerator.instance.generateXml(doc);

        expect(xml, startsWith('<?xml version="1.0" encoding="UTF-8"?>'));
      });

      test('contains xbrl root element', () {
        final doc = XbrlDocumentGenerator.instance.generate(sampleInput);
        final xml = XbrlDocumentGenerator.instance.generateXml(doc);

        expect(xml, contains('<xbrl'));
        expect(xml, contains('</xbrl>'));
      });

      test('includes schemaRef element', () {
        final doc = XbrlDocumentGenerator.instance.generate(sampleInput);
        final xml = XbrlDocumentGenerator.instance.generateXml(doc);

        expect(xml, contains('<schemaRef'));
      });

      test('includes context elements', () {
        final doc = XbrlDocumentGenerator.instance.generate(sampleInput);
        final xml = XbrlDocumentGenerator.instance.generateXml(doc);

        expect(xml, contains('<context'));
        expect(xml, contains('</context>'));
        expect(xml, contains('<entity>'));
        expect(xml, contains('<period>'));
      });

      test('includes unit element with ISO 4217 INR measure', () {
        final doc = XbrlDocumentGenerator.instance.generate(sampleInput);
        final xml = XbrlDocumentGenerator.instance.generateXml(doc);

        expect(xml, contains('<unit id="INR">'));
        expect(xml, contains('<measure>iso4217:INR</measure>'));
      });

      test('includes fact elements with contextRef and value', () {
        final doc = XbrlDocumentGenerator.instance.generate(sampleInput);
        final xml = XbrlDocumentGenerator.instance.generateXml(doc);

        expect(xml, contains('contextRef='));
        expect(xml, contains('in-gaap:CashAndCashEquivalents'));
        expect(xml, contains('5000000.00'));
      });

      test('monetary facts include unitRef', () {
        final doc = XbrlDocumentGenerator.instance.generate(sampleInput);
        final xml = XbrlDocumentGenerator.instance.generateXml(doc);

        expect(xml, contains('unitRef="INR"'));
      });

      test('includes xbrl and in-gaap namespace declarations', () {
        final doc = XbrlDocumentGenerator.instance.generate(sampleInput);
        final xml = XbrlDocumentGenerator.instance.generateXml(doc);

        expect(xml, contains('xmlns="http://www.xbrl.org/2003/instance"'));
        expect(xml, contains('xmlns:in-gaap='));
      });
    });

    group('singleton pattern', () {
      test('returns the same instance', () {
        final a = XbrlDocumentGenerator.instance;
        final b = XbrlDocumentGenerator.instance;
        expect(identical(a, b), isTrue);
      });
    });
  });

  group('XbrlDocument model', () {
    test('equality and hashCode', () {
      const context = XbrlContext(
        contextId: 'I-2024',
        entity: 'U01234MH2020PLC123456',
        scheme: 'http://www.mca.gov.in',
        periodType: XbrlPeriodType.instant,
        periodEnd: '2024-03-31',
      );
      const unit = XbrlUnit(unitId: 'INR', measure: 'iso4217:INR');
      const fact = XbrlFact(
        elementName: 'in-gaap:CashAndCashEquivalents',
        contextRef: 'I-2024',
        unitRef: 'INR',
        value: '5000000.00',
        decimals: 0,
      );

      final a = XbrlDocument(
        instanceDocumentId: 'DOC-001',
        companyName: 'Test Co',
        cin: 'U01234MH2020PLC123456',
        reportingPeriodStart: DateTime(2023, 4, 1),
        reportingPeriodEnd: DateTime(2024, 3, 31),
        contexts: const [context],
        units: const [unit],
        facts: const [fact],
        schemaRef: 'https://mca.gov.in/taxonomy',
      );
      final b = XbrlDocument(
        instanceDocumentId: 'DOC-001',
        companyName: 'Test Co',
        cin: 'U01234MH2020PLC123456',
        reportingPeriodStart: DateTime(2023, 4, 1),
        reportingPeriodEnd: DateTime(2024, 3, 31),
        contexts: const [context],
        units: const [unit],
        facts: const [fact],
        schemaRef: 'https://mca.gov.in/taxonomy',
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith changes specified field', () {
      final original = XbrlDocument(
        instanceDocumentId: 'DOC-001',
        companyName: 'Test Co',
        cin: 'U01234MH2020PLC123456',
        reportingPeriodStart: DateTime(2023, 4, 1),
        reportingPeriodEnd: DateTime(2024, 3, 31),
        contexts: const [],
        units: const [],
        facts: const [],
        schemaRef: 'https://mca.gov.in/taxonomy',
      );
      final updated = original.copyWith(companyName: 'New Co');
      expect(updated.companyName, 'New Co');
      expect(updated.instanceDocumentId, 'DOC-001');
    });
  });

  group('XbrlUnit model', () {
    test('equality and hashCode', () {
      const a = XbrlUnit(unitId: 'INR', measure: 'iso4217:INR');
      const b = XbrlUnit(unitId: 'INR', measure: 'iso4217:INR');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith', () {
      const original = XbrlUnit(unitId: 'INR', measure: 'iso4217:INR');
      final updated = original.copyWith(unitId: 'USD');
      expect(updated.unitId, 'USD');
      expect(updated.measure, 'iso4217:INR');
    });
  });

  group('XbrlTaxonomy model', () {
    test('equality and hashCode', () {
      final elements = <String, XbrlTaxonomyElement>{
        'CashAndCashEquivalents': const XbrlTaxonomyElement(
          elementName: 'CashAndCashEquivalents',
          namespace: 'in-gaap',
          dataType: XbrlDataType.monetaryItemType,
          periodType: XbrlPeriodType.instant,
          balance: XbrlBalance.debit,
          isAbstract: false,
        ),
      };
      final labels = <String, String>{
        'CashAndCashEquivalents': 'Cash and Cash Equivalents',
      };

      final a = XbrlTaxonomy(
        taxonomyName: 'in-gaap-2014-03-31',
        version: '2014-03-31',
        elements: elements,
        labelLinkbase: labels,
      );
      final b = XbrlTaxonomy(
        taxonomyName: 'in-gaap-2014-03-31',
        version: '2014-03-31',
        elements: elements,
        labelLinkbase: labels,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('lookupElement returns correct element', () {
      final elements = <String, XbrlTaxonomyElement>{
        'Revenue': const XbrlTaxonomyElement(
          elementName: 'Revenue',
          namespace: 'in-gaap',
          dataType: XbrlDataType.monetaryItemType,
          periodType: XbrlPeriodType.duration,
          balance: XbrlBalance.credit,
          isAbstract: false,
        ),
      };
      final taxonomy = XbrlTaxonomy(
        taxonomyName: 'in-gaap-2014-03-31',
        version: '2014-03-31',
        elements: elements,
        labelLinkbase: const {},
      );

      final element = taxonomy.lookupElement('Revenue');
      expect(element, isNotNull);
      expect(element!.qualifiedName, 'in-gaap:Revenue');
    });

    test('lookupElement returns null for unknown element', () {
      final taxonomy = XbrlTaxonomy(
        taxonomyName: 'in-gaap-2014-03-31',
        version: '2014-03-31',
        elements: const {},
        labelLinkbase: const {},
      );

      expect(taxonomy.lookupElement('NonExistentElement'), isNull);
    });

    test('labelFor returns human readable label', () {
      final taxonomy = XbrlTaxonomy(
        taxonomyName: 'in-gaap-2014-03-31',
        version: '2014-03-31',
        elements: const {},
        labelLinkbase: const {
          'CashAndCashEquivalents': 'Cash and Cash Equivalents',
        },
      );

      expect(
        taxonomy.labelFor('CashAndCashEquivalents'),
        'Cash and Cash Equivalents',
      );
    });

    test('labelFor returns elementName when label not found', () {
      final taxonomy = XbrlTaxonomy(
        taxonomyName: 'in-gaap-2014-03-31',
        version: '2014-03-31',
        elements: const {},
        labelLinkbase: const {},
      );

      expect(taxonomy.labelFor('UnknownElement'), 'UnknownElement');
    });
  });

  group('XbrlTagMappingInput', () {
    test('copyWith changes companyName', () {
      final original = XbrlTagMappingInput(
        instanceDocumentId: 'DOC-001',
        companyName: 'Test Co',
        cin: 'U01234MH2020PLC123456',
        reportingPeriodStart: DateTime(2023, 4, 1),
        reportingPeriodEnd: DateTime(2024, 3, 31),
        balanceSheet: const ScheduleIIIBalanceSheet(
          cashAndCashEquivalents: 100,
          tradeReceivables: 0,
          propertyPlantAndEquipment: 0,
          totalAssets: 100,
          shareCapital: 100,
          retainedEarnings: 0,
          shortTermBorrowings: 0,
          tradePayables: 0,
          totalEquityAndLiabilities: 100,
          inventories: 0,
          otherCurrentAssets: 0,
          longTermBorrowings: 0,
          otherCurrentLiabilities: 0,
          otherNonCurrentAssets: 0,
          otherNonCurrentLiabilities: 0,
          otherReserves: 0,
        ),
        pnl: const PnlStatement(
          revenue: 0,
          costOfGoodsSold: 0,
          grossProfit: 0,
          operatingExpenses: 0,
          operatingProfit: 0,
          otherIncome: 0,
          profitBeforeTax: 0,
          taxExpense: 0,
          profitAfterTax: 0,
          basicEarningsPerShare: 0,
          dilutedEarningsPerShare: 0,
          depreciation: 0,
          financeCharges: 0,
        ),
        cashFlow: const CashFlowStatement(
          operatingActivities: 0,
          investingActivities: 0,
          financingActivities: 0,
          netCashChange: 0,
          openingCash: 0,
          closingCash: 0,
        ),
      );

      final updated = original.copyWith(companyName: 'New Co');
      expect(updated.companyName, 'New Co');
      expect(updated.cin, 'U01234MH2020PLC123456');
    });
  });
}
