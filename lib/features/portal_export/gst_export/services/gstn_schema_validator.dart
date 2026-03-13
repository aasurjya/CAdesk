import 'dart:convert';

import 'package:ca_app/features/portal_export/gst_export/models/gstr_export_result.dart';

/// Stateless validator for GSTN API payload schemas and field constraints.
///
/// Validates GSTIN format, period format, and payload-level amount rules.
/// All validation methods return either a bool (field-level) or a list of
/// human-readable error strings (payload-level) for UI presentation.
class GstnSchemaValidator {
  GstnSchemaValidator._();

  static final GstnSchemaValidator instance = GstnSchemaValidator._();

  // Valid state codes: 01–38 (India states + UTs as per GSTN numbering).
  static const int _minStateCode = 1;
  static const int _maxStateCode = 38;

  // GSTIN regex: 2-digit state code + 10-char PAN + entity digit + Z + check digit
  // Pattern: [0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][0-9A-Z]Z[0-9A-Z]
  static final RegExp _gstinPattern = RegExp(
    r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][0-9A-Z]Z[0-9A-Z]$',
  );

  static final RegExp _periodPattern = RegExp(r'^[0-9]{2}[0-9]{4}$');

  /// Validates that [gstin] is a properly formatted 15-character GSTIN.
  ///
  /// Rules enforced:
  /// - Must be exactly 15 uppercase alphanumeric characters.
  /// - First two digits must be a valid state code (01–38).
  /// - Must match the GSTN structural pattern.
  bool validateGstin(String gstin) {
    if (gstin.length != 15) return false;
    if (!_gstinPattern.hasMatch(gstin)) return false;

    final stateCode = int.tryParse(gstin.substring(0, 2));
    if (stateCode == null) return false;
    if (stateCode < _minStateCode || stateCode > _maxStateCode) return false;

    return true;
  }

  /// Validates that [period] is in MMYYYY format with a valid month (01–12).
  bool validatePeriod(String period) {
    if (period.length != 6) return false;
    if (!_periodPattern.hasMatch(period)) return false;

    final month = int.tryParse(period.substring(0, 2));
    if (month == null || month < 1 || month > 12) return false;

    return true;
  }

  /// Validates a [GstrExportResult] for GSTR-1 against GSTN schema rules.
  ///
  /// Returns a list of human-readable error strings.
  /// An empty list means the payload is valid.
  List<String> validateGstr1(GstrExportResult result) {
    final errors = <String>[];

    if (result.returnType != GstrReturnType.gstr1) {
      errors.add('Return type must be gstr1 but got ${result.returnType.name}');
    }

    if (!validateGstin(result.gstin)) {
      errors.add('Invalid GSTIN: ${result.gstin}');
    }

    if (!validatePeriod(result.period)) {
      errors.add('Invalid period format: ${result.period}. Expected MMYYYY.');
    }

    try {
      final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
      _checkNegativeAmountsGstr1(json, errors);
    } on FormatException catch (e) {
      errors.add('JSON parse error: $e');
    }

    return List.unmodifiable(errors);
  }

  /// Validates a [GstrExportResult] for GSTR-3B against GSTN schema rules.
  ///
  /// Returns a list of human-readable error strings.
  /// An empty list means the payload is valid.
  List<String> validateGstr3b(GstrExportResult result) {
    final errors = <String>[];

    if (result.returnType != GstrReturnType.gstr3b) {
      errors.add(
        'Return type must be gstr3b but got ${result.returnType.name}',
      );
    }

    if (!validateGstin(result.gstin)) {
      errors.add('Invalid GSTIN: ${result.gstin}');
    }

    if (!validatePeriod(result.period)) {
      errors.add('Invalid period format: ${result.period}. Expected MMYYYY.');
    }

    try {
      final json = jsonDecode(result.jsonPayload) as Map<String, Object?>;
      _checkNegativeAmountsGstr3b(json, errors);
    } on FormatException catch (e) {
      errors.add('JSON parse error: $e');
    }

    return List.unmodifiable(errors);
  }

  // ---------------------------------------------------------------------------
  // Private amount checkers
  // ---------------------------------------------------------------------------

  void _checkNegativeAmountsGstr1(
    Map<String, Object?> json,
    List<String> errors,
  ) {
    final b2b = json['b2b'];
    if (b2b is List) {
      for (final entry in b2b.cast<Map<String, Object?>>()) {
        final invList = entry['inv'];
        if (invList is! List) continue;
        for (final inv in invList.cast<Map<String, Object?>>()) {
          final itms = inv['itms'];
          if (itms is! List) continue;
          for (final item in itms.cast<Map<String, Object?>>()) {
            final det = item['itm_det'];
            if (det is! Map<String, Object?>) continue;
            _assertAmountNonNegative(det, 'txval', 'b2b.itm_det.txval', errors);
            _assertAmountNonNegative(det, 'iamt', 'b2b.itm_det.iamt', errors);
            _assertAmountNonNegative(det, 'camt', 'b2b.itm_det.camt', errors);
            _assertAmountNonNegative(det, 'samt', 'b2b.itm_det.samt', errors);
          }
        }
      }
    }
  }

  void _checkNegativeAmountsGstr3b(
    Map<String, Object?> json,
    List<String> errors,
  ) {
    final supDetails = json['sup_details'];
    if (supDetails is! Map<String, Object?>) return;

    const sections = ['osup_det', 'osup_zero', 'isup_rev'];
    const amtFields = ['txval', 'iamt', 'camt', 'samt', 'csamt'];

    for (final section in sections) {
      final sec = supDetails[section];
      if (sec is! Map<String, Object?>) continue;
      for (final field in amtFields) {
        _assertAmountNonNegative(
          sec,
          field,
          'sup_details.$section.$field',
          errors,
        );
      }
    }
  }

  void _assertAmountNonNegative(
    Map<String, Object?> map,
    String field,
    String path,
    List<String> errors,
  ) {
    final raw = map[field];
    if (raw == null) return;
    final value = double.tryParse(raw.toString());
    if (value != null && value < 0) {
      errors.add('Negative amount not allowed at $path: $raw');
    }
  }
}
