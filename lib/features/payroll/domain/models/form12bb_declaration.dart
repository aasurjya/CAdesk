/// Immutable Form 12BB investment/expenditure declaration model.
///
/// All monetary amounts are stored in paise (1/100th of a rupee)
/// to avoid floating-point rounding errors.
class Form12bbDeclaration {
  const Form12bbDeclaration({
    required this.declarationId,
    required this.employeeId,
    required this.financialYear,
    this.annualRentPaid = 0,
    this.landlordName,
    this.landlordPan,
    this.landlordAddress,
    this.ltaClaimedAmount = 0,
    this.section80C = 0,
    this.section80CCD1B = 0,
    this.section80D = 0,
    this.section80E = 0,
    this.section80G = 0,
    this.section80TTA = 0,
    this.homeLoanInterest = 0,
    this.lenderName,
    this.lenderPan,
    required this.submittedAt,
    this.isVerified = false,
  });

  final String declarationId;
  final String employeeId;

  /// Financial year start, e.g. 2025 means FY 2025-26.
  final int financialYear;

  // --- HRA Exemption ---

  /// Annual rent paid in paise.
  final int annualRentPaid;
  final String? landlordName;

  /// Required if [annualRentPaid] > 10_000_000 paise (Rs 1,00,000).
  final String? landlordPan;
  final String? landlordAddress;

  // --- LTA ---

  /// Leave Travel Allowance claimed in paise.
  final int ltaClaimedAmount;

  // --- Chapter VI-A Deductions ---

  /// Section 80C in paise. Max 15_000_000 (Rs 1,50,000).
  final int section80C;

  /// Section 80CCD(1B) NPS in paise. Max 5_000_000 (Rs 50,000).
  final int section80CCD1B;

  /// Section 80D health insurance in paise.
  final int section80D;

  /// Section 80E education loan interest in paise (no limit).
  final int section80E;

  /// Section 80G donations in paise.
  final int section80G;

  /// Section 80TTA savings interest in paise. Max 1_000_000 (Rs 10,000).
  final int section80TTA;

  // --- Home Loan Interest ---

  /// Section 24(b) home loan interest in paise. Max 20_000_000 (Rs 2,00,000).
  final int homeLoanInterest;
  final String? lenderName;
  final String? lenderPan;

  final DateTime submittedAt;
  final bool isVerified;

  // --- Computed ---

  /// Total of all declared deduction amounts in paise.
  int get totalDeductions =>
      annualRentPaid +
      ltaClaimedAmount +
      section80C +
      section80CCD1B +
      section80D +
      section80E +
      section80G +
      section80TTA +
      homeLoanInterest;

  /// Chapter VI-A subtotal in paise.
  int get chapterVIATotal =>
      section80C +
      section80CCD1B +
      section80D +
      section80E +
      section80G +
      section80TTA;

  /// Whether landlord PAN is required (rent > Rs 1,00,000/year).
  bool get isLandlordPanRequired => annualRentPaid > 10000000;

  Form12bbDeclaration copyWith({
    String? declarationId,
    String? employeeId,
    int? financialYear,
    int? annualRentPaid,
    String? landlordName,
    String? landlordPan,
    String? landlordAddress,
    int? ltaClaimedAmount,
    int? section80C,
    int? section80CCD1B,
    int? section80D,
    int? section80E,
    int? section80G,
    int? section80TTA,
    int? homeLoanInterest,
    String? lenderName,
    String? lenderPan,
    DateTime? submittedAt,
    bool? isVerified,
  }) {
    return Form12bbDeclaration(
      declarationId: declarationId ?? this.declarationId,
      employeeId: employeeId ?? this.employeeId,
      financialYear: financialYear ?? this.financialYear,
      annualRentPaid: annualRentPaid ?? this.annualRentPaid,
      landlordName: landlordName ?? this.landlordName,
      landlordPan: landlordPan ?? this.landlordPan,
      landlordAddress: landlordAddress ?? this.landlordAddress,
      ltaClaimedAmount: ltaClaimedAmount ?? this.ltaClaimedAmount,
      section80C: section80C ?? this.section80C,
      section80CCD1B: section80CCD1B ?? this.section80CCD1B,
      section80D: section80D ?? this.section80D,
      section80E: section80E ?? this.section80E,
      section80G: section80G ?? this.section80G,
      section80TTA: section80TTA ?? this.section80TTA,
      homeLoanInterest: homeLoanInterest ?? this.homeLoanInterest,
      lenderName: lenderName ?? this.lenderName,
      lenderPan: lenderPan ?? this.lenderPan,
      submittedAt: submittedAt ?? this.submittedAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Form12bbDeclaration &&
        other.declarationId == declarationId &&
        other.employeeId == employeeId &&
        other.financialYear == financialYear &&
        other.annualRentPaid == annualRentPaid &&
        other.landlordName == landlordName &&
        other.landlordPan == landlordPan &&
        other.landlordAddress == landlordAddress &&
        other.ltaClaimedAmount == ltaClaimedAmount &&
        other.section80C == section80C &&
        other.section80CCD1B == section80CCD1B &&
        other.section80D == section80D &&
        other.section80E == section80E &&
        other.section80G == section80G &&
        other.section80TTA == section80TTA &&
        other.homeLoanInterest == homeLoanInterest &&
        other.lenderName == lenderName &&
        other.lenderPan == lenderPan &&
        other.submittedAt == submittedAt &&
        other.isVerified == isVerified;
  }

  @override
  int get hashCode => Object.hash(
        declarationId,
        employeeId,
        financialYear,
        annualRentPaid,
        landlordName,
        landlordPan,
        landlordAddress,
        ltaClaimedAmount,
        section80C,
        section80CCD1B,
        section80D,
        section80E,
        section80G,
        section80TTA,
        homeLoanInterest,
        lenderName,
        lenderPan,
        Object.hash(submittedAt, isVerified),
      );

  @override
  String toString() =>
      'Form12bbDeclaration(id: $declarationId, employee: $employeeId, '
      'fy: $financialYear, total: $totalDeductions paise)';
}
