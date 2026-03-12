import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/domain/models/reconciliation/ais_entry.dart';
import 'package:ca_app/features/filing/domain/models/reconciliation/form_26as_entry.dart';

/// Match status after reconciling a reported amount against declared income.
enum MatchStatus {
  /// Amounts match within tolerance.
  matched('Matched'),

  /// Declared amount is less than reported — potential under-reporting.
  underReported('Under-Reported'),

  /// Declared amount exceeds reported — possible over-reporting.
  overReported('Over-Reported'),

  /// Entry exists in source but has no corresponding declaration.
  missing('Missing');

  const MatchStatus(this.label);
  final String label;
}

/// Immutable result of reconciling a single income entry.
class ReconciliationResult {
  const ReconciliationResult({
    required this.source,
    required this.reportedAmount,
    required this.declaredAmount,
    required this.discrepancy,
    required this.status,
  });

  /// Description of the income source being reconciled.
  final String source;

  /// Amount reported in 26AS / AIS.
  final double reportedAmount;

  /// Amount declared in the ITR form.
  final double declaredAmount;

  /// Difference: declaredAmount – reportedAmount.
  final double discrepancy;

  /// Reconciliation match status.
  final MatchStatus status;

  ReconciliationResult copyWith({
    String? source,
    double? reportedAmount,
    double? declaredAmount,
    double? discrepancy,
    MatchStatus? status,
  }) {
    return ReconciliationResult(
      source: source ?? this.source,
      reportedAmount: reportedAmount ?? this.reportedAmount,
      declaredAmount: declaredAmount ?? this.declaredAmount,
      discrepancy: discrepancy ?? this.discrepancy,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReconciliationResult &&
        other.source == source &&
        other.reportedAmount == reportedAmount &&
        other.declaredAmount == declaredAmount &&
        other.discrepancy == discrepancy &&
        other.status == status;
  }

  @override
  int get hashCode =>
      Object.hash(source, reportedAmount, declaredAmount, discrepancy, status);
}

/// Stateless engine that reconciles Form 26AS and AIS entries against
/// declared income in ITR form data.
///
/// Every method returns a new list — no mutation of inputs.
class ReconciliationEngine {
  const ReconciliationEngine._();

  /// Tolerance in INR for considering amounts as matched.
  static const double _tolerance = 1.0;

  /// Reconcile Form 26AS entries against ITR-1 form data.
  ///
  /// Groups 26AS TDS-salary entries and compares against declared
  /// gross salary. Non-salary TDS entries are compared against
  /// other-source income.
  static List<ReconciliationResult> reconcile26AS(
    List<Form26ASEntry> entries,
    Itr1FormData form,
  ) {
    final results = <ReconciliationResult>[];

    // Aggregate salary TDS entries
    final salaryEntries = entries.where(
      (e) => e.entryType == TdsEntryType.tdsSalary,
    );
    if (salaryEntries.isNotEmpty) {
      final totalSalaryReported = salaryEntries.fold(
        0.0,
        (sum, e) => sum + e.grossAmount,
      );
      final declaredSalary = form.salaryIncome.grossSalary;
      results.add(
        _buildResult(
          source: '26AS — Salary (TDS)',
          reported: totalSalaryReported,
          declared: declaredSalary,
        ),
      );
    }

    // Aggregate non-salary TDS entries
    final nonSalaryEntries = entries.where(
      (e) => e.entryType == TdsEntryType.tdsNonSalary,
    );
    if (nonSalaryEntries.isNotEmpty) {
      final totalNonSalaryReported = nonSalaryEntries.fold(
        0.0,
        (sum, e) => sum + e.grossAmount,
      );
      final declaredOther = form.otherSourceIncome.total;
      results.add(
        _buildResult(
          source: '26AS — Non-Salary (TDS)',
          reported: totalNonSalaryReported,
          declared: declaredOther,
        ),
      );
    }

    return results;
  }

  /// Reconcile AIS entries against ITR-1 form data.
  ///
  /// Maps each AIS category to the corresponding head of income
  /// declared in the ITR and produces a reconciliation result.
  static List<ReconciliationResult> reconcileAIS(
    List<AisEntry> entries,
    Itr1FormData form,
  ) {
    final results = <ReconciliationResult>[];

    for (final entry in entries) {
      final declared = _mapAisCategoryToDeclared(entry.category, form);
      results.add(
        _buildResult(
          source: 'AIS — ${entry.category.label} (${entry.informationSource})',
          reported: entry.reportedAmount,
          declared: declared,
        ),
      );
    }

    return results;
  }

  /// Maps an AIS category to the corresponding declared amount in the form.
  static double _mapAisCategoryToDeclared(
    AisCategory category,
    Itr1FormData form,
  ) {
    switch (category) {
      case AisCategory.salary:
        return form.salaryIncome.grossSalary;
      case AisCategory.interest:
        return form.otherSourceIncome.savingsAccountInterest +
            form.otherSourceIncome.fixedDepositInterest;
      case AisCategory.dividend:
        return form.otherSourceIncome.dividendIncome;
      case AisCategory.saleOfSecurities:
      case AisCategory.purchase:
      case AisCategory.otherIncome:
        return form.otherSourceIncome.total;
    }
  }

  /// Builds a [ReconciliationResult] from reported and declared amounts.
  static ReconciliationResult _buildResult({
    required String source,
    required double reported,
    required double declared,
  }) {
    final discrepancy = declared - reported;
    final status = _determineStatus(reported, declared);
    return ReconciliationResult(
      source: source,
      reportedAmount: reported,
      declaredAmount: declared,
      discrepancy: discrepancy,
      status: status,
    );
  }

  /// Determines match status based on the difference between amounts.
  static MatchStatus _determineStatus(double reported, double declared) {
    final diff = declared - reported;
    if (diff.abs() <= _tolerance) return MatchStatus.matched;
    if (declared == 0 && reported > 0) return MatchStatus.missing;
    if (diff < 0) return MatchStatus.underReported;
    return MatchStatus.overReported;
  }
}
