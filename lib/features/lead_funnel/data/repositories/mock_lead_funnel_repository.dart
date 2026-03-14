import 'package:ca_app/features/lead_funnel/domain/models/lead.dart';
import 'package:ca_app/features/lead_funnel/domain/models/campaign.dart';
import 'package:ca_app/features/lead_funnel/domain/repositories/lead_funnel_repository.dart';

/// In-memory mock implementation of [LeadFunnelRepository].
///
/// Seeded with realistic sample data for development and testing.
/// All state mutations return new lists (immutable patterns).
class MockLeadFunnelRepository implements LeadFunnelRepository {
  static final List<Lead> _seedLeads = [
    Lead(
      id: 'mock-lead-001',
      name: 'Arjun Mehta',
      phone: '9876543210',
      email: 'arjun.mehta@example.com',
      source: LeadSource.referral,
      stage: LeadStage.qualified,
      estimatedValue: 120000,
      assignedTo: 'CA Suresh Iyer',
      createdAt: DateTime(2026, 2, 10),
      lastContactedAt: DateTime(2026, 3, 5),
      notes: 'Referred by existing client Rajesh Kumar. Needs GST + ITR.',
    ),
    Lead(
      id: 'mock-lead-002',
      name: 'Sunita Deshmukh',
      phone: '9123456789',
      source: LeadSource.website,
      stage: LeadStage.proposalSent,
      estimatedValue: 75000,
      assignedTo: 'CA Meera Joshi',
      createdAt: DateTime(2026, 2, 28),
      lastContactedAt: DateTime(2026, 3, 10),
      notes: 'Website inquiry for audit services for her textile firm.',
    ),
    Lead(
      id: 'mock-lead-003',
      name: 'Vikram Exports Pvt Ltd',
      phone: '9988776655',
      email: 'accounts@vikramexports.in',
      source: LeadSource.campaign,
      stage: LeadStage.newLead,
      estimatedValue: 250000,
      assignedTo: 'CA Vikram Singh',
      createdAt: DateTime(2026, 3, 12),
      notes: 'Responded to ITR season campaign. Large exporter.',
    ),
  ];

  static final List<Campaign> _seedCampaigns = [
    Campaign(
      id: 'mock-campaign-001',
      title: 'ITR Season 2026 — Salaried Clients',
      type: CampaignType.itrSeason,
      status: CampaignStatus.active,
      startDate: DateTime(2026, 6, 1),
      endDate: DateTime(2026, 7, 31),
      budget: 25000,
      leadsGenerated: 38,
      conversions: 22,
      targetService: 'ITR Filing (Salaried)',
    ),
    Campaign(
      id: 'mock-campaign-002',
      title: 'GST Annual Return Push Q4 FY26',
      type: CampaignType.gstAnnual,
      status: CampaignStatus.planning,
      startDate: DateTime(2026, 12, 1),
      endDate: DateTime(2026, 12, 31),
      budget: 15000,
      leadsGenerated: 0,
      conversions: 0,
      targetService: 'GSTR-9/9C Filing',
    ),
    Campaign(
      id: 'mock-campaign-003',
      title: 'Dormant Client Reactivation — Q1 FY27',
      type: CampaignType.dormantReactivation,
      status: CampaignStatus.completed,
      startDate: DateTime(2026, 4, 1),
      endDate: DateTime(2026, 5, 15),
      budget: 10000,
      leadsGenerated: 18,
      conversions: 7,
      targetService: 'Full Compliance Package',
    ),
  ];

  final List<Lead> _leads = List.of(_seedLeads);
  final List<Campaign> _campaigns = List.of(_seedCampaigns);

  // -------------------------------------------------------------------------
  // Lead
  // -------------------------------------------------------------------------

  @override
  Future<List<Lead>> getLeads() async => List.unmodifiable(_leads);

  @override
  Future<List<Lead>> getLeadsByStage(LeadStage stage) async =>
      List.unmodifiable(_leads.where((l) => l.stage == stage).toList());

  @override
  Future<List<Lead>> getLeadsBySource(LeadSource source) async =>
      List.unmodifiable(_leads.where((l) => l.source == source).toList());

  @override
  Future<Lead?> getLeadById(String id) async {
    final matches = _leads.where((l) => l.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Future<String> insertLead(Lead lead) async {
    _leads.add(lead);
    return lead.id;
  }

  @override
  Future<bool> updateLead(Lead lead) async {
    final idx = _leads.indexWhere((l) => l.id == lead.id);
    if (idx == -1) return false;
    final updated = List<Lead>.of(_leads)..[idx] = lead;
    _leads
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteLead(String id) async {
    final before = _leads.length;
    _leads.removeWhere((l) => l.id == id);
    return _leads.length < before;
  }

  // -------------------------------------------------------------------------
  // Campaign
  // -------------------------------------------------------------------------

  @override
  Future<List<Campaign>> getCampaigns() async => List.unmodifiable(_campaigns);

  @override
  Future<List<Campaign>> getCampaignsByStatus(CampaignStatus status) async =>
      List.unmodifiable(_campaigns.where((c) => c.status == status).toList());

  @override
  Future<String> insertCampaign(Campaign campaign) async {
    _campaigns.add(campaign);
    return campaign.id;
  }

  @override
  Future<bool> updateCampaign(Campaign campaign) async {
    final idx = _campaigns.indexWhere((c) => c.id == campaign.id);
    if (idx == -1) return false;
    final updated = List<Campaign>.of(_campaigns)..[idx] = campaign;
    _campaigns
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteCampaign(String id) async {
    final before = _campaigns.length;
    _campaigns.removeWhere((c) => c.id == id);
    return _campaigns.length < before;
  }
}
