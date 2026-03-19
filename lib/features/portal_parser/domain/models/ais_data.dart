import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// Feedback status a taxpayer has submitted for an AIS entry.
enum AisEntryFeedback {
  accepted(label: 'Accepted', code: 'A'),
  partiallyAccepted(label: 'Partially Accepted', code: 'PA'),
  notAccepted(label: 'Not Accepted', code: 'NA'),
  noFeedback(label: 'No Feedback', code: 'NF');

  const AisEntryFeedback({required this.label, required this.code});

  final String label;
  final String code;

  /// Maps a portal code to [AisEntryFeedback].
  static AisEntryFeedback fromCode(String code) {
    switch (code.toUpperCase().trim()) {
      case 'A':
        return AisEntryFeedback.accepted;
      case 'PA':
        return AisEntryFeedback.partiallyAccepted;
      case 'NA':
        return AisEntryFeedback.notAccepted;
      default:
        return AisEntryFeedback.noFeedback;
    }
  }
}

/// Category of income in AIS.
enum AisIncomeCategory {
  salary(label: 'Salary'),
  interestSavings(label: 'Interest - Savings Account'),
  interestFd(label: 'Interest - Fixed Deposit'),
  interestOther(label: 'Interest - Other'),
  dividend(label: 'Dividend'),
  securitiesTransaction(label: 'Securities Transaction'),
  propertyTransaction(label: 'Property Transaction'),
  foreignRemittance(label: 'Foreign Remittance'),
  other(label: 'Other');

  const AisIncomeCategory({required this.label});

  final String label;

  /// Maps a portal string to [AisIncomeCategory].
  static AisIncomeCategory fromString(String value) {
    final lower = value.toLowerCase().trim();
    if (lower.contains('salary')) return AisIncomeCategory.salary;
    if (lower.contains('savings')) return AisIncomeCategory.interestSavings;
    if (lower.contains('fixed') || lower.contains('fd')) {
      return AisIncomeCategory.interestFd;
    }
    if (lower.contains('interest')) return AisIncomeCategory.interestOther;
    if (lower.contains('dividend')) return AisIncomeCategory.dividend;
    if (lower.contains('securit')) {
      return AisIncomeCategory.securitiesTransaction;
    }
    if (lower.contains('property')) {
      return AisIncomeCategory.propertyTransaction;
    }
    if (lower.contains('foreign') || lower.contains('remittance')) {
      return AisIncomeCategory.foreignRemittance;
    }
    return AisIncomeCategory.other;
  }
}

// ---------------------------------------------------------------------------
// Entry models
// ---------------------------------------------------------------------------

/// A single income entry in the parsed AIS.
@immutable
class AisIncomeEntry {
  const AisIncomeEntry({
    required this.category,
    required this.sourceName,
    required this.sourcePan,
    required this.amountReportedPaise,
    required this.amountDerivedPaise,
    required this.feedback,
    required this.transactionId,
  });

  final AisIncomeCategory category;

  /// Name of the reporting entity / payer.
  final String sourceName;

  /// PAN of the reporting entity.
  final String sourcePan;

  /// Amount as reported by the source, in paise.
  final int amountReportedPaise;

  /// Amount as derived/computed by the department, in paise.
  final int amountDerivedPaise;

  /// Taxpayer feedback for this entry.
  final AisEntryFeedback feedback;

  /// Unique transaction identifier from the portal.
  final String transactionId;

  AisIncomeEntry copyWith({
    AisIncomeCategory? category,
    String? sourceName,
    String? sourcePan,
    int? amountReportedPaise,
    int? amountDerivedPaise,
    AisEntryFeedback? feedback,
    String? transactionId,
  }) {
    return AisIncomeEntry(
      category: category ?? this.category,
      sourceName: sourceName ?? this.sourceName,
      sourcePan: sourcePan ?? this.sourcePan,
      amountReportedPaise: amountReportedPaise ?? this.amountReportedPaise,
      amountDerivedPaise: amountDerivedPaise ?? this.amountDerivedPaise,
      feedback: feedback ?? this.feedback,
      transactionId: transactionId ?? this.transactionId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AisIncomeEntry &&
          runtimeType == other.runtimeType &&
          transactionId == other.transactionId;

  @override
  int get hashCode => transactionId.hashCode;
}

// ---------------------------------------------------------------------------
// Aggregate model
// ---------------------------------------------------------------------------

/// Immutable structured output from parsing an Annual Information Statement.
///
/// All monetary amounts are in **paise** (1 rupee = 100 paise).
@immutable
class AisParserData {
  const AisParserData({
    required this.pan,
    required this.financialYear,
    required this.salaryEntries,
    required this.interestEntries,
    required this.dividendEntries,
    required this.securitiesEntries,
    required this.propertyEntries,
    required this.foreignRemittanceEntries,
    required this.otherEntries,
  });

  /// 10-character PAN.
  final String pan;

  /// Financial year in "YYYY-YY" format (e.g. "2024-25").
  final String financialYear;

  final List<AisIncomeEntry> salaryEntries;
  final List<AisIncomeEntry> interestEntries;
  final List<AisIncomeEntry> dividendEntries;
  final List<AisIncomeEntry> securitiesEntries;
  final List<AisIncomeEntry> propertyEntries;
  final List<AisIncomeEntry> foreignRemittanceEntries;
  final List<AisIncomeEntry> otherEntries;

  // -- Derived --

  /// All entries across every category.
  List<AisIncomeEntry> get allEntries => [
    ...salaryEntries,
    ...interestEntries,
    ...dividendEntries,
    ...securitiesEntries,
    ...propertyEntries,
    ...foreignRemittanceEntries,
    ...otherEntries,
  ];

  /// Total reported income across all categories, in paise.
  int get totalReportedPaise =>
      allEntries.fold(0, (sum, e) => sum + e.amountReportedPaise);

  /// Total derived income across all categories, in paise.
  int get totalDerivedPaise =>
      allEntries.fold(0, (sum, e) => sum + e.amountDerivedPaise);

  AisParserData copyWith({
    String? pan,
    String? financialYear,
    List<AisIncomeEntry>? salaryEntries,
    List<AisIncomeEntry>? interestEntries,
    List<AisIncomeEntry>? dividendEntries,
    List<AisIncomeEntry>? securitiesEntries,
    List<AisIncomeEntry>? propertyEntries,
    List<AisIncomeEntry>? foreignRemittanceEntries,
    List<AisIncomeEntry>? otherEntries,
  }) {
    return AisParserData(
      pan: pan ?? this.pan,
      financialYear: financialYear ?? this.financialYear,
      salaryEntries: salaryEntries ?? this.salaryEntries,
      interestEntries: interestEntries ?? this.interestEntries,
      dividendEntries: dividendEntries ?? this.dividendEntries,
      securitiesEntries: securitiesEntries ?? this.securitiesEntries,
      propertyEntries: propertyEntries ?? this.propertyEntries,
      foreignRemittanceEntries:
          foreignRemittanceEntries ?? this.foreignRemittanceEntries,
      otherEntries: otherEntries ?? this.otherEntries,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AisParserData &&
          runtimeType == other.runtimeType &&
          pan == other.pan &&
          financialYear == other.financialYear;

  @override
  int get hashCode => Object.hash(pan, financialYear);

  @override
  String toString() =>
      'AisParserData(pan: $pan, fy: $financialYear, '
      'entries: ${allEntries.length})';
}
