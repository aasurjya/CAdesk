/// Immutable model representing a financial transaction subject to audit.
///
/// Amounts are stored in paise (1 paise = 1/100 of a rupee) to avoid
/// floating-point rounding errors.
class AuditTransaction {
  const AuditTransaction({
    required this.transactionId,
    required this.partyName,
    required this.amountPaise,
    required this.transactionDate,
    required this.description,
    this.accountCode,
    this.reference,
  });

  final String transactionId;
  final String partyName;

  /// Transaction amount in paise (1/100 rupee). Must be positive.
  final int amountPaise;
  final DateTime transactionDate;
  final String description;

  /// Optional GL account code.
  final String? accountCode;

  /// Optional voucher / reference number.
  final String? reference;

  AuditTransaction copyWith({
    String? transactionId,
    String? partyName,
    int? amountPaise,
    DateTime? transactionDate,
    String? description,
    String? accountCode,
    String? reference,
  }) {
    return AuditTransaction(
      transactionId: transactionId ?? this.transactionId,
      partyName: partyName ?? this.partyName,
      amountPaise: amountPaise ?? this.amountPaise,
      transactionDate: transactionDate ?? this.transactionDate,
      description: description ?? this.description,
      accountCode: accountCode ?? this.accountCode,
      reference: reference ?? this.reference,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuditTransaction && other.transactionId == transactionId;
  }

  @override
  int get hashCode => transactionId.hashCode;
}
