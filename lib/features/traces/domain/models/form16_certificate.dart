/// Immutable Form 16 / Form 16A certificate downloaded from TRACES.
class Form16Certificate {
  const Form16Certificate({
    required this.employerTan,
    required this.employeePan,
    required this.financialYear,
    required this.grossSalary,
    required this.tdsDeducted,
    this.certificateNumber,
    this.quarter,
  });

  /// TAN of the deductor (employer / payer).
  final String employerTan;

  /// PAN of the deductee (employee / payee).
  final String employeePan;

  /// Financial year, e.g. 2024 for FY 2024-25.
  final int financialYear;

  /// Gross salary / payment amount in paise.
  final int grossSalary;

  /// Total TDS deducted in paise.
  final int tdsDeducted;

  /// TRACES certificate number (available after download completes).
  final String? certificateNumber;

  /// Quarter number (1-4), present for Form 16A; null for annual Form 16.
  final int? quarter;

  Form16Certificate copyWith({
    String? employerTan,
    String? employeePan,
    int? financialYear,
    int? grossSalary,
    int? tdsDeducted,
    String? certificateNumber,
    int? quarter,
  }) {
    return Form16Certificate(
      employerTan: employerTan ?? this.employerTan,
      employeePan: employeePan ?? this.employeePan,
      financialYear: financialYear ?? this.financialYear,
      grossSalary: grossSalary ?? this.grossSalary,
      tdsDeducted: tdsDeducted ?? this.tdsDeducted,
      certificateNumber: certificateNumber ?? this.certificateNumber,
      quarter: quarter ?? this.quarter,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Form16Certificate &&
          runtimeType == other.runtimeType &&
          employerTan == other.employerTan &&
          employeePan == other.employeePan &&
          financialYear == other.financialYear &&
          grossSalary == other.grossSalary &&
          tdsDeducted == other.tdsDeducted &&
          certificateNumber == other.certificateNumber &&
          quarter == other.quarter;

  @override
  int get hashCode => Object.hash(
        employerTan,
        employeePan,
        financialYear,
        grossSalary,
        tdsDeducted,
        certificateNumber,
        quarter,
      );
}

/// Immutable TDS certificate record (Form 16A) from TRACES.
class TdsCertificate {
  const TdsCertificate({
    required this.tan,
    required this.deducteePan,
    required this.section,
    required this.period,
    required this.amountPaid,
    required this.taxDeducted,
    this.certificateNumber,
  });

  /// TAN of the deductor.
  final String tan;

  /// PAN of the deductee.
  final String deducteePan;

  /// TDS section (e.g. "194C", "194J").
  final String section;

  /// Period string identifying the quarter / year (e.g. "Q1FY2024").
  final String period;

  /// Amount paid / credited in paise.
  final int amountPaid;

  /// Tax deducted in paise.
  final int taxDeducted;

  /// TRACES certificate number when download is complete.
  final String? certificateNumber;

  TdsCertificate copyWith({
    String? tan,
    String? deducteePan,
    String? section,
    String? period,
    int? amountPaid,
    int? taxDeducted,
    String? certificateNumber,
  }) {
    return TdsCertificate(
      tan: tan ?? this.tan,
      deducteePan: deducteePan ?? this.deducteePan,
      section: section ?? this.section,
      period: period ?? this.period,
      amountPaid: amountPaid ?? this.amountPaid,
      taxDeducted: taxDeducted ?? this.taxDeducted,
      certificateNumber: certificateNumber ?? this.certificateNumber,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TdsCertificate &&
          runtimeType == other.runtimeType &&
          tan == other.tan &&
          deducteePan == other.deducteePan &&
          section == other.section &&
          period == other.period &&
          amountPaid == other.amountPaid &&
          taxDeducted == other.taxDeducted &&
          certificateNumber == other.certificateNumber;

  @override
  int get hashCode => Object.hash(
        tan,
        deducteePan,
        section,
        period,
        amountPaid,
        taxDeducted,
        certificateNumber,
      );
}
