// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// Categories of tax advisory opportunities.
enum OpportunityType {
  taxSaving,
  complianceGap,
  refundOptimization,
  restructuring,
  investmentPlanning,
  retirementPlanning,
  businessStructure,
}

/// How urgent it is to act on the opportunity.
enum OpportunityUrgency {
  immediate,
  thisYear,
  nextYear,
  longTerm,
}

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

/// Immutable model representing a detected tax saving or compliance opportunity.
class TaxOpportunity {
  const TaxOpportunity({
    required this.opportunityId,
    required this.clientPan,
    required this.type,
    required this.title,
    required this.description,
    required this.potentialSaving,
    required this.confidence,
    required this.urgency,
    required this.requiredAction,
    required this.estimatedFee,
    required this.sections,
  }) : assert(confidence >= 0.0 && confidence <= 1.0,
            'confidence must be between 0.0 and 1.0');

  /// Unique identifier for this opportunity.
  final String opportunityId;

  /// PAN of the client this opportunity belongs to.
  final String clientPan;

  /// Category of the opportunity.
  final OpportunityType type;

  /// Short human-readable title.
  final String title;

  /// Detailed description of the opportunity.
  final String description;

  /// Estimated tax saving in paise (Indian paise, 1 ₹ = 100 paise).
  final int potentialSaving;

  /// ML/rule-based confidence score: 0.0 (uncertain) to 1.0 (certain).
  final double confidence;

  /// Urgency of acting on this opportunity.
  final OpportunityUrgency urgency;

  /// Action the CA / client needs to take.
  final String requiredAction;

  /// Estimated CA fee for this service in paise.
  final int estimatedFee;

  /// Relevant Income Tax Act sections (e.g. ['80C', '80D']).
  final List<String> sections;

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  TaxOpportunity copyWith({
    String? opportunityId,
    String? clientPan,
    OpportunityType? type,
    String? title,
    String? description,
    int? potentialSaving,
    double? confidence,
    OpportunityUrgency? urgency,
    String? requiredAction,
    int? estimatedFee,
    List<String>? sections,
  }) {
    return TaxOpportunity(
      opportunityId: opportunityId ?? this.opportunityId,
      clientPan: clientPan ?? this.clientPan,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      potentialSaving: potentialSaving ?? this.potentialSaving,
      confidence: confidence ?? this.confidence,
      urgency: urgency ?? this.urgency,
      requiredAction: requiredAction ?? this.requiredAction,
      estimatedFee: estimatedFee ?? this.estimatedFee,
      sections: sections ?? this.sections,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaxOpportunity &&
          runtimeType == other.runtimeType &&
          opportunityId == other.opportunityId;

  @override
  int get hashCode => opportunityId.hashCode;
}
