/// MSME category as per the MSME Development Act.
///
/// Section 43B(h) of the Income Tax Act covers manufacturing and service
/// MSMEs (micro and small enterprises only).
enum MsmeCategory {
  /// Micro enterprise: investment ≤ ₹1 crore, turnover ≤ ₹5 crore.
  micro,

  /// Small enterprise: investment ≤ ₹10 crore, turnover ≤ ₹50 crore.
  small,

  /// Medium enterprise: investment ≤ ₹50 crore, turnover ≤ ₹250 crore.
  /// Note: Section 43B(h) disallowance does NOT apply to medium enterprises.
  medium,
}

/// Immutable model tracking a payment due to an MSME vendor.
///
/// Used to compute Section 43B(h) disallowances for payments unpaid
/// beyond 45 days (or 15 days where written agreement specifies shorter period)
/// as of March 31 of the financial year.
class MsmePaymentTracker {
  MsmePaymentTracker({
    required this.vendorPan,
    required this.vendorName,
    required this.msmeCategory,
    required this.invoiceDate,
    required this.dueDate,
    required this.paymentDate,
    required this.amountPaise,
    DateTime? referenceDate,
    bool? isOverdue,
    int? daysOverdue,
    bool? disallowanceRisk,
  })  : referenceDate = referenceDate ?? DateTime.now(),
        isOverdue = isOverdue ?? false,
        daysOverdue = daysOverdue ?? 0,
        disallowanceRisk = disallowanceRisk ?? false;

  final String vendorPan;
  final String vendorName;
  final MsmeCategory msmeCategory;
  final DateTime invoiceDate;

  /// Date by which payment is contractually or statutorily due.
  final DateTime dueDate;

  /// Date on which payment was made; null if still outstanding.
  final DateTime? paymentDate;

  /// Invoice amount in paise.
  final int amountPaise;

  /// Reference date for computing overdue status (defaults to today).
  final DateTime referenceDate;

  /// Whether the payment is currently overdue.
  final bool isOverdue;

  /// Number of days the payment is overdue (0 if not overdue).
  final int daysOverdue;

  /// Whether this payment is at risk of being disallowed under Section 43B(h).
  final bool disallowanceRisk;

  MsmePaymentTracker copyWith({
    String? vendorPan,
    String? vendorName,
    MsmeCategory? msmeCategory,
    DateTime? invoiceDate,
    DateTime? dueDate,
    DateTime? paymentDate,
    int? amountPaise,
    DateTime? referenceDate,
    bool? isOverdue,
    int? daysOverdue,
    bool? disallowanceRisk,
  }) {
    return MsmePaymentTracker(
      vendorPan: vendorPan ?? this.vendorPan,
      vendorName: vendorName ?? this.vendorName,
      msmeCategory: msmeCategory ?? this.msmeCategory,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      paymentDate: paymentDate ?? this.paymentDate,
      amountPaise: amountPaise ?? this.amountPaise,
      referenceDate: referenceDate ?? this.referenceDate,
      isOverdue: isOverdue ?? this.isOverdue,
      daysOverdue: daysOverdue ?? this.daysOverdue,
      disallowanceRisk: disallowanceRisk ?? this.disallowanceRisk,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MsmePaymentTracker &&
        other.vendorPan == vendorPan &&
        other.vendorName == vendorName &&
        other.msmeCategory == msmeCategory &&
        other.invoiceDate == invoiceDate &&
        other.dueDate == dueDate &&
        other.paymentDate == paymentDate &&
        other.amountPaise == amountPaise &&
        other.referenceDate == referenceDate &&
        other.isOverdue == isOverdue &&
        other.daysOverdue == daysOverdue &&
        other.disallowanceRisk == disallowanceRisk;
  }

  @override
  int get hashCode => Object.hash(
        vendorPan,
        vendorName,
        msmeCategory,
        invoiceDate,
        dueDate,
        paymentDate,
        amountPaise,
        referenceDate,
        isOverdue,
        daysOverdue,
        disallowanceRisk,
      );
}
