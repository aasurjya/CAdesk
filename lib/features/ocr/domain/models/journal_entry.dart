import 'package:flutter/foundation.dart';

/// Immutable journal entry produced by mapping a bank statement transaction.
///
/// Amount is always stored as a positive value in **paise**.
/// The [isDebit] flag indicates which side of the ledger is affected.
@immutable
class JournalEntry {
  const JournalEntry({
    required this.date,
    required this.description,
    required this.amount,
    required this.isDebit,
    this.referenceNumber,
  });

  /// Date of the journal entry.
  final DateTime date;

  /// Narration / description.
  final String description;

  /// Positive amount in paise.
  final int amount;

  /// True if this entry is a debit; false if credit.
  final bool isDebit;

  /// Optional bank reference / UTR number.
  final String? referenceNumber;

  JournalEntry copyWith({
    DateTime? date,
    String? description,
    int? amount,
    bool? isDebit,
    String? referenceNumber,
  }) {
    return JournalEntry(
      date: date ?? this.date,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      isDebit: isDebit ?? this.isDebit,
      referenceNumber: referenceNumber ?? this.referenceNumber,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalEntry &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          description == other.description &&
          amount == other.amount &&
          isDebit == other.isDebit &&
          referenceNumber == other.referenceNumber;

  @override
  int get hashCode =>
      Object.hash(date, description, amount, isDebit, referenceNumber);

  @override
  String toString() =>
      'JournalEntry(date: $date, ${isDebit ? 'DR' : 'CR'} $amount, '
      'desc: $description)';
}
