/// Arm's Length Price determination method under Section 92C.
enum AlpMethod {
  /// Comparable Uncontrolled Price method.
  cup,

  /// Resale Price Method.
  rpm,

  /// Cost Plus Method.
  cpm,

  /// Transactional Net Margin Method.
  tnmm,

  /// Profit Split Method.
  psm,
}

/// Nature of the international or specified domestic transaction.
enum TransactionNature {
  /// Sale of tangible property.
  sale,

  /// Purchase of tangible property.
  purchase,

  /// Loan or borrowing.
  loan,

  /// Royalty or license fee.
  royalty,

  /// Service fee.
  service,
}

/// Immutable model for an international transaction with an Associated Enterprise.
///
/// Under Sections 92 to 92F, Transfer Pricing provisions apply when:
/// - International transactions exceed ₹1 crore in aggregate
/// - Specified domestic transactions exceed ₹5 crore in aggregate
class InternationalTransaction {
  const InternationalTransaction({
    required this.description,
    required this.associatedEnterprise,
    required this.nature,
    required this.amountPaise,
    required this.currency,
    required this.armLengthPaise,
    required this.method,
    required this.adjustmentPaise,
  });

  final String description;

  /// Name of the associated enterprise (AE) involved in the transaction.
  final String associatedEnterprise;
  final TransactionNature nature;

  /// Transaction amount in paise.
  final int amountPaise;

  /// Currency of the transaction (ISO 4217 code, e.g. 'INR', 'USD').
  final String currency;

  /// Arm's length price as determined by transfer pricing analysis, in paise.
  final int armLengthPaise;

  /// Transfer pricing method used for this transaction.
  final AlpMethod method;

  /// Transfer pricing adjustment in paise (positive = upward; 0 = none).
  final int adjustmentPaise;

  InternationalTransaction copyWith({
    String? description,
    String? associatedEnterprise,
    TransactionNature? nature,
    int? amountPaise,
    String? currency,
    int? armLengthPaise,
    AlpMethod? method,
    int? adjustmentPaise,
  }) {
    return InternationalTransaction(
      description: description ?? this.description,
      associatedEnterprise: associatedEnterprise ?? this.associatedEnterprise,
      nature: nature ?? this.nature,
      amountPaise: amountPaise ?? this.amountPaise,
      currency: currency ?? this.currency,
      armLengthPaise: armLengthPaise ?? this.armLengthPaise,
      method: method ?? this.method,
      adjustmentPaise: adjustmentPaise ?? this.adjustmentPaise,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InternationalTransaction &&
        other.description == description &&
        other.associatedEnterprise == associatedEnterprise &&
        other.nature == nature &&
        other.amountPaise == amountPaise &&
        other.currency == currency &&
        other.armLengthPaise == armLengthPaise &&
        other.method == method &&
        other.adjustmentPaise == adjustmentPaise;
  }

  @override
  int get hashCode => Object.hash(
    description,
    associatedEnterprise,
    nature,
    amountPaise,
    currency,
    armLengthPaise,
    method,
    adjustmentPaise,
  );
}
