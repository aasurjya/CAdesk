/// Lifecycle status of an income tax demand.
enum DemandTrackerStatus {
  raised('Demand Raised'),
  partiallyPaid('Partially Paid'),
  fullPaid('Fully Paid'),
  stayGranted('Stay Granted'),
  inAppeal('In Appeal'),
  rectified('Rectified'),
  withdrawn('Withdrawn');

  const DemandTrackerStatus(this.label);
  final String label;
}

/// Immutable model tracking an income tax demand for a given PAN and AY.
///
/// Amounts are stored in paise (1 INR = 100 paise) to avoid floating-point
/// rounding errors in tax computations.
class DemandTracker {
  const DemandTracker({
    required this.pan,
    required this.assessmentYear,
    required this.demandId,
    required this.section,
    required this.demandAmount,
    required this.outstandingAmount,
    required this.status,
    required this.dueDate,
    required this.interestAccruing,
  });

  final String pan;
  final String assessmentYear;
  final String demandId;

  /// Income Tax Act section under which the demand was raised (e.g. "143(1)").
  final String section;

  /// Original demand amount in paise.
  final int demandAmount;

  /// Current unpaid outstanding amount in paise.
  final int outstandingAmount;

  final DemandTrackerStatus status;
  final DateTime dueDate;

  /// Whether interest under section 220(2) is currently accruing on this demand.
  final bool interestAccruing;

  DemandTracker copyWith({
    String? pan,
    String? assessmentYear,
    String? demandId,
    String? section,
    int? demandAmount,
    int? outstandingAmount,
    DemandTrackerStatus? status,
    DateTime? dueDate,
    bool? interestAccruing,
  }) {
    return DemandTracker(
      pan: pan ?? this.pan,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      demandId: demandId ?? this.demandId,
      section: section ?? this.section,
      demandAmount: demandAmount ?? this.demandAmount,
      outstandingAmount: outstandingAmount ?? this.outstandingAmount,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      interestAccruing: interestAccruing ?? this.interestAccruing,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DemandTracker &&
        other.pan == pan &&
        other.assessmentYear == assessmentYear &&
        other.demandId == demandId &&
        other.section == section &&
        other.demandAmount == demandAmount &&
        other.outstandingAmount == outstandingAmount &&
        other.status == status &&
        other.dueDate == dueDate &&
        other.interestAccruing == interestAccruing;
  }

  @override
  int get hashCode => Object.hash(
        pan,
        assessmentYear,
        demandId,
        section,
        demandAmount,
        outstandingAmount,
        status,
        dueDate,
        interestAccruing,
      );
}
