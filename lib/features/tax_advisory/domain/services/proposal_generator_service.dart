import 'package:ca_app/features/tax_advisory/domain/models/advisory_proposal_full.dart';
import 'package:ca_app/features/tax_advisory/domain/models/client_profile.dart';
import 'package:ca_app/features/tax_advisory/domain/models/proposal_section.dart';
import 'package:ca_app/features/tax_advisory/domain/models/tax_opportunity.dart';

/// Stateless singleton service that assembles a complete [AdvisoryProposalFull]
/// from a ranked list of [TaxOpportunity] items.
///
/// Fee formula (FY 2024-25):
///   proposedFee = base(₹5,000) + 10% of total savings, capped at ₹50,000
///
/// All monetary amounts are in paise (1 ₹ = 100 paise).
class ProposalGeneratorService {
  ProposalGeneratorService._();

  static final ProposalGeneratorService instance =
      ProposalGeneratorService._();

  // ---------------------------------------------------------------------------
  // Constants (paise)
  // ---------------------------------------------------------------------------

  static const int _baseFee = 500000; // ₹5,000
  static const int _feeCap = 5000000; // ₹50,000
  static const int _feePercentageBps = 10; // 10%
  static const int _topNForSaving = 5;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Generates a complete [AdvisoryProposalFull] for [profile] using
  /// [opportunities].
  ///
  /// Opportunities are ranked internally before building the proposal.
  AdvisoryProposalFull generate(
    ClientProfile profile,
    List<TaxOpportunity> opportunities,
  ) {
    final ranked = rankOpportunities(opportunities);
    final top5 = ranked.take(_topNForSaving).toList();

    final totalSaving = top5.fold<int>(
      0,
      (sum, o) => sum + o.potentialSaving,
    );

    final fee = computeProposedFee(opportunities);
    final roi = fee > 0 ? totalSaving / fee : 0.0;

    final top3 = ranked.take(3).toList();
    final summary = generateExecutiveSummary(profile, top3);
    final sections = _buildSections(ranked);

    return AdvisoryProposalFull(
      proposalId: _generateId(profile),
      clientPan: profile.pan,
      generatedAt: DateTime.now(),
      opportunities: ranked,
      totalPotentialSaving: totalSaving,
      proposedFee: fee,
      roi: roi,
      executiveSummary: summary,
      sections: sections,
    );
  }

  /// Computes the recommended CA fee in paise.
  ///
  /// Formula: ₹5,000 base + 10% of total potential savings, capped at ₹50,000.
  int computeProposedFee(List<TaxOpportunity> opportunities) {
    final totalSaving = opportunities.fold<int>(
      0,
      (sum, o) => sum + o.potentialSaving,
    );

    final variableFee = totalSaving * _feePercentageBps ~/ 100;
    final fee = _baseFee + variableFee;

    return fee.clamp(0, _feeCap);
  }

  /// Ranks opportunities by (potentialSaving × confidence) descending.
  List<TaxOpportunity> rankOpportunities(List<TaxOpportunity> opps) {
    final sorted = List<TaxOpportunity>.from(opps)
      ..sort((a, b) {
        final scoreA = a.potentialSaving * a.confidence;
        final scoreB = b.potentialSaving * b.confidence;
        return scoreB.compareTo(scoreA);
      });

    return List.unmodifiable(sorted);
  }

  /// Generates a concise executive summary paragraph.
  String generateExecutiveSummary(
    ClientProfile profile,
    List<TaxOpportunity> top3,
  ) {
    if (top3.isEmpty) {
      return 'Dear ${profile.name}, our analysis of your financial profile '
          'has been completed. Please review the recommendations in this '
          'proposal for optimisation opportunities.';
    }

    final savingStr = _paise(
      top3.fold<int>(0, (s, o) => s + o.potentialSaving),
    );

    final topTitles = top3.map((o) => o.title).join(', ');

    return 'Dear ${profile.name}, our tax advisory analysis for '
        'FY 2024-25 has identified ${top3.length} priority opportunity(ies) '
        'including: $topTitles. Acting on these recommendations could save '
        'you approximately $savingStr in taxes this financial year. '
        'Our team of experienced CAs is ready to assist you in implementing '
        'these strategies before the financial year deadline.';
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Groups ranked opportunities into [ProposalSection]s by [OpportunityType].
  List<ProposalSection> _buildSections(List<TaxOpportunity> ranked) {
    if (ranked.isEmpty) return const [];

    // Group by type
    final groups = <OpportunityType, List<TaxOpportunity>>{};
    for (final opp in ranked) {
      groups.putIfAbsent(opp.type, () => []).add(opp);
    }

    return groups.entries.map((entry) {
      final type = entry.key;
      final opps = entry.value;
      final saving = opps.fold<int>(0, (s, o) => s + o.potentialSaving);

      return ProposalSection(
        sectionTitle: _sectionTitle(type),
        content: _sectionContent(type, opps),
        opportunities: opps,
        estimatedSaving: saving,
      );
    }).toList();
  }

  String _sectionTitle(OpportunityType type) {
    switch (type) {
      case OpportunityType.taxSaving:
        return 'Tax Saving Investments';
      case OpportunityType.complianceGap:
        return 'Compliance Obligations';
      case OpportunityType.refundOptimization:
        return 'Refund Optimisation';
      case OpportunityType.restructuring:
        return 'Tax Regime & Restructuring';
      case OpportunityType.investmentPlanning:
        return 'Investment Planning';
      case OpportunityType.retirementPlanning:
        return 'Retirement & Senior Benefits';
      case OpportunityType.businessStructure:
        return 'Business Structure';
    }
  }

  String _sectionContent(
    OpportunityType type,
    List<TaxOpportunity> opps,
  ) {
    final titles = opps.map((o) => '• ${o.title}').join('\n');
    return 'The following ${opps.length} opportunity(ies) have been '
        'identified in this category:\n$titles';
  }

  String _generateId(ClientProfile profile) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    return 'PROP-${profile.pan}-$ts';
  }

  String _paise(int paise) {
    final rupees = paise / 100;
    if (rupees >= 100000) {
      return '₹${(rupees / 100000).toStringAsFixed(1)}L';
    }
    if (rupees >= 1000) {
      return '₹${(rupees / 1000).toStringAsFixed(0)}K';
    }
    return '₹${rupees.toStringAsFixed(0)}';
  }
}
