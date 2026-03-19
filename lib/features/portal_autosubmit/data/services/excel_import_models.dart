import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';

/// Immutable model representing a single parsed row from an Excel import.
class ExcelClientRow {
  const ExcelClientRow({
    required this.rowNumber,
    required this.pan,
    required this.name,
    required this.encryptedPassword,
    required this.portalType,
    this.salaryIncome,
    this.interestIncome,
    this.deductions80C,
    this.deductions80D,
    this.bankAccount,
    this.ifscCode,
  });

  /// 1-based row number from the spreadsheet (excluding the header).
  final int rowNumber;

  /// PAN (Permanent Account Number), validated format: 5 letters + 4 digits + 1 letter.
  final String pan;

  /// Client display name.
  final String name;

  /// Password encrypted via the caller-supplied callback.
  final String encryptedPassword;

  /// Target government portal.
  final PortalType portalType;

  /// Annual salary income in INR (optional).
  final int? salaryIncome;

  /// Annual interest income in INR (optional).
  final int? interestIncome;

  /// Section 80C deductions in INR (optional).
  final int? deductions80C;

  /// Section 80D deductions in INR (optional).
  final int? deductions80D;

  /// Bank account number (optional).
  final String? bankAccount;

  /// IFSC code for bank branch (optional).
  final String? ifscCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExcelClientRow &&
          runtimeType == other.runtimeType &&
          rowNumber == other.rowNumber &&
          pan == other.pan &&
          name == other.name &&
          encryptedPassword == other.encryptedPassword &&
          portalType == other.portalType &&
          salaryIncome == other.salaryIncome &&
          interestIncome == other.interestIncome &&
          deductions80C == other.deductions80C &&
          deductions80D == other.deductions80D &&
          bankAccount == other.bankAccount &&
          ifscCode == other.ifscCode;

  @override
  int get hashCode => Object.hash(
    rowNumber,
    pan,
    name,
    encryptedPassword,
    portalType,
    salaryIncome,
    interestIncome,
    deductions80C,
    deductions80D,
    bankAccount,
    ifscCode,
  );

  @override
  String toString() =>
      'ExcelClientRow(row: $rowNumber, pan: $pan, name: $name, '
      'portal: ${portalType.name})';
}

/// Immutable model representing a validation error for a specific row.
class ExcelImportError {
  const ExcelImportError({required this.rowNumber, required this.message});

  /// 1-based row number where the error occurred.
  final int rowNumber;

  /// Human-readable description of the validation failure.
  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExcelImportError &&
          runtimeType == other.runtimeType &&
          rowNumber == other.rowNumber &&
          message == other.message;

  @override
  int get hashCode => Object.hash(rowNumber, message);

  @override
  String toString() => 'ExcelImportError(row: $rowNumber, message: $message)';
}

/// Immutable result of parsing and validating an Excel import file.
class ExcelImportResult {
  const ExcelImportResult({
    required this.validRows,
    required this.errors,
    required this.totalRows,
  });

  /// Successfully parsed and validated rows.
  final List<ExcelClientRow> validRows;

  /// Validation errors collected across all rows.
  final List<ExcelImportError> errors;

  /// Total number of data rows in the spreadsheet (excluding header).
  final int totalRows;

  /// Whether the import has any valid rows ready for persistence.
  bool get hasValidRows => validRows.isNotEmpty;

  /// Whether the import encountered any validation errors.
  bool get hasErrors => errors.isNotEmpty;

  @override
  String toString() =>
      'ExcelImportResult(valid: ${validRows.length}, '
      'errors: ${errors.length}, total: $totalRows)';
}
