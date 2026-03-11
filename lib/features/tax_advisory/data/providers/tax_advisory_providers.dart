import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/advisory_opportunity.dart';
import '../../domain/models/advisory_proposal.dart';

// ---------------------------------------------------------------------------
// Mock data — Opportunities
// ---------------------------------------------------------------------------

final List<AdvisoryOpportunity> _mockOpportunities = [
  AdvisoryOpportunity(
    id: 'opp-001',
    clientId: 'client-101',
    clientName: 'Ramesh Agarwal',
    opportunityType: OpportunityType.missingDeductions,
    title: '₹12L Missed HRA Deduction — FY2025',
    description:
        'Client has been paying rent of ₹1L/month in Mumbai but has not claimed HRA exemption for FY2025. '
        'Potential tax saving of ₹3.6L at 30% slab.',
    estimatedFee: 25000,
    priority: OpportunityPriority.high,
    status: OpportunityStatus.new_,
    detectedAt: DateTime(2026, 3, 9, 10, 15),
    signals: [
      'Salary slip shows HRA component',
      'No HRA claim in ITR draft',
      'Rent receipts available in documents',
    ],
  ),
  AdvisoryOpportunity(
    id: 'opp-002',
    clientId: 'client-102',
    clientName: 'Sunanda Krishnamurthy',
    opportunityType: OpportunityType.regimeOptimisation,
    title: 'Regime Switch Saves ₹85K — New vs Old',
    description:
        'Analysis shows switching from new tax regime to old regime saves ₹85,000 for FY2025 '
        'given existing 80C, 80D investments and HRA claims.',
    estimatedFee: 18000,
    priority: OpportunityPriority.high,
    status: OpportunityStatus.reviewed,
    detectedAt: DateTime(2026, 3, 7, 14, 30),
    signals: [
      '80C investments of ₹1.5L confirmed',
      '80D premium ₹50K',
      'HRA eligible ₹3.6L',
    ],
  ),
  AdvisoryOpportunity(
    id: 'opp-003',
    clientId: 'client-103',
    clientName: 'Vikram Bajaj',
    opportunityType: OpportunityType.capitalGainsHarvesting,
    title: '₹3.2L Capital Gains Harvesting Window',
    description:
        'Portfolio has unrealised long-term gains of ₹3.2L eligible for tax-free harvesting '
        'before 31-Mar-2026. Reinvesting resets the cost basis.',
    estimatedFee: 35000,
    priority: OpportunityPriority.high,
    status: OpportunityStatus.proposalSent,
    detectedAt: DateTime(2026, 3, 1, 9, 0),
    signals: [
      'LTCG ₹3.2L in equity portfolio',
      '₹1L LTCG exemption available',
      'No tax on harvested gains this FY',
    ],
  ),
  AdvisoryOpportunity(
    id: 'opp-004',
    clientId: 'client-104',
    clientName: 'Meena Iyer HUF',
    opportunityType: OpportunityType.advanceTaxPlanning,
    title: 'Q4 Advance Tax Shortfall — ₹48K Due',
    description:
        'Estimated advance tax liability for Q4 (Mar 2026) is ₹48,000. '
        'Failure to pay by 15-Mar-2026 will attract 1% monthly interest under Sec 234C.',
    estimatedFee: 8000,
    priority: OpportunityPriority.high,
    status: OpportunityStatus.new_,
    detectedAt: DateTime(2026, 3, 8, 11, 45),
    signals: [
      'Business income projected ₹28L',
      'Previous instalments underpaid',
      'Deadline 15-Mar-2026',
    ],
  ),
  AdvisoryOpportunity(
    id: 'opp-005',
    clientId: 'client-105',
    clientName: 'Patel Exports Pvt Ltd',
    opportunityType: OpportunityType.gstOptimisation,
    title: 'ITC Reversal of ₹1.8L Can Be Recovered',
    description:
        'Auto-reversed ITC of ₹1.8L due to GSTR-2A/2B mismatch can be reclaimed by reconciling '
        'supplier invoices and filing rectification in GSTR-3B.',
    estimatedFee: 45000,
    priority: OpportunityPriority.medium,
    status: OpportunityStatus.reviewed,
    detectedAt: DateTime(2026, 2, 28, 16, 0),
    signals: [
      'ITC reversal in Feb GSTR-3B',
      '12 supplier invoices unmatched',
      'Suppliers have filed GSTR-1',
    ],
  ),
  AdvisoryOpportunity(
    id: 'opp-006',
    clientId: 'client-106',
    clientName: 'Arjun Nambiar',
    opportunityType: OpportunityType.nriCompliance,
    title: 'NRI Rental Income — TDS & FEMA Filing Pending',
    description:
        'Client (NRI) has rental income from Mumbai property. Tenant has not deducted TDS under '
        'Sec 195 for 6 months, creating a compliance risk of ₹2.4L liability.',
    estimatedFee: 55000,
    priority: OpportunityPriority.high,
    status: OpportunityStatus.new_,
    detectedAt: DateTime(2026, 3, 5, 13, 20),
    signals: [
      'NRI status confirmed',
      'Rental agreement ₹40K/month',
      'TDS Form 15CA/CB not filed',
    ],
  ),
  AdvisoryOpportunity(
    id: 'opp-007',
    clientId: 'client-107',
    clientName: 'NovaTech Solutions LLP',
    opportunityType: OpportunityType.startupIncentive,
    title: 'Sec 80-IAC Tax Holiday — 3 Years Eligible',
    description:
        'Startup incorporated in Jan 2023 with DPIIT recognition is eligible for 100% profit '
        'deduction under Sec 80-IAC for 3 consecutive years.',
    estimatedFee: 75000,
    priority: OpportunityPriority.medium,
    status: OpportunityStatus.converted,
    detectedAt: DateTime(2026, 2, 20, 10, 0),
    signals: [
      'DPIIT certificate available',
      'Incorporated Jan 2023',
      'Profit of ₹42L in FY2025',
    ],
  ),
  AdvisoryOpportunity(
    id: 'opp-008',
    clientId: 'client-108',
    clientName: 'Sharma & Sons Trading Co',
    opportunityType: OpportunityType.tdsPlanning,
    title: 'TDS Default Risk — ₹6.2L Contractor Payments',
    description:
        'Payments of ₹6.2L to contractors exceed ₹30K threshold; TDS under Sec 194C '
        'has not been deducted for 4 months creating disallowance risk under Sec 40(a)(ia).',
    estimatedFee: 22000,
    priority: OpportunityPriority.medium,
    status: OpportunityStatus.new_,
    detectedAt: DateTime(2026, 3, 10, 8, 30),
    signals: [
      'Contractor payments ₹6.2L',
      'No TDS deducted Oct–Jan',
      'Disallowance risk ₹6.2L',
    ],
  ),
];

// ---------------------------------------------------------------------------
// Mock data — Proposals
// ---------------------------------------------------------------------------

final List<AdvisoryProposal> _mockProposals = [
  AdvisoryProposal(
    id: 'prop-001',
    opportunityId: 'opp-003',
    clientName: 'Vikram Bajaj',
    proposedFee: 35000,
    scope:
        'Capital gains harvesting strategy: identify eligible LTCG positions, '
        'execute before 31-Mar-2026, reinvest with reset cost basis, and '
        'file revised advance tax computation.',
    sentAt: DateTime(2026, 3, 3, 11, 0),
    status: ProposalStatus.sent,
  ),
  AdvisoryProposal(
    id: 'prop-002',
    opportunityId: 'opp-007',
    clientName: 'NovaTech Solutions LLP',
    proposedFee: 75000,
    scope:
        'Sec 80-IAC application: eligibility review, documentation checklist, '
        'Form 1 filing with DPIIT, and incorporation into FY2025 ITR to claim '
        '100% profit deduction.',
    sentAt: DateTime(2026, 2, 22, 14, 0),
    status: ProposalStatus.accepted,
    acceptedAt: DateTime(2026, 2, 25, 10, 30),
  ),
  AdvisoryProposal(
    id: 'prop-003',
    opportunityId: 'opp-002',
    clientName: 'Sunanda Krishnamurthy',
    proposedFee: 18000,
    scope:
        'Comprehensive regime comparison report for FY2025: compute tax under '
        'both regimes, recommend optimal choice, and file ITR with selected regime.',
    sentAt: DateTime(2026, 3, 8, 9, 0),
    status: ProposalStatus.sent,
  ),
  AdvisoryProposal(
    id: 'prop-004',
    opportunityId: 'opp-005',
    clientName: 'Patel Exports Pvt Ltd',
    proposedFee: 45000,
    scope:
        'GST ITC reconciliation: match GSTR-2A vs books, contact suppliers for '
        'amendments, prepare and file GSTR-3B rectification to recover ₹1.8L ITC.',
    sentAt: DateTime(2026, 3, 2, 15, 30),
    status: ProposalStatus.rejected,
  ),
  AdvisoryProposal(
    id: 'prop-005',
    opportunityId: 'opp-006',
    clientName: 'Arjun Nambiar',
    proposedFee: 55000,
    scope:
        'NRI compliance package: TDS computation under Sec 195 for 6 months, '
        'Form 15CA/CB preparation, FEMA reporting for rental repatriation, '
        'and advance tax calculation.',
    sentAt: DateTime(2026, 3, 7, 12, 0),
    status: ProposalStatus.draft,
  ),
];

// ---------------------------------------------------------------------------
// Notifiers
// ---------------------------------------------------------------------------

class _OpportunitiesNotifier extends Notifier<List<AdvisoryOpportunity>> {
  @override
  List<AdvisoryOpportunity> build() => List.unmodifiable(_mockOpportunities);
}

class _ProposalsNotifier extends Notifier<List<AdvisoryProposal>> {
  @override
  List<AdvisoryProposal> build() => List.unmodifiable(_mockProposals);
}

class _OpportunityTypeFilterNotifier extends Notifier<OpportunityType?> {
  @override
  OpportunityType? build() => null;

  void update(OpportunityType? value) => state = value;
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// All advisory opportunities (unfiltered).
final allOpportunitiesProvider =
    NotifierProvider<_OpportunitiesNotifier, List<AdvisoryOpportunity>>(
      _OpportunitiesNotifier.new,
    );

/// All advisory proposals.
final allProposalsProvider =
    NotifierProvider<_ProposalsNotifier, List<AdvisoryProposal>>(
      _ProposalsNotifier.new,
    );

/// Currently selected opportunity type filter (null = show all).
final opportunityTypeFilterProvider =
    NotifierProvider<_OpportunityTypeFilterNotifier, OpportunityType?>(
      _OpportunityTypeFilterNotifier.new,
    );

/// Opportunities filtered by the selected OpportunityType.
final filteredOpportunitiesProvider = Provider<List<AdvisoryOpportunity>>((
  ref,
) {
  final filter = ref.watch(opportunityTypeFilterProvider);
  final all = ref.watch(allOpportunitiesProvider);
  if (filter == null) return all;
  return all.where((o) => o.opportunityType == filter).toList();
});

/// Summary statistics for the advisory dashboard.
final advisorySummaryProvider = Provider<Map<String, dynamic>>((ref) {
  final opportunities = ref.watch(allOpportunitiesProvider);
  final total = opportunities.length;
  final highPriority = opportunities
      .where((o) => o.priority == OpportunityPriority.high)
      .length;
  final converted = opportunities
      .where((o) => o.status == OpportunityStatus.converted)
      .length;

  final totalFeesPipeline = opportunities
      .where((o) => o.status != OpportunityStatus.dismissed)
      .fold<double>(0, (sum, o) => sum + o.estimatedFee);

  final String feeLabel;
  if (totalFeesPipeline >= 100000) {
    final lakhs = totalFeesPipeline / 100000;
    final formatted = lakhs == lakhs.truncateToDouble()
        ? '${lakhs.toInt()}L'
        : '${lakhs.toStringAsFixed(1)}L';
    feeLabel = '₹$formatted';
  } else if (totalFeesPipeline >= 1000) {
    final thousands = totalFeesPipeline / 1000;
    final formatted = thousands == thousands.truncateToDouble()
        ? '${thousands.toInt()}K'
        : '${thousands.toStringAsFixed(1)}K';
    feeLabel = '₹$formatted';
  } else {
    feeLabel = '₹${totalFeesPipeline.toInt()}';
  }

  return {
    'total': total,
    'highPriority': highPriority,
    'converted': converted,
    'totalFeesPipeline': feeLabel,
  };
});
