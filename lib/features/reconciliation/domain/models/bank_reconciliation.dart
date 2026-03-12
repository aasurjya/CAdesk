import 'bank_recon_item.dart';

/// Immutable model representing the result of reconciling a bank account
/// statement against the corresponding book entries for a given period.
///
/// All monetary amounts are in **paise** (1 INR = 100 paise).
///
/// ### Key Concepts
/// - **Bank balance**: closing balance per the bank statement.
/// - **Book balance**: closing balance per the accounting records.
/// - **Unreconciled items**: transactions present in one source but not the other.
/// - **Reconciled items**: transactions successfully matched across both sources.
class BankReconciliation {
  const BankReconciliation({
    required this.accountNumber,
    required this.bankName,
    required this.period,
    required this.bankBalance,
    required this.bookBalance,
    required this.unreconciledItems,
    required this.reconciledItems,
  });

  /// Masked bank account number (e.g. '****1234').
  final String accountNumber;

  /// Name of the bank (e.g. 'HDFC Bank', 'State Bank of India').
  final String bankName;

  /// Reconciliation period (e.g. 'Apr 2025', 'FY 2025-26 Q1').
  final String period;

  /// Closing balance as per the bank statement, in paise.
  final int bankBalance;

  /// Closing balance as per the books of accounts, in paise.
  final int bookBalance;

  /// Transactions present in only one source — not yet matched.
  final List<BankReconItem> unreconciledItems;

  /// Transactions successfully matched in both bank statement and books.
  final List<BankReconItem> reconciledItems;

  /// Whether the bank and book balances are equal.
  ///
  /// A `true` value means the reconciliation is complete with no net difference.
  /// Note: individual timing differences may still exist even when balanced.
  bool get isBalanced => bankBalance == bookBalance;

  BankReconciliation copyWith({
    String? accountNumber,
    String? bankName,
    String? period,
    int? bankBalance,
    int? bookBalance,
    List<BankReconItem>? unreconciledItems,
    List<BankReconItem>? reconciledItems,
  }) {
    return BankReconciliation(
      accountNumber: accountNumber ?? this.accountNumber,
      bankName: bankName ?? this.bankName,
      period: period ?? this.period,
      bankBalance: bankBalance ?? this.bankBalance,
      bookBalance: bookBalance ?? this.bookBalance,
      unreconciledItems: unreconciledItems ?? this.unreconciledItems,
      reconciledItems: reconciledItems ?? this.reconciledItems,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BankReconciliation) return false;
    if (other.accountNumber != accountNumber) return false;
    if (other.bankName != bankName) return false;
    if (other.period != period) return false;
    if (other.bankBalance != bankBalance) return false;
    if (other.bookBalance != bookBalance) return false;
    if (other.unreconciledItems.length != unreconciledItems.length) return false;
    if (other.reconciledItems.length != reconciledItems.length) return false;
    for (var i = 0; i < unreconciledItems.length; i++) {
      if (other.unreconciledItems[i] != unreconciledItems[i]) return false;
    }
    for (var i = 0; i < reconciledItems.length; i++) {
      if (other.reconciledItems[i] != reconciledItems[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        accountNumber,
        bankName,
        period,
        bankBalance,
        bookBalance,
        Object.hashAll(unreconciledItems),
        Object.hashAll(reconciledItems),
      );
}
