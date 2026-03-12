/// ESI contribution breakdown for a single employee for one month.
///
/// Contributions per the Employees' State Insurance Act, 1948.
/// All monetary values are in paise (1/100th of a rupee).
///
/// ## Contribution rates (on ESI wage, only when wage ≤ ₹21,000/month)
/// - Employee share: 0.75%
/// - Employer share: 3.25%
///
/// When [isApplicable] is false, both contributions are 0.
class EsiContribution {
  const EsiContribution({
    required this.esiWagePaise,
    required this.employeeContributionPaise,
    required this.employerContributionPaise,
    required this.isApplicable,
  });

  /// ESI wage on which contributions are computed, in paise.
  final int esiWagePaise;

  /// Employee's 0.75% ESI contribution in paise (0 if not applicable).
  final int employeeContributionPaise;

  /// Employer's 3.25% ESI contribution in paise (0 if not applicable).
  final int employerContributionPaise;

  /// Whether ESI is applicable for this employee this month.
  ///
  /// False when the ESI wage exceeds the ₹21,000/month ceiling (2100000 paise).
  final bool isApplicable;

  /// ESI wage ceiling — ₹21,000/month (2100000 paise).
  static const int wageCeilingPaise = 2100000;

  /// Employee ESI rate: 0.75%.
  static const double employeeRate = 0.0075;

  /// Employer ESI rate: 3.25%.
  static const double employerRate = 0.0325;

  /// Total combined ESI contribution (employee + employer) in paise.
  int get totalContributionPaise =>
      employeeContributionPaise + employerContributionPaise;

  EsiContribution copyWith({
    int? esiWagePaise,
    int? employeeContributionPaise,
    int? employerContributionPaise,
    bool? isApplicable,
  }) {
    return EsiContribution(
      esiWagePaise: esiWagePaise ?? this.esiWagePaise,
      employeeContributionPaise:
          employeeContributionPaise ?? this.employeeContributionPaise,
      employerContributionPaise:
          employerContributionPaise ?? this.employerContributionPaise,
      isApplicable: isApplicable ?? this.isApplicable,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EsiContribution &&
        other.esiWagePaise == esiWagePaise &&
        other.employeeContributionPaise == employeeContributionPaise &&
        other.employerContributionPaise == employerContributionPaise &&
        other.isApplicable == isApplicable;
  }

  @override
  int get hashCode => Object.hash(
    esiWagePaise,
    employeeContributionPaise,
    employerContributionPaise,
    isApplicable,
  );

  @override
  String toString() =>
      'EsiContribution(wage: $esiWagePaise, employee: $employeeContributionPaise, '
      'employer: $employerContributionPaise, applicable: $isApplicable)';
}
