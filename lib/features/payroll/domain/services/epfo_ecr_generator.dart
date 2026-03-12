import 'package:ca_app/features/payroll/domain/models/payroll_run.dart';

/// Stateless service that generates EPFO ECR (Electronic Challan cum Return)
/// files in the pipe-delimited format prescribed by EPFO.
///
/// ## ECR Format
/// **Header line:**
/// ```
/// #~# ESTCODE | WAGE_MONTH | WAGE_YEAR | NO_OF_EMPLOYEES | TOTAL_PF_WAGES #~#
/// ```
///
/// **Detail rows (one per employee):**
/// ```
/// UAN | NAME | GROSS_WAGES | EPF_WAGES | EPS_WAGES | EPF_CONTRIBUTION | EPS_CONTRIBUTION | EMPLOYEE_SHARE | EMPLOYER_SHARE
/// ```
///
/// All wage and contribution values in the ECR are expressed in **rupees**
/// (not paise) as integers. Conversion: paise ÷ 100.
class EpfoEcrGenerator {
  EpfoEcrGenerator._();

  /// Generates an EPFO ECR text file for a batch of payroll runs.
  ///
  /// Parameters:
  /// - [runs] — list of [PayrollRun] for one establishment for one month.
  /// - [establishmentId] — EPFO establishment code (e.g. `MHBAN0001234000`).
  /// - [month] — wage month (1–12).
  /// - [year] — wage year (e.g. 2025).
  ///
  /// Returns an empty string when [runs] is empty.
  static String generateEcr({
    required List<PayrollRun> runs,
    required String establishmentId,
    required int month,
    required int year,
  }) {
    if (runs.isEmpty) return '';

    final buffer = StringBuffer();

    // Header
    buffer.writeln(_buildHeader(runs, establishmentId, month, year));

    // Detail rows
    for (final run in runs) {
      buffer.writeln(_buildDetailRow(run));
    }

    // Remove trailing newline added by the last writeln
    final result = buffer.toString().trimRight();
    return result;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static String _buildHeader(
    List<PayrollRun> runs,
    String establishmentId,
    int month,
    int year,
  ) {
    final wageMonth = month.toString().padLeft(2, '0');
    final totalEmployees = runs.length;
    final totalPfWagesRupees = runs.fold<int>(
      0,
      (sum, r) => sum + (r.pfContribution.pfWagePaise ~/ 100),
    );

    return '#~# $establishmentId | $wageMonth | $year | $totalEmployees | $totalPfWagesRupees #~#';
  }

  static String _buildDetailRow(PayrollRun run) {
    final grossRupees = run.grossAfterLopPaise ~/ 100;
    final epfWageRupees = run.pfContribution.pfWagePaise ~/ 100;
    // EPS wage = same as EPF wage per EPFO spec
    final epsWageRupees = epfWageRupees;
    final epfContribRupees = run.pfContribution.employerEpfPaise ~/ 100;
    final epsContribRupees = run.pfContribution.employerEpsPaise ~/ 100;
    final employeeShareRupees = run.pfContribution.employeeSharePaise ~/ 100;
    final employerShareRupees =
        (run.pfContribution.employerEpfPaise +
            run.pfContribution.employerEpsPaise) ~/
        100;

    final fields = [
      run.uan,
      run.employeeName,
      grossRupees.toString(),
      epfWageRupees.toString(),
      epsWageRupees.toString(),
      epfContribRupees.toString(),
      epsContribRupees.toString(),
      employeeShareRupees.toString(),
      employerShareRupees.toString(),
    ];

    return fields.join(' | ');
  }
}
