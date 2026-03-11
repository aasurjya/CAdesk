/// Date utilities tailored to the Indian financial / tax calendar.
///
/// The Indian financial year runs from April 1 to March 31.
/// The assessment year is the financial year immediately following the
/// income year (e.g. FY 2025-26 -> AY 2026-27).
class IndianDateUtils {
  IndianDateUtils._();

  /// Formats [date] as DD/MM/YYYY, the standard Indian date format.
  static String formatIndianDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  /// Returns the financial year label for the given [date], e.g. "FY 2025-26".
  ///
  /// If [date] is omitted, defaults to [DateTime.now].
  /// If the date is between April 1 and March 31 of the next calendar year,
  /// the financial year start is the April year.
  static String currentFinancialYear([DateTime? date]) {
    final ref = date ?? DateTime.now();
    final startYear = ref.month >= 4 ? ref.year : ref.year - 1;
    final endYearShort = ((startYear + 1) % 100).toString().padLeft(2, '0');
    return 'FY $startYear-$endYearShort';
  }

  /// Returns April 1 of the financial year that contains [date].
  ///
  /// If [date] is omitted, defaults to [DateTime.now].
  static DateTime financialYearStart([DateTime? date]) {
    final ref = date ?? DateTime.now();
    final startYear = ref.month >= 4 ? ref.year : ref.year - 1;
    return DateTime(startYear, 4, 1);
  }

  /// Returns March 31 of the financial year that contains [date].
  ///
  /// If [date] is omitted, defaults to [DateTime.now].
  static DateTime financialYearEnd([DateTime? date]) {
    final ref = date ?? DateTime.now();
    final startYear = ref.month >= 4 ? ref.year : ref.year - 1;
    return DateTime(startYear + 1, 3, 31);
  }

  /// Returns the current assessment year label, e.g. "2026-27".
  ///
  /// The assessment year is one year ahead of the financial year.
  static String currentAssessmentYear() {
    final now = DateTime.now();
    final fyStartYear = now.month >= 4 ? now.year : now.year - 1;
    final ayStartYear = fyStartYear + 1;
    final ayEndYearShort = ((ayStartYear + 1) % 100).toString().padLeft(2, '0');
    return '$ayStartYear-$ayEndYearShort';
  }

  /// Returns the number of whole days remaining until [deadline].
  ///
  /// If [from] is provided, it is used as the reference date instead of today.
  /// A negative value means the deadline has already passed.
  static int daysUntilDeadline(DateTime deadline, {DateTime? from}) {
    final ref = from ?? DateTime.now();
    final refMidnight = DateTime(ref.year, ref.month, ref.day);
    final deadlineMidnight = DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
    );
    return deadlineMidnight.difference(refMidnight).inDays;
  }

  /// Returns `true` when [deadline] is strictly in the past (before [from]).
  ///
  /// If [from] is omitted, defaults to [DateTime.now].
  static bool isOverdue(DateTime deadline, {DateTime? from}) {
    return daysUntilDeadline(deadline, from: from) < 0;
  }

  /// Returns a human-readable relative date string.
  ///
  /// If [from] is provided, it is used as the reference date instead of today.
  /// Examples: "Today", "Yesterday", "Tomorrow", "3 days ago",
  /// "In 5 days", or the formatted date for distances > 30 days.
  static String formatRelativeDate(DateTime date, {DateTime? from}) {
    final ref = from ?? DateTime.now();
    final todayMidnight = DateTime(ref.year, ref.month, ref.day);
    final dateMidnight = DateTime(date.year, date.month, date.day);
    final diff = dateMidnight.difference(todayMidnight).inDays;

    if (diff == 0) return 'Today';
    if (diff == -1) return 'Yesterday';
    if (diff == 1) return 'Tomorrow';

    if (diff < -30 || diff > 30) {
      return formatIndianDate(date);
    }

    if (diff < 0) {
      return '${diff.abs()} days ago';
    }

    return 'In $diff days';
  }
}
