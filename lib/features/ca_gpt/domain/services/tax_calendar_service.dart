/// An immutable tax compliance deadline.
class TaxDeadline {
  const TaxDeadline({
    required this.description,
    required this.date,
    required this.category,
    required this.isRecurring,
  });

  final String description;
  final DateTime date;

  /// Category tag: 'ITR', 'GST', 'TDS', 'Advance Tax', 'GST Annual', etc.
  final String category;

  /// Whether this deadline recurs every month (e.g. monthly GST filings).
  final bool isRecurring;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaxDeadline &&
        other.description == description &&
        other.date == date &&
        other.category == category &&
        other.isRecurring == isRecurring;
  }

  @override
  int get hashCode => Object.hash(description, date, category, isRecurring);
}

/// Stateless service for retrieving Indian tax compliance deadlines.
///
/// Contains built-in deadlines for FY 2024-25 (and adjacent assessment years).
/// All methods are static — no instantiation required.
class TaxCalendarService {
  TaxCalendarService._();

  // ---------------------------------------------------------------------------
  // Deadline builder helpers
  // ---------------------------------------------------------------------------

  /// Builds the standard FY 2024-25 deadline list for [financialYear] == 2024.
  ///
  /// For other financial years, dates are extrapolated by shifting the year.
  static List<TaxDeadline> _buildDeadlines(int financialYear) {
    final fy = financialYear; // start year of the FY, e.g. 2024 for FY 2024-25
    final ay = fy + 1; // assessment year calendar year, e.g. 2025

    final deadlines = <TaxDeadline>[
      // -----------------------------------------------------------------------
      // ITR Filing
      // -----------------------------------------------------------------------
      TaxDeadline(
        description: 'ITR filing due date — Individuals / HUF (non-audit)',
        date: DateTime(ay, 7, 31),
        category: 'ITR',
        isRecurring: false,
      ),
      TaxDeadline(
        description: 'ITR filing due date — Audit cases (u/s 44AB)',
        date: DateTime(ay, 10, 31),
        category: 'ITR',
        isRecurring: false,
      ),
      TaxDeadline(
        description: 'ITR filing due date — Transfer pricing cases',
        date: DateTime(ay, 11, 30),
        category: 'ITR',
        isRecurring: false,
      ),
      TaxDeadline(
        description: 'Belated / Revised ITR filing deadline',
        date: DateTime(ay, 12, 31),
        category: 'ITR',
        isRecurring: false,
      ),

      // -----------------------------------------------------------------------
      // Advance Tax (dates in calendar year of FY)
      // -----------------------------------------------------------------------
      TaxDeadline(
        description: 'Advance Tax — 1st installment (15% of estimated tax)',
        date: DateTime(fy, 6, 15),
        category: 'Advance Tax',
        isRecurring: false,
      ),
      TaxDeadline(
        description: 'Advance Tax — 2nd installment (cumulative 45%)',
        date: DateTime(fy, 9, 15),
        category: 'Advance Tax',
        isRecurring: false,
      ),
      TaxDeadline(
        description: 'Advance Tax — 3rd installment (cumulative 75%)',
        date: DateTime(fy, 12, 15),
        category: 'Advance Tax',
        isRecurring: false,
      ),
      TaxDeadline(
        description: 'Advance Tax — 4th installment (100%)',
        date: DateTime(ay, 3, 15),
        category: 'Advance Tax',
        isRecurring: false,
      ),

      // -----------------------------------------------------------------------
      // TDS — Monthly deposit (7th of following month)
      // -----------------------------------------------------------------------
      ..._monthlyDeadlines(
        description: (month, year) =>
            'TDS deposit — ${_monthName(month)} $year deductions',
        category: 'TDS',
        dayOfMonth: 7,
        startMonth: 4,
        startYear: fy,
        count: 12,
        isRecurring: true,
      ),

      // -----------------------------------------------------------------------
      // TDS — Quarterly returns
      // -----------------------------------------------------------------------
      TaxDeadline(
        description: 'TDS quarterly return — Q1 (Apr–Jun)',
        date: DateTime(fy, 7, 31),
        category: 'TDS',
        isRecurring: false,
      ),
      TaxDeadline(
        description: 'TDS quarterly return — Q2 (Jul–Sep)',
        date: DateTime(fy, 10, 31),
        category: 'TDS',
        isRecurring: false,
      ),
      TaxDeadline(
        description: 'TDS quarterly return — Q3 (Oct–Dec)',
        date: DateTime(ay, 1, 31),
        category: 'TDS',
        isRecurring: false,
      ),
      TaxDeadline(
        description: 'TDS quarterly return — Q4 (Jan–Mar)',
        date: DateTime(ay, 5, 31),
        category: 'TDS',
        isRecurring: false,
      ),

      // -----------------------------------------------------------------------
      // GST — Monthly GSTR-1 (11th of following month)
      // -----------------------------------------------------------------------
      ..._monthlyDeadlines(
        description: (month, year) =>
            'GSTR-1 — ${_monthName(month)} $year (monthly filers)',
        category: 'GST',
        dayOfMonth: 11,
        startMonth: 4,
        startYear: fy,
        count: 12,
        isRecurring: true,
      ),

      // -----------------------------------------------------------------------
      // GST — Monthly GSTR-3B (20th of following month)
      // -----------------------------------------------------------------------
      ..._monthlyDeadlines(
        description: (month, year) =>
            'GSTR-3B — ${_monthName(month)} $year (monthly filers)',
        category: 'GST',
        dayOfMonth: 20,
        startMonth: 4,
        startYear: fy,
        count: 12,
        isRecurring: true,
      ),

      // -----------------------------------------------------------------------
      // GST Annual Return
      // -----------------------------------------------------------------------
      TaxDeadline(
        description:
            'GSTR-9 — GST Annual Return for FY $fy-${(ay % 100).toString().padLeft(2, '0')}',
        date: DateTime(ay, 12, 31),
        category: 'GST Annual',
        isRecurring: false,
      ),
    ];

    return List<TaxDeadline>.unmodifiable(deadlines);
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns all compliance deadlines for the given [financialYear].
  ///
  /// [financialYear] is the starting year, e.g. 2024 for FY 2024-25.
  static List<TaxDeadline> getDeadlines(int financialYear) {
    return _buildDeadlines(financialYear);
  }

  /// Returns deadlines occurring within [days] days of [from] for [financialYear].
  ///
  /// Both [from] and [from] + [days] are inclusive boundaries.
  static List<TaxDeadline> getUpcomingDeadlines(
    int financialYear,
    DateTime from, {
    int days = 30,
  }) {
    final until = from.add(Duration(days: days));
    return _buildDeadlines(financialYear)
        .where(
          (d) =>
              !d.date.isBefore(from) &&
              d.date.isBefore(until.add(const Duration(days: 1))),
        )
        .toList();
  }

  /// Returns true if [date] is a compliance deadline in the given [financialYear].
  static bool isDeadlineDate(DateTime date, int financialYear) {
    return _buildDeadlines(financialYear).any(
      (d) =>
          d.date.year == date.year &&
          d.date.month == date.month &&
          d.date.day == date.day,
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Generates [count] monthly deadline entries starting from [startMonth]/[startYear].
  ///
  /// [dayOfMonth] is the due-date day in the *following* month.
  static List<TaxDeadline> _monthlyDeadlines({
    required String Function(int month, int year) description,
    required String category,
    required int dayOfMonth,
    required int startMonth,
    required int startYear,
    required int count,
    required bool isRecurring,
  }) {
    final list = <TaxDeadline>[];
    var month = startMonth;
    var year = startYear;

    for (int i = 0; i < count; i++) {
      // The due-date falls in the *following* month.
      var dueMonth = month + 1;
      var dueYear = year;
      if (dueMonth > 12) {
        dueMonth -= 12;
        dueYear += 1;
      }

      list.add(
        TaxDeadline(
          description: description(month, year),
          date: DateTime(dueYear, dueMonth, dayOfMonth),
          category: category,
          isRecurring: isRecurring,
        ),
      );

      month += 1;
      if (month > 12) {
        month = 1;
        year += 1;
      }
    }
    return list;
  }

  static const List<String> _months = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static String _monthName(int month) => _months[month];
}
