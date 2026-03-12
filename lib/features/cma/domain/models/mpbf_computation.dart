/// MPBF computation method as per the Tandon Committee recommendations.
///
/// Indian banks must select the method based on borrower category and
/// exposure size.
enum MpbfMethod {
  /// Method 1: Bank finances 75% of the Working Capital Gap.
  /// WCG = Total CA - CL (excl. bank borrowings).
  method1,

  /// Method 2: Bank finances 75% of CA minus CL (excl. bank borrowings).
  /// Requires the borrower to bring at least 25% of CA as NWC from
  /// long-term sources.
  method2,

  /// Turnover Method (Nayak Committee): MPBF = 20% of projected annual sales.
  /// Applicable for borrowers with fund-based working capital limits
  /// up to ₹5 crore.
  method3TurnoverMethod,
}

/// Immutable result of an MPBF (Maximum Permissible Bank Finance) computation.
///
/// Holds inputs, intermediate values, and final assessed limit.
/// All monetary values are in **paise** (1/100 rupee).
class MpbfComputation {
  const MpbfComputation({
    required this.method,
    required this.totalCurrentAssets,
    required this.currentLiabilitiesExcludingBankBorrowings,
    required this.workingCapitalGap,
    required this.nwcFromLongTermSources,
    required this.method1Mpbf,
    required this.method2Mpbf,
    required this.assessedLimit,
    required this.drawingPower,
    required this.actualSanctioned,
  });

  factory MpbfComputation.empty() => const MpbfComputation(
    method: MpbfMethod.method2,
    totalCurrentAssets: 0,
    currentLiabilitiesExcludingBankBorrowings: 0,
    workingCapitalGap: 0,
    nwcFromLongTermSources: 0,
    method1Mpbf: 0,
    method2Mpbf: 0,
    assessedLimit: 0,
    drawingPower: 0,
    actualSanctioned: 0,
  );

  /// Method used to compute the assessed MPBF.
  final MpbfMethod method;

  /// Total current assets from the projected balance sheet.
  final int totalCurrentAssets;

  /// Current liabilities excluding bank borrowings.
  final int currentLiabilitiesExcludingBankBorrowings;

  /// Working capital gap = totalCA - CL excl. bank.
  final int workingCapitalGap;

  /// Net working capital contributed from long-term sources (NWC).
  final int nwcFromLongTermSources;

  /// MPBF computed via Method 1 (75% of WCG).
  final int method1Mpbf;

  /// MPBF computed via Method 2 (75% of CA - CL excl. bank).
  final int method2Mpbf;

  /// Final assessed working capital limit (lower of applicable MPBF and
  /// drawing power, or bank's own norms).
  final int assessedLimit;

  /// Drawing power = (stock × DP%) + (debtors × DP%) - creditors.
  final int drawingPower;

  /// Actual amount sanctioned by the bank.
  final int actualSanctioned;

  MpbfComputation copyWith({
    MpbfMethod? method,
    int? totalCurrentAssets,
    int? currentLiabilitiesExcludingBankBorrowings,
    int? workingCapitalGap,
    int? nwcFromLongTermSources,
    int? method1Mpbf,
    int? method2Mpbf,
    int? assessedLimit,
    int? drawingPower,
    int? actualSanctioned,
  }) {
    return MpbfComputation(
      method: method ?? this.method,
      totalCurrentAssets: totalCurrentAssets ?? this.totalCurrentAssets,
      currentLiabilitiesExcludingBankBorrowings:
          currentLiabilitiesExcludingBankBorrowings ??
          this.currentLiabilitiesExcludingBankBorrowings,
      workingCapitalGap: workingCapitalGap ?? this.workingCapitalGap,
      nwcFromLongTermSources:
          nwcFromLongTermSources ?? this.nwcFromLongTermSources,
      method1Mpbf: method1Mpbf ?? this.method1Mpbf,
      method2Mpbf: method2Mpbf ?? this.method2Mpbf,
      assessedLimit: assessedLimit ?? this.assessedLimit,
      drawingPower: drawingPower ?? this.drawingPower,
      actualSanctioned: actualSanctioned ?? this.actualSanctioned,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MpbfComputation &&
        other.method == method &&
        other.totalCurrentAssets == totalCurrentAssets &&
        other.currentLiabilitiesExcludingBankBorrowings ==
            currentLiabilitiesExcludingBankBorrowings &&
        other.workingCapitalGap == workingCapitalGap &&
        other.nwcFromLongTermSources == nwcFromLongTermSources &&
        other.method1Mpbf == method1Mpbf &&
        other.method2Mpbf == method2Mpbf &&
        other.assessedLimit == assessedLimit &&
        other.drawingPower == drawingPower &&
        other.actualSanctioned == actualSanctioned;
  }

  @override
  int get hashCode => Object.hash(
    method,
    totalCurrentAssets,
    currentLiabilitiesExcludingBankBorrowings,
    workingCapitalGap,
    nwcFromLongTermSources,
    method1Mpbf,
    method2Mpbf,
    assessedLimit,
    drawingPower,
    actualSanctioned,
  );
}
