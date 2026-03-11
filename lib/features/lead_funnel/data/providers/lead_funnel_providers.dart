import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/campaign.dart';
import '../../domain/models/lead.dart';

// ---------------------------------------------------------------------------
// Mock data — Leads
// ---------------------------------------------------------------------------

final List<Lead> _mockLeads = [
  Lead(
    id: 'lead-001',
    name: 'Arjun Malhotra',
    phone: '+91 98200 11234',
    email: 'arjun.m@gmail.com',
    source: LeadSource.referral,
    stage: LeadStage.newLead,
    estimatedValue: 35000,
    assignedTo: 'Priya Mehta',
    createdAt: DateTime(2026, 3, 9),
    lastContactedAt: null,
    notes: 'Referred by Tata Steel client. Needs ITR filing for FY2025.',
  ),
  Lead(
    id: 'lead-002',
    name: 'Sunita Agarwal',
    phone: '+91 99870 56789',
    email: 'sunita.a@yahoo.in',
    source: LeadSource.website,
    stage: LeadStage.contacted,
    estimatedValue: 120000,
    assignedTo: 'Rajesh Sharma',
    createdAt: DateTime(2026, 3, 1),
    lastContactedAt: DateTime(2026, 3, 8),
    notes: 'Startup incorporated in Jan 2026. Needs GST + bookkeeping bundle.',
  ),
  Lead(
    id: 'lead-003',
    name: 'Deepak Choudhary',
    phone: '+91 91234 78900',
    email: null,
    source: LeadSource.whatsApp,
    stage: LeadStage.qualified,
    estimatedValue: 75000,
    assignedTo: 'Anil Kumar',
    createdAt: DateTime(2026, 2, 20),
    lastContactedAt: DateTime(2026, 3, 5),
    notes: 'NRI returning to India. Needs NRI ITR + FEMA advisory.',
  ),
  Lead(
    id: 'lead-004',
    name: 'Kavitha Reddy',
    phone: '+91 88001 23456',
    email: 'kavitha.r@rediffmail.com',
    source: LeadSource.walkin,
    stage: LeadStage.proposalSent,
    estimatedValue: 200000,
    assignedTo: 'Rajesh Sharma',
    createdAt: DateTime(2026, 2, 10),
    lastContactedAt: DateTime(2026, 3, 7),
    notes:
        'Manufacturing unit in Pune. Statutory audit + GST annual return bundle.',
  ),
  Lead(
    id: 'lead-005',
    name: 'Rohit Jain',
    phone: '+91 97300 99001',
    email: 'rohit.jain@outlook.com',
    source: LeadSource.socialMedia,
    stage: LeadStage.negotiation,
    estimatedValue: 150000,
    assignedTo: 'Priya Mehta',
    createdAt: DateTime(2026, 2, 5),
    lastContactedAt: DateTime(2026, 3, 9),
    notes: 'E-commerce firm. Needs GST reconciliation + income tax planning.',
  ),
  Lead(
    id: 'lead-006',
    name: 'Meera Pillai',
    phone: '+91 94450 67812',
    email: 'meera.p@gmail.com',
    source: LeadSource.campaign,
    stage: LeadStage.won,
    estimatedValue: 90000,
    assignedTo: 'Sunita Rao',
    createdAt: DateTime(2026, 1, 15),
    lastContactedAt: DateTime(2026, 2, 28),
    notes: 'Converted via ITR Season campaign. Annual ITR + advisory retainer.',
  ),
  Lead(
    id: 'lead-007',
    name: 'Sanjay Dubey',
    phone: '+91 98765 43210',
    email: null,
    source: LeadSource.partner,
    stage: LeadStage.lost,
    estimatedValue: 60000,
    assignedTo: 'Anil Kumar',
    createdAt: DateTime(2026, 1, 20),
    lastContactedAt: DateTime(2026, 2, 10),
    notes:
        'Went with a Big-4 firm for audit due to MNC subsidiary requirement.',
  ),
  Lead(
    id: 'lead-008',
    name: 'Pooja Nambiar',
    phone: '+91 99120 34567',
    email: 'pooja.n@gmail.com',
    source: LeadSource.referral,
    stage: LeadStage.contacted,
    estimatedValue: 45000,
    assignedTo: 'Priya Mehta',
    createdAt: DateTime(2026, 3, 6),
    lastContactedAt: DateTime(2026, 3, 6),
    notes: 'Doctor in private practice. ITR filing + advance tax planning.',
  ),
  Lead(
    id: 'lead-009',
    name: 'Harish Tiwari',
    phone: '+91 80001 11223',
    email: 'harish.t@startup.in',
    source: LeadSource.website,
    stage: LeadStage.newLead,
    estimatedValue: 180000,
    assignedTo: 'Rajesh Sharma',
    createdAt: DateTime(2026, 3, 10),
    lastContactedAt: null,
    notes: 'Series-A startup. Needs company secretarial + CFO advisory.',
  ),
  Lead(
    id: 'lead-010',
    name: 'Ananya Krishnan',
    phone: '+91 91778 88990',
    email: 'ananya.k@nri.com',
    source: LeadSource.campaign,
    stage: LeadStage.qualified,
    estimatedValue: 250000,
    assignedTo: 'Sunita Rao',
    createdAt: DateTime(2026, 2, 25),
    lastContactedAt: DateTime(2026, 3, 3),
    notes:
        'NRI based in the US. Large property sale — capital gains + NRI ITR.',
  ),
];

// ---------------------------------------------------------------------------
// Mock data — Campaigns
// ---------------------------------------------------------------------------

final List<Campaign> _mockCampaigns = [
  Campaign(
    id: 'camp-001',
    title: 'ITR Season 2025 Outreach',
    type: CampaignType.itrSeason,
    status: CampaignStatus.active,
    startDate: DateTime(2026, 3, 1),
    endDate: DateTime(2026, 7, 31),
    budget: 50000,
    leadsGenerated: 28,
    conversions: 12,
    targetService: 'Income Tax Return Filing',
  ),
  Campaign(
    id: 'camp-002',
    title: 'GST Annual Return Drive',
    type: CampaignType.gstAnnual,
    status: CampaignStatus.active,
    startDate: DateTime(2026, 2, 15),
    endDate: DateTime(2026, 4, 30),
    budget: 35000,
    leadsGenerated: 15,
    conversions: 6,
    targetService: 'GST GSTR-9 & 9C Filing',
  ),
  Campaign(
    id: 'camp-003',
    title: 'Advance Tax Q1 Reminder',
    type: CampaignType.advanceTax,
    status: CampaignStatus.planning,
    startDate: DateTime(2026, 5, 15),
    endDate: DateTime(2026, 6, 15),
    budget: 20000,
    leadsGenerated: 0,
    conversions: 0,
    targetService: 'Advance Tax Computation & Payment',
  ),
  Campaign(
    id: 'camp-004',
    title: 'Dormant Client Re-engagement',
    type: CampaignType.dormantReactivation,
    status: CampaignStatus.completed,
    startDate: DateTime(2026, 1, 1),
    endDate: DateTime(2026, 2, 28),
    budget: 15000,
    leadsGenerated: 22,
    conversions: 9,
    targetService: 'All Services',
  ),
  Campaign(
    id: 'camp-005',
    title: 'Startup Founders Referral Drive',
    type: CampaignType.referralDrive,
    status: CampaignStatus.active,
    startDate: DateTime(2026, 2, 1),
    endDate: DateTime(2026, 5, 31),
    budget: 25000,
    leadsGenerated: 10,
    conversions: 3,
    targetService: 'Startup Advisory & Company Formation',
  ),
];

// ---------------------------------------------------------------------------
// Providers — Leads
// ---------------------------------------------------------------------------

/// All leads — mutable list managed by [AllLeadsNotifier].
final allLeadsProvider = NotifierProvider<AllLeadsNotifier, List<Lead>>(
  AllLeadsNotifier.new,
);

class AllLeadsNotifier extends Notifier<List<Lead>> {
  @override
  List<Lead> build() => List.unmodifiable(_mockLeads);

  void updateLead(Lead updated) {
    state = List.unmodifiable(
      state.map((l) => l.id == updated.id ? updated : l),
    );
  }
}

/// Selected [LeadStage] filter — null means show all.
final leadStageFilterProvider =
    NotifierProvider<LeadStageFilterNotifier, LeadStage?>(
      LeadStageFilterNotifier.new,
    );

class LeadStageFilterNotifier extends Notifier<LeadStage?> {
  @override
  LeadStage? build() => null;

  void update(LeadStage? stage) => state = stage;
}

/// Leads filtered by [leadStageFilterProvider].
final filteredLeadsProvider = Provider<List<Lead>>((ref) {
  final stage = ref.watch(leadStageFilterProvider);
  final all = ref.watch(allLeadsProvider);
  if (stage == null) return all;
  return all.where((l) => l.stage == stage).toList();
});

// ---------------------------------------------------------------------------
// Providers — Campaigns
// ---------------------------------------------------------------------------

/// All campaigns — mutable list managed by [AllCampaignsNotifier].
final allCampaignsProvider =
    NotifierProvider<AllCampaignsNotifier, List<Campaign>>(
      AllCampaignsNotifier.new,
    );

class AllCampaignsNotifier extends Notifier<List<Campaign>> {
  @override
  List<Campaign> build() => List.unmodifiable(_mockCampaigns);

  void updateCampaign(Campaign updated) {
    state = List.unmodifiable(
      state.map((c) => c.id == updated.id ? updated : c),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary provider
// ---------------------------------------------------------------------------

/// High-level funnel KPIs for the summary cards.
final leadFunnelSummaryProvider = Provider<Map<String, dynamic>>((ref) {
  final leads = ref.watch(allLeadsProvider);

  final now = DateTime(2026, 3, 11);
  final weekAgo = now.subtract(const Duration(days: 7));

  final totalLeads = leads.length;
  final newThisWeek = leads.where((l) => l.createdAt.isAfter(weekAgo)).length;
  final won = leads.where((l) => l.stage == LeadStage.won).length;

  final pipelineValue = leads
      .where((l) => l.stage != LeadStage.won && l.stage != LeadStage.lost)
      .fold<double>(0, (sum, l) => sum + l.estimatedValue);

  final String formattedPipeline;
  if (pipelineValue >= 100000) {
    formattedPipeline = '₹${(pipelineValue / 100000).toStringAsFixed(1)}L';
  } else {
    formattedPipeline = '₹${pipelineValue.toStringAsFixed(0)}';
  }

  return {
    'totalLeads': totalLeads,
    'newThisWeek': newThisWeek,
    'won': won,
    'totalPipelineValue': formattedPipeline,
  };
});
