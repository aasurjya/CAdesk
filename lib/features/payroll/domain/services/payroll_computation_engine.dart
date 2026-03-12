import 'package:ca_app/features/payroll/domain/models/attendance_record.dart';
import 'package:ca_app/features/payroll/domain/models/esi_contribution.dart';
import 'package:ca_app/features/payroll/domain/models/pf_contribution.dart';
import 'package:ca_app/features/payroll/domain/models/payroll_run.dart';
import 'package:ca_app/features/payroll/domain/models/salary_package.dart';

/// Stateless service that performs the core payroll computation for a single
/// employee for a single month.
///
/// ## Computation flow
/// 1. Gross Pay = sum of all earning components in [SalaryPackage]
/// 2. LOP deduction = (Gross / totalDaysInMonth) × lopDays
/// 3. Gross after LOP = Gross − LOP
/// 4. PF employee contribution = 12% of effective PF wage (capped at ₹15,000)
/// 5. ESI employee contribution = 0.75% of ESI wage (if wage ≤ ₹21,000)
/// 6. Net pay = Gross after LOP − PF employee − ESI employee − TDS
class PayrollComputationEngine {
  PayrollComputationEngine._();

  /// Computes payroll for a single employee–month combination.
  ///
  /// Parameters:
  /// - [employeeId] — unique employee identifier.
  /// - [attendance] — attendance record for the month.
  /// - [package] — salary package (CTC components).
  /// - [month] — calendar month (1–12).
  /// - [year] — calendar year.
  /// - [monthlyTds] — TDS to deduct this month in paise.
  /// - [employeeName] — display name (defaults to empty; populate before
  ///   generating payslips or ECR).
  /// - [uan] — Universal Account Number (defaults to empty).
  /// - [runId] — optional run identifier; auto-generated if empty.
  static PayrollRun computePayroll({
    required String employeeId,
    required AttendanceRecord attendance,
    required SalaryPackage package,
    required int month,
    required int year,
    required int monthlyTds,
    String employeeName = '',
    String uan = '',
    String runId = '',
  }) {
    final grossPay = package.grossPaise;
    final totalDays = attendance.totalDaysInMonth;
    final lopDays = attendance.lopDays;

    // LOP deduction (integer division, truncated)
    final lopDeduction = lopDays > 0 ? (grossPay * lopDays) ~/ totalDays : 0;

    final grossAfterLop = grossPay - lopDeduction;

    final pf = _computePf(package.pfWagePaise);
    final esi = _computeEsi(package.esiWagePaise);

    final totalDeductions =
        pf.employeeSharePaise + esi.employeeContributionPaise + monthlyTds;

    final netPay = grossAfterLop - totalDeductions;

    final id = runId.isNotEmpty
        ? runId
        : '$employeeId-${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';

    return PayrollRun(
      runId: id,
      month: month,
      year: year,
      employeeId: employeeId,
      employeeName: employeeName,
      uan: uan,
      grossPayPaise: grossPay,
      lopDeductionPaise: lopDeduction,
      grossAfterLopPaise: grossAfterLop,
      deductionsPaise: totalDeductions,
      netPayPaise: netPay,
      tdsDeductedPaise: monthlyTds,
      pfContribution: pf,
      esiContribution: esi,
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Computes full PF contribution breakdown.
  ///
  /// Effective PF wage is capped at [PfContribution.wageCeilingPaise] (₹15,000).
  static PfContribution _computePf(int pfWagePaise) {
    final effectiveWage = pfWagePaise > PfContribution.wageCeilingPaise
        ? PfContribution.wageCeilingPaise
        : pfWagePaise;

    final employeeShare = (effectiveWage * 12) ~/ 100;

    // EPS = 8.33% of effective wage
    final eps = (effectiveWage * 833) ~/ 10000;
    final epf = employeeShare - eps;
    final adminCharges = (effectiveWage * 50) ~/ 10000; // 0.50%

    return PfContribution(
      pfWagePaise: effectiveWage,
      employeeSharePaise: employeeShare,
      employerEpsPaise: eps,
      employerEpfPaise: epf,
      adminChargesPaise: adminCharges,
    );
  }

  /// Computes ESI contribution breakdown.
  ///
  /// ESI is not applicable when ESI wage exceeds [EsiContribution.wageCeilingPaise]
  /// (₹21,000/month).
  static EsiContribution _computeEsi(int esiWagePaise) {
    final isApplicable =
        esiWagePaise > 0 && esiWagePaise <= EsiContribution.wageCeilingPaise;

    if (!isApplicable) {
      return const EsiContribution(
        esiWagePaise: 0,
        employeeContributionPaise: 0,
        employerContributionPaise: 0,
        isApplicable: false,
      );
    }

    // Employee 0.75% = wage * 75 / 10000
    final employeeEsi = (esiWagePaise * 75) ~/ 10000;
    // Employer 3.25% = wage * 325 / 10000
    final employerEsi = (esiWagePaise * 325) ~/ 10000;

    return EsiContribution(
      esiWagePaise: esiWagePaise,
      employeeContributionPaise: employeeEsi,
      employerContributionPaise: employerEsi,
      isApplicable: true,
    );
  }
}
