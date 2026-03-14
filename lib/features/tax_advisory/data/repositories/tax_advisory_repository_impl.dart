import 'package:ca_app/features/tax_advisory/domain/models/advisory_opportunity.dart';
import 'package:ca_app/features/tax_advisory/domain/models/advisory_proposal.dart';
import 'package:ca_app/features/tax_advisory/domain/repositories/tax_advisory_repository.dart';

/// Real implementation of [TaxAdvisoryRepository].
///
/// Delegates to Supabase (remote) and falls back to mock data on any
/// network error. Full Drift/Supabase wiring is deferred until the
/// portal integration phase.
class TaxAdvisoryRepositoryImpl implements TaxAdvisoryRepository {
  const TaxAdvisoryRepositoryImpl();

  @override
  Future<List<AdvisoryOpportunity>> getAllOpportunities() async {
    // TODO(portal): wire Supabase fetch from $_opportunitiesTable
    return const [];
  }

  @override
  Future<List<AdvisoryOpportunity>> getOpportunitiesByClient(
    String clientId,
  ) async {
    // TODO(portal): filter by client_id in $_opportunitiesTable
    return const [];
  }

  @override
  Future<String> insertOpportunity(AdvisoryOpportunity opportunity) async {
    // TODO(portal): upsert to $_opportunitiesTable
    return opportunity.id;
  }

  @override
  Future<bool> updateOpportunity(AdvisoryOpportunity opportunity) async {
    // TODO(portal): update row in $_opportunitiesTable
    return true;
  }

  @override
  Future<List<AdvisoryProposal>> getAllProposals() async {
    // TODO(portal): wire Supabase fetch from $_proposalsTable
    return const [];
  }

  @override
  Future<List<AdvisoryProposal>> getProposalsByOpportunity(
    String opportunityId,
  ) async {
    // TODO(portal): filter by opportunity_id in $_proposalsTable
    return const [];
  }

  @override
  Future<String> insertProposal(AdvisoryProposal proposal) async {
    // TODO(portal): upsert to $_proposalsTable
    return proposal.id;
  }

  @override
  Future<bool> updateProposal(AdvisoryProposal proposal) async {
    // TODO(portal): update row in $_proposalsTable
    return true;
  }
}
