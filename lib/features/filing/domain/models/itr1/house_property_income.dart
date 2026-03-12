/// Type of house property for ITR-1.
enum PropertyType {
  selfOccupied('Self-Occupied'),
  letOut('Let Out');

  const PropertyType(this.label);
  final String label;
}

/// Immutable model for house property income in ITR-1 (Sahaj).
///
/// ITR-1 supports a single self-occupied or let-out house property.
/// For let-out property the annual letable value (gross rent) is declared
/// and deductions are applied per Section 24.
class HousePropertyIncome {
  const HousePropertyIncome({
    required this.annualLetableValue,
    required this.municipalTaxesPaid,
    required this.interestOnLoan,
    this.propertyType = PropertyType.selfOccupied,
  });

  factory HousePropertyIncome.empty() => const HousePropertyIncome(
    annualLetableValue: 0,
    municipalTaxesPaid: 0,
    interestOnLoan: 0,
  );

  /// Gross annual rent receivable / annual value of the property.
  final double annualLetableValue;

  /// Municipal / local body taxes actually paid during the year.
  final double municipalTaxesPaid;

  /// Interest on housing loan (Section 24(b)).
  /// Self-occupied: capped at ₹2,00,000 by the calling layer.
  /// Let-out: no cap under ITR-1 rules.
  final double interestOnLoan;

  /// Type of house property — affects interest deduction cap.
  final PropertyType propertyType;

  /// Annual value after deducting municipal taxes paid.
  double get netAnnualValue => annualLetableValue - municipalTaxesPaid;

  /// Standard deduction of 30% on Net Annual Value (Section 24(a)).
  /// Applicable only when Net Annual Value is positive.
  double get standardDeduction30Percent =>
      netAnnualValue > 0 ? netAnnualValue * 0.30 : 0;

  /// Income (or loss) from house property after all Section 24 deductions.
  double get incomeFromHouseProperty =>
      netAnnualValue - standardDeduction30Percent - interestOnLoan;

  HousePropertyIncome copyWith({
    double? annualLetableValue,
    double? municipalTaxesPaid,
    double? interestOnLoan,
    PropertyType? propertyType,
  }) {
    return HousePropertyIncome(
      annualLetableValue: annualLetableValue ?? this.annualLetableValue,
      municipalTaxesPaid: municipalTaxesPaid ?? this.municipalTaxesPaid,
      interestOnLoan: interestOnLoan ?? this.interestOnLoan,
      propertyType: propertyType ?? this.propertyType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HousePropertyIncome &&
        other.annualLetableValue == annualLetableValue &&
        other.municipalTaxesPaid == municipalTaxesPaid &&
        other.interestOnLoan == interestOnLoan &&
        other.propertyType == propertyType;
  }

  @override
  int get hashCode => Object.hash(
    annualLetableValue,
    municipalTaxesPaid,
    interestOnLoan,
    propertyType,
  );
}
