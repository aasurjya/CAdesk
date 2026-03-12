/// Stateless mapper from GSTN API error codes to user-friendly messages.
///
/// Maps standard GSTN portal error response codes (e.g. "RET191001") to
/// actionable messages that can be shown directly in the CA Desk UI.
/// Also indicates whether an error condition is retryable.
class GstnErrorCodeMapper {
  GstnErrorCodeMapper._();

  static final GstnErrorCodeMapper instance = GstnErrorCodeMapper._();

  static const String _fallbackMessage =
      'An unexpected error occurred. Please check your return data and try again.';

  static const Map<String, _ErrorEntry> _entries = {
    'RET191001': _ErrorEntry(
      message: 'Invalid GSTIN. Please verify the GSTIN and resubmit.',
      retryable: false,
    ),
    'RET191002': _ErrorEntry(
      message:
          'Period mismatch. The filing period in your return does not match the selected period on the portal.',
      retryable: false,
    ),
    'RET191003': _ErrorEntry(
      message:
          'Duplicate filing detected. A return for this GSTIN and period has already been submitted.',
      retryable: false,
    ),
  };

  /// Returns a human-readable message for the given GSTN [errorCode].
  ///
  /// Returns a generic fallback message for unknown or empty codes.
  String getMessage(String errorCode) {
    return _entries[errorCode]?.message ?? _fallbackMessage;
  }

  /// Returns whether the error identified by [errorCode] is retryable.
  ///
  /// Returns `false` for unknown or empty codes.
  bool isRetryable(String errorCode) {
    return _entries[errorCode]?.retryable ?? false;
  }
}

/// Internal immutable holder for an error entry.
class _ErrorEntry {
  const _ErrorEntry({required this.message, required this.retryable});

  final String message;
  final bool retryable;
}
