/// Lifecycle status of an income tax refund claim.
enum RefundTrackerStatus {
  notInitiated('Not Initiated'),
  initiated('Initiated'),
  processing('Processing'),
  issued('Issued'),
  adjusted('Adjusted Against Demand'),
  failed('Failed');

  const RefundTrackerStatus(this.label);
  final String label;
}

/// Immutable model tracking an income tax refund for a given PAN and AY.
///
/// Amounts are stored in paise (1 INR = 100 paise) to avoid floating-point
/// rounding errors in tax computations.
class RefundTracker {
  const RefundTracker({
    required this.pan,
    required this.assessmentYear,
    required this.refundAmount,
    required this.status,
    required this.refundBankAccount,
    this.issuedDate,
    this.adjustedAgainstDemand = false,
    this.expectedDate,
  });

  final String pan;
  final String assessmentYear;

  /// Refund amount in paise.
  final int refundAmount;

  final RefundTrackerStatus status;

  /// Masked bank account number (e.g. "XXXX1234").
  final String refundBankAccount;

  final DateTime? issuedDate;
  final bool adjustedAgainstDemand;
  final DateTime? expectedDate;

  RefundTracker copyWith({
    String? pan,
    String? assessmentYear,
    int? refundAmount,
    RefundTrackerStatus? status,
    String? refundBankAccount,
    DateTime? issuedDate,
    bool? adjustedAgainstDemand,
    DateTime? expectedDate,
  }) {
    return RefundTracker(
      pan: pan ?? this.pan,
      assessmentYear: assessmentYear ?? this.assessmentYear,
      refundAmount: refundAmount ?? this.refundAmount,
      status: status ?? this.status,
      refundBankAccount: refundBankAccount ?? this.refundBankAccount,
      issuedDate: issuedDate ?? this.issuedDate,
      adjustedAgainstDemand:
          adjustedAgainstDemand ?? this.adjustedAgainstDemand,
      expectedDate: expectedDate ?? this.expectedDate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RefundTracker &&
        other.pan == pan &&
        other.assessmentYear == assessmentYear &&
        other.refundAmount == refundAmount &&
        other.status == status &&
        other.refundBankAccount == refundBankAccount &&
        other.issuedDate == issuedDate &&
        other.adjustedAgainstDemand == adjustedAgainstDemand &&
        other.expectedDate == expectedDate;
  }

  @override
  int get hashCode => Object.hash(
    pan,
    assessmentYear,
    refundAmount,
    status,
    refundBankAccount,
    issuedDate,
    adjustedAgainstDemand,
    expectedDate,
  );
}
