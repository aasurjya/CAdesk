import 'package:ca_app/features/tax_advisory/domain/models/advisory_opportunity.dart';
import 'package:ca_app/features/tax_advisory/domain/models/advisory_proposal.dart';

/// Abstract contract for tax advisory data operations.
///
/// Concrete implementations can use Supabase (real) or in-memory data (mock).
abstract class TaxAdvisoryRepository {
  /// Retrieve all advisory opportunities.
  Future<List<AdvisoryOpportunity>> getAllOpportunities();

  /// Retrieve opportunities for a given [clientId].
  Future<List<AdvisoryOpportunity>> getOpportunitiesByClient(String clientId);

  /// Insert a new [AdvisoryOpportunity]. Returns its ID.
  Future<String> insertOpportunity(AdvisoryOpportunity opportunity);

  /// Update an existing [AdvisoryOpportunity]. Returns true on success.
  Future<bool> updateOpportunity(AdvisoryOpportunity opportunity);

  /// Retrieve all advisory proposals.
  Future<List<AdvisoryProposal>> getAllProposals();

  /// Retrieve proposals for a given [opportunityId].
  Future<List<AdvisoryProposal>> getProposalsByOpportunity(
    String opportunityId,
  );

  /// Insert a new [AdvisoryProposal]. Returns its ID.
  Future<String> insertProposal(AdvisoryProposal proposal);

  /// Update an existing [AdvisoryProposal]. Returns true on success.
  Future<bool> updateProposal(AdvisoryProposal proposal);
}
