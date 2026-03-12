import 'package:flutter/foundation.dart';

/// Regulatory source / issuing authority.
enum RegSource {
  cbdt,
  cbic,
  mca,
  sebi,
  rbi,
  epfo,
  nclt,
  itat,
  highCourt,
  supremeCourt,
}

/// Category of the regulatory update.
enum UpdateCategory {
  circular,
  notification,
  amendment,
  clarification,
  caseLaw,
  pressRelease,
  deadline,
}

/// Business impact level.
enum ImpactLevel { high, medium, low }

/// Immutable model representing a single regulatory update (circular,
/// notification, case law, etc.) issued by a statutory body.
@immutable
class RegulatoryUpdate {
  const RegulatoryUpdate({
    required this.updateId,
    required this.title,
    required this.summary,
    required this.source,
    required this.category,
    required this.publicationDate,
    required this.effectiveDate,
    required this.impactLevel,
    required this.affectedSections,
    required this.url,
    required this.isRead,
  });

  /// Unique identifier for this update.
  final String updateId;

  /// Short descriptive title.
  final String title;

  /// Plain-language summary (1–3 sentences).
  final String summary;

  /// Statutory body that issued this update.
  final RegSource source;

  /// Category classifying the nature of the update.
  final UpdateCategory category;

  /// Date the update was published.
  final DateTime publicationDate;

  /// Date from which the update takes effect (nullable).
  final DateTime? effectiveDate;

  /// Business impact level.
  final ImpactLevel impactLevel;

  /// Income-tax / GST / Companies Act sections affected.
  final List<String> affectedSections;

  /// Link to the official gazette or CBDT/CBIC/MCA portal (nullable).
  final String? url;

  /// Whether the CA user has marked this update as read.
  final bool isRead;

  /// Returns a new [RegulatoryUpdate] with the specified fields replaced.
  RegulatoryUpdate copyWith({
    String? updateId,
    String? title,
    String? summary,
    RegSource? source,
    UpdateCategory? category,
    DateTime? publicationDate,
    DateTime? effectiveDate,
    ImpactLevel? impactLevel,
    List<String>? affectedSections,
    String? url,
    bool? isRead,
  }) {
    return RegulatoryUpdate(
      updateId: updateId ?? this.updateId,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      source: source ?? this.source,
      category: category ?? this.category,
      publicationDate: publicationDate ?? this.publicationDate,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      impactLevel: impactLevel ?? this.impactLevel,
      affectedSections: affectedSections ?? this.affectedSections,
      url: url ?? this.url,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegulatoryUpdate &&
          runtimeType == other.runtimeType &&
          updateId == other.updateId &&
          title == other.title &&
          summary == other.summary &&
          source == other.source &&
          category == other.category &&
          publicationDate == other.publicationDate &&
          effectiveDate == other.effectiveDate &&
          impactLevel == other.impactLevel &&
          url == other.url &&
          isRead == other.isRead;

  @override
  int get hashCode => Object.hash(
    updateId,
    title,
    summary,
    source,
    category,
    publicationDate,
    effectiveDate,
    impactLevel,
    url,
    isRead,
  );

  @override
  String toString() =>
      'RegulatoryUpdate(updateId: $updateId, source: ${source.name}, '
      'impact: ${impactLevel.name}, isRead: $isRead)';
}
