import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/it_act_transition/domain/models/tax_year.dart';
import 'package:ca_app/features/it_act_transition/domain/services/tax_year_service.dart';

void main() {
  group('TaxYearService.ayToDisplayLabel', () {
    test('1961 Act AY stays as AY', () {
      expect(TaxYearService.ayToDisplayLabel('AY 2026-27'), 'AY 2026-27');
    });

    test('2025 Act AY converts to TY', () {
      expect(TaxYearService.ayToDisplayLabel('AY 2028-29'), 'TY 2027-28');
    });
  });

  group('TaxYearService.fyToDisplayLabel', () {
    test('FY 2025-26 → AY 2026-27', () {
      expect(TaxYearService.fyToDisplayLabel('2025-26'), 'AY 2026-27');
    });

    test('FY 2026-27 → TY 2026-27', () {
      expect(TaxYearService.fyToDisplayLabel('2026-27'), 'TY 2026-27');
    });
  });

  group('TaxYearService.filingDueDate', () {
    final fy2025 = TaxYear(startYear: 2025);

    test('non-audit due July 31', () {
      final due = TaxYearService.filingDueDate(taxYear: fy2025);
      expect(due, DateTime(2026, 7, 31));
    });

    test('audit due October 31', () {
      final due = TaxYearService.filingDueDate(
        taxYear: fy2025,
        isAuditCase: true,
      );
      expect(due, DateTime(2026, 10, 31));
    });

    test('TP due November 30', () {
      final due = TaxYearService.filingDueDate(
        taxYear: fy2025,
        isTransferPricingCase: true,
      );
      expect(due, DateTime(2026, 11, 30));
    });

    test('TP takes priority over audit', () {
      final due = TaxYearService.filingDueDate(
        taxYear: fy2025,
        isAuditCase: true,
        isTransferPricingCase: true,
      );
      expect(due, DateTime(2026, 11, 30));
    });
  });

  group('TaxYearService.belatedReturnDeadline', () {
    test('returns December 31 of AY year', () {
      final ty = TaxYear(startYear: 2025);
      expect(TaxYearService.belatedReturnDeadline(ty), DateTime(2026, 12, 31));
    });
  });

  group('TaxYearService.updatedReturnDeadline', () {
    test('returns 4 years from end of AY', () {
      final ty = TaxYear(startYear: 2025);
      expect(TaxYearService.updatedReturnDeadline(ty), DateTime(2030, 3, 31));
    });
  });

  group('TaxYearService.advanceTaxInstallments', () {
    test('returns 4 installments', () {
      final ty = TaxYear(startYear: 2025);
      final installments = TaxYearService.advanceTaxInstallments(ty);
      expect(installments.length, 4);
    });

    test('correct dates for FY 2025-26', () {
      final ty = TaxYear(startYear: 2025);
      final installments = TaxYearService.advanceTaxInstallments(ty);
      expect(installments[0].dueDate, DateTime(2025, 6, 15));
      expect(installments[1].dueDate, DateTime(2025, 9, 15));
      expect(installments[2].dueDate, DateTime(2025, 12, 15));
      expect(installments[3].dueDate, DateTime(2026, 3, 15));
    });

    test('correct cumulative percentages', () {
      final ty = TaxYear(startYear: 2025);
      final installments = TaxYearService.advanceTaxInstallments(ty);
      expect(installments[0].cumulativePercent, 15);
      expect(installments[1].cumulativePercent, 45);
      expect(installments[2].cumulativePercent, 75);
      expect(installments[3].cumulativePercent, 100);
    });
  });

  group('TaxYearService.actNameForFy', () {
    test('FY 2025-26 → IT Act 1961', () {
      expect(
        TaxYearService.actNameForFy('2025-26'),
        'Income-tax Act, 1961',
      );
    });

    test('FY 2026-27 → IT Act 2025', () {
      expect(
        TaxYearService.actNameForFy('2026-27'),
        'Income-tax Act, 2025',
      );
    });
  });

  group('TaxYearService.recentTaxYears', () {
    test('returns requested count', () {
      final years = TaxYearService.recentTaxYears(count: 3);
      expect(years.length, 3);
    });

    test('first is current, rest are prior', () {
      final years = TaxYearService.recentTaxYears(count: 3);
      expect(years[0].startYear, greaterThan(years[1].startYear));
      expect(years[1].startYear, greaterThan(years[2].startYear));
    });

    test('default count is 6', () {
      final years = TaxYearService.recentTaxYears();
      expect(years.length, 6);
    });
  });

  group('TaxYearService.isUnderNewAct', () {
    test('AY 2026-27 is NOT under new act', () {
      expect(TaxYearService.isUnderNewAct('AY 2026-27'), isFalse);
    });

    test('AY 2027-28 IS under new act', () {
      expect(TaxYearService.isUnderNewAct('AY 2027-28'), isTrue);
    });
  });
}
