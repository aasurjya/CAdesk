import 'package:ca_app/features/tax_advisory/domain/models/advisory_opportunity.dart';
import 'package:ca_app/features/tax_advisory/domain/models/advisory_proposal.dart';
import 'package:ca_app/features/tax_advisory/domain/repositories/tax_advisory_repository.dart';

/// In-memory mock implementation of [TaxAdvisoryRepository].
///
/// Seeded with realistic sample data for development and testing.
/// All state mutations return new lists (immutable patterns).
class MockTaxAdvisoryRepository implements TaxAdvisoryRepository {
  static final List<AdvisoryOpportunity> _seedOpportunities = [
    AdvisoryOpportunity(
      id: 'opp-mock-001',
      clientId: 'client-101',
      clientName: 'Ramesh Agarwal',
      opportunityType: OpportunityType.missingDeductions,
      title: 'Missed HRA Deduction — FY2025',
      description:
          'Client has been paying rent but has not claimed HRA exemption.',
      estimatedFee: 25000,
      priority: OpportunityPriority.high,
      status: OpportunityStatus.new_,
      detectedAt: DateTime(2026, 3, 9),
      signals: const [
        'Salary slip shows HRA component',
        'No HRA claim in ITR draft',
      ],
    ),
    AdvisoryOpportunity(
      id: 'opp-mock-002',
      clientId: 'client-102',
      clientName: 'Sunanda Krishnamurthy',
      opportunityType: OpportunityType.regimeOptimisation,
      title: 'Regime Switch Saves 85K',
      description: 'Switching from new to old tax regime saves significantly.',
      estimatedFee: 18000,
      priority: OpportunityPriority.high,
      status: OpportunityStatus.reviewed,
      detectedAt: DateTime(2026, 3, 7),
      signals: const ['80C investments confirmed', '80D premium available'],
    ),
  ];

  static final List<AdvisoryProposal> _seedProposals = [
    AdvisoryProposal(
      id: 'prop-mock-001',
      opportunityId: 'opp-mock-002',
      clientName: 'Sunanda Krishnamurthy',
      proposedFee: 18000,
      scope: 'Comprehensive regime comparison report for FY2025.',
      sentAt: DateTime(2026, 3, 8),
      status: ProposalStatus.sent,
    ),
  ];

  final List<AdvisoryOpportunity> _opportunities = List.of(_seedOpportunities);
  final List<AdvisoryProposal> _proposals = List.of(_seedProposals);

  @override
  Future<List<AdvisoryOpportunity>> getAllOpportunities() async {
    return List.unmodifiable(_opportunities);
  }

  @override
  Future<List<AdvisoryOpportunity>> getOpportunitiesByClient(
    String clientId,
  ) async {
    return List.unmodifiable(
      _opportunities.where((o) => o.clientId == clientId).toList(),
    );
  }

  @override
  Future<String> insertOpportunity(AdvisoryOpportunity opportunity) async {
    _opportunities.add(opportunity);
    return opportunity.id;
  }

  @override
  Future<bool> updateOpportunity(AdvisoryOpportunity opportunity) async {
    final idx = _opportunities.indexWhere((o) => o.id == opportunity.id);
    if (idx == -1) return false;
    final updated = List<AdvisoryOpportunity>.of(_opportunities)
      ..[idx] = opportunity;
    _opportunities
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<List<AdvisoryProposal>> getAllProposals() async {
    return List.unmodifiable(_proposals);
  }

  @override
  Future<List<AdvisoryProposal>> getProposalsByOpportunity(
    String opportunityId,
  ) async {
    return List.unmodifiable(
      _proposals.where((p) => p.opportunityId == opportunityId).toList(),
    );
  }

  @override
  Future<String> insertProposal(AdvisoryProposal proposal) async {
    _proposals.add(proposal);
    return proposal.id;
  }

  @override
  Future<bool> updateProposal(AdvisoryProposal proposal) async {
    final idx = _proposals.indexWhere((p) => p.id == proposal.id);
    if (idx == -1) return false;
    final updated = List<AdvisoryProposal>.of(_proposals)..[idx] = proposal;
    _proposals
      ..clear()
      ..addAll(updated);
    return true;
  }
}
