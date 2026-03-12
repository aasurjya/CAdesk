import 'package:flutter/foundation.dart';

/// Type of correction statement as defined by the Income Tax Department.
enum CorrectionType {
  c1(label: 'C1', description: 'Correction in deductor details'),
  c2(label: 'C2', description: 'Correction in challan details'),
  c3(label: 'C3', description: 'Correction in deductee details'),
  c5(label: 'C5', description: 'Correction in PAN of deductee'),
  c9(label: 'C9', description: 'add new challan and deductee rows');

  const CorrectionType({required this.label, required this.description});

  final String label;
  final String description;
}

/// Immutable model representing a TDS correction statement.
///
/// A correction statement amends a previously filed TDS return.
/// Different correction types (C1–C9) address different aspects of the return.
@immutable
class TdsCorrectionStatement {
  const TdsCorrectionStatement({
    required this.id,
    required this.originalReturnId,
    required this.correctionType,
    required this.financialYear,
    required this.quarter,
    required this.tan,
    required this.changedFields,
    required this.createdAt,
  });

  /// Unique identifier for this correction statement.
  final String id;

  /// ID of the original TDS return being corrected.
  final String originalReturnId;

  /// Type of correction (C1, C2, C3, C5, or C9).
  final CorrectionType correctionType;

  /// Financial year of the return being corrected, e.g. "2025-26".
  final String financialYear;

  /// Quarter (1–4) of the return being corrected.
  final int quarter;

  /// TAN of the deductor.
  final String tan;

  /// Map of field names to their corrected values (all stored as strings).
  final Map<String, String> changedFields;

  /// Creation timestamp. May be null for draft statements.
  final DateTime? createdAt;

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  TdsCorrectionStatement copyWith({
    String? id,
    String? originalReturnId,
    CorrectionType? correctionType,
    String? financialYear,
    int? quarter,
    String? tan,
    Map<String, String>? changedFields,
    DateTime? createdAt,
  }) {
    return TdsCorrectionStatement(
      id: id ?? this.id,
      originalReturnId: originalReturnId ?? this.originalReturnId,
      correctionType: correctionType ?? this.correctionType,
      financialYear: financialYear ?? this.financialYear,
      quarter: quarter ?? this.quarter,
      tan: tan ?? this.tan,
      changedFields: changedFields ?? this.changedFields,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TdsCorrectionStatement &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          originalReturnId == other.originalReturnId &&
          correctionType == other.correctionType &&
          financialYear == other.financialYear &&
          quarter == other.quarter &&
          tan == other.tan &&
          _mapEquals(changedFields, other.changedFields) &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
    id,
    originalReturnId,
    correctionType,
    financialYear,
    quarter,
    tan,
    Object.hashAll(
      changedFields.entries.map((e) => Object.hash(e.key, e.value)),
    ),
    createdAt,
  );

  @override
  String toString() =>
      'TdsCorrectionStatement(id: $id, type: ${correctionType.label}, '
      'fy: $financialYear, Q$quarter)';
}

/// Static service for TDS correction statement management.
class TdsCorrectionService {
  TdsCorrectionService._();

  // TAN: 4 uppercase alpha + 5 digits + 1 uppercase alpha
  static final RegExp _tanPattern = RegExp(r'^[A-Z]{4}[0-9]{5}[A-Z]$');

  // ---------------------------------------------------------------------------
  // Factory
  // ---------------------------------------------------------------------------

  /// Creates a new [TdsCorrectionStatement] with a generated ID.
  static TdsCorrectionStatement createCorrection({
    required String originalReturnId,
    required CorrectionType correctionType,
    required String financialYear,
    required int quarter,
    required String tan,
    required Map<String, String> changedFields,
  }) {
    final id = _generateId(originalReturnId, correctionType);
    return TdsCorrectionStatement(
      id: id,
      originalReturnId: originalReturnId,
      correctionType: correctionType,
      financialYear: financialYear,
      quarter: quarter,
      tan: tan,
      changedFields: Map.unmodifiable(changedFields),
      createdAt: null,
    );
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  /// Validates a [TdsCorrectionStatement] and returns error messages.
  ///
  /// An empty list indicates a valid correction statement.
  static List<String> validate(TdsCorrectionStatement correction) {
    final errors = <String>[];

    if (correction.changedFields.isEmpty) {
      errors.add('At least one field must be specified for correction');
    }

    if (correction.quarter < 1 || correction.quarter > 4) {
      errors.add(
        'Invalid quarter: ${correction.quarter}. Must be between 1 and 4',
      );
    }

    if (!_tanPattern.hasMatch(correction.tan)) {
      errors.add('Invalid TAN format: ${correction.tan}');
    }

    return errors;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static String _generateId(String returnId, CorrectionType type) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'corr-${type.label}-$returnId-$timestamp';
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (!b.containsKey(entry.key) || b[entry.key] != entry.value) return false;
  }
  return true;
}
