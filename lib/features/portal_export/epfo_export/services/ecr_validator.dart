import 'package:ca_app/features/portal_export/epfo_export/models/ecr_member_row.dart';

/// Stateless singleton that validates EPFO ECR data and file content.
///
/// ## Validation scope
/// - UAN format (12-digit numeric)
/// - Establishment ID format (7-digit numeric)
/// - Member row business rules (wage caps, contribution rates, NCP range)
/// - ECR file content structure (header presence, field counts, sign checks)
class EcrValidator {
  EcrValidator._();

  /// Singleton instance.
  static final EcrValidator instance = EcrValidator._();

  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  /// EPS wage ceiling in paise (₹15,000).
  static const int _epsCeilingPaise = 1500000;

  /// Maximum NCP (Non-Contributing Period) days in any calendar month.
  static const int _maxNcpDays = 31;

  /// Employee EPF rate: 12%.
  static const double _employeeEpfRate = 0.12;

  /// Tolerance for floating-point rounding in contribution checks (paise).
  /// Allows ±2 paise deviation to accommodate rounding.
  static const int _contributionTolerancePaise = 2;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns true when [uan] is exactly 12 numeric digits.
  bool validateUan(String uan) =>
      RegExp(r'^\d{12}$').hasMatch(uan);

  /// Returns true when [estId] is exactly 7 numeric digits.
  bool validateEstablishmentId(String estId) =>
      RegExp(r'^\d{7}$').hasMatch(estId);

  /// Validates business rules for a single [EcrMemberRow].
  ///
  /// Returns a list of human-readable error messages; empty means valid.
  List<String> validateMemberRow(EcrMemberRow row) {
    final errors = <String>[];

    // UAN format
    if (!validateUan(row.uan)) {
      errors.add('UAN "${row.uan}" is invalid — must be exactly 12 digits.');
    }

    // Member name must not be blank
    if (row.memberName.trim().isEmpty) {
      errors.add('Member name must not be empty.');
    }

    // Gross wages must be non-negative
    if (row.grossWagesPaise < 0) {
      errors.add(
        'Gross wages (${row.grossWagesPaise}) must not be negative.',
      );
    }

    // EPF wages must not exceed gross wages
    if (row.epfWagesPaise > row.grossWagesPaise) {
      errors.add(
        'EPF wage (${row.epfWagesPaise}) must not exceed gross wage '
        '(${row.grossWagesPaise}).',
      );
    }

    // EPS wages must not exceed EPF wages
    if (row.epsWagesPaise > row.epfWagesPaise) {
      errors.add(
        'EPS wage (${row.epsWagesPaise}) must not exceed EPF wage '
        '(${row.epfWagesPaise}).',
      );
    }

    // EPS wages must not exceed ₹15,000 ceiling
    if (row.epsWagesPaise > _epsCeilingPaise) {
      errors.add(
        'EPS wage (${row.epsWagesPaise}) exceeds the ₹15,000 EPS ceiling '
        '($_epsCeilingPaise paise).',
      );
    }

    // Employee EPF ≈ 12% of EPF wages (within ±2 paise tolerance)
    if (row.epfWagesPaise > 0) {
      final expectedEpf = (row.epfWagesPaise * _employeeEpfRate).round();
      final diff = (row.employeeEpfPaise - expectedEpf).abs();
      if (diff > _contributionTolerancePaise) {
        errors.add(
          'Employee EPF contribution (${row.employeeEpfPaise}) does not match '
          '12% of EPF wages ($expectedEpf ± $_contributionTolerancePaise paise).',
        );
      }
    }

    // NCP days must be in range 0–31
    if (row.ncp < 0) {
      errors.add('NCP days (${row.ncp}) must not be negative.');
    }
    if (row.ncp > _maxNcpDays) {
      errors.add('NCP days (${row.ncp}) must not exceed $_maxNcpDays.');
    }

    return List.unmodifiable(errors);
  }

  /// Validates the structural integrity of a fully-rendered ECR file [content].
  ///
  /// Checks performed:
  /// - File is non-empty and has a valid EPFO ECR header
  /// - Each data row contains exactly 11 `#~#` separators (12 fields)
  /// - Each data row's first field is a valid 12-digit UAN
  /// - No wage field in any data row is negative
  ///
  /// Returns a list of human-readable error messages; empty means valid.
  List<String> validateEcrContent(String content) {
    final errors = <String>[];

    if (content.trim().isEmpty) {
      errors.add('ECR content is empty.');
      return List.unmodifiable(errors);
    }

    final lines = content
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // Check header presence
    if (lines.isEmpty || !lines.first.startsWith('#~#EPFO#~#ECR#~#V2.0#~#')) {
      errors.add(
        'ECR header is missing or malformed. '
        'Expected line starting with "#~#EPFO#~#ECR#~#V2.0#~#".',
      );
    }

    // Validate data rows (skip header line)
    final dataLines = lines.skip(1).toList();
    for (var i = 0; i < dataLines.length; i++) {
      final line = dataLines[i];
      final rowErrors = _validateDataLine(line, rowIndex: i + 1);
      errors.addAll(rowErrors);
    }

    return List.unmodifiable(errors);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Validates a single ECR data line (not the header).
  List<String> _validateDataLine(String line, {required int rowIndex}) {
    final errors = <String>[];

    // Count #~# occurrences — must be exactly 11
    final separatorCount = '#~#'.allMatches(line).length;
    if (separatorCount != 11) {
      errors.add(
        'Row $rowIndex: expected 11 field separators (#~#) but found '
        '$separatorCount. Check for missing or extra fields.',
      );
      // Cannot reliably parse further if separator count is wrong
      return errors;
    }

    // Split by #~# to get individual fields
    final fields = line.split('#~#').where((f) => f.isNotEmpty).toList();

    if (fields.isEmpty) {
      errors.add('Row $rowIndex: could not parse any fields.');
      return errors;
    }

    // Field 0: UAN
    final uan = fields[0];
    if (!validateUan(uan)) {
      errors.add(
        'Row $rowIndex: UAN "$uan" is invalid — must be exactly 12 digits.',
      );
    }

    // Fields 2–8: wage and contribution values must be non-negative integers
    // Indices in `fields`: gross=2, epfWage=3, epsWage=4, edliWage=5,
    //   empEpf=6, empEps=7, empEpfToFund=8
    const wageFieldIndices = [2, 3, 4, 5, 6, 7, 8];
    for (final idx in wageFieldIndices) {
      if (idx >= fields.length) break;
      final raw = fields[idx];
      final value = int.tryParse(raw);
      if (value == null || value < 0) {
        errors.add(
          'Row $rowIndex, field ${idx + 1}: "$raw" is negative or not a '
          'valid integer. Wage/contribution fields must be non-negative.',
        );
      }
    }

    return errors;
  }
}
