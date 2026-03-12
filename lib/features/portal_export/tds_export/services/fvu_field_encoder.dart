/// Stateless utility for encoding individual fields in NSDL TIN 2.0 FVU files.
///
/// All methods are pure functions — given the same input, they always return
/// the same output with no side-effects.
class FvuFieldEncoder {
  FvuFieldEncoder._();

  // ---------------------------------------------------------------------------
  // Padding
  // ---------------------------------------------------------------------------

  /// Right-aligns [value] in a field of [width] characters using [pad].
  ///
  /// If [value] is longer than [width], it is truncated to exactly [width].
  /// Used for numeric fields that must be right-aligned (e.g. amounts, counts).
  static String padLeft(String value, int width, {String pad = ' '}) {
    if (value.length >= width) return value.substring(0, width);
    return value.padLeft(width, pad);
  }

  /// Left-aligns [value] in a field of [width] characters using [pad].
  ///
  /// If [value] is longer than [width], it is truncated to exactly [width].
  /// Used for alpha fields that must be left-aligned (e.g. names, PAN, TAN).
  static String padRight(String value, int width, {String pad = ' '}) {
    if (value.length >= width) return value.substring(0, width);
    return value.padRight(width, pad);
  }

  // ---------------------------------------------------------------------------
  // Amount encoding
  // ---------------------------------------------------------------------------

  /// Encodes [paise] as a 15-digit zero-padded integer string.
  ///
  /// The FVU spec stores amounts as integer paise with no decimal point.
  /// Example: 150000 paise → "000000000150000"
  static String encodeAmount(int paise) {
    return paise.toString().padLeft(15, '0');
  }

  // ---------------------------------------------------------------------------
  // Identifier encoding
  // ---------------------------------------------------------------------------

  /// Encodes a PAN: uppercased, trimmed.
  ///
  /// Returns "PANNOTAVBL" if [pan] is blank or empty — the NSDL-prescribed
  /// sentinel value when the deductee's PAN is not available.
  static String encodePan(String pan) {
    final trimmed = pan.trim().toUpperCase();
    if (trimmed.isEmpty) return 'PANNOTAVBL';
    return trimmed;
  }

  /// Encodes a TAN: uppercased, trimmed, padded/truncated to 10 characters.
  static String encodeTan(String tan) {
    final trimmed = tan.trim().toUpperCase();
    return padRight(trimmed, 10);
  }

  // ---------------------------------------------------------------------------
  // Date encoding
  // ---------------------------------------------------------------------------

  /// Encodes [date] as "DDMMYYYY" (8 characters), zero-padding day and month.
  static String encodeDate(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    return '$dd$mm$yyyy';
  }

  // ---------------------------------------------------------------------------
  // Quarter encoding
  // ---------------------------------------------------------------------------

  /// Encodes a quarter number (1–4) as "Q1", "Q2", "Q3", or "Q4".
  ///
  /// Throws [ArgumentError] for values outside 1–4.
  static String encodeQuarter(int quarter) {
    if (quarter < 1 || quarter > 4) {
      throw ArgumentError.value(
        quarter,
        'quarter',
        'Quarter must be between 1 and 4 inclusive',
      );
    }
    return 'Q$quarter';
  }

  // ---------------------------------------------------------------------------
  // Rate encoding
  // ---------------------------------------------------------------------------

  /// Encodes [rate] as a decimal string with exactly 2 decimal places.
  ///
  /// Truncates (not rounds) additional decimal digits.
  /// Example: 10.0 → "10.00", 7.5 → "7.50", 10.123 → "10.12"
  static String encodeRate(double rate) {
    // Truncate to 2 decimal places without rounding
    final truncated = (rate * 100).truncate() / 100;
    return truncated.toStringAsFixed(2);
  }
}
