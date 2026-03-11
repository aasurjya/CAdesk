import 'package:flutter/foundation.dart';

/// Immutable model representing a regulatory circular issued by a statutory body.
@immutable
class RegulatoryCircular {
  const RegulatoryCircular({
    required this.id,
    required this.circularNumber,
    required this.issuingBody,
    required this.title,
    required this.summary,
    required this.issueDate,
    required this.effectiveDate,
    required this.category,
    required this.impactLevel,
    required this.affectedClientsCount,
    required this.keyChanges,
  });

  /// Unique identifier.
  final String id;

  /// Official circular number, e.g. "CBDT Circular No. 3/2026".
  final String circularNumber;

  /// Statutory body that issued the circular: CBDT, GSTN, MCA, RBI, SEBI,
  /// ICAI, or EPFO.
  final String issuingBody;

  /// Short descriptive title.
  final String title;

  /// One-to-two sentence plain-language summary.
  final String summary;

  /// Human-readable issue date, e.g. "10 Mar 2026".
  final String issueDate;

  /// Human-readable effective date.
  final String effectiveDate;

  /// Regulatory category: Income Tax, GST, MCA, RBI, SEBI, Labour, or ICAI.
  final String category;

  /// Business impact level: High, Medium, or Low.
  final String impactLevel;

  /// Number of clients in the practice affected by this circular.
  final int affectedClientsCount;

  /// Two-to-three bullet-point key changes introduced by the circular.
  final List<String> keyChanges;

  /// Returns a new [RegulatoryCircular] with the specified fields replaced.
  RegulatoryCircular copyWith({
    String? id,
    String? circularNumber,
    String? issuingBody,
    String? title,
    String? summary,
    String? issueDate,
    String? effectiveDate,
    String? category,
    String? impactLevel,
    int? affectedClientsCount,
    List<String>? keyChanges,
  }) {
    return RegulatoryCircular(
      id: id ?? this.id,
      circularNumber: circularNumber ?? this.circularNumber,
      issuingBody: issuingBody ?? this.issuingBody,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      issueDate: issueDate ?? this.issueDate,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      category: category ?? this.category,
      impactLevel: impactLevel ?? this.impactLevel,
      affectedClientsCount: affectedClientsCount ?? this.affectedClientsCount,
      keyChanges: keyChanges ?? this.keyChanges,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegulatoryCircular &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          circularNumber == other.circularNumber &&
          issuingBody == other.issuingBody &&
          title == other.title &&
          summary == other.summary &&
          issueDate == other.issueDate &&
          effectiveDate == other.effectiveDate &&
          category == other.category &&
          impactLevel == other.impactLevel &&
          affectedClientsCount == other.affectedClientsCount;

  @override
  int get hashCode => Object.hash(
    id,
    circularNumber,
    issuingBody,
    title,
    summary,
    issueDate,
    effectiveDate,
    category,
    impactLevel,
    affectedClientsCount,
  );

  @override
  String toString() =>
      'RegulatoryCircular(id: $id, circular: $circularNumber, '
      'body: $issuingBody, impact: $impactLevel)';
}
