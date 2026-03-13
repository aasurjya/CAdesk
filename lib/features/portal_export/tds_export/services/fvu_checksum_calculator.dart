/// Stateless utility for computing and verifying checksums in FVU files.
///
/// The checksum algorithm is a simple sum of all ASCII code values modulo
/// 65536, formatted as a 5-digit zero-padded decimal string.
class FvuChecksumCalculator {
  FvuChecksumCalculator._();

  static const int _modulus = 65536;
  static const int _fieldWidth = 5;
  static const String _separator = '|';

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Computes a checksum for [fvuContent].
  ///
  /// Algorithm: sum all character code units (ASCII values) modulo 65536,
  /// then format as a 5-digit zero-padded decimal string.
  ///
  /// Returns "00000" for an empty string.
  static String computeChecksum(String fvuContent) {
    if (fvuContent.isEmpty) return '00000';

    var sum = 0;
    for (final codeUnit in fvuContent.codeUnits) {
      sum += codeUnit;
    }

    final checksum = sum % _modulus;
    return checksum.toString().padLeft(_fieldWidth, '0');
  }

  /// Appends the checksum of [fvuContent] to the string, separated by a pipe.
  ///
  /// The checksum is computed over the original [fvuContent] (before appending)
  /// and appended as "|CCCCC" where CCCCC is the 5-digit zero-padded checksum.
  static String appendChecksum(String fvuContent) {
    final checksum = computeChecksum(fvuContent);
    return '$fvuContent$_separator$checksum';
  }

  /// Verifies that [fvuContentWithChecksum] ends with a valid checksum.
  ///
  /// Strips the last pipe-delimited segment, recomputes the checksum of the
  /// remaining content, and compares it to the appended checksum.
  ///
  /// Returns false if:
  /// - The content does not contain a pipe separator.
  /// - The last segment is not a valid 5-digit decimal.
  /// - The computed checksum does not match the appended checksum.
  static bool verifyChecksum(String fvuContentWithChecksum) {
    final lastPipeIndex = fvuContentWithChecksum.lastIndexOf(_separator);
    if (lastPipeIndex < 0) return false;

    final originalContent = fvuContentWithChecksum.substring(0, lastPipeIndex);
    final appendedChecksum = fvuContentWithChecksum.substring(
      lastPipeIndex + 1,
    );

    // Validate that the appended segment is a parseable integer
    if (int.tryParse(appendedChecksum) == null) return false;
    if (appendedChecksum.length != _fieldWidth) return false;

    final expected = computeChecksum(originalContent);
    return appendedChecksum == expected;
  }
}
