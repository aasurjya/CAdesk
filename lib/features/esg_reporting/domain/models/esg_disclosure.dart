/// Immutable model representing an ESG disclosure for a client.
class EsgDisclosure {
  const EsgDisclosure({
    required this.id,
    required this.clientName,
    required this.clientPan,
    required this.disclosureType,
    required this.reportingYear,
    required this.environmentScore,
    required this.socialScore,
    required this.governanceScore,
    required this.overallScore,
    required this.status,
    required this.sebiCategory,
    required this.pendingItems,
  });

  /// Unique identifier for the disclosure.
  final String id;

  /// Full legal name of the client entity.
  final String clientName;

  /// Permanent Account Number of the client.
  final String clientPan;

  /// Type of ESG disclosure:
  /// BRSR, Integrated Report, Sustainability Report, Carbon Disclosure.
  final String disclosureType;

  /// Financial year of the report, e.g. "FY 2024-25".
  final String reportingYear;

  /// Environmental pillar score (0–100).
  final double environmentScore;

  /// Social pillar score (0–100).
  final double socialScore;

  /// Governance pillar score (0–100).
  final double governanceScore;

  /// Overall ESG score — computed average of the three pillars (0–100).
  final double overallScore;

  /// Workflow status: Draft | Under Review | Filed | Published.
  final String status;

  /// SEBI classification: Listed Top 1000 | BRSR Core | Voluntary.
  final String sebiCategory;

  /// Outstanding action items before the disclosure can be finalised.
  final List<String> pendingItems;

  EsgDisclosure copyWith({
    String? id,
    String? clientName,
    String? clientPan,
    String? disclosureType,
    String? reportingYear,
    double? environmentScore,
    double? socialScore,
    double? governanceScore,
    double? overallScore,
    String? status,
    String? sebiCategory,
    List<String>? pendingItems,
  }) {
    return EsgDisclosure(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      clientPan: clientPan ?? this.clientPan,
      disclosureType: disclosureType ?? this.disclosureType,
      reportingYear: reportingYear ?? this.reportingYear,
      environmentScore: environmentScore ?? this.environmentScore,
      socialScore: socialScore ?? this.socialScore,
      governanceScore: governanceScore ?? this.governanceScore,
      overallScore: overallScore ?? this.overallScore,
      status: status ?? this.status,
      sebiCategory: sebiCategory ?? this.sebiCategory,
      pendingItems: pendingItems ?? this.pendingItems,
    );
  }
}
