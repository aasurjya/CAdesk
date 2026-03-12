/// Reason for filing an updated return under Section 139(8A).
enum UpdateReason {
  /// Return was not filed for the relevant assessment year.
  returnNotFiled('Return not filed'),

  /// Income was not reported in the original / revised return.
  incomeNotReported('Income not reported'),

  /// Income was reported under the wrong head of income.
  wrongHeadOfIncome('Wrong head of income'),

  /// Carry-forward loss was incorrectly claimed.
  reductionOfCarryForwardLoss('Reduction of carry-forward loss'),

  /// Wrong rate of tax was applied.
  wrongRateOfTax('Wrong rate of tax'),

  /// Any other reason not covered above.
  other('Other');

  const UpdateReason(this.label);
  final String label;
}

/// Immutable model for an Updated Return (ITR-U) filed under
/// Section 139(8A) of the Income Tax Act.
///
/// ITR-U can be filed within 24 months from the end of the relevant
/// assessment year. An additional tax of 25% (within 12 months) or
/// 50% (12–24 months) is payable on the additional tax liability.
class UpdatedReturn {
  const UpdatedReturn({
    required this.originalAckNumber,
    required this.originalFilingDate,
    required this.reasonForUpdate,
    required this.additionalTaxPercentage,
    required this.additionalIncome,
    required this.additionalTax,
  });

  /// Acknowledgement number of the original / revised return.
  final String originalAckNumber;

  /// Filing date of the original / revised return.
  final DateTime originalFilingDate;

  /// Reason for filing the updated return.
  final UpdateReason reasonForUpdate;

  /// Additional tax percentage: 25 (within 12 months) or 50 (12–24 months).
  final int additionalTaxPercentage;

  /// Additional income being declared in the updated return.
  final double additionalIncome;

  /// Additional tax liability on the newly declared income.
  final double additionalTax;

  /// Additional tax amount payable (percentage of additional tax).
  ///
  /// This is the penalty component: 25% or 50% of the additional tax.
  double get additionalTaxAmount =>
      additionalTax * additionalTaxPercentage / 100;

  /// Total tax payable = additional tax + additional tax amount (penalty).
  double get totalTaxPayable => additionalTax + additionalTaxAmount;

  UpdatedReturn copyWith({
    String? originalAckNumber,
    DateTime? originalFilingDate,
    UpdateReason? reasonForUpdate,
    int? additionalTaxPercentage,
    double? additionalIncome,
    double? additionalTax,
  }) {
    return UpdatedReturn(
      originalAckNumber: originalAckNumber ?? this.originalAckNumber,
      originalFilingDate: originalFilingDate ?? this.originalFilingDate,
      reasonForUpdate: reasonForUpdate ?? this.reasonForUpdate,
      additionalTaxPercentage:
          additionalTaxPercentage ?? this.additionalTaxPercentage,
      additionalIncome: additionalIncome ?? this.additionalIncome,
      additionalTax: additionalTax ?? this.additionalTax,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpdatedReturn &&
        other.originalAckNumber == originalAckNumber &&
        other.originalFilingDate == originalFilingDate &&
        other.reasonForUpdate == reasonForUpdate &&
        other.additionalTaxPercentage == additionalTaxPercentage &&
        other.additionalIncome == additionalIncome &&
        other.additionalTax == additionalTax;
  }

  @override
  int get hashCode => Object.hash(
    originalAckNumber,
    originalFilingDate,
    reasonForUpdate,
    additionalTaxPercentage,
    additionalIncome,
    additionalTax,
  );
}
