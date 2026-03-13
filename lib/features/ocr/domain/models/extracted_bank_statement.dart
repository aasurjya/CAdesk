import 'package:ca_app/features/ocr/domain/models/extracted_transaction.dart';
import 'package:flutter/foundation.dart';

/// Immutable structured data extracted from a bank statement.
///
/// All monetary amounts are in **paise** (1 INR = 100 paise).
@immutable
class ExtractedBankStatement {
  const ExtractedBankStatement({
    required this.accountNumber,
    required this.bankName,
    required this.ifscCode,
    required this.period,
    required this.openingBalance,
    required this.closingBalance,
    required this.transactions,
  });

  /// Masked account number (e.g. "XXXX1234").
  final String accountNumber;

  /// Name of the bank (e.g. "SBI", "HDFC Bank").
  final String bankName;

  /// IFSC code of the branch (e.g. "SBIN0001234").
  final String ifscCode;

  /// Statement period description (e.g. "Apr 2023 – Mar 2024").
  final String period;

  /// Opening balance at start of period in paise.
  final int openingBalance;

  /// Closing balance at end of period in paise.
  final int closingBalance;

  /// Ordered list of transactions in this statement.
  final List<ExtractedTransaction> transactions;

  ExtractedBankStatement copyWith({
    String? accountNumber,
    String? bankName,
    String? ifscCode,
    String? period,
    int? openingBalance,
    int? closingBalance,
    List<ExtractedTransaction>? transactions,
  }) {
    return ExtractedBankStatement(
      accountNumber: accountNumber ?? this.accountNumber,
      bankName: bankName ?? this.bankName,
      ifscCode: ifscCode ?? this.ifscCode,
      period: period ?? this.period,
      openingBalance: openingBalance ?? this.openingBalance,
      closingBalance: closingBalance ?? this.closingBalance,
      transactions: transactions ?? this.transactions,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtractedBankStatement &&
          runtimeType == other.runtimeType &&
          accountNumber == other.accountNumber &&
          bankName == other.bankName &&
          ifscCode == other.ifscCode &&
          period == other.period &&
          openingBalance == other.openingBalance &&
          closingBalance == other.closingBalance &&
          _listEquals(transactions, other.transactions);

  bool _listEquals(List<ExtractedTransaction> a, List<ExtractedTransaction> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    accountNumber,
    bankName,
    ifscCode,
    period,
    openingBalance,
    closingBalance,
    Object.hashAll(transactions),
  );

  @override
  String toString() =>
      'ExtractedBankStatement(account: $accountNumber, bank: $bankName, '
      'opening: $openingBalance, closing: $closingBalance, '
      'txCount: ${transactions.length})';
}
