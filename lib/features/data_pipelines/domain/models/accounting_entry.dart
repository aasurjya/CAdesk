/// Source accounting system from which the entry was imported.
enum AccountingSource { tally, zoho, sap, quickbooks, busy, marg, csv }

/// Immutable model representing a double-entry accounting record.
///
/// Each entry captures a single debit/credit pair as exported from accounting
/// software. Amounts are stored in **paise** (₹1 = 100 paise).
class AccountingEntry {
  const AccountingEntry({
    required this.entryId,
    required this.source,
    required this.date,
    required this.voucherType,
    required this.debitAccount,
    required this.creditAccount,
    required this.amount,
    required this.narration,
    required this.reference,
  });

  /// Unique identifier for this entry (generated on import).
  final String entryId;

  /// Source accounting system.
  final AccountingSource source;

  /// Date of the accounting entry.
  final DateTime date;

  /// Voucher type (e.g. 'Payment', 'Receipt', 'Journal', 'Invoice').
  final String voucherType;

  /// Account head being debited.
  final String debitAccount;

  /// Account head being credited.
  final String creditAccount;

  /// Amount in paise.
  final int amount;

  /// Narration / description of the entry.
  final String narration;

  /// Optional external reference (voucher number, invoice number, etc.).
  final String? reference;

  /// Returns a new [AccountingEntry] with specified fields replaced.
  AccountingEntry copyWith({
    String? entryId,
    AccountingSource? source,
    DateTime? date,
    String? voucherType,
    String? debitAccount,
    String? creditAccount,
    int? amount,
    String? narration,
    String? reference,
  }) {
    return AccountingEntry(
      entryId: entryId ?? this.entryId,
      source: source ?? this.source,
      date: date ?? this.date,
      voucherType: voucherType ?? this.voucherType,
      debitAccount: debitAccount ?? this.debitAccount,
      creditAccount: creditAccount ?? this.creditAccount,
      amount: amount ?? this.amount,
      narration: narration ?? this.narration,
      reference: reference ?? this.reference,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AccountingEntry &&
        other.entryId == entryId &&
        other.source == source &&
        other.date == date &&
        other.voucherType == voucherType &&
        other.debitAccount == debitAccount &&
        other.creditAccount == creditAccount &&
        other.amount == amount &&
        other.narration == narration &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(
    entryId,
    source,
    date,
    voucherType,
    debitAccount,
    creditAccount,
    amount,
    narration,
    reference,
  );
}
