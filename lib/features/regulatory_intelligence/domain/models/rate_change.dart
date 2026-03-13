import 'package:flutter/foundation.dart';

/// Tax / duty category affected by the rate change.
enum RateCategory { incomeTax, gst, tds, tcs, customs, stampDuty }

/// Immutable model representing a change in a tax rate, duty, or threshold
/// introduced by a statutory instrument (Finance Act, Notification, etc.).
@immutable
class RateChange {
  const RateChange({
    required this.effectiveDate,
    required this.category,
    required this.description,
    required this.oldValue,
    required this.newValue,
    required this.circularReference,
    required this.affectedAssessees,
  });

  /// Date from which the new rate is effective.
  final DateTime effectiveDate;

  /// Tax category this change belongs to.
  final RateCategory category;

  /// Human-readable description, e.g. "STCG under Section 111A increased".
  final String description;

  /// Previous value, e.g. "15%" or "₹1,00,000".
  final String oldValue;

  /// New value after the change, e.g. "20%" or "₹1,25,000".
  final String newValue;

  /// Authoritative reference, e.g. "Finance Act 2024" or "Notification 35/2024".
  final String circularReference;

  /// Assessee categories affected, e.g. ["Equity Investor", "Mutual Fund Holder"].
  final List<String> affectedAssessees;

  /// Returns a new [RateChange] with the specified fields replaced.
  RateChange copyWith({
    DateTime? effectiveDate,
    RateCategory? category,
    String? description,
    String? oldValue,
    String? newValue,
    String? circularReference,
    List<String>? affectedAssessees,
  }) {
    return RateChange(
      effectiveDate: effectiveDate ?? this.effectiveDate,
      category: category ?? this.category,
      description: description ?? this.description,
      oldValue: oldValue ?? this.oldValue,
      newValue: newValue ?? this.newValue,
      circularReference: circularReference ?? this.circularReference,
      affectedAssessees: affectedAssessees ?? this.affectedAssessees,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RateChange &&
          runtimeType == other.runtimeType &&
          effectiveDate == other.effectiveDate &&
          category == other.category &&
          description == other.description &&
          oldValue == other.oldValue &&
          newValue == other.newValue &&
          circularReference == other.circularReference;

  @override
  int get hashCode => Object.hash(
    effectiveDate,
    category,
    description,
    oldValue,
    newValue,
    circularReference,
  );

  @override
  String toString() =>
      'RateChange(category: ${category.name}, '
      'effectiveDate: $effectiveDate, $oldValue → $newValue)';
}
