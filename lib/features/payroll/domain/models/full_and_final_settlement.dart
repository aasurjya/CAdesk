/// Full and Final Settlement computation for a departing employee.
///
/// Covers all dues payable or recoverable on an employee's last working day,
/// per Indian labour law (Payment of Gratuity Act 1972, Shops & Establishment
/// Acts, applicable state rules).
///
/// All monetary values are in paise (1/100th of a rupee).
class FullAndFinalSettlement {
  const FullAndFinalSettlement({
    required this.employeeId,
    required this.relievingDate,
    required this.joiningDate,
    required this.yearsOfService,
    required this.pendingLeaves,
    required this.gratuityAmountPaise,
    required this.leaveEncashmentAmountPaise,
    required this.noticePayPaise,
    required this.totalPayablePaise,
  });

  /// Employee identifier.
  final String employeeId;

  /// Last working day / relieving date.
  final DateTime relievingDate;

  /// Date of joining for service period computation.
  final DateTime joiningDate;

  /// Completed years of service (used for gratuity eligibility).
  final int yearsOfService;

  /// Number of pending approved leaves being encashed.
  final int pendingLeaves;

  /// Gratuity amount payable in paise (0 if service < 5 years).
  final int gratuityAmountPaise;

  /// Leave encashment amount for pending leaves in paise.
  final int leaveEncashmentAmountPaise;

  /// Notice pay in paise.
  ///
  /// Positive: employer owes employee (employer-initiated termination without
  /// notice).
  /// Negative: employee owes employer (resigned without serving notice period).
  /// Zero: full notice period served or no notice period applicable.
  final int noticePayPaise;

  /// Total amount payable to the employee in paise.
  ///
  /// = [gratuityAmountPaise] + [leaveEncashmentAmountPaise] + [noticePayPaise]
  /// A negative total means the employee owes money to the employer.
  final int totalPayablePaise;

  FullAndFinalSettlement copyWith({
    String? employeeId,
    DateTime? relievingDate,
    DateTime? joiningDate,
    int? yearsOfService,
    int? pendingLeaves,
    int? gratuityAmountPaise,
    int? leaveEncashmentAmountPaise,
    int? noticePayPaise,
    int? totalPayablePaise,
  }) {
    return FullAndFinalSettlement(
      employeeId: employeeId ?? this.employeeId,
      relievingDate: relievingDate ?? this.relievingDate,
      joiningDate: joiningDate ?? this.joiningDate,
      yearsOfService: yearsOfService ?? this.yearsOfService,
      pendingLeaves: pendingLeaves ?? this.pendingLeaves,
      gratuityAmountPaise: gratuityAmountPaise ?? this.gratuityAmountPaise,
      leaveEncashmentAmountPaise:
          leaveEncashmentAmountPaise ?? this.leaveEncashmentAmountPaise,
      noticePayPaise: noticePayPaise ?? this.noticePayPaise,
      totalPayablePaise: totalPayablePaise ?? this.totalPayablePaise,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FullAndFinalSettlement &&
        other.employeeId == employeeId &&
        other.relievingDate == relievingDate &&
        other.joiningDate == joiningDate &&
        other.yearsOfService == yearsOfService &&
        other.pendingLeaves == pendingLeaves &&
        other.gratuityAmountPaise == gratuityAmountPaise &&
        other.leaveEncashmentAmountPaise == leaveEncashmentAmountPaise &&
        other.noticePayPaise == noticePayPaise &&
        other.totalPayablePaise == totalPayablePaise;
  }

  @override
  int get hashCode => Object.hash(
    employeeId,
    relievingDate,
    joiningDate,
    yearsOfService,
    pendingLeaves,
    gratuityAmountPaise,
    leaveEncashmentAmountPaise,
    noticePayPaise,
    totalPayablePaise,
  );

  @override
  String toString() =>
      'FullAndFinalSettlement(employee: $employeeId, '
      'relievingDate: $relievingDate, '
      'yearsOfService: $yearsOfService, '
      'gratuity: $gratuityAmountPaise, '
      'leaveEncashment: $leaveEncashmentAmountPaise, '
      'noticePay: $noticePayPaise, '
      'total: $totalPayablePaise)';
}
