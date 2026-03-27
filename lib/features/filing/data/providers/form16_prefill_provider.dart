import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/filing/domain/models/itr1/chapter_via_deductions.dart';
import 'package:ca_app/features/filing/domain/models/itr1/house_property_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/itr1/other_source_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/salary_income.dart';
import 'package:ca_app/features/filing/domain/models/itr1/tds_payment_summary.dart';
import 'package:ca_app/features/ocr/domain/models/extracted_form16.dart';
import 'package:ca_app/features/ocr/domain/services/ocr_data_mapper_service.dart';
import 'package:ca_app/features/tds/domain/models/form16_data.dart';
import 'package:ca_app/features/tds/domain/models/tds_return_form.dart';

// ---------------------------------------------------------------------------
// Form16PrefillResult — immutable result of mapping Form 16 to ITR-1 data
// ---------------------------------------------------------------------------

/// Immutable result of pre-filling ITR-1 fields from a Form 16 source.
///
/// Maps salary, deductions, house property, other sources, TDS, and regime.
@immutable
class Form16PrefillResult {
  const Form16PrefillResult({
    required this.salaryIncome,
    required this.source,
    required this.tdsDeducted,
    this.deductions,
    this.housePropertyIncome,
    this.otherSourceIncome,
    this.tdsPaymentSummary,
    this.selectedRegime,
  });

  /// Pre-filled salary income model ready to apply to the ITR-1 form.
  final SalaryIncome salaryIncome;

  /// Human-readable description of the data source (e.g. employer name).
  final String source;

  /// Total TDS deducted as reported on the Form 16 (in rupees, not paise).
  final double tdsDeducted;

  /// Chapter VI-A deductions extracted from Form 16 Part B (if available).
  final ChapterViaDeductions? deductions;

  /// House property income from Form 16 Part B (if available).
  final HousePropertyIncome? housePropertyIncome;

  /// Other source income from Form 16 Part B (if available).
  final OtherSourceIncome? otherSourceIncome;

  /// TDS payment summary pre-populated from Form 16 Part A.
  final TdsPaymentSummary? tdsPaymentSummary;

  /// Tax regime indicated in Form 16 (if available).
  final TaxRegime? selectedRegime;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Form16PrefillResult &&
          runtimeType == other.runtimeType &&
          salaryIncome == other.salaryIncome &&
          source == other.source &&
          tdsDeducted == other.tdsDeducted;

  @override
  int get hashCode => Object.hash(salaryIncome, source, tdsDeducted);

  @override
  String toString() =>
      'Form16PrefillResult(source: $source, tds: $tdsDeducted)';
}

// ---------------------------------------------------------------------------
// Prefill from OCR ExtractedForm16
// ---------------------------------------------------------------------------

/// Maps an [ExtractedForm16] (OCR output) to a [Form16PrefillResult].
///
/// [ExtractedForm16] stores amounts in **paise** (int). [SalaryIncome] uses
/// **rupees** (double). This provider converts paise to rupees during mapping.
///
/// The OCR model only captures grossSalary and standardDeduction at a
/// summary level; perquisites and profits-in-lieu are not extracted by OCR
/// and default to zero. The user can fill them manually after prefill.
Form16PrefillResult prefillFromOcr(ExtractedForm16 form16) {
  final mapper = OcrDataMapperService.instance;
  final mapped = mapper.mapToItrIncome(form16);

  final grossSalaryPaise = mapped['grossSalary'] ?? 0;
  final standardDeductionPaise = mapped['standardDeduction'] ?? 0;
  final tdsDeductedPaise = mapped['tdsDeducted'] ?? 0;

  final salaryIncome = SalaryIncome(
    grossSalary: grossSalaryPaise / 100.0,
    allowancesExemptUnderSection10: 0,
    valueOfPerquisites: 0,
    profitsInLieuOfSalary: 0,
    standardDeduction: standardDeductionPaise / 100.0,
  );

  return Form16PrefillResult(
    salaryIncome: salaryIncome,
    source: '${form16.employerName} (OCR)',
    tdsDeducted: tdsDeductedPaise / 100.0,
  );
}

/// Riverpod family provider: given an [ExtractedForm16], returns the
/// pre-filled result. Use `ref.read(prefillFromOcrProvider(form16))`.
final prefillFromOcrProvider =
    Provider.family<Form16PrefillResult, ExtractedForm16>(
      (ref, form16) => prefillFromOcr(form16),
    );

// ---------------------------------------------------------------------------
// Prefill from existing Form16Data (TDS module)
// ---------------------------------------------------------------------------

/// Maps a [Form16Data] (from the TDS module) to a [Form16PrefillResult].
///
/// [Form16Data] stores amounts as **doubles in rupees**, so no unit
/// conversion is needed. The Part B provides detailed breakdowns that map
/// to salary, deductions, house property, other sources, TDS, and regime.
Form16PrefillResult prefillFromForm16Data(Form16Data form16) {
  final breakup = form16.partB.salaryBreakup;

  // Salary income mapping
  final salaryIncome = SalaryIncome(
    grossSalary: breakup.grossSalary,
    allowancesExemptUnderSection10: breakup.exemptAllowances,
    valueOfPerquisites: breakup.valueOfPerquisites17_2,
    profitsInLieuOfSalary: breakup.profitsInLieuOfSalary17_3,
    standardDeduction: breakup.standardDeduction,
  );

  // Chapter VI-A deductions mapping
  final f16Deductions = form16.partB.deductions;
  final deductions = ChapterViaDeductions(
    section80C:
        f16Deductions.section80C +
        f16Deductions.section80CCC +
        f16Deductions.section80CCD1,
    section80CCD1B: f16Deductions.section80CCD1B,
    section80DSelf: f16Deductions.section80D,
    section80DParents: 0, // Not available in Form 16
    section80E: f16Deductions.section80E,
    section80G: f16Deductions.section80G,
    section80TTA: f16Deductions.section80TTA,
    section80TTB: f16Deductions.section80TTB,
  );

  // House property income mapping (negative means loss)
  final hpIncome = form16.partB.incomeFromHouseProperty;
  final housePropertyIncome = hpIncome != 0
      ? HousePropertyIncome(
          annualLetableValue: hpIncome > 0 ? hpIncome : 0,
          municipalTaxesPaid: 0,
          interestOnLoan: hpIncome < 0 ? -hpIncome : 0,
          propertyType: hpIncome <= 0
              ? PropertyType.selfOccupied
              : PropertyType.letOut,
        )
      : null;

  // Other source income mapping
  final osIncome = form16.partB.incomeFromOtherSources;
  final otherSourceIncome = osIncome != 0
      ? OtherSourceIncome(
          savingsAccountInterest: 0,
          fixedDepositInterest: 0,
          dividendIncome: 0,
          familyPension: 0,
          otherIncome: osIncome,
        )
      : null;

  // TDS payment summary from Part A
  final tdsPaymentSummary = TdsPaymentSummary(
    tdsOnSalary: form16.partA.totalTaxDeducted,
    tdsOnOtherIncome: 0,
    advanceTaxQ1: 0,
    advanceTaxQ2: 0,
    advanceTaxQ3: 0,
    advanceTaxQ4: 0,
    selfAssessmentTax: 0,
  );

  // Tax regime from Form 16 computation
  final regimeStr = form16.partB.taxComputation.taxRegime.toLowerCase();
  final selectedRegime = regimeStr.contains('old')
      ? TaxRegime.oldRegime
      : TaxRegime.newRegime;

  return Form16PrefillResult(
    salaryIncome: salaryIncome,
    source: '${form16.employerName} (Form 16)',
    tdsDeducted: form16.partA.totalTaxDeducted,
    deductions: deductions,
    housePropertyIncome: housePropertyIncome,
    otherSourceIncome: otherSourceIncome,
    tdsPaymentSummary: tdsPaymentSummary,
    selectedRegime: selectedRegime,
  );
}

/// Riverpod family provider: given a [Form16Data], returns the pre-filled
/// result. Use `ref.read(prefillFromForm16DataProvider(form16Data))`.
final prefillFromForm16DataProvider =
    Provider.family<Form16PrefillResult, Form16Data>(
      (ref, form16) => prefillFromForm16Data(form16),
    );

// ---------------------------------------------------------------------------
// Mock Form 16 list provider (until real repository is wired)
// ---------------------------------------------------------------------------

final _mockForm16List = <Form16Data>[
  Form16Data(
    certificateNumber: 'CERT-2026-001',
    employerTan: 'MUMS12345A',
    employerPan: 'AABCT1234A',
    employerName: 'Tata Consultancy Services Ltd',
    employerAddress: const TdsAddress(
      line1: '9th Floor, Nirmal Building',
      line2: 'Nariman Point, Mumbai 400021',
      city: 'Mumbai',
      state: 'Maharashtra',
      pincode: '400021',
    ),
    employeePan: 'ABCPK1234F',
    employeeName: 'Ramesh Kumar',
    employeeAddress: const TdsAddress(
      line1: '12, MG Road',
      city: 'Mumbai',
      state: 'Maharashtra',
      pincode: '400001',
    ),
    assessmentYear: 'AY 2026-27',
    periodFrom: DateTime(2025, 4, 1),
    periodTo: DateTime(2026, 3, 31),
    partA: const Form16PartA(quarterlyDetails: []),
    partB: Form16PartB(
      salaryBreakup: const SalaryBreakup(
        grossSalary: 1800000,
        salaryAsPerSection17_1: 1600000,
        valueOfPerquisites17_2: 50000,
        profitsInLieuOfSalary17_3: 0,
        exemptAllowances: 150000,
        standardDeduction: 75000,
        entertainmentAllowance: 0,
        professionalTax: 2400,
      ),
      incomeFromHouseProperty: 0,
      incomeFromOtherSources: 45000,
      deductions: ChapterVIADeductions.zero(),
      taxComputation: const TaxComputation(
        totalTaxableIncome: 1622600,
        taxOnTotalIncome: 280000,
        rebate87A: 0,
        surcharge: 0,
        educationCess: 11200,
        totalTaxPayable: 291200,
        reliefSection89: 0,
        netTaxPayable: 291200,
        taxRegime: 'New',
      ),
    ),
  ),
  Form16Data(
    certificateNumber: 'CERT-2026-002',
    employerTan: 'BLRI98765B',
    employerPan: 'AABCI5678B',
    employerName: 'Infosys Ltd',
    employerAddress: const TdsAddress(
      line1: '44, Electronics City',
      line2: 'Hosur Road, Bengaluru 560100',
      city: 'Bengaluru',
      state: 'Karnataka',
      pincode: '560100',
    ),
    employeePan: 'BCDPS5678G',
    employeeName: 'Priya Sharma',
    employeeAddress: const TdsAddress(
      line1: '22, Koramangala',
      city: 'Bengaluru',
      state: 'Karnataka',
      pincode: '560034',
    ),
    assessmentYear: 'AY 2026-27',
    periodFrom: DateTime(2025, 4, 1),
    periodTo: DateTime(2026, 3, 31),
    partA: const Form16PartA(quarterlyDetails: []),
    partB: Form16PartB(
      salaryBreakup: const SalaryBreakup(
        grossSalary: 2400000,
        salaryAsPerSection17_1: 2100000,
        valueOfPerquisites17_2: 80000,
        profitsInLieuOfSalary17_3: 20000,
        exemptAllowances: 200000,
        standardDeduction: 75000,
        entertainmentAllowance: 0,
        professionalTax: 2400,
      ),
      incomeFromHouseProperty: -150000,
      incomeFromOtherSources: 120000,
      deductions: ChapterVIADeductions.zero(),
      taxComputation: const TaxComputation(
        totalTaxableIncome: 2192600,
        taxOnTotalIncome: 420000,
        rebate87A: 0,
        surcharge: 0,
        educationCess: 16800,
        totalTaxPayable: 436800,
        reliefSection89: 0,
        netTaxPayable: 436800,
        taxRegime: 'New',
      ),
    ),
  ),
];

/// Provider exposing the list of available Form 16 records for selection.
final form16ListProvider = Provider<List<Form16Data>>((ref) {
  return List.unmodifiable(_mockForm16List);
});
