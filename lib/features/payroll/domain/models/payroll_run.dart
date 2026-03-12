import 'package:ca_app/features/payroll/domain/models/esi_contribution.dart';
import 'package:ca_app/features/payroll/domain/models/pf_contribution.dart';

/// Result of a single payroll computation for one employee for one month.
///
/// Captures gross pay, all deductions, net pay, and statutory contributions.
/// All monetary values are in paise (1/100th of a rupee).
class PayrollRun {
  const PayrollRun({
    required this.runId,
    required this.month,
    required this.year,
    required this.employeeId,
    required this.employeeName,
    required this.uan,
    required this.grossPayPaise,
    required this.lopDeductionPaise,
    required this.grossAfterLopPaise,
    required this.deductionsPaise,
    required this.netPayPaise,
    required this.tdsDeductedPaise,
    required this.pfContribution,
    required this.esiContribution,
  });

  /// Unique identifier for this payroll run.
  final String runId;

  /// Calendar month (1–12).
  final int month;

  /// Calendar year (e.g. 2025).
  final int year;

  /// Employee identifier.
  final String employeeId;

  /// Employee display name (for reports and ECR).
  final String employeeName;

  /// Universal Account Number for EPFO filings.
  final String uan;

  /// Total gross pay (sum of all earning components) in paise.
  final int grossPayPaise;

  /// LOP (Loss of Pay) deduction amount in paise.
  final int lopDeductionPaise;

  /// Gross pay after LOP deduction in paise.
  final int grossAfterLopPaise;

  /// Total statutory and voluntary deductions (PF + ESI + TDS + others) in paise.
  final int deductionsPaise;

  /// Net take-home pay in paise.
  final int netPayPaise;

  /// TDS deducted this month in paise.
  final int tdsDeductedPaise;

  /// Breakdown of PF contributions (employee + employer splits).
  final PfContribution pfContribution;

  /// Breakdown of ESI contributions (employee + employer).
  final EsiContribution esiContribution;

  PayrollRun copyWith({
    String? runId,
    int? month,
    int? year,
    String? employeeId,
    String? employeeName,
    String? uan,
    int? grossPayPaise,
    int? lopDeductionPaise,
    int? grossAfterLopPaise,
    int? deductionsPaise,
    int? netPayPaise,
    int? tdsDeductedPaise,
    PfContribution? pfContribution,
    EsiContribution? esiContribution,
  }) {
    return PayrollRun(
      runId: runId ?? this.runId,
      month: month ?? this.month,
      year: year ?? this.year,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      uan: uan ?? this.uan,
      grossPayPaise: grossPayPaise ?? this.grossPayPaise,
      lopDeductionPaise: lopDeductionPaise ?? this.lopDeductionPaise,
      grossAfterLopPaise: grossAfterLopPaise ?? this.grossAfterLopPaise,
      deductionsPaise: deductionsPaise ?? this.deductionsPaise,
      netPayPaise: netPayPaise ?? this.netPayPaise,
      tdsDeductedPaise: tdsDeductedPaise ?? this.tdsDeductedPaise,
      pfContribution: pfContribution ?? this.pfContribution,
      esiContribution: esiContribution ?? this.esiContribution,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PayrollRun &&
        other.runId == runId &&
        other.month == month &&
        other.year == year &&
        other.employeeId == employeeId &&
        other.employeeName == employeeName &&
        other.uan == uan &&
        other.grossPayPaise == grossPayPaise &&
        other.lopDeductionPaise == lopDeductionPaise &&
        other.grossAfterLopPaise == grossAfterLopPaise &&
        other.deductionsPaise == deductionsPaise &&
        other.netPayPaise == netPayPaise &&
        other.tdsDeductedPaise == tdsDeductedPaise &&
        other.pfContribution == pfContribution &&
        other.esiContribution == esiContribution;
  }

  @override
  int get hashCode => Object.hash(
    runId,
    month,
    year,
    employeeId,
    employeeName,
    uan,
    grossPayPaise,
    lopDeductionPaise,
    grossAfterLopPaise,
    deductionsPaise,
    netPayPaise,
    tdsDeductedPaise,
    pfContribution,
    esiContribution,
  );

  @override
  String toString() =>
      'PayrollRun(id: $runId, employee: $employeeId, $month/$year, '
      'gross: $grossPayPaise, net: $netPayPaise)';
}
