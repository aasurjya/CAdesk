import 'package:ca_app/features/it_act_transition/domain/models/act_mode.dart';

/// Represents a Tax Year (April 1 to March 31).
///
/// Under the IT Act 1961, this was referred to as "Previous Year" (PY) for
/// income computation and "Assessment Year" (AY) for filing (AY = PY + 1).
///
/// Under the IT Act 2025, the concept is unified as "Tax Year" (TY),
/// eliminating the AY/PY distinction. TY 2026-27 is the first Tax Year
/// under the new Act.
class TaxYear implements Comparable<TaxYear> {
  const TaxYear({required this.startYear});

  /// The calendar year in which the tax year begins (April).
  final int startYear;

  /// The calendar year in which the tax year ends (March).
  int get endYear => startYear + 1;

  /// The applicable Act for this tax year.
  ActMode get actMode => ActMode.forFinancialYear(financialYearString);

  /// April 1 of the start year.
  DateTime get startDate => DateTime(startYear, 4, 1);

  /// March 31 of the end year.
  DateTime get endDate => DateTime(endYear, 3, 31);

  // ---------------------------------------------------------------------------
  // Display Strings
  // ---------------------------------------------------------------------------

  /// "2025-26" format.
  String get financialYearString =>
      '$startYear-${endYear.toString().substring(2)}';

  /// "AY 2026-27" format (AY = FY + 1).
  String get assessmentYearString =>
      'AY ${startYear + 1}-${(endYear + 1).toString().substring(2)}';

  /// "TY 2026-27" format — Tax Year under the 2025 Act is identical to the
  /// Financial Year span (April–March), just labelled "TY" instead of "FY".
  String get taxYearString =>
      'TY $startYear-${endYear.toString().substring(2)}';

  /// Automatically picks the right label based on the Act:
  /// - 1961 Act → "AY 2026-27" (Assessment Year = FY + 1)
  /// - 2025 Act → "TY 2026-27" (Tax Year = same span as FY)
  String get displayLabel =>
      actMode == ActMode.act1961 ? assessmentYearString : taxYearString;

  // ---------------------------------------------------------------------------
  // Factories
  // ---------------------------------------------------------------------------

  /// Parse a financial year string like "2025-26".
  factory TaxYear.fromFinancialYear(String fy) {
    final match = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(fy);
    if (match == null) {
      throw FormatException(
        'Invalid financial year format: "$fy". Expected "YYYY-YY".',
      );
    }
    return TaxYear(startYear: int.parse(match.group(1)!));
  }

  /// Parse an assessment year string like "AY 2026-27" or "2026-27".
  /// AY start year maps to FY start year - 1.
  factory TaxYear.fromAssessmentYear(String ay) {
    final cleaned = ay.replaceFirst(RegExp(r'^AY\s*'), '');
    final match = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(cleaned);
    if (match == null) {
      throw FormatException(
        'Invalid assessment year format: "$ay". Expected "AY YYYY-YY".',
      );
    }
    return TaxYear(startYear: int.parse(match.group(1)!) - 1);
  }

  /// Create from any date — maps to the FY that contains that date.
  factory TaxYear.fromDate(DateTime date) {
    // April–December → startYear = date.year
    // January–March → startYear = date.year - 1
    final startYear = date.month >= 4 ? date.year : date.year - 1;
    return TaxYear(startYear: startYear);
  }

  /// The current tax year based on [DateTime.now].
  static TaxYear get current => TaxYear.fromDate(DateTime.now());

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  /// Whether [date] falls within this tax year (inclusive of start and end).
  bool containsDate(DateTime date) {
    return !date.isBefore(startDate) && !date.isAfter(endDate);
  }

  // ---------------------------------------------------------------------------
  // Immutable copy
  // ---------------------------------------------------------------------------

  TaxYear copyWith({int? startYear}) =>
      TaxYear(startYear: startYear ?? this.startYear);

  // ---------------------------------------------------------------------------
  // Comparable, equality, toString
  // ---------------------------------------------------------------------------

  @override
  int compareTo(TaxYear other) => startYear.compareTo(other.startYear);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaxYear &&
          runtimeType == other.runtimeType &&
          startYear == other.startYear;

  @override
  int get hashCode => startYear.hashCode;

  @override
  String toString() => 'TaxYear($financialYearString)';
}
