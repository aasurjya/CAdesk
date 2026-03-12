/// Represents a validation error for a specific field in a filing form.
class ValidationError {
  const ValidationError({
    required this.field,
    required this.message,
    this.code,
  });

  /// The field name that failed validation (e.g. 'pan', 'aadhaarNumber').
  final String field;

  /// Human-readable error message.
  final String message;

  /// Optional machine-readable error code for programmatic handling.
  final String? code;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidationError &&
        other.field == field &&
        other.message == message &&
        other.code == code;
  }

  @override
  int get hashCode => Object.hash(field, message, code);

  @override
  String toString() => 'ValidationError($field: $message)';
}
