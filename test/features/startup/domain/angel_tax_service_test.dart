import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/startup/domain/models/angel_tax_computation.dart';
import 'package:ca_app/features/startup/domain/services/angel_tax_service.dart';
import 'package:ca_app/features/startup/domain/services/section80iac_service.dart';

void main() {
  group('AngelTaxService', () {
    late AngelTaxService service;

    setUp(() {
      service = AngelTaxService.instance;
    });

    test('singleton returns same instance', () {
      expect(AngelTaxService.instance, same(AngelTaxService.instance));
    });

    group('computeAngelTax', () {
      test('30% tax on excess over FMV (Section 56(2)(viib))', () {
        // Issue price Rs 1500, FMV Rs 1000, raise Rs 15L
        // Excess = 15L - 10L = 5L = 50000000 paise
        // Tax = 30% of 50000000 = 15000000 paise
        const input = AngelTaxInput(
          issuePricePaise: 150000, // Rs 1500 per share
          fairMarketValuePaise: 100000, // Rs 1000 FMV
          amountRaisedPaise: 15000000, // Rs 15L total raised
          exemptionApplied: false,
        );
        final result = service.computeAngelTax(input);
        expect(result.excessOverFmvPaise, 5000000); // Rs 5L excess
        expect(result.angelTaxPayablePaise, 1500000); // 30% of 5L
        expect(result.exemptionApplied, false);
      });

      test('zero tax when DPIIT exempt', () {
        const input = AngelTaxInput(
          issuePricePaise: 150000,
          fairMarketValuePaise: 100000,
          amountRaisedPaise: 15000000,
          exemptionApplied: true,
        );
        final result = service.computeAngelTax(input);
        expect(result.angelTaxPayablePaise, 0);
        expect(result.exemptionApplied, true);
      });

      test('zero tax when issue price does not exceed FMV', () {
        const input = AngelTaxInput(
          issuePricePaise: 100000, // equal to FMV
          fairMarketValuePaise: 100000,
          amountRaisedPaise: 10000000,
          exemptionApplied: false,
        );
        final result = service.computeAngelTax(input);
        expect(result.excessOverFmvPaise, 0);
        expect(result.angelTaxPayablePaise, 0);
      });

      test('zero excess when issue price below FMV', () {
        const input = AngelTaxInput(
          issuePricePaise: 80000, // below FMV
          fairMarketValuePaise: 100000,
          amountRaisedPaise: 8000000,
          exemptionApplied: false,
        );
        final result = service.computeAngelTax(input);
        expect(result.excessOverFmvPaise, 0);
        expect(result.angelTaxPayablePaise, 0);
      });
    });

    group('isDpiitExempt', () {
      test('returns bool for any dpiit number', () {
        final result = service.isDpiitExempt('DPIIT12345');
        expect(result, isA<bool>());
      });

      test('empty dpiit number returns false', () {
        expect(service.isDpiitExempt(''), false);
      });
    });
  });

  group('Section80IACService', () {
    late Section80IACService service;

    setUp(() {
      service = Section80IACService.instance;
    });

    test('singleton returns same instance', () {
      expect(Section80IACService.instance, same(Section80IACService.instance));
    });

    group('computeDeduction', () {
      test('100% deduction for eligible startup within 10 year window', () {
        // Incorporated April 2018, FY 2023-24 (year 6 of first 10 years)
        final startup = StartupData(
          name: 'Tech Startup Pvt Ltd',
          pan: 'AAAAA0001A',
          dpiitNumber: 'DPIIT12345',
          incorporationDate: DateTime(2018, 4, 1),
          entityType: StartupEntityType.company,
          netProfitPaise: 10000000, // Rs 10L profit
          financialYears80IACApplied: const [],
        );
        final deduction = service.computeDeduction(startup, 2024);
        // Should allow 100% deduction = 10L = 1000000000 paise
        expect(deduction, 10000000);
      });

      test('zero deduction if more than 10 years from incorporation', () {
        final startup = StartupData(
          name: 'Old Startup Pvt Ltd',
          pan: 'BBBBB0002B',
          dpiitNumber: 'DPIIT99999',
          incorporationDate: DateTime(2010, 4, 1), // > 10 years before FY2024
          entityType: StartupEntityType.company,
          netProfitPaise: 10000000,
          financialYears80IACApplied: const [],
        );
        final deduction = service.computeDeduction(startup, 2024);
        expect(deduction, 0);
      });

      test('zero deduction if already applied for 3 consecutive years', () {
        final startup = StartupData(
          name: 'Exhausted Startup',
          pan: 'CCCCC0003C',
          dpiitNumber: 'DPIIT11111',
          incorporationDate: DateTime(2018, 4, 1),
          entityType: StartupEntityType.company,
          netProfitPaise: 10000000,
          financialYears80IACApplied: const [2020, 2021, 2022], // 3 years used
        );
        final deduction = service.computeDeduction(startup, 2024);
        expect(deduction, 0);
      });

      test('zero deduction for partnership entity', () {
        final startup = StartupData(
          name: 'Partnership Startup',
          pan: 'DDDDD0004D',
          dpiitNumber: 'DPIIT22222',
          incorporationDate: DateTime(2020, 4, 1),
          entityType: StartupEntityType.partnership,
          netProfitPaise: 10000000,
          financialYears80IACApplied: const [],
        );
        final deduction = service.computeDeduction(startup, 2024);
        expect(deduction, 0);
      });

      test('zero deduction if incorporated before April 1 2016', () {
        final startup = StartupData(
          name: 'Pre-2016 LLP',
          pan: 'EEEEE0005E',
          dpiitNumber: 'DPIIT33333',
          incorporationDate: DateTime(2015, 3, 31), // before April 1 2016
          entityType: StartupEntityType.llp,
          netProfitPaise: 10000000,
          financialYears80IACApplied: const [],
        );
        final deduction = service.computeDeduction(startup, 2024);
        expect(deduction, 0);
      });
    });
  });

  group('AngelTaxComputation model', () {
    test('equality and copyWith', () {
      const a = AngelTaxComputation(
        issuePricePaise: 150000,
        fairMarketValuePaise: 100000,
        amountRaisedPaise: 15000000,
        excessOverFmvPaise: 5000000,
        angelTaxPayablePaise: 1500000,
        exemptionApplied: false,
      );
      const b = AngelTaxComputation(
        issuePricePaise: 150000,
        fairMarketValuePaise: 100000,
        amountRaisedPaise: 15000000,
        excessOverFmvPaise: 5000000,
        angelTaxPayablePaise: 1500000,
        exemptionApplied: false,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));

      final updated = a.copyWith(
        exemptionApplied: true,
        angelTaxPayablePaise: 0,
      );
      expect(updated.exemptionApplied, true);
      expect(a.exemptionApplied, false);
    });
  });
}
