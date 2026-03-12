/// Period type for an XBRL context — instant (point-in-time) or
/// duration (period of time).
enum XbrlPeriodType {
  /// A point-in-time context (e.g. balance sheet date).
  instant,

  /// A period context (e.g. full financial year for P&L).
  duration,
}

/// Immutable XBRL context identifying the entity and reporting period
/// for a set of facts.
///
/// Instant contexts require only [periodEnd].
/// Duration contexts require both [periodStart] and [periodEnd].
class XbrlContext {
  const XbrlContext({
    required this.contextId,
    required this.entity,
    required this.scheme,
    required this.periodType,
    required this.periodEnd,
    this.periodStart,
  });

  /// Unique identifier used as the `id` attribute in the XML context element.
  final String contextId;

  /// The entity identifier — typically the CIN for Indian companies.
  final String entity;

  /// The scheme URI for the entity identifier
  /// (e.g. `http://www.mca.gov.in`).
  final String scheme;

  /// Whether this context covers an instant or a duration.
  final XbrlPeriodType periodType;

  /// ISO-8601 date string for the period end (required for both types).
  final String periodEnd;

  /// ISO-8601 date string for the period start (only for [XbrlPeriodType.duration]).
  final String? periodStart;

  XbrlContext copyWith({
    String? contextId,
    String? entity,
    String? scheme,
    XbrlPeriodType? periodType,
    String? periodEnd,
    String? periodStart,
  }) {
    return XbrlContext(
      contextId: contextId ?? this.contextId,
      entity: entity ?? this.entity,
      scheme: scheme ?? this.scheme,
      periodType: periodType ?? this.periodType,
      periodEnd: periodEnd ?? this.periodEnd,
      periodStart: periodStart ?? this.periodStart,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is XbrlContext &&
        other.contextId == contextId &&
        other.entity == entity &&
        other.scheme == scheme &&
        other.periodType == periodType &&
        other.periodEnd == periodEnd &&
        other.periodStart == periodStart;
  }

  @override
  int get hashCode => Object.hash(
    contextId,
    entity,
    scheme,
    periodType,
    periodEnd,
    periodStart,
  );

  @override
  String toString() =>
      'XbrlContext($contextId, $entity, $periodType, end=$periodEnd)';
}
