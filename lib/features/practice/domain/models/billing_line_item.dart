/// A single line on a billing invoice.
///
/// All monetary values are in paise (100 paise = ₹1).
/// SAC codes follow CBIC classification for professional services.
class BillingLineItem {
  const BillingLineItem({
    required this.description,
    required this.sacCode,
    required this.quantity,
    required this.rate,
    required this.amount,
    required this.gstRate,
  });

  /// Description of the service rendered.
  final String description;

  /// Services Accounting Code (SAC) per CBIC.
  /// Common CA SAC codes:
  /// - 998211: Accounting/bookkeeping — 18% GST
  /// - 998212: Financial auditing — 18% GST
  /// - 998221: Tax advisory — 18% GST
  /// - 998232: Secretarial compliance — 18% GST
  final String sacCode;

  /// Number of units (hours, filings, etc.).
  final double quantity;

  /// Rate per unit in paise.
  final int rate;

  /// Total amount in paise (quantity × rate, rounded).
  final int amount;

  /// GST rate as a decimal (e.g., 0.18 for 18%).
  final double gstRate;

  BillingLineItem copyWith({
    String? description,
    String? sacCode,
    double? quantity,
    int? rate,
    int? amount,
    double? gstRate,
  }) {
    return BillingLineItem(
      description: description ?? this.description,
      sacCode: sacCode ?? this.sacCode,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      amount: amount ?? this.amount,
      gstRate: gstRate ?? this.gstRate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BillingLineItem &&
        other.description == description &&
        other.sacCode == sacCode &&
        other.quantity == quantity &&
        other.rate == rate &&
        other.amount == amount &&
        other.gstRate == gstRate;
  }

  @override
  int get hashCode =>
      Object.hash(description, sacCode, quantity, rate, amount, gstRate);
}
