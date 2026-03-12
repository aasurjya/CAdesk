/// Immutable model representing a single validation error encountered during import.
///
/// Errors are associated with a specific row in the source file so users can
/// locate and correct the problematic data.
class ImportError {
  const ImportError({
    required this.rowNumber,
    required this.field,
    required this.value,
    required this.reason,
  });

  /// 1-based row number in the source CSV (row 1 is the header).
  final int rowNumber;

  /// Name of the field or column that failed validation.
  final String field;

  /// Raw value that caused the error (as a string for display purposes).
  final String value;

  /// Human-readable explanation of why the value is invalid.
  final String reason;

  /// Returns a new [ImportError] with specified fields replaced.
  ImportError copyWith({
    int? rowNumber,
    String? field,
    String? value,
    String? reason,
  }) {
    return ImportError(
      rowNumber: rowNumber ?? this.rowNumber,
      field: field ?? this.field,
      value: value ?? this.value,
      reason: reason ?? this.reason,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImportError &&
        other.rowNumber == rowNumber &&
        other.field == field &&
        other.value == value &&
        other.reason == reason;
  }

  @override
  int get hashCode => Object.hash(rowNumber, field, value, reason);
}
