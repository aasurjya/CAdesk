/// Basis on which professional fees are charged.
enum FeeBasis {
  /// Single fixed fee for the engagement.
  fixed(label: 'Fixed'),

  /// Rate per hour of work performed.
  hourly(label: 'Hourly'),

  /// Periodic retainer regardless of hours worked.
  retainer(label: 'Retainer'),

  /// Fee tied to value delivered (e.g., tax savings).
  valueAdded(label: 'Value Added');

  const FeeBasis({required this.label});

  final String label;
}

/// How frequently billing cycles occur.
enum BillingFrequency {
  /// Billed every calendar month.
  monthly(label: 'Monthly'),

  /// Billed every quarter.
  quarterly(label: 'Quarterly'),

  /// Single annual billing.
  annual(label: 'Annual'),

  /// Billed at defined project milestones.
  milestone(label: 'Milestone');

  const BillingFrequency({required this.label});

  final String label;
}

/// Immutable fee structure defining how a client is charged.
class FeeStructure {
  const FeeStructure({
    required this.basis,
    required this.fixedAmount,
    required this.hourlyRate,
    required this.retainerAmount,
    required this.billingFrequency,
  });

  /// Fee charging basis.
  final FeeBasis basis;

  /// Fixed amount in paise; non-null only when [basis] is [FeeBasis.fixed].
  final int? fixedAmount;

  /// Hourly rate in paise; non-null only when [basis] is [FeeBasis.hourly].
  final int? hourlyRate;

  /// Retainer amount in paise; non-null only when [basis] is [FeeBasis.retainer].
  final int? retainerAmount;

  /// How often invoices are generated.
  final BillingFrequency billingFrequency;

  FeeStructure copyWith({
    FeeBasis? basis,
    int? fixedAmount,
    int? hourlyRate,
    int? retainerAmount,
    BillingFrequency? billingFrequency,
  }) {
    return FeeStructure(
      basis: basis ?? this.basis,
      fixedAmount: fixedAmount ?? this.fixedAmount,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      retainerAmount: retainerAmount ?? this.retainerAmount,
      billingFrequency: billingFrequency ?? this.billingFrequency,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeeStructure &&
        other.basis == basis &&
        other.fixedAmount == fixedAmount &&
        other.hourlyRate == hourlyRate &&
        other.retainerAmount == retainerAmount &&
        other.billingFrequency == billingFrequency;
  }

  @override
  int get hashCode => Object.hash(
    basis,
    fixedAmount,
    hourlyRate,
    retainerAmount,
    billingFrequency,
  );
}
