import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/filing/domain/models/itr1/salary_income.dart';
import 'package:ca_app/features/payroll/data/providers/payroll_providers.dart';
import 'package:ca_app/features/payroll/domain/models/employee.dart';
import 'package:ca_app/features/payroll/domain/models/payroll_month.dart';

// ---------------------------------------------------------------------------
// Immutable result model
// ---------------------------------------------------------------------------

/// Aggregated payroll data for prefilling ITR-1 salary income.
class PayrollPrefillResult {
  const PayrollPrefillResult({
    required this.salaryIncome,
    required this.tdsDeducted,
    required this.employerPfContribution,
    required this.employeeName,
    required this.monthCount,
  });

  /// SalaryIncome model ready for ITR-1 prefill.
  final SalaryIncome salaryIncome;

  /// Total TDS deducted across the financial year.
  final double tdsDeducted;

  /// Total employer PF contribution (useful for 80C prefill).
  final double employerPfContribution;

  /// Employee name for display in the picker.
  final String employeeName;

  /// Number of payslip months included in the aggregation.
  final int monthCount;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PayrollPrefillResult &&
        other.salaryIncome == salaryIncome &&
        other.tdsDeducted == tdsDeducted &&
        other.employerPfContribution == employerPfContribution &&
        other.employeeName == employeeName &&
        other.monthCount == monthCount;
  }

  @override
  int get hashCode => Object.hash(
    salaryIncome,
    tdsDeducted,
    employerPfContribution,
    employeeName,
    monthCount,
  );

  @override
  String toString() =>
      'PayrollPrefillResult(employee: $employeeName, months: $monthCount, '
      'gross: ${salaryIncome.grossSalary}, tds: $tdsDeducted)';
}

// ---------------------------------------------------------------------------
// Payroll Prefill Service — pure computation, no side effects
// ---------------------------------------------------------------------------

/// Aggregates monthly payroll records into annual salary income figures
/// for ITR-1 prefill.
///
/// All amounts follow the [SalaryIncome] convention (double, in INR).
class PayrollPrefillService {
  PayrollPrefillService._();
  static final instance = PayrollPrefillService._();

  /// Aggregates monthly [PayrollMonth] records for a financial year into
  /// a [SalaryIncome] model suitable for ITR-1.
  ///
  /// [payslips] must be the payroll records for one employee for the FY.
  SalaryIncome aggregateToSalaryIncome(List<PayrollMonth> payslips) {
    if (payslips.isEmpty) {
      return SalaryIncome.empty();
    }

    final grossSalary = payslips.fold<double>(0, (sum, p) => sum + p.grossPaid);

    // HRA and LTA exemptions are not separately tracked in PayrollMonth,
    // so we set Section 10 exemptions to zero (user can override manually).
    const allowancesExemptUnderSection10 = 0.0;

    // No perquisite components in the current payroll model.
    const valueOfPerquisites = 0.0;

    // No separate profit-in-lieu tracking in PayrollMonth.
    const profitsInLieuOfSalary = 0.0;

    // Standard deduction for new regime AY 2025-26 onwards: Rs 75,000.
    // Capped at gross salary if gross is lower.
    final standardDeduction = grossSalary < 75000 ? grossSalary : 75000.0;

    return SalaryIncome(
      grossSalary: grossSalary,
      allowancesExemptUnderSection10: allowancesExemptUnderSection10,
      valueOfPerquisites: valueOfPerquisites,
      profitsInLieuOfSalary: profitsInLieuOfSalary,
      standardDeduction: standardDeduction,
    );
  }

  /// Total TDS deducted from payroll across all months.
  double totalTdsDeducted(List<PayrollMonth> payslips) {
    return payslips.fold<double>(0, (sum, p) => sum + p.tdsDeducted);
  }

  /// Total employer PF contribution across all months.
  ///
  /// Employer PF mirrors employee PF at 12% of basic (capped at Rs 15,000).
  /// Since [PayrollMonth] only stores employee PF deducted, we use the same
  /// value as an approximation (employer share = employee share for standard
  /// PF contributions).
  double totalEmployerPfContribution(List<PayrollMonth> payslips) {
    return payslips.fold<double>(0, (sum, p) => sum + p.pfDeducted);
  }

  /// Total professional tax deducted across all months.
  ///
  /// Professional tax is not separately tracked in [PayrollMonth]; it is
  /// included in [PayrollMonth.otherDeductions]. We sum otherDeductions
  /// as a proxy (in the current mock data, otherDeductions = 0, so this
  /// returns 0 unless the data model is extended).
  double totalProfessionalTax(List<PayrollMonth> payslips) {
    return payslips.fold<double>(0, (sum, p) => sum + p.otherDeductions);
  }

  /// Builds a complete [PayrollPrefillResult] from payroll records.
  PayrollPrefillResult buildResult({
    required List<PayrollMonth> payslips,
    required String employeeName,
  }) {
    return PayrollPrefillResult(
      salaryIncome: aggregateToSalaryIncome(payslips),
      tdsDeducted: totalTdsDeducted(payslips),
      employerPfContribution: totalEmployerPfContribution(payslips),
      employeeName: employeeName,
      monthCount: payslips.length,
    );
  }
}

// ---------------------------------------------------------------------------
// Financial year helpers
// ---------------------------------------------------------------------------

/// Returns the start and end months for an Indian financial year.
///
/// FY 2025-26 runs Apr 2025 (month=4, year=2025) to Mar 2026 (month=3, year=2026).
({int startMonth, int startYear, int endMonth, int endYear}) _fyRange(
  int financialYear,
) {
  return (
    startMonth: 4,
    startYear: financialYear,
    endMonth: 3,
    endYear: financialYear + 1,
  );
}

/// Whether a [PayrollMonth] falls within the given financial year.
bool _isInFinancialYear(PayrollMonth record, int financialYear) {
  final fy = _fyRange(financialYear);

  // Apr–Dec of the start year
  if (record.year == fy.startYear && record.month >= fy.startMonth) {
    return true;
  }
  // Jan–Mar of the end year
  if (record.year == fy.endYear && record.month <= fy.endMonth) {
    return true;
  }
  return false;
}

// ---------------------------------------------------------------------------
// Riverpod Providers
// ---------------------------------------------------------------------------

/// Provides the singleton [PayrollPrefillService].
final payrollPrefillServiceProvider = Provider<PayrollPrefillService>(
  (_) => PayrollPrefillService.instance,
);

/// Parameter record for the annual summary provider.
typedef PayrollPrefillParams = ({String employeeId, int financialYear});

/// Fetches and aggregates payroll records for a specific employee and
/// financial year, returning a [PayrollPrefillResult].
///
/// Usage:
/// ```dart
/// final result = ref.watch(
///   payrollAnnualSummaryProvider(
///     (employeeId: 'emp-001', financialYear: 2025),
///   ),
/// );
/// ```
final payrollAnnualSummaryProvider =
    Provider.family<PayrollPrefillResult, PayrollPrefillParams>((ref, params) {
      final allPayroll = ref.watch(payrollMonthsProvider);
      final employees = ref.watch(employeesProvider);
      final service = ref.watch(payrollPrefillServiceProvider);

      // Filter payroll records for this employee in the given FY
      final employeePayslips = allPayroll
          .where(
            (record) =>
                record.employeeId == params.employeeId &&
                _isInFinancialYear(record, params.financialYear),
          )
          .toList();

      // Find employee name
      final employee = employees.cast<Employee?>().firstWhere(
        (e) => e?.id == params.employeeId,
        orElse: () => null,
      );

      return service.buildResult(
        payslips: employeePayslips,
        employeeName: employee?.name ?? 'Unknown Employee',
      );
    });

/// Provides the list of available financial years for payroll prefill.
///
/// Derived from the distinct financial years present in payroll data.
final payrollAvailableFYsProvider = Provider<List<int>>((ref) {
  final allPayroll = ref.watch(payrollMonthsProvider);

  final fySet = <int>{};
  for (final record in allPayroll) {
    // Apr-Dec belongs to FY starting that year
    if (record.month >= 4) {
      fySet.add(record.year);
    }
    // Jan-Mar belongs to FY starting previous year
    if (record.month <= 3) {
      fySet.add(record.year - 1);
    }
  }

  final sorted = fySet.toList()..sort((a, b) => b.compareTo(a));
  return List.unmodifiable(sorted);
});
