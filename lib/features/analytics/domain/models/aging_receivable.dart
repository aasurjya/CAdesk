/// Aging bucket for categorising overdue receivables.
enum AgingBucket {
  current('Current', 0),
  days30('1-30 Days', 30),
  days60('31-60 Days', 60),
  days90('61-90 Days', 90),
  over90('90+ Days', 91);

  const AgingBucket(this.label, this.maxDays);

  final String label;
  final int maxDays;
}

/// An outstanding receivable against a client invoice.
class AgingReceivable {
  const AgingReceivable({
    required this.clientId,
    required this.clientName,
    required this.invoiceId,
    required this.amount,
    required this.dueDate,
    required this.daysPastDue,
    required this.bucket,
  });

  final String clientId;
  final String clientName;
  final String invoiceId;
  final double amount;
  final DateTime dueDate;
  final int daysPastDue;
  final AgingBucket bucket;

  AgingReceivable copyWith({
    String? clientId,
    String? clientName,
    String? invoiceId,
    double? amount,
    DateTime? dueDate,
    int? daysPastDue,
    AgingBucket? bucket,
  }) {
    return AgingReceivable(
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      invoiceId: invoiceId ?? this.invoiceId,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      daysPastDue: daysPastDue ?? this.daysPastDue,
      bucket: bucket ?? this.bucket,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AgingReceivable && other.invoiceId == invoiceId;
  }

  @override
  int get hashCode => invoiceId.hashCode;
}
