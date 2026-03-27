import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// Feedback status for a TIS derived income category.
enum TisFeedbackStatus {
  accepted(label: 'Accepted', code: 'A'),
  notAccepted(label: 'Not Accepted', code: 'NA'),
  partiallyAccepted(label: 'Partially Accepted', code: 'PA'),
  noFeedback(label: 'No Feedback', code: 'NF');

  const TisFeedbackStatus({required this.label, required this.code});

  final String label;
  final String code;

  /// Maps a portal code to [TisFeedbackStatus].
  static TisFeedbackStatus fromCode(String code) {
    switch (code.toUpperCase().trim()) {
      case 'A':
        return TisFeedbackStatus.accepted;
      case 'NA':
        return TisFeedbackStatus.notAccepted;
      case 'PA':
        return TisFeedbackStatus.partiallyAccepted;
      default:
        return TisFeedbackStatus.noFeedback;
    }
  }
}

/// Income category as classified in TIS.
enum TisIncomeCategory {
  salary(label: 'Salary'),
  interest(label: 'Interest'),
  dividend(label: 'Dividend'),
  rentalIncome(label: 'Rental Income'),
  capitalGains(label: 'Capital Gains'),
  businessIncome(label: 'Business/Profession'),
  otherSources(label: 'Other Sources');

  const TisIncomeCategory({required this.label});

  final String label;

  /// Maps a portal string to [TisIncomeCategory].
  static TisIncomeCategory fromString(String value) {
    final lower = value.toLowerCase().trim();
    if (lower.contains('salary')) return TisIncomeCategory.salary;
    if (lower.contains('interest')) return TisIncomeCategory.interest;
    if (lower.contains('dividend')) return TisIncomeCategory.dividend;
    if (lower.contains('rental') || lower.contains('house')) {
      return TisIncomeCategory.rentalIncome;
    }
    if (lower.contains('capital')) return TisIncomeCategory.capitalGains;
    if (lower.contains('business') || lower.contains('profession')) {
      return TisIncomeCategory.businessIncome;
    }
    return TisIncomeCategory.otherSources;
  }
}

// ---------------------------------------------------------------------------
// Entry model
// ---------------------------------------------------------------------------

/// A single derived income summary entry in TIS.
@immutable
class TisDerivedIncome {
  const TisDerivedIncome({
    required this.category,
    required this.reportedAmountPaise,
    required this.computedAmountPaise,
    required this.differentialPaise,
    required this.feedbackStatus,
    required this.sourceCount,
  });

  final TisIncomeCategory category;

  /// Amount as reported by information sources, in paise.
  final int reportedAmountPaise;

  /// Amount as computed/derived by the department, in paise.
  final int computedAmountPaise;

  /// Difference between reported and computed (reported - computed), in paise.
  final int differentialPaise;

  /// Taxpayer feedback status for this category.
  final TisFeedbackStatus feedbackStatus;

  /// Number of information sources contributing to this category.
  final int sourceCount;

  TisDerivedIncome copyWith({
    TisIncomeCategory? category,
    int? reportedAmountPaise,
    int? computedAmountPaise,
    int? differentialPaise,
    TisFeedbackStatus? feedbackStatus,
    int? sourceCount,
  }) {
    return TisDerivedIncome(
      category: category ?? this.category,
      reportedAmountPaise: reportedAmountPaise ?? this.reportedAmountPaise,
      computedAmountPaise: computedAmountPaise ?? this.computedAmountPaise,
      differentialPaise: differentialPaise ?? this.differentialPaise,
      feedbackStatus: feedbackStatus ?? this.feedbackStatus,
      sourceCount: sourceCount ?? this.sourceCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TisDerivedIncome &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          reportedAmountPaise == other.reportedAmountPaise &&
          computedAmountPaise == other.computedAmountPaise;

  @override
  int get hashCode =>
      Object.hash(category, reportedAmountPaise, computedAmountPaise);
}

// ---------------------------------------------------------------------------
// Aggregate model
// ---------------------------------------------------------------------------

/// Immutable structured output from parsing a Taxpayer Information Summary.
///
/// All monetary amounts are in **paise** (1 rupee = 100 paise).
@immutable
class TisParserData {
  const TisParserData({
    required this.pan,
    required this.financialYear,
    required this.derivedIncomes,
  });

  /// 10-character PAN.
  final String pan;

  /// Financial year in "YYYY-YY" format (e.g. "2024-25").
  final String financialYear;

  /// Category-wise derived income summaries.
  final List<TisDerivedIncome> derivedIncomes;

  // -- Derived --

  /// Total reported income across all categories, in paise.
  int get totalReportedPaise =>
      derivedIncomes.fold(0, (sum, e) => sum + e.reportedAmountPaise);

  /// Total computed income across all categories, in paise.
  int get totalComputedPaise =>
      derivedIncomes.fold(0, (sum, e) => sum + e.computedAmountPaise);

  /// Categories where taxpayer has accepted the derived amount.
  List<TisDerivedIncome> get acceptedCategories => derivedIncomes
      .where((e) => e.feedbackStatus == TisFeedbackStatus.accepted)
      .toList(growable: false);

  /// Categories where taxpayer has not yet provided feedback.
  List<TisDerivedIncome> get pendingFeedbackCategories => derivedIncomes
      .where((e) => e.feedbackStatus == TisFeedbackStatus.noFeedback)
      .toList(growable: false);

  /// Categories with a non-zero differential (reported != computed).
  List<TisDerivedIncome> get categoriesWithDifference => derivedIncomes
      .where((e) => e.differentialPaise != 0)
      .toList(growable: false);

  TisParserData copyWith({
    String? pan,
    String? financialYear,
    List<TisDerivedIncome>? derivedIncomes,
  }) {
    return TisParserData(
      pan: pan ?? this.pan,
      financialYear: financialYear ?? this.financialYear,
      derivedIncomes: derivedIncomes ?? this.derivedIncomes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TisParserData &&
          runtimeType == other.runtimeType &&
          pan == other.pan &&
          financialYear == other.financialYear;

  @override
  int get hashCode => Object.hash(pan, financialYear);

  @override
  String toString() =>
      'TisParserData(pan: $pan, fy: $financialYear, '
      'categories: ${derivedIncomes.length})';
}
