/// Type of legal reference used in a tax answer.
enum CitationType {
  section,
  rule,
  circular,
  notification,
  caselaw,
  cbdtInstruction,
}

/// An individual citation supporting a tax answer.
///
/// Immutable — all fields are final. Use [copyWith] for transformations.
class TaxCitation {
  const TaxCitation({
    required this.type,
    required this.reference,
    required this.summary,
    required this.relevanceScore,
    this.url,
  });

  final CitationType type;

  /// Human-readable reference string, e.g. "Section 44AD", "Circular 5/2023".
  final String reference;

  /// Brief explanation of what this citation says.
  final String summary;

  /// Optional link to the official source document.
  final String? url;

  /// Score in range 0.0–1.0 indicating how relevant this citation is.
  final double relevanceScore;

  TaxCitation copyWith({
    CitationType? type,
    String? reference,
    String? summary,
    String? url,
    double? relevanceScore,
  }) {
    return TaxCitation(
      type: type ?? this.type,
      reference: reference ?? this.reference,
      summary: summary ?? this.summary,
      url: url ?? this.url,
      relevanceScore: relevanceScore ?? this.relevanceScore,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaxCitation &&
        other.type == type &&
        other.reference == reference &&
        other.summary == summary &&
        other.url == url &&
        other.relevanceScore == relevanceScore;
  }

  @override
  int get hashCode =>
      Object.hash(type, reference, summary, url, relevanceScore);
}
