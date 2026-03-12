/// Entity type of the startup for Section 80-IAC eligibility.
enum StartupEntityType {
  /// Private limited company or public company.
  company,

  /// Limited Liability Partnership.
  llp,

  /// Partnership firm (NOT eligible for Section 80-IAC).
  partnership,
}

/// Data required to compute Section 80-IAC deduction.
class StartupData {
  StartupData({
    required this.name,
    required this.pan,
    required this.dpiitNumber,
    required this.incorporationDate,
    required this.entityType,
    required this.netProfitPaise,
    required this.financialYears80IACApplied,
  });

  final String name;
  final String pan;
  final String dpiitNumber;
  final DateTime incorporationDate;
  final StartupEntityType entityType;

  /// Net profit for the current financial year in paise.
  final int netProfitPaise;

  /// Financial years in which Section 80-IAC deduction was previously claimed.
  final List<int> financialYears80IACApplied;
}

/// Service for computing Section 80-IAC deduction for eligible startups.
///
/// Section 80-IAC allows 100% deduction of profit for 3 consecutive years
/// (out of the first 10 years from incorporation) for:
/// - Company or LLP incorporated after April 1, 2016
/// - DPIIT-registered startup
/// - Turnover not exceeding ₹100 crore in year of deduction claim
///
/// NOT available for partnerships.
class Section80IACService {
  Section80IACService._();

  static final Section80IACService instance = Section80IACService._();

  /// Cutoff date for incorporation eligibility: April 1, 2016.
  static final DateTime _incorporationCutoff = DateTime(2016, 4, 1);

  /// Maximum years from incorporation during which deduction can be claimed.
  static const int _windowYears = 10;

  /// Maximum number of years deduction can be claimed.
  static const int _maxYears = 3;

  /// Computes the Section 80-IAC deduction in paise.
  ///
  /// Returns [StartupData.netProfitPaise] (100% deduction) if eligible,
  /// or 0 if ineligible.
  ///
  /// [financialYear] is the ending year of the financial year
  /// (e.g., 2024 represents FY 2023-24).
  int computeDeduction(StartupData startup, int financialYear) {
    if (!_isEligible(startup, financialYear)) return 0;
    return startup.netProfitPaise > 0 ? startup.netProfitPaise : 0;
  }

  bool _isEligible(StartupData startup, int financialYear) {
    // Only company or LLP entities are eligible
    if (startup.entityType == StartupEntityType.partnership) return false;

    // Must be incorporated on or after April 1, 2016
    if (startup.incorporationDate.isBefore(_incorporationCutoff)) return false;

    // Must be within the first 10 years from incorporation
    final incorporationYear = startup.incorporationDate.year;
    final yearsSinceIncorporation = financialYear - incorporationYear;
    if (yearsSinceIncorporation > _windowYears) return false;

    // Cannot claim more than 3 years total
    if (startup.financialYears80IACApplied.length >= _maxYears) return false;

    return true;
  }
}
