/// Status of a payment to an MSME vendor.
enum MsmePaymentStatus {
  paidOnTime('Paid On Time'),
  paidLate('Paid Late'),
  overdue('Overdue'),
  disputed('Disputed');

  const MsmePaymentStatus(this.label);
  final String label;
}

/// Immutable model representing a payment record for an MSME vendor.
class MsmePayment {
  const MsmePayment({
    required this.id,
    required this.clientId,
    required this.vendorId,
    required this.vendorName,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.invoiceAmount,
    required this.dueDate,
    this.paymentDate,
    required this.daysToPay,
    required this.isWithin45Days,
    required this.penaltyInterest,
    required this.status,
  });

  final String id;
  final String clientId;
  final String vendorId;
  final String vendorName;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final double invoiceAmount;
  final DateTime dueDate;
  final DateTime? paymentDate;
  final int daysToPay;
  final bool isWithin45Days;
  final double penaltyInterest;
  final MsmePaymentStatus status;

  MsmePayment copyWith({
    String? id,
    String? clientId,
    String? vendorId,
    String? vendorName,
    String? invoiceNumber,
    DateTime? invoiceDate,
    double? invoiceAmount,
    DateTime? dueDate,
    DateTime? paymentDate,
    int? daysToPay,
    bool? isWithin45Days,
    double? penaltyInterest,
    MsmePaymentStatus? status,
  }) {
    return MsmePayment(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      invoiceAmount: invoiceAmount ?? this.invoiceAmount,
      dueDate: dueDate ?? this.dueDate,
      paymentDate: paymentDate ?? this.paymentDate,
      daysToPay: daysToPay ?? this.daysToPay,
      isWithin45Days: isWithin45Days ?? this.isWithin45Days,
      penaltyInterest: penaltyInterest ?? this.penaltyInterest,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MsmePayment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
