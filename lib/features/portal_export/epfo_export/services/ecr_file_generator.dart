import 'package:ca_app/features/payroll/domain/models/payroll_run.dart';
import 'package:ca_app/features/portal_export/epfo_export/models/ecr_export_result.dart';
import 'package:ca_app/features/portal_export/epfo_export/models/ecr_member_row.dart';
import 'package:ca_app/features/portal_export/epfo_export/services/ecr_validator.dart';

/// Stateless singleton that generates EPFO ECR v2.0 pipe-delimited files.
///
/// ## Output format
///
/// ```
/// #~#EPFO#~#ECR#~#V2.0#~#<estId>#~#<MM YYYY>#~#<memberCount>#~#
/// <UAN>#~#<Name>#~#<Gross>#~#<EPF>#~#<EPS>#~#<EDLI>#~#<EmpEPF>#~#<EmpEPS>#~#<EmpEPF>#~#<NCP>#~#<Refund>#~#
/// ...
/// ```
///
/// All monetary values in the ECR file are expressed in **rupees** (integer).
/// Internal paise values are divided by 100 when writing the file.
class EcrFileGenerator {
  EcrFileGenerator._();

  /// Singleton instance.
  static final EcrFileGenerator instance = EcrFileGenerator._();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Generates a complete ECR v2.0 file from a list of [PayrollRun] records.
  ///
  /// Parameters:
  /// - [runs] — payroll runs for one establishment, one wage month.
  /// - [establishmentId] — 7-digit EPFO establishment code.
  /// - [month] — wage month (1–12).
  /// - [year] — wage year (e.g. 2024).
  ///
  /// Returns an [EcrExportResult] containing the file content and metadata.
  /// When [runs] is empty, returns a result with empty [EcrExportResult.fileContent].
  EcrExportResult generate(
    List<PayrollRun> runs,
    String establishmentId,
    int month,
    int year,
  ) {
    final allErrors = <String>[];

    // Validate establishment ID upfront
    if (!EcrValidator.instance.validateEstablishmentId(establishmentId)) {
      allErrors.add(
        'Establishment ID "$establishmentId" is invalid — '
        'must be exactly 7 numeric digits.',
      );
    }

    if (runs.isEmpty) {
      return EcrExportResult(
        establishmentId: establishmentId,
        month: month,
        year: year,
        ecrType: EcrType.ecr1,
        fileContent: '',
        fileName: generateFileName(establishmentId, month, year),
        memberCount: 0,
        totalWages: 0,
        totalPfContribution: 0,
        validationErrors: List.unmodifiable(allErrors),
      );
    }

    final memberRows = buildMemberRows(runs);

    // Validate each member row
    for (final row in memberRows) {
      final rowErrors = EcrValidator.instance.validateMemberRow(row);
      allErrors.addAll(rowErrors);
    }

    final fileContent = _buildFileContent(
      memberRows,
      establishmentId,
      month,
      year,
    );

    final totalWages = runs.fold<int>(
      0,
      (sum, r) => sum + r.grossAfterLopPaise,
    );
    final totalPfContribution = runs.fold<int>(
      0,
      (sum, r) => sum + r.pfContribution.employeeSharePaise,
    );

    return EcrExportResult(
      establishmentId: establishmentId,
      month: month,
      year: year,
      ecrType: EcrType.ecr1,
      fileContent: fileContent,
      fileName: generateFileName(establishmentId, month, year),
      memberCount: memberRows.length,
      totalWages: totalWages,
      totalPfContribution: totalPfContribution,
      validationErrors: List.unmodifiable(allErrors),
    );
  }

  /// Maps a list of [PayrollRun] records to [EcrMemberRow] objects.
  ///
  /// EDLI wages and EPS wages are set equal to EPF wages per EPFO spec.
  List<EcrMemberRow> buildMemberRows(List<PayrollRun> runs) {
    return runs.map(_toMemberRow).toList(growable: false);
  }

  /// Builds the ECR v2.0 header line.
  ///
  /// Format: `#~#EPFO#~#ECR#~#V2.0#~#<estId>#~#<MM YYYY>#~#<memberCount>#~#`
  String generateHeader(
    String establishmentId,
    int month,
    int year,
    int memberCount,
  ) {
    final paddedMonth = month.toString().padLeft(2, '0');
    return '#~#EPFO#~#ECR#~#V2.0#~#$establishmentId#~#$paddedMonth $year#~#$memberCount#~#';
  }

  /// Builds a single ECR data row for one employee.
  ///
  /// Format (11 `#~#` separators, values in rupees):
  /// `<UAN>#~#<Name>#~#<Gross>#~#<EPF>#~#<EPS>#~#<EDLI>#~#<EmpEPF>#~#<EmpEPS>#~#<EmpEPFtoFund>#~#<NCP>#~#<Refund>#~#`
  String generateDetailRow(EcrMemberRow row) {
    final grossRupees = row.grossWagesPaise ~/ 100;
    final epfRupees = row.epfWagesPaise ~/ 100;
    final epsRupees = row.epsWagesPaise ~/ 100;
    final edliRupees = row.edliWagesPaise ~/ 100;
    final empEpfRupees = row.employeeEpfPaise ~/ 100;
    final empEpsRupees = row.employerEpsPaise ~/ 100;
    final empEpfToFundRupees = row.employerEpfPaise ~/ 100;
    final refundRupees = row.refundsPaise ~/ 100;

    return '${row.uan}#~#${row.memberName}#~#$grossRupees#~#$epfRupees'
        '#~#$epsRupees#~#$edliRupees#~#$empEpfRupees#~#$empEpsRupees'
        '#~#$empEpfToFundRupees#~#${row.ncp}#~#$refundRupees#~#';
  }

  /// Generates the ECR file name.
  ///
  /// Format: `ECR_<estId>_<MM><YYYY>.txt`
  String generateFileName(String establishmentId, int month, int year) {
    final paddedMonth = month.toString().padLeft(2, '0');
    return 'ECR_${establishmentId}_$paddedMonth$year.txt';
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  EcrMemberRow _toMemberRow(PayrollRun run) {
    return EcrMemberRow(
      uan: run.uan,
      memberName: run.employeeName,
      grossWagesPaise: run.grossAfterLopPaise,
      epfWagesPaise: run.pfContribution.pfWagePaise,
      epsWagesPaise: run.pfContribution.pfWagePaise, // EPS = EPF wage per spec
      edliWagesPaise: run.pfContribution.pfWagePaise, // EDLI = EPF wage per spec
      employeeEpfPaise: run.pfContribution.employeeSharePaise,
      employerEpsPaise: run.pfContribution.employerEpsPaise,
      employerEpfPaise: run.pfContribution.employerEpfPaise,
      ncp: _ncpFromLop(run),
      refundsPaise: 0,
    );
  }

  /// Derives NCP (Non-Contributing Period) days from LOP deduction.
  ///
  /// When there is no LOP deduction, NCP = 0.
  /// Otherwise, infers days from the proportion of gross pay deducted as LOP.
  /// Uses a 30-day month for proportioning as a conservative default.
  int _ncpFromLop(PayrollRun run) {
    if (run.lopDeductionPaise <= 0) return 0;
    if (run.grossPayPaise <= 0) return 0;

    const assumedWorkingDays = 30;
    final lopRatio = run.lopDeductionPaise / run.grossPayPaise;
    return (lopRatio * assumedWorkingDays).round().clamp(0, 31);
  }

  String _buildFileContent(
    List<EcrMemberRow> rows,
    String establishmentId,
    int month,
    int year,
  ) {
    final buffer = StringBuffer();
    buffer.writeln(generateHeader(establishmentId, month, year, rows.length));
    for (final row in rows) {
      buffer.writeln(generateDetailRow(row));
    }
    return buffer.toString();
  }
}
