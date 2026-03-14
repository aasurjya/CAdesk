/// Immutable model summarising the day's workload for the Today screen.
class TodaySummary {
  const TodaySummary({
    required this.overdueCount,
    required this.dueTodayCount,
    required this.dueThisWeekCount,
    required this.completedTodayCount,
    required this.date,
  });

  /// Number of overdue tasks/deadlines.
  final int overdueCount;

  /// Number of tasks due today.
  final int dueTodayCount;

  /// Number of tasks due within the next 7 days.
  final int dueThisWeekCount;

  /// Number of tasks completed today.
  final int completedTodayCount;

  /// The date this summary was computed for.
  final DateTime date;

  bool get hasOverdue => overdueCount > 0;
  bool get hasDueToday => dueTodayCount > 0;

  TodaySummary copyWith({
    int? overdueCount,
    int? dueTodayCount,
    int? dueThisWeekCount,
    int? completedTodayCount,
    DateTime? date,
  }) {
    return TodaySummary(
      overdueCount: overdueCount ?? this.overdueCount,
      dueTodayCount: dueTodayCount ?? this.dueTodayCount,
      dueThisWeekCount: dueThisWeekCount ?? this.dueThisWeekCount,
      completedTodayCount: completedTodayCount ?? this.completedTodayCount,
      date: date ?? this.date,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodaySummary &&
          runtimeType == other.runtimeType &&
          date == other.date;

  @override
  int get hashCode => date.hashCode;
}
