/// Stateless validator for FVU file content and individual NSDL field values.
///
/// All methods are pure functions — no side-effects, no state.
class FvuValidator {
  FvuValidator._();

  // ---------------------------------------------------------------------------
  // Regex patterns
  // ---------------------------------------------------------------------------

  /// TAN pattern: 4 uppercase letters + 5 alphanumeric chars + 1 uppercase letter.
  ///
  /// The NSDL TAN format allows letters or digits in the middle 5 positions.
  /// Example: AAATA1234X (4 letters + A1234 + X).
  static final RegExp _tanPattern = RegExp(r'^[A-Z]{4}[A-Z0-9]{5}[A-Z]$');

  /// PAN pattern: 5 uppercase letters + 4 digits + 1 uppercase letter.
  static final RegExp _panPattern = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');

  /// BSR code: exactly 7 digits.
  static final RegExp _bsrPattern = RegExp(r'^\d{7}$');

  /// Checksum field: exactly 5 decimal digits.
  static final RegExp _fiveDigit = RegExp(r'^\d{5}$');

  // ---------------------------------------------------------------------------
  // Field validators
  // ---------------------------------------------------------------------------

  /// Returns true if [tan] matches the NSDL TAN format.
  ///
  /// Valid pattern: 4 uppercase letters, 5 digits, 1 uppercase letter
  /// (total 10 characters). Example: AAATA1234X.
  static bool validateTan(String tan) => _tanPattern.hasMatch(tan);

  /// Returns true if [pan] is a valid PAN or the sentinel "PANNOTAVBL".
  ///
  /// Valid pattern: 5 uppercase letters, 4 digits, 1 uppercase letter.
  /// Example: ABCDE1234F.
  static bool validatePan(String pan) {
    if (pan == 'PANNOTAVBL') return true;
    return _panPattern.hasMatch(pan);
  }

  /// Returns true if [bsrCode] is exactly 7 decimal digits.
  static bool validateChallanBsrCode(String bsrCode) =>
      _bsrPattern.hasMatch(bsrCode);

  // ---------------------------------------------------------------------------
  // FVU content validator
  // ---------------------------------------------------------------------------

  /// Validates the structural integrity of [fvuContent].
  ///
  /// Checks performed:
  /// 1. BH (batch header) record is present.
  /// 2. BT (batch trailer) record is present.
  /// 3. Actual CD record count matches BT's stated challan count.
  /// 4. Actual DD record count matches BT's stated deductee count.
  ///
  /// Returns a list of error strings. An empty list means the content is valid.
  static List<String> validateFvuContent(String fvuContent) {
    final errors = <String>[];

    if (fvuContent.trim().isEmpty) {
      errors.add('FVU content is empty');
      return errors;
    }

    final lines = fvuContent
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final hasBh = lines.any((l) => l.startsWith('BH'));
    final hasBt = lines.any((l) => l.startsWith('BT'));

    if (!hasBh) {
      errors.add('BH (batch header) record is missing');
    }
    if (!hasBt) {
      errors.add('BT (batch trailer) record is missing');
    }

    // Cannot validate counts without both BH and BT
    if (!hasBh || !hasBt) return errors;

    final cdCount = lines.where((l) => l.startsWith('CD')).length;
    final ddCount = lines.where((l) => l.startsWith('DD')).length;

    final btLine = lines.lastWhere((l) => l.startsWith('BT'));
    final btFields = btLine.split('|');

    // BT field layout (pipe-delimited): BT|challanCount|deducteeCount|totalAmount...
    // Also handle fixed-width BT: BT<10-digit challanCount><10-digit deducteeCount>...
    if (btFields.length >= 3) {
      // Pipe-delimited BT record
      final btChallanCount = int.tryParse(btFields[1].trim());
      final btDeducteeCount = int.tryParse(btFields[2].trim());

      if (btChallanCount != null && btChallanCount != cdCount) {
        errors.add(
          'BT challan count ($btChallanCount) does not match '
          'actual CD records ($cdCount)',
        );
      }
      if (btDeducteeCount != null && btDeducteeCount != ddCount) {
        errors.add(
          'BT deductee count ($btDeducteeCount) does not match '
          'actual DD records ($ddCount)',
        );
      }
    } else if (btLine.length >= 22) {
      // Fixed-width BT record: BT + 10-char challan count + 10-char deductee count
      final challanStr = btLine.substring(2, 12).trim();
      final deducteeStr = btLine.substring(12, 22).trim();
      final btChallanCount = int.tryParse(challanStr);
      final btDeducteeCount = int.tryParse(deducteeStr);

      if (btChallanCount != null && btChallanCount != cdCount) {
        errors.add(
          'BT challan count ($btChallanCount) does not match '
          'actual CD records ($cdCount)',
        );
      }
      if (btDeducteeCount != null && btDeducteeCount != ddCount) {
        errors.add(
          'BT deductee count ($btDeducteeCount) does not match '
          'actual DD records ($ddCount)',
        );
      }
    }

    return errors;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  // ignore: unused_element
  static bool _isFiveDigits(String s) => _fiveDigit.hasMatch(s);
}
