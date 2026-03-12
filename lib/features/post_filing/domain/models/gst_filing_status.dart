/// Type of GST return.
enum GstReturnType {
  gstr1('GSTR-1'),
  gstr3b('GSTR-3B'),
  gstr9('GSTR-9');

  const GstReturnType(this.label);
  final String label;
}

/// Lifecycle state of a GST return filing.
enum GstFilingState {
  notFiled('Not Filed'),
  saved('Saved as Draft'),
  submitted('Submitted'),
  filed('Filed'),
  processed('Processed'),
  rejected('Rejected');

  const GstFilingState(this.label);
  final String label;
}

/// Immutable model representing the filing status of a GST return.
///
/// Late fees are stored in paise (1 INR = 100 paise) to avoid floating-point
/// rounding errors.
class GstFilingStatus {
  const GstFilingStatus({
    required this.gstin,
    required this.returnType,
    required this.period,
    required this.status,
    this.filedAt,
    this.arn,
    this.lateFee,
  });

  final String gstin;
  final GstReturnType returnType;

  /// Return period in MMYYYY format (e.g. "032025" for March 2025).
  final String period;

  final GstFilingState status;
  final DateTime? filedAt;

  /// Acknowledgement Reference Number issued by GST portal on filing.
  final String? arn;

  /// Late fee amount in paise (if applicable).
  final int? lateFee;

  GstFilingStatus copyWith({
    String? gstin,
    GstReturnType? returnType,
    String? period,
    GstFilingState? status,
    DateTime? filedAt,
    String? arn,
    int? lateFee,
  }) {
    return GstFilingStatus(
      gstin: gstin ?? this.gstin,
      returnType: returnType ?? this.returnType,
      period: period ?? this.period,
      status: status ?? this.status,
      filedAt: filedAt ?? this.filedAt,
      arn: arn ?? this.arn,
      lateFee: lateFee ?? this.lateFee,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GstFilingStatus &&
        other.gstin == gstin &&
        other.returnType == returnType &&
        other.period == period &&
        other.status == status &&
        other.filedAt == filedAt &&
        other.arn == arn &&
        other.lateFee == lateFee;
  }

  @override
  int get hashCode =>
      Object.hash(gstin, returnType, period, status, filedAt, arn, lateFee);
}
