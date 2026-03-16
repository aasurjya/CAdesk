/// Represents which version of the Income Tax Act applies.
///
/// - [act1961]: The Income-tax Act, 1961 — applies to FY 2025-26 and earlier
///   (AY 2026-27 and earlier). Also governs pending proceedings initiated
///   under the 1961 Act even after April 1, 2026.
/// - [act2025]: The Income-tax Act, 2025 — applies from Tax Year 2026-27
///   (FY starting April 1, 2026) onwards.
enum ActMode {
  act1961(label: 'Income-tax Act, 1961', shortLabel: 'IT Act 1961'),
  act2025(label: 'Income-tax Act, 2025', shortLabel: 'IT Act 2025');

  const ActMode({required this.label, required this.shortLabel});

  final String label;
  final String shortLabel;

  /// The 1961 Act applies up to and including March 31, 2026.
  DateTime get effectiveUntil => DateTime(2026, 3, 31);

  /// The 2025 Act takes effect from April 1, 2026.
  DateTime get effectiveFrom => DateTime(2026, 4, 1);

  /// The cutoff year: FY starting from this year uses the 2025 Act.
  static const int _cutoffStartYear = 2026;

  /// Returns the current [ActMode] based on [DateTime.now].
  static ActMode get current => forDate(DateTime.now());

  /// Returns the applicable [ActMode] for a given [date].
  ///
  /// Dates before April 1, 2026 → [act1961].
  /// Dates on or after April 1, 2026 → [act2025].
  static ActMode forDate(DateTime date) {
    final cutoff = DateTime(2026, 4, 1);
    return date.isBefore(cutoff) ? act1961 : act2025;
  }

  /// Returns the applicable [ActMode] for a financial year string.
  ///
  /// Format: "YYYY-YY" (e.g., "2025-26", "2026-27").
  /// FY 2025-26 and earlier → [act1961].
  /// FY 2026-27 and later → [act2025].
  static ActMode forFinancialYear(String fy) {
    final startYear = _parseStartYear(fy);
    return startYear >= _cutoffStartYear ? act2025 : act1961;
  }

  /// Returns the applicable [ActMode] for an assessment year string.
  ///
  /// Format: "YYYY-YY" or "AY YYYY-YY" (e.g., "2026-27", "AY 2026-27").
  /// AY = FY + 1, so AY 2026-27 → FY 2025-26 → [act1961].
  /// AY 2027-28 → FY 2026-27 → [act2025].
  static ActMode forAssessmentYear(String ay) {
    final cleaned = ay.replaceFirst(RegExp(r'^AY\s*'), '');
    final ayStartYear = _parseStartYear(cleaned);
    // AY start year is FY start year + 1
    final fyStartYear = ayStartYear - 1;
    return fyStartYear >= _cutoffStartYear ? act2025 : act1961;
  }

  static int _parseStartYear(String yearString) {
    final match = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(yearString);
    if (match == null) {
      throw FormatException(
        'Invalid year format: "$yearString". Expected "YYYY-YY" (e.g., "2025-26").',
      );
    }
    return int.parse(match.group(1)!);
  }
}
