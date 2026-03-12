import 'package:flutter/foundation.dart';

/// Immutable representation of a single line item in an invoice.
///
/// All monetary amounts are in **paise** (1 INR = 100 paise).
@immutable
class ExtractedLineItem {
  const ExtractedLineItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
    required this.hsnCode,
  });

  /// Description of the goods or services.
  final String description;

  /// Quantity of units.
  final int quantity;

  /// Unit price in paise.
  final int unitPrice;

  /// Total line amount (quantity × unitPrice) in paise.
  final int amount;

  /// HSN/SAC code for GST classification, if available.
  final String? hsnCode;

  ExtractedLineItem copyWith({
    String? description,
    int? quantity,
    int? unitPrice,
    int? amount,
    String? hsnCode,
  }) {
    return ExtractedLineItem(
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      amount: amount ?? this.amount,
      hsnCode: hsnCode ?? this.hsnCode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtractedLineItem &&
          runtimeType == other.runtimeType &&
          description == other.description &&
          quantity == other.quantity &&
          unitPrice == other.unitPrice &&
          amount == other.amount &&
          hsnCode == other.hsnCode;

  @override
  int get hashCode =>
      Object.hash(description, quantity, unitPrice, amount, hsnCode);

  @override
  String toString() =>
      'ExtractedLineItem(desc: $description, qty: $quantity, '
      'unitPrice: $unitPrice, amount: $amount)';
}
