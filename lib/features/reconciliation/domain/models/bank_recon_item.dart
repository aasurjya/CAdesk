/// Direction of a bank or book transaction.
enum TxType {
  /// Money coming in (deposit, receipt).
  credit('Credit'),

  /// Money going out (withdrawal, payment).
  debit('Debit');

  const TxType(this.label);

  /// Human-readable label for UI display.
  final String label;
}

/// Reconciliation status of a single bank or book transaction.
enum ReconItemStatus {
  /// Transaction appears in both bank statement and books with matching amount.
  matched('Matched'),

  /// Transaction is in the books but not yet in the bank statement
  /// (e.g. cheque issued but not yet presented, deposit in transit).
  unmatchedInBooks('Unmatched in Books'),

  /// Transaction is in the bank statement but not yet in the books
  /// (e.g. bank charges, interest credited by bank).
  unmatchedInBank('Unmatched in Bank'),

  /// Transaction exists on both sides but with a timing lag
  /// (e.g. ECS/NEFT in T+1 settlement, post-dated cheque).
  timing('Timing Difference');

  const ReconItemStatus(this.label);

  /// Human-readable label for UI display.
  final String label;
}

/// Immutable model representing a single reconciliation item — either a bank
/// statement transaction or a book entry that is being matched.
///
/// All monetary amounts are in **paise** (1 INR = 100 paise).
class BankReconItem {
  const BankReconItem({
    required this.transactionId,
    required this.date,
    required this.description,
    required this.amount,
    required this.type,
    required this.status,
  });

  /// Unique identifier for this transaction (from bank statement or books).
  final String transactionId;

  /// Date of the transaction.
  final DateTime date;

  /// Narration or description of the transaction.
  final String description;

  /// Transaction amount in paise.
  final int amount;

  /// Whether this is a debit or credit transaction.
  final TxType type;

  /// Reconciliation status of this item.
  final ReconItemStatus status;

  BankReconItem copyWith({
    String? transactionId,
    DateTime? date,
    String? description,
    int? amount,
    TxType? type,
    ReconItemStatus? status,
  }) {
    return BankReconItem(
      transactionId: transactionId ?? this.transactionId,
      date: date ?? this.date,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BankReconItem &&
        other.transactionId == transactionId &&
        other.date == date &&
        other.description == description &&
        other.amount == amount &&
        other.type == type &&
        other.status == status;
  }

  @override
  int get hashCode =>
      Object.hash(transactionId, date, description, amount, type, status);
}
