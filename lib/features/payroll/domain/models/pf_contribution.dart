/// PF contribution breakdown for a single employee for one month.
///
/// Statutory PF contributions per the Employees' Provident Fund Act, 1952.
/// All monetary values are in paise (1/100th of a rupee).
///
/// ## Contribution rates (on PF wage, capped at ₹15,000)
/// - Employee share: 12%
/// - Employer EPS (Employees' Pension Scheme): 8.33% (min ₹1,250 if wage ≤ ₹15,000)
/// - Employer EPF (balance after EPS): 3.67%
/// - Admin charges: 0.50% on EPF wages
class PfContribution {
  const PfContribution({
    required this.pfWagePaise,
    required this.employeeSharePaise,
    required this.employerEpsPaise,
    required this.employerEpfPaise,
    required this.adminChargesPaise,
  });

  /// PF wage on which contributions are computed (capped at 1500000 paise).
  final int pfWagePaise;

  /// Employee's 12% contribution in paise.
  final int employeeSharePaise;

  /// Employer's EPS contribution (8.33%) in paise.
  final int employerEpsPaise;

  /// Employer's EPF contribution (12% − EPS) in paise.
  final int employerEpfPaise;

  /// EPFO admin charges (0.50%) in paise.
  final int adminChargesPaise;

  /// Total employer contribution (EPS + EPF + admin charges) in paise.
  int get totalEmployerPaise =>
      employerEpsPaise + employerEpfPaise + adminChargesPaise;

  /// PF wage ceiling — ₹15,000 (1500000 paise).
  static const int wageCeilingPaise = 1500000;

  /// Minimum EPS contribution when PF wage is at or below ceiling.
  static const int minEpsContributionPaise = 125000; // ₹1,250

  PfContribution copyWith({
    int? pfWagePaise,
    int? employeeSharePaise,
    int? employerEpsPaise,
    int? employerEpfPaise,
    int? adminChargesPaise,
  }) {
    return PfContribution(
      pfWagePaise: pfWagePaise ?? this.pfWagePaise,
      employeeSharePaise: employeeSharePaise ?? this.employeeSharePaise,
      employerEpsPaise: employerEpsPaise ?? this.employerEpsPaise,
      employerEpfPaise: employerEpfPaise ?? this.employerEpfPaise,
      adminChargesPaise: adminChargesPaise ?? this.adminChargesPaise,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PfContribution &&
        other.pfWagePaise == pfWagePaise &&
        other.employeeSharePaise == employeeSharePaise &&
        other.employerEpsPaise == employerEpsPaise &&
        other.employerEpfPaise == employerEpfPaise &&
        other.adminChargesPaise == adminChargesPaise;
  }

  @override
  int get hashCode => Object.hash(
    pfWagePaise,
    employeeSharePaise,
    employerEpsPaise,
    employerEpfPaise,
    adminChargesPaise,
  );

  @override
  String toString() =>
      'PfContribution(wage: $pfWagePaise, employee: $employeeSharePaise, '
      'eps: $employerEpsPaise, epf: $employerEpfPaise, '
      'admin: $adminChargesPaise)';
}
