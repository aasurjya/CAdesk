import 'package:ca_app/features/tds/domain/models/tds_return.dart';
import 'package:ca_app/features/tds/domain/models/tds_return_form.dart';
import 'package:flutter/foundation.dart';

/// Quarterly TDS summary detail within Form 16 Part A.
@immutable
class Form16QuarterDetail {
  const Form16QuarterDetail({
    required this.quarter,
    required this.receiptNumbers,
    required this.taxDeducted,
    required this.taxDeposited,
    this.dateOfDeposit,
    this.bsrCode,
    this.challanSerialNumber,
    required this.status,
  });

  final TdsQuarter quarter;
  final List<String> receiptNumbers;
  final double taxDeducted;
  final double taxDeposited;
  final DateTime? dateOfDeposit;
  final String? bsrCode;
  final String? challanSerialNumber;
  final String status;

  Form16QuarterDetail copyWith({
    TdsQuarter? quarter,
    List<String>? receiptNumbers,
    double? taxDeducted,
    double? taxDeposited,
    DateTime? dateOfDeposit,
    String? bsrCode,
    String? challanSerialNumber,
    String? status,
  }) {
    return Form16QuarterDetail(
      quarter: quarter ?? this.quarter,
      receiptNumbers: receiptNumbers ?? this.receiptNumbers,
      taxDeducted: taxDeducted ?? this.taxDeducted,
      taxDeposited: taxDeposited ?? this.taxDeposited,
      dateOfDeposit: dateOfDeposit ?? this.dateOfDeposit,
      bsrCode: bsrCode ?? this.bsrCode,
      challanSerialNumber: challanSerialNumber ?? this.challanSerialNumber,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Form16QuarterDetail &&
          runtimeType == other.runtimeType &&
          quarter == other.quarter &&
          _listEquals(receiptNumbers, other.receiptNumbers) &&
          taxDeducted == other.taxDeducted &&
          taxDeposited == other.taxDeposited &&
          dateOfDeposit == other.dateOfDeposit &&
          bsrCode == other.bsrCode &&
          challanSerialNumber == other.challanSerialNumber &&
          status == other.status;

  @override
  int get hashCode => Object.hash(
    quarter,
    Object.hashAll(receiptNumbers),
    taxDeducted,
    taxDeposited,
    dateOfDeposit,
    bsrCode,
    challanSerialNumber,
    status,
  );

  @override
  String toString() =>
      'Form16QuarterDetail(quarter: ${quarter.label}, '
      'deducted: $taxDeducted, deposited: $taxDeposited)';
}

/// Form 16 Part A — Quarterly TDS summary from TRACES.
@immutable
class Form16PartA {
  const Form16PartA({required this.quarterlyDetails});

  final List<Form16QuarterDetail> quarterlyDetails;

  double get totalTaxDeducted =>
      quarterlyDetails.fold(0.0, (sum, q) => sum + q.taxDeducted);

  double get totalTaxDeposited =>
      quarterlyDetails.fold(0.0, (sum, q) => sum + q.taxDeposited);

  Form16PartA copyWith({List<Form16QuarterDetail>? quarterlyDetails}) {
    return Form16PartA(
      quarterlyDetails: quarterlyDetails ?? this.quarterlyDetails,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Form16PartA &&
          runtimeType == other.runtimeType &&
          listEquals(quarterlyDetails, other.quarterlyDetails);

  @override
  int get hashCode => Object.hashAll(quarterlyDetails);

  @override
  String toString() =>
      'Form16PartA(quarters: ${quarterlyDetails.length}, '
      'deducted: $totalTaxDeducted)';
}

/// Salary breakdown within Form 16 Part B.
@immutable
class SalaryBreakup {
  const SalaryBreakup({
    required this.grossSalary,
    required this.salaryAsPerSection17_1,
    required this.valueOfPerquisites17_2,
    required this.profitsInLieuOfSalary17_3,
    required this.exemptAllowances,
    required this.standardDeduction,
    required this.entertainmentAllowance,
    required this.professionalTax,
  });

  final double grossSalary;
  final double salaryAsPerSection17_1;
  final double valueOfPerquisites17_2;
  final double profitsInLieuOfSalary17_3;
  final double exemptAllowances;
  final double standardDeduction;
  final double entertainmentAllowance;
  final double professionalTax;

  double get netSalary => grossSalary - exemptAllowances;

  double get incomeFromSalary =>
      netSalary - standardDeduction - entertainmentAllowance - professionalTax;

  SalaryBreakup copyWith({
    double? grossSalary,
    double? salaryAsPerSection17_1,
    double? valueOfPerquisites17_2,
    double? profitsInLieuOfSalary17_3,
    double? exemptAllowances,
    double? standardDeduction,
    double? entertainmentAllowance,
    double? professionalTax,
  }) {
    return SalaryBreakup(
      grossSalary: grossSalary ?? this.grossSalary,
      salaryAsPerSection17_1:
          salaryAsPerSection17_1 ?? this.salaryAsPerSection17_1,
      valueOfPerquisites17_2:
          valueOfPerquisites17_2 ?? this.valueOfPerquisites17_2,
      profitsInLieuOfSalary17_3:
          profitsInLieuOfSalary17_3 ?? this.profitsInLieuOfSalary17_3,
      exemptAllowances: exemptAllowances ?? this.exemptAllowances,
      standardDeduction: standardDeduction ?? this.standardDeduction,
      entertainmentAllowance:
          entertainmentAllowance ?? this.entertainmentAllowance,
      professionalTax: professionalTax ?? this.professionalTax,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalaryBreakup &&
          runtimeType == other.runtimeType &&
          grossSalary == other.grossSalary &&
          salaryAsPerSection17_1 == other.salaryAsPerSection17_1 &&
          valueOfPerquisites17_2 == other.valueOfPerquisites17_2 &&
          profitsInLieuOfSalary17_3 == other.profitsInLieuOfSalary17_3 &&
          exemptAllowances == other.exemptAllowances &&
          standardDeduction == other.standardDeduction &&
          entertainmentAllowance == other.entertainmentAllowance &&
          professionalTax == other.professionalTax;

  @override
  int get hashCode => Object.hash(
    grossSalary,
    salaryAsPerSection17_1,
    valueOfPerquisites17_2,
    profitsInLieuOfSalary17_3,
    exemptAllowances,
    standardDeduction,
    entertainmentAllowance,
    professionalTax,
  );

  @override
  String toString() =>
      'SalaryBreakup(gross: $grossSalary, net: $netSalary, '
      'income: $incomeFromSalary)';
}

/// Chapter VI-A deductions within Form 16 Part B.
@immutable
class ChapterVIADeductions {
  const ChapterVIADeductions({
    required this.section80C,
    required this.section80CCC,
    required this.section80CCD1,
    required this.section80CCD1B,
    required this.section80CCD2,
    required this.section80D,
    required this.section80DD,
    required this.section80DDB,
    required this.section80E,
    required this.section80EE,
    required this.section80EEA,
    required this.section80G,
    required this.section80GG,
    required this.section80GGA,
    required this.section80GGC,
    required this.section80TTA,
    required this.section80TTB,
    required this.section80U,
  });

  /// Factory that creates a [ChapterVIADeductions] with all sections at zero.
  factory ChapterVIADeductions.zero() {
    return const ChapterVIADeductions(
      section80C: 0,
      section80CCC: 0,
      section80CCD1: 0,
      section80CCD1B: 0,
      section80CCD2: 0,
      section80D: 0,
      section80DD: 0,
      section80DDB: 0,
      section80E: 0,
      section80EE: 0,
      section80EEA: 0,
      section80G: 0,
      section80GG: 0,
      section80GGA: 0,
      section80GGC: 0,
      section80TTA: 0,
      section80TTB: 0,
      section80U: 0,
    );
  }

  final double section80C;
  final double section80CCC;
  final double section80CCD1;
  final double section80CCD1B;
  final double section80CCD2;
  final double section80D;
  final double section80DD;
  final double section80DDB;
  final double section80E;
  final double section80EE;
  final double section80EEA;
  final double section80G;
  final double section80GG;
  final double section80GGA;
  final double section80GGC;
  final double section80TTA;
  final double section80TTB;
  final double section80U;

  double get total =>
      section80C +
      section80CCC +
      section80CCD1 +
      section80CCD1B +
      section80CCD2 +
      section80D +
      section80DD +
      section80DDB +
      section80E +
      section80EE +
      section80EEA +
      section80G +
      section80GG +
      section80GGA +
      section80GGC +
      section80TTA +
      section80TTB +
      section80U;

  ChapterVIADeductions copyWith({
    double? section80C,
    double? section80CCC,
    double? section80CCD1,
    double? section80CCD1B,
    double? section80CCD2,
    double? section80D,
    double? section80DD,
    double? section80DDB,
    double? section80E,
    double? section80EE,
    double? section80EEA,
    double? section80G,
    double? section80GG,
    double? section80GGA,
    double? section80GGC,
    double? section80TTA,
    double? section80TTB,
    double? section80U,
  }) {
    return ChapterVIADeductions(
      section80C: section80C ?? this.section80C,
      section80CCC: section80CCC ?? this.section80CCC,
      section80CCD1: section80CCD1 ?? this.section80CCD1,
      section80CCD1B: section80CCD1B ?? this.section80CCD1B,
      section80CCD2: section80CCD2 ?? this.section80CCD2,
      section80D: section80D ?? this.section80D,
      section80DD: section80DD ?? this.section80DD,
      section80DDB: section80DDB ?? this.section80DDB,
      section80E: section80E ?? this.section80E,
      section80EE: section80EE ?? this.section80EE,
      section80EEA: section80EEA ?? this.section80EEA,
      section80G: section80G ?? this.section80G,
      section80GG: section80GG ?? this.section80GG,
      section80GGA: section80GGA ?? this.section80GGA,
      section80GGC: section80GGC ?? this.section80GGC,
      section80TTA: section80TTA ?? this.section80TTA,
      section80TTB: section80TTB ?? this.section80TTB,
      section80U: section80U ?? this.section80U,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChapterVIADeductions &&
          runtimeType == other.runtimeType &&
          section80C == other.section80C &&
          section80CCC == other.section80CCC &&
          section80CCD1 == other.section80CCD1 &&
          section80CCD1B == other.section80CCD1B &&
          section80CCD2 == other.section80CCD2 &&
          section80D == other.section80D &&
          section80DD == other.section80DD &&
          section80DDB == other.section80DDB &&
          section80E == other.section80E &&
          section80EE == other.section80EE &&
          section80EEA == other.section80EEA &&
          section80G == other.section80G &&
          section80GG == other.section80GG &&
          section80GGA == other.section80GGA &&
          section80GGC == other.section80GGC &&
          section80TTA == other.section80TTA &&
          section80TTB == other.section80TTB &&
          section80U == other.section80U;

  @override
  int get hashCode => Object.hash(
    Object.hash(
      section80C,
      section80CCC,
      section80CCD1,
      section80CCD1B,
      section80CCD2,
      section80D,
      section80DD,
      section80DDB,
      section80E,
      section80EE,
    ),
    Object.hash(
      section80EEA,
      section80G,
      section80GG,
      section80GGA,
      section80GGC,
      section80TTA,
      section80TTB,
      section80U,
    ),
  );

  @override
  String toString() => 'ChapterVIADeductions(total: $total)';
}

/// Tax computation within Form 16 Part B.
@immutable
class TaxComputation {
  const TaxComputation({
    required this.totalTaxableIncome,
    required this.taxOnTotalIncome,
    required this.rebate87A,
    required this.surcharge,
    required this.educationCess,
    required this.totalTaxPayable,
    required this.reliefSection89,
    required this.netTaxPayable,
    required this.taxRegime,
  });

  final double totalTaxableIncome;
  final double taxOnTotalIncome;
  final double rebate87A;
  final double surcharge;
  final double educationCess;
  final double totalTaxPayable;
  final double reliefSection89;
  final double netTaxPayable;
  final String taxRegime;

  TaxComputation copyWith({
    double? totalTaxableIncome,
    double? taxOnTotalIncome,
    double? rebate87A,
    double? surcharge,
    double? educationCess,
    double? totalTaxPayable,
    double? reliefSection89,
    double? netTaxPayable,
    String? taxRegime,
  }) {
    return TaxComputation(
      totalTaxableIncome: totalTaxableIncome ?? this.totalTaxableIncome,
      taxOnTotalIncome: taxOnTotalIncome ?? this.taxOnTotalIncome,
      rebate87A: rebate87A ?? this.rebate87A,
      surcharge: surcharge ?? this.surcharge,
      educationCess: educationCess ?? this.educationCess,
      totalTaxPayable: totalTaxPayable ?? this.totalTaxPayable,
      reliefSection89: reliefSection89 ?? this.reliefSection89,
      netTaxPayable: netTaxPayable ?? this.netTaxPayable,
      taxRegime: taxRegime ?? this.taxRegime,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaxComputation &&
          runtimeType == other.runtimeType &&
          totalTaxableIncome == other.totalTaxableIncome &&
          taxOnTotalIncome == other.taxOnTotalIncome &&
          rebate87A == other.rebate87A &&
          surcharge == other.surcharge &&
          educationCess == other.educationCess &&
          totalTaxPayable == other.totalTaxPayable &&
          reliefSection89 == other.reliefSection89 &&
          netTaxPayable == other.netTaxPayable &&
          taxRegime == other.taxRegime;

  @override
  int get hashCode => Object.hash(
    totalTaxableIncome,
    taxOnTotalIncome,
    rebate87A,
    surcharge,
    educationCess,
    totalTaxPayable,
    reliefSection89,
    netTaxPayable,
    taxRegime,
  );

  @override
  String toString() =>
      'TaxComputation(taxable: $totalTaxableIncome, '
      'net: $netTaxPayable, regime: $taxRegime)';
}

/// Form 16 Part B — Salary, deductions, and tax computation.
@immutable
class Form16PartB {
  const Form16PartB({
    required this.salaryBreakup,
    required this.incomeFromHouseProperty,
    required this.incomeFromOtherSources,
    required this.deductions,
    required this.taxComputation,
  });

  final SalaryBreakup salaryBreakup;
  final double incomeFromHouseProperty;
  final double incomeFromOtherSources;
  final ChapterVIADeductions deductions;
  final TaxComputation taxComputation;

  double get grossTotalIncome =>
      salaryBreakup.incomeFromSalary +
      incomeFromHouseProperty +
      incomeFromOtherSources;

  Form16PartB copyWith({
    SalaryBreakup? salaryBreakup,
    double? incomeFromHouseProperty,
    double? incomeFromOtherSources,
    ChapterVIADeductions? deductions,
    TaxComputation? taxComputation,
  }) {
    return Form16PartB(
      salaryBreakup: salaryBreakup ?? this.salaryBreakup,
      incomeFromHouseProperty:
          incomeFromHouseProperty ?? this.incomeFromHouseProperty,
      incomeFromOtherSources:
          incomeFromOtherSources ?? this.incomeFromOtherSources,
      deductions: deductions ?? this.deductions,
      taxComputation: taxComputation ?? this.taxComputation,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Form16PartB &&
          runtimeType == other.runtimeType &&
          salaryBreakup == other.salaryBreakup &&
          incomeFromHouseProperty == other.incomeFromHouseProperty &&
          incomeFromOtherSources == other.incomeFromOtherSources &&
          deductions == other.deductions &&
          taxComputation == other.taxComputation;

  @override
  int get hashCode => Object.hash(
    salaryBreakup,
    incomeFromHouseProperty,
    incomeFromOtherSources,
    deductions,
    taxComputation,
  );

  @override
  String toString() =>
      'Form16PartB(grossTotal: $grossTotalIncome, '
      'deductions: ${deductions.total})';
}

/// Complete Form 16 — TDS certificate for salary income.
@immutable
class Form16Data {
  const Form16Data({
    required this.certificateNumber,
    required this.employerTan,
    required this.employerPan,
    required this.employerName,
    required this.employerAddress,
    required this.employeePan,
    required this.employeeName,
    required this.employeeAddress,
    required this.assessmentYear,
    required this.periodFrom,
    required this.periodTo,
    required this.partA,
    required this.partB,
  });

  final String certificateNumber;
  final String employerTan;
  final String employerPan;
  final String employerName;
  final TdsAddress employerAddress;
  final String employeePan;
  final String employeeName;
  final TdsAddress employeeAddress;
  final String assessmentYear;
  final DateTime periodFrom;
  final DateTime periodTo;
  final Form16PartA partA;
  final Form16PartB partB;

  Form16Data copyWith({
    String? certificateNumber,
    String? employerTan,
    String? employerPan,
    String? employerName,
    TdsAddress? employerAddress,
    String? employeePan,
    String? employeeName,
    TdsAddress? employeeAddress,
    String? assessmentYear,
    DateTime? periodFrom,
    DateTime? periodTo,
    Form16PartA? partA,
    Form16PartB? partB,
  }) {
    return Form16Data(
      certificateNumber: certificateNumber ?? this.certificateNumber,
      employerTan: employerTan ?? this.employerTan,
      employerPan: employerPan ?? this.employerPan,
      employerName: employerName ?? this.employerName,
      employerAddress: employerAddress ?? this.employerAddress,
      employeePan: employeePan ?? this.employeePan,
      employeeName: employeeName ?? this.employeeName,
      employeeAddress: employeeAddress ?? this.employeeAddress,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      periodFrom: periodFrom ?? this.periodFrom,
      periodTo: periodTo ?? this.periodTo,
      partA: partA ?? this.partA,
      partB: partB ?? this.partB,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Form16Data &&
          runtimeType == other.runtimeType &&
          certificateNumber == other.certificateNumber;

  @override
  int get hashCode => certificateNumber.hashCode;

  @override
  String toString() =>
      'Form16Data(cert: $certificateNumber, '
      'employer: $employerName, employee: $employeeName)';
}

// Private helper for list equality comparison.
bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
