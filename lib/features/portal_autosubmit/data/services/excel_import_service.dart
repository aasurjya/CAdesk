import 'dart:typed_data';

import 'package:ca_app/features/portal_autosubmit/data/services/excel_import_models.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

/// Regular expression matching a valid Indian PAN:
/// 5 uppercase letters, 4 digits, 1 uppercase letter.
final RegExp _panPattern = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');

/// Canonical header names mapped to their expected column keys.
///
/// Keys are lowercased + trimmed versions of the expected header text.
const Map<String, String> _headerAliases = {
  'pan': 'pan',
  'name': 'name',
  'password': 'password',
  'portal': 'portal',
  'salary income': 'salaryIncome',
  'interest income': 'interestIncome',
  '80c deductions': 'deductions80C',
  '80d deductions': 'deductions80D',
  'bank account': 'bankAccount',
  'ifsc code': 'ifscCode',
};

/// Maps a portal string (case-insensitive) to a [PortalType] enum value.
///
/// Returns `null` if the string does not match any known portal.
PortalType? parsePortalType(String? raw) {
  if (raw == null || raw.trim().isEmpty) return PortalType.itd;
  switch (raw.trim().toUpperCase()) {
    case 'ITD':
      return PortalType.itd;
    case 'GSTN':
      return PortalType.gstn;
    case 'TRACES':
      return PortalType.traces;
    case 'MCA':
      return PortalType.mca;
    case 'EPFO':
      return PortalType.epfo;
    default:
      return null;
  }
}

/// Validates a PAN string against the Indian PAN format.
bool isValidPan(String? pan) {
  if (pan == null || pan.trim().isEmpty) return false;
  return _panPattern.hasMatch(pan.trim().toUpperCase());
}

/// Service that reads .xlsx files and parses client data for bulk import.
///
/// This service ONLY parses and validates — it does not write to the database.
/// The caller decides whether to persist the returned [ExcelImportResult].
class ExcelImportService {
  const ExcelImportService();

  /// Parses [bytes] as an .xlsx file and validates each data row.
  ///
  /// [encryptPassword] is called for every valid row's password before
  /// inclusion in the result. This allows callers to inject their own
  /// encryption strategy (e.g. [CredentialEncryptionService.encrypt]).
  ///
  /// Returns an [ExcelImportResult] containing valid rows, errors, and totals.
  Future<ExcelImportResult> parseExcelBytes({
    required Uint8List bytes,
    required Future<String> Function(String plaintext) encryptPassword,
  }) async {
    final SpreadsheetDecoder decoder;
    try {
      decoder = SpreadsheetDecoder.decodeBytes(bytes);
    } on Object {
      return const ExcelImportResult(
        validRows: [],
        errors: [
          ExcelImportError(
            rowNumber: 0,
            message: 'Failed to decode file. Ensure it is a valid .xlsx file.',
          ),
        ],
        totalRows: 0,
      );
    }

    if (decoder.tables.isEmpty) {
      return const ExcelImportResult(
        validRows: [],
        errors: [
          ExcelImportError(
            rowNumber: 0,
            message: 'Spreadsheet contains no sheets.',
          ),
        ],
        totalRows: 0,
      );
    }

    final sheet = decoder.tables.values.first;
    final rows = sheet.rows;

    if (rows.isEmpty) {
      return const ExcelImportResult(validRows: [], errors: [], totalRows: 0);
    }

    // Build column index map from header row.
    final headerMap = _buildHeaderMap(rows.first);
    if (headerMap == null) {
      return const ExcelImportResult(
        validRows: [],
        errors: [
          ExcelImportError(
            rowNumber: 1,
            message:
                'Header row is missing required columns: PAN, Name, Password.',
          ),
        ],
        totalRows: 0,
      );
    }

    final dataRows = rows.skip(1).toList();
    final validRows = <ExcelClientRow>[];
    final errors = <ExcelImportError>[];

    for (var i = 0; i < dataRows.length; i++) {
      final rowNumber = i + 2; // 1-based, header is row 1
      final row = dataRows[i];

      // Skip entirely blank rows.
      if (_isBlankRow(row)) continue;

      final rowErrors = <String>[];

      final rawPan = _cellString(row, headerMap['pan']);
      final rawName = _cellString(row, headerMap['name']);
      final rawPassword = _cellString(row, headerMap['password']);
      final rawPortal = _cellString(row, headerMap['portal']);

      // Validate required fields.
      if (rawPan == null || rawPan.trim().isEmpty) {
        rowErrors.add('PAN is required');
      } else if (!isValidPan(rawPan)) {
        rowErrors.add(
          'Invalid PAN format "$rawPan" — expected 5 letters + 4 digits + 1 letter',
        );
      }

      if (rawName == null || rawName.trim().isEmpty) {
        rowErrors.add('Name is required');
      }

      if (rawPassword == null || rawPassword.trim().isEmpty) {
        rowErrors.add('Password is required');
      }

      // Validate portal type if provided.
      final portalType = parsePortalType(rawPortal);
      if (portalType == null) {
        rowErrors.add(
          'Invalid portal "$rawPortal" — expected one of: ITD, GSTN, TRACES, MCA, EPFO',
        );
      }

      // Parse optional integer fields.
      final salaryIncome = _parseOptionalInt(
        row,
        headerMap['salaryIncome'],
        'Salary Income',
        rowErrors,
      );
      final interestIncome = _parseOptionalInt(
        row,
        headerMap['interestIncome'],
        'Interest Income',
        rowErrors,
      );
      final deductions80C = _parseOptionalInt(
        row,
        headerMap['deductions80C'],
        '80C Deductions',
        rowErrors,
      );
      final deductions80D = _parseOptionalInt(
        row,
        headerMap['deductions80D'],
        '80D Deductions',
        rowErrors,
      );

      final bankAccount = _cellString(row, headerMap['bankAccount']);
      final ifscCode = _cellString(row, headerMap['ifscCode']);

      if (rowErrors.isNotEmpty) {
        for (final msg in rowErrors) {
          errors.add(ExcelImportError(rowNumber: rowNumber, message: msg));
        }
        continue;
      }

      // Encrypt password for valid rows.
      final encrypted = await encryptPassword(rawPassword!.trim());

      validRows.add(
        ExcelClientRow(
          rowNumber: rowNumber,
          pan: rawPan!.trim().toUpperCase(),
          name: rawName!.trim(),
          encryptedPassword: encrypted,
          portalType: portalType!,
          salaryIncome: salaryIncome,
          interestIncome: interestIncome,
          deductions80C: deductions80C,
          deductions80D: deductions80D,
          bankAccount: bankAccount?.trim(),
          ifscCode: ifscCode?.trim(),
        ),
      );
    }

    return ExcelImportResult(
      validRows: List.unmodifiable(validRows),
      errors: List.unmodifiable(errors),
      totalRows: dataRows.where((r) => !_isBlankRow(r)).length,
    );
  }

  /// Builds a map from canonical column key to column index.
  ///
  /// Returns `null` if required columns (PAN, Name, Password) are missing.
  Map<String, int>? _buildHeaderMap(List<dynamic> headerRow) {
    final map = <String, int>{};

    for (var col = 0; col < headerRow.length; col++) {
      final raw = headerRow[col]?.toString().trim().toLowerCase();
      if (raw == null || raw.isEmpty) continue;
      final key = _headerAliases[raw];
      if (key != null) {
        map[key] = col;
      }
    }

    // Require PAN, Name, Password columns.
    if (!map.containsKey('pan') ||
        !map.containsKey('name') ||
        !map.containsKey('password')) {
      return null;
    }

    return map;
  }

  /// Extracts a string from a cell, returning `null` for empty/missing cells.
  String? _cellString(List<dynamic> row, int? colIndex) {
    if (colIndex == null || colIndex >= row.length) return null;
    final value = row[colIndex];
    if (value == null) return null;
    final str = value.toString().trim();
    return str.isEmpty ? null : str;
  }

  /// Parses an optional integer cell. Adds an error to [errors] if the cell
  /// contains a non-numeric, non-empty value.
  int? _parseOptionalInt(
    List<dynamic> row,
    int? colIndex,
    String fieldName,
    List<String> errors,
  ) {
    if (colIndex == null || colIndex >= row.length) return null;
    final value = row[colIndex];
    if (value == null) return null;

    if (value is int) return value;
    if (value is double) return value.toInt();

    final str = value.toString().trim();
    if (str.isEmpty) return null;

    final parsed = int.tryParse(str);
    if (parsed == null) {
      errors.add('$fieldName must be a number, got "$str"');
    }
    return parsed;
  }

  /// Returns `true` if every cell in the row is null or empty.
  bool _isBlankRow(List<dynamic> row) {
    return row.every((cell) => cell == null || cell.toString().trim().isEmpty);
  }
}
