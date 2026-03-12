import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/mca/domain/models/aoc4_financial_statement.dart';
import 'package:ca_app/features/mca/domain/models/company.dart';
import 'package:ca_app/features/mca/domain/models/financial_statements.dart';
import 'package:ca_app/features/mca/domain/services/aoc4_preparation_service.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Company _makeCompany() => Company(
  id: 'c1',
  cin: 'U74999MH2018PTC123456',
  companyName: 'Test Private Ltd',
  incorporationDate: DateTime(2018, 1, 1),
  category: CompanyCategory.privateLimited,
  paidUpCapital: 100000,
  authorisedCapital: 1000000,
  registeredAddress: '123 MG Road, Mumbai',
  rocJurisdiction: 'ROC Mumbai',
  directors: const [],
);

FinancialStatements _makeFs({
  double balanceSheetTotal = 5000000,
  double profitAfterTax = 200000,
  double dividendPaid = 0,
  DateTime? auditReportDate,
}) => FinancialStatements(
  balanceSheetTotal: balanceSheetTotal,
  profitAfterTax: profitAfterTax,
  dividendPaid: dividendPaid,
  auditReportDate: auditReportDate ?? DateTime(2024, 8, 20),
);

void main() {
  // -------------------------------------------------------------------------
  // prepareAoc4
  // -------------------------------------------------------------------------
  group('Aoc4PreparationService.prepareAoc4', () {
    test('returns Aoc4FinancialStatement with correct CIN', () {
      final company = _makeCompany();
      final fs = _makeFs();
      final result = Aoc4PreparationService.instance.prepareAoc4(
        company,
        fs,
        2024,
      );
      expect(result.cin, 'U74999MH2018PTC123456');
    });

    test('financial year is set correctly', () {
      final company = _makeCompany();
      final fs = _makeFs();
      final result = Aoc4PreparationService.instance.prepareAoc4(
        company,
        fs,
        2024,
      );
      expect(result.financialYear, 2024);
    });

    test('balance sheet total copied from financial statements', () {
      final company = _makeCompany();
      final fs = _makeFs(balanceSheetTotal: 9876543);
      final result = Aoc4PreparationService.instance.prepareAoc4(
        company,
        fs,
        2024,
      );
      expect(result.balanceSheetTotal, 9876543);
    });

    test('profit after tax copied from financial statements', () {
      final company = _makeCompany();
      final fs = _makeFs(profitAfterTax: 350000);
      final result = Aoc4PreparationService.instance.prepareAoc4(
        company,
        fs,
        2024,
      );
      expect(result.profitAfterTax, 350000);
    });

    test('dividend paid copied from financial statements', () {
      final company = _makeCompany();
      final fs = _makeFs(dividendPaid: 50000);
      final result = Aoc4PreparationService.instance.prepareAoc4(
        company,
        fs,
        2024,
      );
      expect(result.dividendPaid, 50000);
    });

    test('audit report date copied from financial statements', () {
      final auditDate = DateTime(2024, 9, 1);
      final company = _makeCompany();
      final fs = _makeFs(auditReportDate: auditDate);
      final result = Aoc4PreparationService.instance.prepareAoc4(
        company,
        fs,
        2024,
      );
      expect(result.auditReportDate, auditDate);
    });

    test('audit qualifications starts empty by default', () {
      final company = _makeCompany();
      final fs = _makeFs();
      final result = Aoc4PreparationService.instance.prepareAoc4(
        company,
        fs,
        2024,
      );
      expect(result.auditQualifications, isEmpty);
    });
  });

  // -------------------------------------------------------------------------
  // computeFilingDeadline
  // -------------------------------------------------------------------------
  group('Aoc4PreparationService.computeFilingDeadline', () {
    test('deadline is exactly 30 days after AGM', () {
      final agmDate = DateTime(2024, 9, 15);
      final deadline = Aoc4PreparationService.instance.computeFilingDeadline(
        agmDate,
      );
      expect(deadline, DateTime(2024, 10, 15));
    });

    test('deadline wraps correctly across month boundary', () {
      final agmDate = DateTime(2024, 10, 10);
      final deadline = Aoc4PreparationService.instance.computeFilingDeadline(
        agmDate,
      );
      expect(deadline, DateTime(2024, 11, 9));
    });

    test('deadline wraps correctly across year boundary', () {
      final agmDate = DateTime(2024, 12, 20);
      final deadline = Aoc4PreparationService.instance.computeFilingDeadline(
        agmDate,
      );
      expect(deadline, DateTime(2025, 1, 19));
    });

    test('typical September 30 AGM → deadline October 30', () {
      // Standard for March-end FY companies
      final agmDate = DateTime(2024, 9, 30);
      final deadline = Aoc4PreparationService.instance.computeFilingDeadline(
        agmDate,
      );
      expect(deadline, DateTime(2024, 10, 30));
    });
  });
}
