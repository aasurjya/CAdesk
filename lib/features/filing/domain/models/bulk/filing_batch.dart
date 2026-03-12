import 'package:flutter/foundation.dart';

/// Immutable model representing a batch of filing jobs grouped for
/// bulk operations (e.g. "AY 2025-26 Salaried Clients").
class FilingBatch {
  const FilingBatch({
    required this.id,
    required this.name,
    required this.jobIds,
    required this.createdAt,
    required this.assessmentYear,
  });

  /// Creates an empty batch with sensible defaults.
  factory FilingBatch.empty() {
    return FilingBatch(
      id: '',
      name: '',
      jobIds: const [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      assessmentYear: '',
    );
  }

  final String id;
  final String name;
  final List<String> jobIds;
  final DateTime createdAt;
  final String assessmentYear;

  /// Number of jobs in this batch.
  int get jobCount => jobIds.length;

  FilingBatch copyWith({
    String? id,
    String? name,
    List<String>? jobIds,
    DateTime? createdAt,
    String? assessmentYear,
  }) {
    return FilingBatch(
      id: id ?? this.id,
      name: name ?? this.name,
      jobIds: jobIds ?? this.jobIds,
      createdAt: createdAt ?? this.createdAt,
      assessmentYear: assessmentYear ?? this.assessmentYear,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilingBatch &&
        other.id == id &&
        other.name == name &&
        listEquals(other.jobIds, jobIds) &&
        other.createdAt == createdAt &&
        other.assessmentYear == assessmentYear;
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, assessmentYear);
}
