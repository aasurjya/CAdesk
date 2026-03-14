import 'package:ca_app/features/lead_funnel/domain/models/lead.dart';
import 'package:ca_app/features/lead_funnel/domain/models/campaign.dart';

/// Abstract contract for lead funnel data operations.
///
/// Covers leads and marketing campaigns.
abstract class LeadFunnelRepository {
  // -------------------------------------------------------------------------
  // Lead operations
  // -------------------------------------------------------------------------

  /// Retrieve all leads.
  Future<List<Lead>> getLeads();

  /// Retrieve leads filtered by [stage].
  Future<List<Lead>> getLeadsByStage(LeadStage stage);

  /// Retrieve leads filtered by [source].
  Future<List<Lead>> getLeadsBySource(LeadSource source);

  /// Retrieve a single lead by [id]. Returns null if not found.
  Future<Lead?> getLeadById(String id);

  /// Insert a new [Lead] and return its ID.
  Future<String> insertLead(Lead lead);

  /// Update an existing [Lead]. Returns true on success.
  Future<bool> updateLead(Lead lead);

  /// Delete the lead identified by [id]. Returns true on success.
  Future<bool> deleteLead(String id);

  // -------------------------------------------------------------------------
  // Campaign operations
  // -------------------------------------------------------------------------

  /// Retrieve all campaigns.
  Future<List<Campaign>> getCampaigns();

  /// Retrieve campaigns filtered by [status].
  Future<List<Campaign>> getCampaignsByStatus(CampaignStatus status);

  /// Insert a new [Campaign] and return its ID.
  Future<String> insertCampaign(Campaign campaign);

  /// Update an existing [Campaign]. Returns true on success.
  Future<bool> updateCampaign(Campaign campaign);

  /// Delete the campaign identified by [id]. Returns true on success.
  Future<bool> deleteCampaign(String id);
}
