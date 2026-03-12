/// Immutable model for aggregate filing statistics used in
/// reports and dashboard analytics.
class FilingStatistics {
  const FilingStatistics({
    required this.totalFilings,
    required this.filedCount,
    required this.pendingCount,
    required this.overdueCount,
    required this.averageTurnaroundDays,
    required this.revenueCollected,
    required this.revenueOutstanding,
  });

  factory FilingStatistics.empty() => const FilingStatistics(
    totalFilings: 0,
    filedCount: 0,
    pendingCount: 0,
    overdueCount: 0,
    averageTurnaroundDays: 0,
    revenueCollected: 0,
    revenueOutstanding: 0,
  );

  /// Total number of filing jobs across all statuses.
  final int totalFilings;

  /// Number of filings that have been filed or verified.
  final int filedCount;

  /// Number of filings still in progress (not yet filed).
  final int pendingCount;

  /// Number of filings past their due date and not yet filed.
  final int overdueCount;

  /// Average number of days from job creation to filing.
  final double averageTurnaroundDays;

  /// Total fee revenue collected from filed returns.
  final double revenueCollected;

  /// Outstanding fee revenue from pending/overdue filings.
  final double revenueOutstanding;

  /// Percentage of total filings that have been completed.
  ///
  /// Returns 0.0 if there are no filings to avoid division by zero.
  double get completionRate =>
      totalFilings > 0 ? filedCount / totalFilings : 0.0;

  /// Total revenue (collected + outstanding).
  double get totalRevenue => revenueCollected + revenueOutstanding;

  FilingStatistics copyWith({
    int? totalFilings,
    int? filedCount,
    int? pendingCount,
    int? overdueCount,
    double? averageTurnaroundDays,
    double? revenueCollected,
    double? revenueOutstanding,
  }) {
    return FilingStatistics(
      totalFilings: totalFilings ?? this.totalFilings,
      filedCount: filedCount ?? this.filedCount,
      pendingCount: pendingCount ?? this.pendingCount,
      overdueCount: overdueCount ?? this.overdueCount,
      averageTurnaroundDays:
          averageTurnaroundDays ?? this.averageTurnaroundDays,
      revenueCollected: revenueCollected ?? this.revenueCollected,
      revenueOutstanding: revenueOutstanding ?? this.revenueOutstanding,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilingStatistics &&
        other.totalFilings == totalFilings &&
        other.filedCount == filedCount &&
        other.pendingCount == pendingCount &&
        other.overdueCount == overdueCount &&
        other.averageTurnaroundDays == averageTurnaroundDays &&
        other.revenueCollected == revenueCollected &&
        other.revenueOutstanding == revenueOutstanding;
  }

  @override
  int get hashCode => Object.hash(
    totalFilings,
    filedCount,
    pendingCount,
    overdueCount,
    averageTurnaroundDays,
    revenueCollected,
    revenueOutstanding,
  );
}
