/// Represents the complete CTC (Cost to Company) salary package for an employee.
///
/// All monetary values are stored in paise (1/100th of a rupee) to avoid
/// floating-point rounding errors in payroll computations.
class SalaryPackage {
  const SalaryPackage({
    required this.basicPaise,
    required this.hraPaise,
    required this.specialAllowancePaise,
    required this.ltaPaise,
    required this.medicalPaise,
    required this.conveyancePaise,
    required this.pfWagePaise,
    required this.esiWagePaise,
  });

  /// Basic salary component in paise.
  final int basicPaise;

  /// House Rent Allowance in paise.
  final int hraPaise;

  /// Special allowance (flexible component) in paise.
  final int specialAllowancePaise;

  /// Leave Travel Allowance in paise.
  final int ltaPaise;

  /// Medical allowance in paise.
  final int medicalPaise;

  /// Conveyance allowance in paise.
  final int conveyancePaise;

  /// PF wage (Basic + DA) used for PF computation, in paise.
  ///
  /// Subject to a wage ceiling of ₹15,000 (1500000 paise) for statutory PF.
  final int pfWagePaise;

  /// ESI wage (gross CTC components for ESI) in paise.
  ///
  /// ESI is applicable only when this is ≤ ₹21,000/month (2100000 paise).
  final int esiWagePaise;

  /// Total gross monthly salary in paise.
  int get grossPaise =>
      basicPaise +
      hraPaise +
      specialAllowancePaise +
      ltaPaise +
      medicalPaise +
      conveyancePaise;

  SalaryPackage copyWith({
    int? basicPaise,
    int? hraPaise,
    int? specialAllowancePaise,
    int? ltaPaise,
    int? medicalPaise,
    int? conveyancePaise,
    int? pfWagePaise,
    int? esiWagePaise,
  }) {
    return SalaryPackage(
      basicPaise: basicPaise ?? this.basicPaise,
      hraPaise: hraPaise ?? this.hraPaise,
      specialAllowancePaise:
          specialAllowancePaise ?? this.specialAllowancePaise,
      ltaPaise: ltaPaise ?? this.ltaPaise,
      medicalPaise: medicalPaise ?? this.medicalPaise,
      conveyancePaise: conveyancePaise ?? this.conveyancePaise,
      pfWagePaise: pfWagePaise ?? this.pfWagePaise,
      esiWagePaise: esiWagePaise ?? this.esiWagePaise,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SalaryPackage &&
        other.basicPaise == basicPaise &&
        other.hraPaise == hraPaise &&
        other.specialAllowancePaise == specialAllowancePaise &&
        other.ltaPaise == ltaPaise &&
        other.medicalPaise == medicalPaise &&
        other.conveyancePaise == conveyancePaise &&
        other.pfWagePaise == pfWagePaise &&
        other.esiWagePaise == esiWagePaise;
  }

  @override
  int get hashCode => Object.hash(
    basicPaise,
    hraPaise,
    specialAllowancePaise,
    ltaPaise,
    medicalPaise,
    conveyancePaise,
    pfWagePaise,
    esiWagePaise,
  );

  @override
  String toString() =>
      'SalaryPackage(basic: $basicPaise, hra: $hraPaise, '
      'special: $specialAllowancePaise, lta: $ltaPaise, '
      'medical: $medicalPaise, conveyance: $conveyancePaise, '
      'pfWage: $pfWagePaise, esiWage: $esiWagePaise)';
}
