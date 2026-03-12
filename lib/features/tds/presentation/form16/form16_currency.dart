/// Formats a paise amount to Indian rupee string with comma grouping.
///
/// Example: 120000000 (paise) → "₹12,00,000"
/// Uses the Indian numbering system: XX,XX,XXX
String formatPaise(double paise) {
  final rupees = (paise / 100).round();
  if (rupees < 0) {
    return '-${formatPaise(-paise)}';
  }
  return '₹${_indianCommaFormat(rupees)}';
}

String _indianCommaFormat(int value) {
  if (value < 1000) return value.toString();

  final str = value.toString();
  final len = str.length;

  // Last 3 digits
  final last3 = str.substring(len - 3);
  final remaining = str.substring(0, len - 3);

  // Group remaining digits in pairs from right
  final buffer = StringBuffer();
  for (var i = 0; i < remaining.length; i++) {
    if (i > 0 && (remaining.length - i) % 2 == 0) {
      buffer.write(',');
    }
    buffer.write(remaining[i]);
  }
  buffer.write(',');
  buffer.write(last3);

  return buffer.toString();
}
