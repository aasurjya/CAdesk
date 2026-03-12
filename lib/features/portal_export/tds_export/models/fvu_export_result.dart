import 'package:flutter/foundation.dart';

/// Form type for the FVU export.
enum FvuExportFormType {
  form24Q,
  form26Q,
  form27Q,
  form27EQ;

  /// Returns the label string used in FVU file naming.
  String get label {
    switch (this) {
      case FvuExportFormType.form24Q:
        return '24Q';
      case FvuExportFormType.form26Q:
        return '26Q';
      case FvuExportFormType.form27Q:
        return '27Q';
      case FvuExportFormType.form27EQ:
        return '27EQ';
    }
  }
}

/// Financial year quarter for the FVU export.
enum FvuExportQuarter {
  q1,
  q2,
  q3,
  q4;

  /// Returns the label string used in FVU file naming (e.g. "Q1").
  String get label {
    switch (this) {
      case FvuExportQuarter.q1:
        return 'Q1';
      case FvuExportQuarter.q2:
        return 'Q2';
      case FvuExportQuarter.q3:
        return 'Q3';
      case FvuExportQuarter.q4:
        return 'Q4';
    }
  }

  /// Returns the integer quarter number (1–4).
  int get number {
    switch (this) {
      case FvuExportQuarter.q1:
        return 1;
      case FvuExportQuarter.q2:
        return 2;
      case FvuExportQuarter.q3:
        return 3;
      case FvuExportQuarter.q4:
        return 4;
    }
  }
}

/// Immutable result of generating an FVU file for NSDL/TIN 2.0 submission.
///
/// Contains the complete FVU text content ready to be saved as a `.fvu` file,
/// along with metadata about the return and any validation errors found.
@immutable
class FvuExportResult {
  const FvuExportResult({
    required this.formType,
    required this.quarter,
    required this.financialYear,
    required this.tanNumber,
    required this.fvuFileContent,
    required this.fileName,
    required this.recordCount,
    required this.challanCount,
    required this.validationErrors,
  });

  /// The TDS return form type.
  final FvuExportFormType formType;

  /// The financial year quarter of the return.
  final FvuExportQuarter quarter;

  /// The starting calendar year of the financial year (e.g. 2024 for FY 2024-25).
  final int financialYear;

  /// TAN number of the deductor.
  final String tanNumber;

  /// The complete FVU file text content, ready to save as a `.fvu` file.
  final String fvuFileContent;

  /// The suggested file name (e.g. "TDS_26Q_Q1_2024_AAATA1234X.fvu").
  final String fileName;

  /// Total number of deductee (DD) records in the FVU file.
  final int recordCount;

  /// Total number of challan (CD) records in the FVU file.
  final int challanCount;

  /// List of validation errors found during FVU generation.
  /// Empty means the FVU content is valid for submission.
  final List<String> validationErrors;

  // ---------------------------------------------------------------------------
  // Derived
  // ---------------------------------------------------------------------------

  /// Returns true when there are no validation errors.
  bool get isValid => validationErrors.isEmpty;

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  FvuExportResult copyWith({
    FvuExportFormType? formType,
    FvuExportQuarter? quarter,
    int? financialYear,
    String? tanNumber,
    String? fvuFileContent,
    String? fileName,
    int? recordCount,
    int? challanCount,
    List<String>? validationErrors,
  }) {
    return FvuExportResult(
      formType: formType ?? this.formType,
      quarter: quarter ?? this.quarter,
      financialYear: financialYear ?? this.financialYear,
      tanNumber: tanNumber ?? this.tanNumber,
      fvuFileContent: fvuFileContent ?? this.fvuFileContent,
      fileName: fileName ?? this.fileName,
      recordCount: recordCount ?? this.recordCount,
      challanCount: challanCount ?? this.challanCount,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FvuExportResult &&
          runtimeType == other.runtimeType &&
          formType == other.formType &&
          quarter == other.quarter &&
          financialYear == other.financialYear &&
          tanNumber == other.tanNumber &&
          fvuFileContent == other.fvuFileContent &&
          fileName == other.fileName &&
          recordCount == other.recordCount &&
          challanCount == other.challanCount &&
          _listEquals(validationErrors, other.validationErrors);

  @override
  int get hashCode => Object.hash(
    formType,
    quarter,
    financialYear,
    tanNumber,
    fvuFileContent,
    fileName,
    recordCount,
    challanCount,
    Object.hashAll(validationErrors),
  );

  @override
  String toString() =>
      'FvuExportResult(tan: $tanNumber, form: ${formType.label}, '
      'quarter: ${quarter.label}, fy: $financialYear, '
      'challans: $challanCount, records: $recordCount, '
      'valid: $isValid)';
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
