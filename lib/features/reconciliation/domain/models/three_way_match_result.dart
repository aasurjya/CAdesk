import 'reconciliation_variance.dart';

/// An income item found in AIS but not reported in the ITR schedules.
///
/// Represents a potential unreported income that the assessee needs to
/// explain or include in the return before filing.
class UnreportedIncomeItem {
  const UnreportedIncomeItem({
    required this.sourceName,
    required this.category,
    required this.aisAmount,
    this.itrAmount = 0,
  });

  /// Name of the reporting entity in AIS (e.g. 'HDFC Bank', 'Infosys Ltd').
  final String sourceName;

  /// Category of income (e.g. 'Salary', 'Interest', 'Dividend').
  final String category;

  /// Amount reported in AIS, in paise.
  final int aisAmount;

  /// Amount declared in ITR (0 if not reported at all), in paise.
  final int itrAmount;

  /// Difference between AIS amount and ITR declaration, in paise.
  int get unreportedAmount => aisAmount - itrAmount;

  UnreportedIncomeItem copyWith({
    String? sourceName,
    String? category,
    int? aisAmount,
    int? itrAmount,
  }) {
    return UnreportedIncomeItem(
      sourceName: sourceName ?? this.sourceName,
      category: category ?? this.category,
      aisAmount: aisAmount ?? this.aisAmount,
      itrAmount: itrAmount ?? this.itrAmount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UnreportedIncomeItem &&
        other.sourceName == sourceName &&
        other.category == category &&
        other.aisAmount == aisAmount &&
        other.itrAmount == itrAmount;
  }

  @override
  int get hashCode => Object.hash(sourceName, category, aisAmount, itrAmount);
}

/// Immutable result of a three-way reconciliation between Form 26AS,
/// AIS, and ITR data for a specific PAN and assessment year.
///
/// All monetary amounts are in **paise** (1 INR = 100 paise).
class ThreeWayMatchResult {
  const ThreeWayMatchResult({
    required this.pan,
    required this.assessmentYear,
    required this.form26AsTotal,
    required this.aisTotalIncome,
    required this.itrTotalIncome,
    required this.form26AsVsAis,
    required this.form26AsVsItr,
    required this.aisVsItr,
    required this.unreportedIncome,
    required this.recommendations,
  });

  /// PAN of the assessee.
  final String pan;

  /// Assessment year this reconciliation covers (e.g. '2025-26').
  final String assessmentYear;

  /// Total income/TDS as shown in Form 26AS, in paise.
  final int form26AsTotal;

  /// Total income as reported in AIS, in paise.
  final int aisTotalIncome;

  /// Total income as declared in the ITR form, in paise.
  final int itrTotalIncome;

  /// Variance analysis between Form 26AS and AIS.
  final ReconciliationVariance form26AsVsAis;

  /// Variance analysis between Form 26AS and ITR.
  final ReconciliationVariance form26AsVsItr;

  /// Variance analysis between AIS and ITR.
  final ReconciliationVariance aisVsItr;

  /// Income items found in AIS but not declared in the ITR.
  final List<UnreportedIncomeItem> unreportedIncome;

  /// Actionable recommendations for the CA / assessee.
  final List<String> recommendations;

  /// Whether all three sources are within acceptable variance thresholds.
  bool get isFullyMatched =>
      form26AsVsAis.status == VarianceStatus.matched &&
      form26AsVsItr.status == VarianceStatus.matched &&
      aisVsItr.status == VarianceStatus.matched;

  ThreeWayMatchResult copyWith({
    String? pan,
    String? assessmentYear,
    int? form26AsTotal,
    int? aisTotalIncome,
    int? itrTotalIncome,
    ReconciliationVariance? form26AsVsAis,
    ReconciliationVariance? form26AsVsItr,
    ReconciliationVariance? aisVsItr,
    List<UnreportedIncomeItem>? unreportedIncome,
    List<String>? recommendations,
  }) {
    return ThreeWayMatchResult(
      pan: pan ?? this.pan,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      form26AsTotal: form26AsTotal ?? this.form26AsTotal,
      aisTotalIncome: aisTotalIncome ?? this.aisTotalIncome,
      itrTotalIncome: itrTotalIncome ?? this.itrTotalIncome,
      form26AsVsAis: form26AsVsAis ?? this.form26AsVsAis,
      form26AsVsItr: form26AsVsItr ?? this.form26AsVsItr,
      aisVsItr: aisVsItr ?? this.aisVsItr,
      unreportedIncome: unreportedIncome ?? this.unreportedIncome,
      recommendations: recommendations ?? this.recommendations,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ThreeWayMatchResult) return false;
    if (other.pan != pan) return false;
    if (other.assessmentYear != assessmentYear) return false;
    if (other.form26AsTotal != form26AsTotal) return false;
    if (other.aisTotalIncome != aisTotalIncome) return false;
    if (other.itrTotalIncome != itrTotalIncome) return false;
    if (other.form26AsVsAis != form26AsVsAis) return false;
    if (other.form26AsVsItr != form26AsVsItr) return false;
    if (other.aisVsItr != aisVsItr) return false;
    if (other.unreportedIncome.length != unreportedIncome.length) return false;
    if (other.recommendations.length != recommendations.length) return false;
    for (var i = 0; i < unreportedIncome.length; i++) {
      if (other.unreportedIncome[i] != unreportedIncome[i]) return false;
    }
    for (var i = 0; i < recommendations.length; i++) {
      if (other.recommendations[i] != recommendations[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    pan,
    assessmentYear,
    form26AsTotal,
    aisTotalIncome,
    itrTotalIncome,
    form26AsVsAis,
    form26AsVsItr,
    aisVsItr,
    Object.hashAll(unreportedIncome),
    Object.hashAll(recommendations),
  );
}
