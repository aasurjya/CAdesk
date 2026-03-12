import 'package:ca_app/features/tds/domain/models/form16_data.dart';
import 'package:ca_app/features/tds/domain/models/form16a_data.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';
import 'package:ca_app/features/tds/domain/models/tds_return_form.dart';
import 'package:ca_app/features/tds/domain/services/form16_generation_service.dart';
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
      receiptNumbers: const ['CH001'],
      taxDeducted: taxDeducted,
      taxDeposited: taxDeposited,
      dateOfDeposit: DateTime(2025, 7, 7),
      bsrCode: '0002390',
      challanSerialNumber: 'SER001',
      status: 'matched',
    );
  }

  SalaryBreakup makeSalaryBreakup() {
    return const SalaryBreakup(
      grossSalary: 1200000,
      salaryAsPerSection17_1: 1200000,
      valueOfPerquisites17_2: 0,
      profitsInLieuOfSalary17_3: 0,
      exemptAllowances: 50000,
      standardDeduction: 75000,
      entertainmentAllowance: 0,
      professionalTax: 2500,
    );
  }

  Form16PartA makePartA() {
    return Form16PartA(quarterlyDetails: [
      makeQuarterDetail(quarter: TdsQuarter.q1),
      makeQuarterDetail(quarter: TdsQuarter.q2),
    ]);
  }

  Form16PartB makePartB() {
    return Form16PartB(
      salaryBreakup: makeSalaryBreakup(),
      incomeFromHouseProperty: 0,
      incomeFromOtherSources: 0,
      deductions: ChapterVIADeductions.zero(),
      taxComputation: const TaxComputation(
        totalTaxableIncome: 1072500,
        taxOnTotalIncome: 114400,
        rebate87A: 0,
        surcharge: 0,
        educationCess: 4576,
        totalTaxPayable: 118976,
        reliefSection89: 0,
        netTaxPayable: 118976,
        taxRegime: 'old',
      ),
    );
  }

  Form16ATransaction makeTransaction({
    double amountPaid = 100000,
    double tdsDeducted = 10000,
    double tdsDeposited = 10000,
  }) {
    return Form16ATransaction(
      dateOfPayment: DateTime(2025, 6, 15),
      dateOfDeduction: DateTime(2025, 6, 15),
      amountPaid: amountPaid,
      tdsDeducted: tdsDeducted,
      tdsDeposited: tdsDeposited,
      challanNumber: 'CH001',
      bsrCode: '0002390',
      dateOfDeposit: DateTime(2025, 7, 7),
    );
  }

  // ---------------------------------------------------------------------------
  // generateForm16
  // ---------------------------------------------------------------------------

  group('Form16GenerationService.generateForm16 →', () {
    test('creates valid Form16Data with all fields', () {
      final result = Form16GenerationService.generateForm16(
        certificateNumber: 'CERT001',
        employerTan: 'MUMB12345A',
        employerPan: 'ABCDE1234F',
        employerName: 'ABC Corp',
        employerAddress: testAddress,
        employeePan: 'XYZAB5678C',
        employeeName: 'Rajesh Kumar',
        employeeAddress: testAddress,
        assessmentYear: '2026-27',
        periodFrom: DateTime(2025, 4, 1),
        periodTo: DateTime(2026, 3, 31),
        partA: makePartA(),
        partB: makePartB(),
      );

      expect(result.certificateNumber, 'CERT001');
      expect(result.employerTan, 'MUMB12345A');
      expect(result.employeeName, 'Rajesh Kumar');
    });
  });

  // ---------------------------------------------------------------------------
  // generateForm16A
  // ---------------------------------------------------------------------------

  group('Form16GenerationService.generateForm16A →', () {
    test('creates valid Form16AData with all fields', () {
      final result = Form16GenerationService.generateForm16A(
        certificateNumber: 'CERT16A-001',
        deductorTan: 'DELH67890B',
        deductorPan: 'ABCDE1234F',
        deductorName: 'XYZ Services',
        deductorAddress: testAddress,
        deducteePan: 'PQRST9876Z',
        deducteeName: 'Amit Verma',
        deducteeAddress: testAddress,
        assessmentYear: '2026-27',
        quarter: TdsQuarter.q1,
        section: '194J',
        transactions: [makeTransaction()],
      );

      expect(result.certificateNumber, 'CERT16A-001');
      expect(result.deductorTan, 'DELH67890B');
      expect(result.section, '194J');
      expect(result.transactions.length, 1);
    });
  });

  // ---------------------------------------------------------------------------
  // bulkGenerateForm16
  // ---------------------------------------------------------------------------

  group('Form16GenerationService.bulkGenerateForm16 →', () {
    test('generates N forms with sequential certificate numbers', () {
      final results = Form16GenerationService.bulkGenerateForm16(
        employerTan: 'MUMB12345A',
        employerPan: 'ABCDE1234F',
        employerName: 'ABC Corp',
        employerAddress: testAddress,
        assessmentYear: '2026-27',
        periodFrom: DateTime(2025, 4, 1),
        periodTo: DateTime(2026, 3, 31),
        employees: [
          (
            employeePan: 'AAAAA1111A',
            employeeName: 'Employee One',
            employeeAddress: testAddress,
            partA: makePartA(),
            partB: makePartB(),
          ),
          (
            employeePan: 'BBBBB2222B',
            employeeName: 'Employee Two',
            employeeAddress: testAddress,
            partA: makePartA(),
            partB: makePartB(),
          ),
          (
            employeePan: 'CCCCC3333C',
            employeeName: 'Employee Three',
            employeeAddress: testAddress,
            partA: makePartA(),
            partB: makePartB(),
          ),
        ],
      );

      expect(results.length, 3);
      expect(
        results[0].certificateNumber,
        'MUMB12345A/2026-27/Form16/001',
      );
      expect(
        results[1].certificateNumber,
        'MUMB12345A/2026-27/Form16/002',
      );
      expect(
        results[2].certificateNumber,
        'MUMB12345A/2026-27/Form16/003',
      );
      expect(results[0].employeeName, 'Employee One');
      expect(results[2].employeeName, 'Employee Three');
    });

    test('empty employees list returns empty results', () {
      final results = Form16GenerationService.bulkGenerateForm16(
        employerTan: 'MUMB12345A',
        employerPan: 'ABCDE1234F',
        employerName: 'ABC Corp',
        employerAddress: testAddress,
        assessmentYear: '2026-27',
        periodFrom: DateTime(2025, 4, 1),
        periodTo: DateTime(2026, 3, 31),
        employees: const [],
      );
      expect(results, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // bulkGenerateForm16A
  // ---------------------------------------------------------------------------

  group('Form16GenerationService.bulkGenerateForm16A →', () {
    test('generates N forms with sequential certificate numbers', () {
      final results = Form16GenerationService.bulkGenerateForm16A(
        deductorTan: 'DELH67890B',
        deductorPan: 'ABCDE1234F',
        deductorName: 'XYZ Services',
        deductorAddress: testAddress,
        assessmentYear: '2026-27',
        quarter: TdsQuarter.q1,
        section: '194J',
        deductees: [
          (
            deducteePan: 'AAAAA1111A',
            deducteeName: 'Deductee One',
            deducteeAddress: testAddress,
            transactions: [makeTransaction()],
          ),
          (
            deducteePan: 'BBBBB2222B',
            deducteeName: 'Deductee Two',
            deducteeAddress: testAddress,
            transactions: [makeTransaction(), makeTransaction()],
          ),
        ],
      );

      expect(results.length, 2);
      expect(
        results[0].certificateNumber,
        'DELH67890B/2026-27/Form16A/001',
      );
      expect(
        results[1].certificateNumber,
        'DELH67890B/2026-27/Form16A/002',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // validateForm16
  // ---------------------------------------------------------------------------

  group('Form16GenerationService.validateForm16 →', () {
    Form16Data makeValidForm16() {
      return Form16GenerationService.generateForm16(
        certificateNumber: 'CERT001',
        employerTan: 'MUMB12345A',
        employerPan: 'ABCDE1234F',
        employerName: 'ABC Corp',
        employerAddress: testAddress,
        employeePan: 'XYZAB5678C',
        employeeName: 'Rajesh Kumar',
        employeeAddress: testAddress,
        assessmentYear: '2026-27',
        periodFrom: DateTime(2025, 4, 1),
        periodTo: DateTime(2026, 3, 31),
        partA: makePartA(),
        partB: makePartB(),
      );
    }

    test('valid data returns empty errors', () {
      final errors = Form16GenerationService.validateForm16(makeValidForm16());
      expect(errors, isEmpty);
    });

    test('invalid TAN format returns error', () {
      final form = makeValidForm16().copyWith(employerTan: 'INVALID');
      final errors = Form16GenerationService.validateForm16(form);
      expect(errors, contains(contains('TAN')));
    });

    test('invalid employer PAN format returns error', () {
      final form = makeValidForm16().copyWith(employerPan: '12345');
      final errors = Form16GenerationService.validateForm16(form);
      expect(errors, contains(contains('employer PAN')));
    });

    test('invalid employee PAN format returns error', () {
      final form = makeValidForm16().copyWith(employeePan: 'BAD');
      final errors = Form16GenerationService.validateForm16(form);
      expect(errors, contains(contains('employee PAN')));
    });

    test('period from after period to returns error', () {
      final form = makeValidForm16().copyWith(
        periodFrom: DateTime(2026, 4, 1),
        periodTo: DateTime(2025, 3, 31),
      );
      final errors = Form16GenerationService.validateForm16(form);
      expect(errors, contains(contains('period')));
    });

    test('no quarter details returns error', () {
      final form = makeValidForm16().copyWith(
        partA: const Form16PartA(quarterlyDetails: []),
      );
      final errors = Form16GenerationService.validateForm16(form);
      expect(errors, contains(contains('quarter')));
    });

    test('invalid assessment year format returns error', () {
      final form = makeValidForm16().copyWith(assessmentYear: '2026');
      final errors = Form16GenerationService.validateForm16(form);
      expect(errors, contains(contains('assessment year')));
    });
  });

  // ---------------------------------------------------------------------------
  // validateForm16A
  // ---------------------------------------------------------------------------

  group('Form16GenerationService.validateForm16A →', () {
    Form16AData makeValidForm16A() {
      return Form16GenerationService.generateForm16A(
        certificateNumber: 'CERT16A-001',
        deductorTan: 'DELH67890B',
        deductorPan: 'ABCDE1234F',
        deductorName: 'XYZ Services',
        deductorAddress: testAddress,
        deducteePan: 'PQRST9876Z',
        deducteeName: 'Amit Verma',
        deducteeAddress: testAddress,
        assessmentYear: '2026-27',
        quarter: TdsQuarter.q1,
        section: '194J',
        transactions: [makeTransaction()],
      );
    }

    test('valid data returns empty errors', () {
      final errors =
          Form16GenerationService.validateForm16A(makeValidForm16A());
      expect(errors, isEmpty);
    });

    test('no transactions returns error', () {
      final form = makeValidForm16A().copyWith(transactions: const []);
      final errors = Form16GenerationService.validateForm16A(form);
      expect(errors, contains(contains('transaction')));
    });

    test('empty section returns error', () {
      final form = makeValidForm16A().copyWith(section: '');
      final errors = Form16GenerationService.validateForm16A(form);
      expect(errors, contains(contains('section')));
    });

    test('invalid TAN returns error', () {
      final form = makeValidForm16A().copyWith(deductorTan: 'BAD');
      final errors = Form16GenerationService.validateForm16A(form);
      expect(errors, contains(contains('TAN')));
    });

    test('invalid deductee PAN returns error', () {
      final form = makeValidForm16A().copyWith(deducteePan: 'X');
      final errors = Form16GenerationService.validateForm16A(form);
      expect(errors, contains(contains('deductee PAN')));
    });
  });

  // ---------------------------------------------------------------------------
  // computePartBTotals
  // ---------------------------------------------------------------------------

  group('Form16GenerationService.computePartBTotals →', () {
    test('recalculates grossTotalIncome correctly', () {
      final partB = Form16PartB(
        salaryBreakup: makeSalaryBreakup(),
        incomeFromHouseProperty: -200000,
        incomeFromOtherSources: 50000,
        deductions: ChapterVIADeductions.zero(),
        taxComputation: const TaxComputation(
          totalTaxableIncome: 0,
          taxOnTotalIncome: 0,
          rebate87A: 0,
          surcharge: 0,
          educationCess: 0,
          totalTaxPayable: 0,
          reliefSection89: 0,
          netTaxPayable: 0,
          taxRegime: 'old',
        ),
      );

      final result = Form16GenerationService.computePartBTotals(partB);

      // incomeFromSalary = 1200000 - 50000 - 75000 - 0 - 2500 = 1072500
      // gross = 1072500 + (-200000) + 50000 = 922500
      expect(result.grossTotalIncome, 922500);
    });
  });
}
