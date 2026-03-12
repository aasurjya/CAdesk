import 'package:flutter/foundation.dart';

/// Immutable representation of a single bank statement transaction.
///
/// All monetary amounts are in **paise** (1 INR = 100 paise).
@immutable
class ExtractedTransaction {
  const ExtractedTransaction({
    required this.date,
    required this.description,
    required this.debit,
    required this.credit,
    required this.balance,
    required this.referenceNumber,
  });

  /// Transaction date.
  final DateTime date;

  /// Narration / description of the transaction.
  final String description;

  /// Amount debited in paise (0 if this is a credit transaction).
  final int debit;

  /// Amount credited in paise (0 if this is a debit transaction).
  final int credit;

  /// Running balance after this transaction in paise.
  final int balance;

  /// Bank reference / UTR number, if available.
  final String? referenceNumber;

  ExtractedTransaction copyWith({
    DateTime? date,
    String? description,
    int? debit,
    int? credit,
    int? balance,
    String? referenceNumber,
  }) {
    return ExtractedTransaction(
      date: date ?? this.date,
      description: description ?? this.description,
      debit: debit ?? this.debit,
      credit: credit ?? this.credit,
      balance: balance ?? this.balance,
      referenceNumber: referenceNumber ?? this.referenceNumber,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtractedTransaction &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          description == other.description &&
          debit == other.debit &&
          credit == other.credit &&
          balance == other.balance &&
          referenceNumber == other.referenceNumber;

  @override
  int get hashCode => Object.hash(
        date,
        description,
        debit,
        credit,
        balance,
        referenceNumber,
      );

  @override
  String toString() =>
      'ExtractedTransaction(date: $date, desc: $description, '
      'debit: $debit, credit: $credit, balance: $balance)';
}
