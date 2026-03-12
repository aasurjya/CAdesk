/// Attendance record for a single employee for a given month.
///
/// Used by the payroll engine to compute LOP (Loss of Pay) deductions and
/// to verify the working days in a month.
class AttendanceRecord {
  const AttendanceRecord({
    required this.employeeId,
    required this.month,
    required this.year,
    required this.presentDays,
    required this.leaveDays,
    required this.lopDays,
    required this.holidays,
  });

  /// Employee identifier.
  final String employeeId;

  /// Calendar month (1–12).
  final int month;

  /// Calendar year (e.g. 2025).
  final int year;

  /// Number of days the employee was present.
  final int presentDays;

  /// Number of approved leave days (paid leave — does not attract LOP).
  final int leaveDays;

  /// Number of Loss of Pay days (absent without approved leave).
  final int lopDays;

  /// Number of public holidays in the month.
  final int holidays;

  /// Total calendar days in this month.
  int get totalDaysInMonth {
    return DateTime(year, month + 1, 0).day;
  }

  /// Working days = total days − holidays.
  int get workingDays => totalDaysInMonth - holidays;

  AttendanceRecord copyWith({
    String? employeeId,
    int? month,
    int? year,
    int? presentDays,
    int? leaveDays,
    int? lopDays,
    int? holidays,
  }) {
    return AttendanceRecord(
      employeeId: employeeId ?? this.employeeId,
      month: month ?? this.month,
      year: year ?? this.year,
      presentDays: presentDays ?? this.presentDays,
      leaveDays: leaveDays ?? this.leaveDays,
      lopDays: lopDays ?? this.lopDays,
      holidays: holidays ?? this.holidays,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttendanceRecord &&
        other.employeeId == employeeId &&
        other.month == month &&
        other.year == year &&
        other.presentDays == presentDays &&
        other.leaveDays == leaveDays &&
        other.lopDays == lopDays &&
        other.holidays == holidays;
  }

  @override
  int get hashCode => Object.hash(
    employeeId,
    month,
    year,
    presentDays,
    leaveDays,
    lopDays,
    holidays,
  );

  @override
  String toString() =>
      'AttendanceRecord(employee: $employeeId, $month/$year, '
      'present: $presentDays, leave: $leaveDays, lop: $lopDays, '
      'holidays: $holidays)';
}
