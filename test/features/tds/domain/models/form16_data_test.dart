import 'package:ca_app/features/tds/domain/models/form16_data.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';
import 'package:ca_app/features/tds/domain/models/tds_return_form.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Shared test fixtures
  // ---------------------------------------------------------------------------

  final testAddress = TdsAddress(
    line1: '123 MG Road',
    city: 'Mumbai',
    state: 'Maharashtra',
    pincode: '400001',
  );

  Form16QuarterDetail makeQuarterDetail({
    TdsQuarter quarter = TdsQuarter.q1,
    double taxDeducted = 25000,
    double taxDeposited = 25000,
  }) {
    return Form16QuarterDetail(
      quarter: quarter,
      receiptNumbers: const ['CH001', 'CH002'],
      taxDeducted: taxDeducted,
      taxDeposited: taxDeposited,
      dateOfDeposit: DateTime(2025, 7, 7),
      bsrCode: '0002390',
      challanSerialNumber: 'SER001',
      status: 'matched',
    );
  }

  SalaryBreakup makeSalaryBreakup({
    double grossSalary = 1200000,
    double exemptAllowances = 50000,
    double standardDeduction = 75000,
    double professionalTax = 2500,
  }) {
    return SalaryBreakup(
      grossSalary: grossSalary,
      salaryAsPerSection17_1: grossSalary,
      valueOfPerquisites17_2: 0,
      profitsInLieuOfSalary17_3: 0,
      exemptAllowances: exemptAllowances,
      standardDeduction: standardDeduction,
      entertainmentAllowance: 0,
      professionalTax: professionalTax,
    );
  }

  ChapterVIADeductions makeDeductions({
    double section80C = 150000,
    double section80D = 25000,
  }) {
    return ChapterVIADeductions(
      section80C: section80C,
      section80CCC: 0,
      section80CCD1: 0,
      section80CCD1B: 50000,
      section80CCD2: 0,
      section80D: section80D,
      section80DD: 0,
      section80DDB: 0,
      section80E: 0,
      section80EE: 0,
      section80EEA: 0,
      section80G: 10000,
      section80GG: 0,
      section80GGA: 0,
      section80GGC: 0,
      section80TTA: 10000,
      section80TTB: 0,
      section80U: 0,
    );
  }

  TaxComputation makeTaxComputation({
    double totalTaxableIncome = 827500,
    double taxOnTotalIncome = 57500,
    double educationCess = 2300,
  }) {
    return TaxComputation(
      totalTaxableIncome: totalTaxableIncome,
      taxOnTotalIncome: taxOnTotalIncome,
      rebate87A: 0,
      surcharge: 0,
      educationCess: educationCess,
      totalTaxPayable: taxOnTotalIncome + educationCess,
      reliefSection89: 0,
      netTaxPayable: taxOnTotalIncome + educationCess,
      taxRegime: 'old',
    );
  }

  // ---------------------------------------------------------------------------
  // Form16QuarterDetail
  // ---------------------------------------------------------------------------

  group('Form16QuarterDetail →', () {
    test('creates with required fields', () {
      final detail = makeQuarterDetail();
      expect(detail.quarter, TdsQuarter.q1);
      expect(detail.taxDeducted, 25000);
      expect(detail.taxDeposited, 25000);
      expect(detail.receiptNumbers, ['CH001', 'CH002']);
      expect(detail.bsrCode, '0002390');
      expect(detail.status, 'matched');
    });

    test('copyWith replaces specified fields only', () {
      final original = makeQuarterDetail();
      final updated = original.copyWith(
        quarter: TdsQuarter.q2,
        taxDeducted: 30000,
      );
      expect(updated.quarter, TdsQuarter.q2);
      expect(updated.taxDeducted, 30000);
      expect(updated.taxDeposited, original.taxDeposited);
      expect(updated.bsrCode, original.bsrCode);
    });

    test('equality compares all fields', () {
      final a = makeQuarterDetail();
      final b = makeQuarterDetail();
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('inequality when fields differ', () {
      final a = makeQuarterDetail(taxDeducted: 25000);
      final b = makeQuarterDetail(taxDeducted: 30000);
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // Form16PartA
  // ---------------------------------------------------------------------------

  group('Form16PartA →', () {
    test('creates with quarterly details', () {
      final partA = Form16PartA(quarterlyDetails: [
        makeQuarterDetail(quarter: TdsQuarter.q1, taxDeducted: 25000),
        makeQuarterDetail(quarter: TdsQuarter.q2, taxDeducted: 30000),
      ]);
      expect(partA.quarterlyDetails.length, 2);
    });

    test('totalTaxDeducted sums all quarters', () {
      final partA = Form16PartA(quarterlyDetails: [
        makeQuarterDetail(taxDeducted: 25000, taxDeposited: 25000),
        makeQuarterDetail(taxDeducted: 30000, taxDeposited: 30000),
        makeQuarterDetail(taxDeducted: 20000, taxDeposited: 20000),
      ]);
      expect(partA.totalTaxDeducted, 75000);
      expect(partA.totalTaxDeposited, 75000);
    });

    test('empty quarterly details gives zero totals', () {
      final partA = Form16PartA(quarterlyDetails: const []);
      expect(partA.totalTaxDeducted, 0);
      expect(partA.totalTaxDeposited, 0);
    });

    test('copyWith replaces quarterlyDetails', () {
      final original = Form16PartA(quarterlyDetails: [makeQuarterDetail()]);
      final updated = original.copyWith(quarterlyDetails: const []);
      expect(updated.quarterlyDetails, isEmpty);
    });

    test('equality compares quarterlyDetails', () {
      final a = Form16PartA(quarterlyDetails: [makeQuarterDetail()]);
      final b = Form16PartA(quarterlyDetails: [makeQuarterDetail()]);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  // ---------------------------------------------------------------------------
  // SalaryBreakup
  // ---------------------------------------------------------------------------

  group('SalaryBreakup →', () {
    test('creates with correct fields', () {
      final s = makeSalaryBreakup();
      expect(s.grossSalary, 1200000);
      expect(s.standardDeduction, 75000);
    });

    test('netSalary = gross - exemptAllowances', () {
      final s = makeSalaryBreakup(
        grossSalary: 1200000,
        exemptAllowances: 50000,
      );
      expect(s.netSalary, 1150000);
    });

    test('incomeFromSalary = net - stdDed - entertainment - PT', () {
      final s = makeSalaryBreakup(
        grossSalary: 1200000,
        exemptAllowances: 50000,
        standardDeduction: 75000,
        professionalTax: 2500,
      );
      // net = 1200000 - 50000 = 1150000
      // income = 1150000 - 75000 - 0 - 2500 = 1072500
      expect(s.incomeFromSalary, 1072500);
    });

    test('copyWith replaces specified fields only', () {
      final original = makeSalaryBreakup();
      final updated = original.copyWith(grossSalary: 1500000);
      expect(updated.grossSalary, 1500000);
      expect(updated.standardDeduction, original.standardDeduction);
    });

    test('equality compares all fields', () {
      final a = makeSalaryBreakup();
      final b = makeSalaryBreakup();
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  // ---------------------------------------------------------------------------
  // ChapterVIADeductions
  // ---------------------------------------------------------------------------

  group('ChapterVIADeductions →', () {
    test('zero() factory creates all-zero deductions', () {
      final d = ChapterVIADeductions.zero();
      expect(d.section80C, 0);
      expect(d.section80D, 0);
      expect(d.section80TTA, 0);
      expect(d.total, 0);
    });

    test('total sums all 18 sections', () {
      final d = makeDeductions(section80C: 150000, section80D: 25000);
      // 150000 + 0 + 0 + 50000 + 0 + 25000 + 0 + 0 + 0 + 0 + 0 + 10000 + 0 + 0 + 0 + 10000 + 0 + 0
      expect(d.total, 245000);
    });

    test('copyWith replaces specified fields only', () {
      final original = ChapterVIADeductions.zero();
      final updated = original.copyWith(section80C: 150000);
      expect(updated.section80C, 150000);
      expect(updated.section80D, 0);
    });

    test('equality compares all fields', () {
      final a = makeDeductions();
      final b = makeDeductions();
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('inequality when any field differs', () {
      final a = makeDeductions(section80C: 150000);
      final b = makeDeductions(section80C: 100000);
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // TaxComputation
  // ---------------------------------------------------------------------------

  group('TaxComputation →', () {
    test('creates with correct fields', () {
      final tc = makeTaxComputation();
      expect(tc.taxRegime, 'old');
      expect(tc.totalTaxPayable, 59800);
      expect(tc.netTaxPayable, 59800);
    });

    test('copyWith replaces specified fields only', () {
      final original = makeTaxComputation();
      final updated = original.copyWith(taxRegime: 'new');
      expect(updated.taxRegime, 'new');
      expect(updated.totalTaxableIncome, original.totalTaxableIncome);
    });

    test('equality compares all fields', () {
      final a = makeTaxComputation();
      final b = makeTaxComputation();
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  // ---------------------------------------------------------------------------
  // Form16PartB
  // ---------------------------------------------------------------------------

  group('Form16PartB →', () {
    test('creates with sub-models', () {
      final partB = Form16PartB(
        salaryBreakup: makeSalaryBreakup(),
        incomeFromHouseProperty: -200000,
        incomeFromOtherSources: 50000,
        deductions: makeDeductions(),
        taxComputation: makeTaxComputation(),
      );
      expect(partB.salaryBreakup.grossSalary, 1200000);
      expect(partB.incomeFromHouseProperty, -200000);
    });

    test('grossTotalIncome = salary + house prop + other sources', () {
      final partB = Form16PartB(
        salaryBreakup: makeSalaryBreakup(
          grossSalary: 1200000,
          exemptAllowances: 50000,
          standardDeduction: 75000,
          professionalTax: 2500,
        ),
        incomeFromHouseProperty: -200000,
        incomeFromOtherSources: 50000,
        deductions: makeDeductions(),
        taxComputation: makeTaxComputation(),
      );
      // incomeFromSalary = 1072500, house = -200000, other = 50000
      expect(partB.grossTotalIncome, 922500);
    });

    test('copyWith replaces specified fields only', () {
      final original = Form16PartB(
        salaryBreakup: makeSalaryBreakup(),
        incomeFromHouseProperty: 0,
        incomeFromOtherSources: 0,
        deductions: makeDeductions(),
        taxComputation: makeTaxComputation(),
      );
      final updated = original.copyWith(incomeFromHouseProperty: -150000);
      expect(updated.incomeFromHouseProperty, -150000);
      expect(updated.incomeFromOtherSources, 0);
    });

    test('equality compares all fields', () {
      final a = Form16PartB(
        salaryBreakup: makeSalaryBreakup(),
        incomeFromHouseProperty: 0,
        incomeFromOtherSources: 0,
        deductions: makeDeductions(),
        taxComputation: makeTaxComputation(),
      );
      final b = Form16PartB(
        salaryBreakup: makeSalaryBreakup(),
        incomeFromHouseProperty: 0,
        incomeFromOtherSources: 0,
        deductions: makeDeductions(),
        taxComputation: makeTaxComputation(),
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  // ---------------------------------------------------------------------------
  // Form16Data
  // ---------------------------------------------------------------------------

  group('Form16Data →', () {
    Form16Data makeForm16Data({String certificateNumber = 'CERT001'}) {
      return Form16Data(
        certificateNumber: certificateNumber,
        employerTan: 'MUMB12345A',
        employerPan: 'ABCDE1234F',
        employerName: 'ABC Corp Pvt Ltd',
        employerAddress: testAddress,
        employeePan: 'XYZAB5678C',
        employeeName: 'Rajesh Kumar',
        employeeAddress: testAddress,
        assessmentYear: '2026-27',
        periodFrom: DateTime(2025, 4, 1),
        periodTo: DateTime(2026, 3, 31),
        partA: Form16PartA(quarterlyDetails: [
          makeQuarterDetail(quarter: TdsQuarter.q1),
          makeQuarterDetail(quarter: TdsQuarter.q2),
        ]),
        partB: Form16PartB(
          salaryBreakup: makeSalaryBreakup(),
          incomeFromHouseProperty: 0,
          incomeFromOtherSources: 0,
          deductions: makeDeductions(),
          taxComputation: makeTaxComputation(),
        ),
      );
    }

    test('creates with all required fields', () {
      final form = makeForm16Data();
      expect(form.certificateNumber, 'CERT001');
      expect(form.employerTan, 'MUMB12345A');
      expect(form.employeePan, 'XYZAB5678C');
      expect(form.assessmentYear, '2026-27');
      expect(form.partA.quarterlyDetails.length, 2);
    });

    test('equality by certificateNumber', () {
      final a = makeForm16Data(certificateNumber: 'CERT001');
      final b = makeForm16Data(certificateNumber: 'CERT001');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('inequality when certificateNumber differs', () {
      final a = makeForm16Data(certificateNumber: 'CERT001');
      final b = makeForm16Data(certificateNumber: 'CERT002');
      expect(a, isNot(equals(b)));
    });

    test('copyWith replaces specified fields only', () {
      final original = makeForm16Data();
      final updated = original.copyWith(employeeName: 'Suresh Patel');
      expect(updated.employeeName, 'Suresh Patel');
      expect(updated.certificateNumber, original.certificateNumber);
      expect(updated.employerTan, original.employerTan);
    });

    test('full realistic salary data', () {
      final form = Form16Data(
        certificateNumber: 'MUMB12345A/2026-27/Form16/001',
        employerTan: 'MUMB12345A',
        employerPan: 'ABCDE1234F',
        employerName: 'TechSoft India Pvt Ltd',
        employerAddress: testAddress,
        employeePan: 'XYZAB5678C',
        employeeName: 'Priya Sharma',
        employeeAddress: testAddress,
        assessmentYear: '2026-27',
        periodFrom: DateTime(2025, 4, 1),
        periodTo: DateTime(2026, 3, 31),
        partA: Form16PartA(quarterlyDetails: [
          makeQuarterDetail(
            quarter: TdsQuarter.q1,
            taxDeducted: 15000,
            taxDeposited: 15000,
          ),
          makeQuarterDetail(
            quarter: TdsQuarter.q2,
            taxDeducted: 15000,
            taxDeposited: 15000,
          ),
          makeQuarterDetail(
            quarter: TdsQuarter.q3,
            taxDeducted: 15000,
            taxDeposited: 15000,
          ),
          makeQuarterDetail(
            quarter: TdsQuarter.q4,
            taxDeducted: 14800,
            taxDeposited: 14800,
          ),
        ]),
        partB: Form16PartB(
          salaryBreakup: makeSalaryBreakup(),
          incomeFromHouseProperty: -200000,
          incomeFromOtherSources: 30000,
          deductions: makeDeductions(),
          taxComputation: makeTaxComputation(
            totalTaxableIncome: 827500,
            taxOnTotalIncome: 57500,
            educationCess: 2300,
          ),
        ),
      );

      expect(form.partA.totalTaxDeducted, 59800);
      expect(form.partA.totalTaxDeposited, 59800);
      expect(form.partB.taxComputation.netTaxPayable, 59800);
    });
  });
}
