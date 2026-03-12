import 'package:ca_app/features/portal_export/tds_export/models/fvu_export_result.dart';
import 'package:ca_app/features/portal_export/tds_export/services/fvu_validator.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_file_structure.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';
import 'package:ca_app/features/tds/domain/services/fvu_generation_service.dart';

/// Stateless service for generating FVU export packages.
///
/// Delegates raw FVU text generation to [FvuGenerationService] (Phase 2),
/// then wraps the result in [FvuExportResult] with computed metadata and
/// validation errors.
class FvuFileGenerator {
  FvuFileGenerator._();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Generates an [FvuExportResult] from [structure] for the given [tanNumber].
  ///
  /// The result includes:
  /// - The complete FVU file text (via [FvuGenerationService])
  /// - Computed metadata: record count, challan count, form type, quarter
  /// - A suggested file name following the NSDL naming convention
  /// - Validation errors (empty list if valid)
  static FvuExportResult generate(
    FvuFileStructure structure,
    String tanNumber,
  ) {
    final rawContent = FvuGenerationService.generate(structure);
    final errors = FvuValidator.validateFvuContent(rawContent);

    final header = structure.batchHeader;
    final formType = _mapFormType(header.formType);
    final quarter = _mapQuarter(header.quarter);

    // Extract the starting calendar year from the financial year string
    // e.g. "2024-25" → 2024
    final financialYear = _parseFinancialYear(header.financialYear);

    final fileName = generateFileName(
      header.formType.label,
      header.quarterNumber,
      financialYear,
      tanNumber,
    );

    return FvuExportResult(
      formType: formType,
      quarter: quarter,
      financialYear: financialYear,
      tanNumber: tanNumber.trim().toUpperCase(),
      fvuFileContent: rawContent,
      fileName: fileName,
      recordCount: structure.totalDeducteeCount,
      challanCount: structure.totalChallanCount,
      validationErrors: errors,
    );
  }

  /// Generates an FVU file name following the NSDL naming convention.
  ///
  /// Format: `TDS_<FormType>_<Quarter>_<FY>_<TAN>.fvu`
  /// Example: `TDS_26Q_Q1_2024_AAATA1234X.fvu`
  ///
  /// - [formType]: form label string, e.g. "26Q", "24Q", "27EQ"
  /// - [quarter]: integer 1–4
  /// - [financialYear]: starting calendar year, e.g. 2024
  /// - [tan]: TAN of the deductor (converted to uppercase)
  static String generateFileName(
    String formType,
    int quarter,
    int financialYear,
    String tan,
  ) {
    final upperTan = tan.trim().toUpperCase();
    return 'TDS_${formType}_Q${quarter}_${financialYear}_$upperTan.fvu';
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static FvuExportFormType _mapFormType(TdsFormType formType) {
    switch (formType) {
      case TdsFormType.form24Q:
        return FvuExportFormType.form24Q;
      case TdsFormType.form26Q:
        return FvuExportFormType.form26Q;
      case TdsFormType.form27Q:
        return FvuExportFormType.form27Q;
      case TdsFormType.form27EQ:
        return FvuExportFormType.form27EQ;
    }
  }

  static FvuExportQuarter _mapQuarter(TdsQuarter quarter) {
    switch (quarter) {
      case TdsQuarter.q1:
        return FvuExportQuarter.q1;
      case TdsQuarter.q2:
        return FvuExportQuarter.q2;
      case TdsQuarter.q3:
        return FvuExportQuarter.q3;
      case TdsQuarter.q4:
        return FvuExportQuarter.q4;
    }
  }

  /// Parses the starting year from a financial year string like "2024-25".
  ///
  /// Returns 0 if parsing fails — callers treat this as an invalid FY.
  static int _parseFinancialYear(String financialYear) {
    final parts = financialYear.split('-');
    if (parts.isEmpty) return 0;
    return int.tryParse(parts[0].trim()) ?? 0;
  }
}
