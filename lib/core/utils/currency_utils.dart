/// Indian currency formatting utilities.
///
/// The Indian numbering system groups digits as:
/// ones, then pairs from the right: 1,23,45,678 (not 12,345,678).
class CurrencyUtils {
  CurrencyUtils._();

  /// Formats [amount] in the Indian numbering system with the Rupee symbol.
  ///
  /// Example: `formatINR(123456.50)` returns `"₹1,23,456.50"`.
  /// Negative amounts are prefixed with a minus sign: `"-₹1,23,456.50"`.
  static String formatINR(double amount) {
    final isNegative = amount < 0;
    final absolute = amount.abs();
    final parts = absolute.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];

    final formattedInteger = _formatIndianInteger(integerPart);
    final prefix = isNegative ? '-₹' : '₹';
    return '$prefix$formattedInteger.$decimalPart';
  }

  /// Formats [amount] in a compact Indian notation.
  ///
  /// Thresholds:
  /// - >= 1 Crore  (10,000,000) -> "₹X.XXCr"
  /// - >= 1 Lakh   (100,000)    -> "₹X.XXL"
  /// - >= 1 Thousand (1,000)    -> "₹X.XXK"
  /// - Otherwise                -> "₹X.XX"
  static String formatINRCompact(double amount) {
    final isNegative = amount < 0;
    final absolute = amount.abs();
    final prefix = isNegative ? '-₹' : '₹';

    if (absolute >= 10000000) {
      final value = absolute / 10000000;
      return '$prefix${_trimTrailingZeros(value.toStringAsFixed(2))}Cr';
    }
    if (absolute >= 100000) {
      final value = absolute / 100000;
      return '$prefix${_trimTrailingZeros(value.toStringAsFixed(2))}L';
    }
    if (absolute >= 1000) {
      final value = absolute / 1000;
      return '$prefix${_trimTrailingZeros(value.toStringAsFixed(2))}K';
    }
    return '$prefix${_trimTrailingZeros(absolute.toStringAsFixed(2))}';
  }

  /// Parses an Indian-formatted currency string back to a [double].
  ///
  /// Handles:
  /// - Rupee symbol (₹)
  /// - Commas in Indian grouping
  /// - Compact suffixes: Cr, L, K
  /// - Negative prefix (-)
  ///
  /// Throws [FormatException] if the string cannot be parsed.
  static double parseINR(String value) {
    if (value.isEmpty) {
      throw const FormatException('Cannot parse empty string as INR');
    }

    var cleaned = value.trim().replaceAll(',', '').replaceAll('₹', '');

    final isNegative = cleaned.startsWith('-');
    if (isNegative) {
      cleaned = cleaned.substring(1);
    }

    double multiplier = 1;
    if (cleaned.endsWith('Cr') || cleaned.endsWith('cr')) {
      multiplier = 10000000;
      cleaned = cleaned.substring(0, cleaned.length - 2);
    } else if (cleaned.endsWith('L') || cleaned.endsWith('l')) {
      multiplier = 100000;
      cleaned = cleaned.substring(0, cleaned.length - 1);
    } else if (cleaned.endsWith('K') || cleaned.endsWith('k')) {
      multiplier = 1000;
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }

    final parsed = double.tryParse(cleaned.trim());
    if (parsed == null) {
      throw FormatException('Invalid INR format: "$value"');
    }

    return (isNegative ? -1 : 1) * parsed * multiplier;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Groups an integer string using the Indian numbering system.
  ///
  /// The last three digits form the first group, then every two digits
  /// form subsequent groups: e.g. "1234567" -> "12,34,567".
  static String _formatIndianInteger(String digits) {
    if (digits.length <= 3) return digits;

    final lastThree = digits.substring(digits.length - 3);
    var remaining = digits.substring(0, digits.length - 3);

    final groups = <String>[];
    while (remaining.length > 2) {
      groups.add(remaining.substring(remaining.length - 2));
      remaining = remaining.substring(0, remaining.length - 2);
    }
    if (remaining.isNotEmpty) {
      groups.add(remaining);
    }

    final reversed = groups.reversed.join(',');
    return '$reversed,$lastThree';
  }

  /// Removes unnecessary trailing zeros after the decimal point.
  ///
  /// "1.50" -> "1.5", "2.00" -> "2", "1.23" -> "1.23".
  static String _trimTrailingZeros(String value) {
    if (!value.contains('.')) return value;
    var trimmed = value.replaceAll(RegExp(r'0+$'), '');
    if (trimmed.endsWith('.')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}
