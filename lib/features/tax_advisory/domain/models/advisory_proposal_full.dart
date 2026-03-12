import 'package:ca_app/features/tax_advisory/domain/models/proposal_section.dart';
import 'package:ca_app/features/tax_advisory/domain/models/tax_opportunity.dart';

/// Immutable model representing a complete tax advisory proposal for a client.
///
/// Named [AdvisoryProposalFull] to avoid collision with the existing
/// [AdvisoryProposal] UI model in the same feature folder.
///
/// All monetary amounts are in paise (1 ₹ = 100 paise).
class AdvisoryProposalFull {
  const AdvisoryProposalFull({
    required this.proposalId,
    required this.clientPan,
    required this.generatedAt,
    required this.opportunities,
    required this.totalPotentialSaving,
    required this.proposedFee,
    required this.roi,
    required this.executiveSummary,
    required this.sections,
  }) : assert(proposedFee > 0, 'proposedFee must be positive');

  /// Unique proposal identifier.
  final String proposalId;

  /// PAN of the client this proposal is for.
  final String clientPan;

  /// Timestamp when this proposal was generated.
  final DateTime generatedAt;

  /// All ranked opportunities included in this proposal.
  final List<TaxOpportunity> opportunities;

  /// Sum of potentialSaving for top 5 opportunities in paise.
  final int totalPotentialSaving;

  /// Recommended CA fee in paise.
  final int proposedFee;

  /// Return-on-investment: totalPotentialSaving / proposedFee.
  final double roi;

  /// High-level summary paragraph for the proposal document.
  final String executiveSummary;

  /// Structured sections of the proposal document.
  final List<ProposalSection> sections;

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  AdvisoryProposalFull copyWith({
    String? proposalId,
    String? clientPan,
    DateTime? generatedAt,
    List<TaxOpportunity>? opportunities,
    int? totalPotentialSaving,
    int? proposedFee,
    double? roi,
    String? executiveSummary,
    List<ProposalSection>? sections,
  }) {
    return AdvisoryProposalFull(
      proposalId: proposalId ?? this.proposalId,
      clientPan: clientPan ?? this.clientPan,
      generatedAt: generatedAt ?? this.generatedAt,
      opportunities: opportunities ?? this.opportunities,
      totalPotentialSaving: totalPotentialSaving ?? this.totalPotentialSaving,
      proposedFee: proposedFee ?? this.proposedFee,
      roi: roi ?? this.roi,
      executiveSummary: executiveSummary ?? this.executiveSummary,
      sections: sections ?? this.sections,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdvisoryProposalFull &&
          runtimeType == other.runtimeType &&
          proposalId == other.proposalId;

  @override
  int get hashCode => proposalId.hashCode;
}
