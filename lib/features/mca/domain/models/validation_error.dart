/// A single validation error returned by form preparation services.
class ValidationError {
  const ValidationError({required this.field, required this.message});

  /// The model field name that failed validation (e.g. 'cin', 'agmDate').
  final String field;

  /// Human-readable description of the validation failure.
  final String message;

  ValidationError copyWith({String? field, String? message}) {
    return ValidationError(
      field: field ?? this.field,
      message: message ?? this.message,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidationError &&
        other.field == field &&
        other.message == message;
  }

  @override
  int get hashCode => Object.hash(field, message);

  @override
  String toString() => 'ValidationError(field: $field, message: $message)';
}
