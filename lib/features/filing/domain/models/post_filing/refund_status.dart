/// Lifecycle stage of an income tax refund.
enum RefundLifecycle {
  notApplicable('Not Applicable'),
  initiated('Initiated'),
  inTransit('In Transit'),
  credited('Credited'),
  failed('Failed'),
  reissued('Reissued');

  const RefundLifecycle(this.label);
  final String label;
}

/// Immutable model representing the refund status for a filed return.
class RefundStatus {
  const RefundStatus({
    required this.refundAmount,
    required this.status,
    required this.bankAccount,
    required this.ifsc,
    this.initiatedDate,
    this.creditedDate,
    this.failureReason,
  });

  final double refundAmount;
  final RefundLifecycle status;
  final String bankAccount;
  final String ifsc;
  final DateTime? initiatedDate;
  final DateTime? creditedDate;
  final String? failureReason;

  RefundStatus copyWith({
    double? refundAmount,
    RefundLifecycle? status,
    String? bankAccount,
    String? ifsc,
    DateTime? initiatedDate,
    DateTime? creditedDate,
    String? failureReason,
  }) {
    return RefundStatus(
      refundAmount: refundAmount ?? this.refundAmount,
      status: status ?? this.status,
      bankAccount: bankAccount ?? this.bankAccount,
      ifsc: ifsc ?? this.ifsc,
      initiatedDate: initiatedDate ?? this.initiatedDate,
      creditedDate: creditedDate ?? this.creditedDate,
      failureReason: failureReason ?? this.failureReason,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RefundStatus &&
        other.refundAmount == refundAmount &&
        other.status == status &&
        other.bankAccount == bankAccount &&
        other.ifsc == ifsc &&
        other.initiatedDate == initiatedDate &&
        other.creditedDate == creditedDate &&
        other.failureReason == failureReason;
  }

  @override
  int get hashCode => Object.hash(
    refundAmount,
    status,
    bankAccount,
    ifsc,
    initiatedDate,
    creditedDate,
    failureReason,
  );
}
