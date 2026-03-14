import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/features/lead_funnel/domain/models/lead.dart';
import 'package:ca_app/features/lead_funnel/domain/models/campaign.dart';
import 'package:ca_app/features/lead_funnel/domain/repositories/lead_funnel_repository.dart';

/// Real implementation of [LeadFunnelRepository] backed by Supabase.
///
/// Falls back to empty results on network errors to keep the UI responsive.
class LeadFunnelRepositoryImpl implements LeadFunnelRepository {
  const LeadFunnelRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const _leadsTable = 'leads';
  static const _campaignsTable = 'campaigns';

  // -------------------------------------------------------------------------
  // Lead
  // -------------------------------------------------------------------------

  @override
  Future<List<Lead>> getLeads() async {
    try {
      final rows = await _client.from(_leadsTable).select();
      return List.unmodifiable((rows as List).map(_leadFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<Lead>> getLeadsByStage(LeadStage stage) async {
    try {
      final rows = await _client
          .from(_leadsTable)
          .select()
          .eq('stage', stage.name);
      return List.unmodifiable((rows as List).map(_leadFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<Lead>> getLeadsBySource(LeadSource source) async {
    try {
      final rows = await _client
          .from(_leadsTable)
          .select()
          .eq('source', source.name);
      return List.unmodifiable((rows as List).map(_leadFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<Lead?> getLeadById(String id) async {
    try {
      final row = await _client
          .from(_leadsTable)
          .select()
          .eq('id', id)
          .single();
      return _leadFromRow(row);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String> insertLead(Lead lead) async {
    final row = await _client
        .from(_leadsTable)
        .insert(_leadToRow(lead))
        .select()
        .single();
    return row['id'] as String;
  }

  @override
  Future<bool> updateLead(Lead lead) async {
    try {
      await _client
          .from(_leadsTable)
          .update(_leadToRow(lead))
          .eq('id', lead.id);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteLead(String id) async {
    try {
      await _client.from(_leadsTable).delete().eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // Campaign
  // -------------------------------------------------------------------------

  @override
  Future<List<Campaign>> getCampaigns() async {
    try {
      final rows = await _client.from(_campaignsTable).select();
      return List.unmodifiable((rows as List).map(_campaignFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<Campaign>> getCampaignsByStatus(CampaignStatus status) async {
    try {
      final rows = await _client
          .from(_campaignsTable)
          .select()
          .eq('status', status.name);
      return List.unmodifiable((rows as List).map(_campaignFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<String> insertCampaign(Campaign campaign) async {
    final row = await _client
        .from(_campaignsTable)
        .insert(_campaignToRow(campaign))
        .select()
        .single();
    return row['id'] as String;
  }

  @override
  Future<bool> updateCampaign(Campaign campaign) async {
    try {
      await _client
          .from(_campaignsTable)
          .update(_campaignToRow(campaign))
          .eq('id', campaign.id);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteCampaign(String id) async {
    try {
      await _client.from(_campaignsTable).delete().eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // Mappers
  // -------------------------------------------------------------------------

  Lead _leadFromRow(dynamic row) {
    final m = row as Map<String, dynamic>;
    return Lead(
      id: m['id'] as String,
      name: m['name'] as String,
      phone: m['phone'] as String,
      email: m['email'] as String?,
      source: LeadSource.values.firstWhere((e) => e.name == m['source']),
      stage: LeadStage.values.firstWhere((e) => e.name == m['stage']),
      estimatedValue: (m['estimated_value'] as num).toDouble(),
      assignedTo: m['assigned_to'] as String,
      createdAt: DateTime.parse(m['created_at'] as String),
      lastContactedAt: m['last_contacted_at'] != null
          ? DateTime.parse(m['last_contacted_at'] as String)
          : null,
      notes: m['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> _leadToRow(Lead l) => {
    'id': l.id,
    'name': l.name,
    'phone': l.phone,
    'email': l.email,
    'source': l.source.name,
    'stage': l.stage.name,
    'estimated_value': l.estimatedValue,
    'assigned_to': l.assignedTo,
    'created_at': l.createdAt.toIso8601String(),
    'last_contacted_at': l.lastContactedAt?.toIso8601String(),
    'notes': l.notes,
  };

  Campaign _campaignFromRow(dynamic row) {
    final m = row as Map<String, dynamic>;
    return Campaign(
      id: m['id'] as String,
      title: m['title'] as String,
      type: CampaignType.values.firstWhere((e) => e.name == m['type']),
      status: CampaignStatus.values.firstWhere((e) => e.name == m['status']),
      startDate: DateTime.parse(m['start_date'] as String),
      endDate: DateTime.parse(m['end_date'] as String),
      budget: (m['budget'] as num).toDouble(),
      leadsGenerated: m['leads_generated'] as int,
      conversions: m['conversions'] as int,
      targetService: m['target_service'] as String,
    );
  }

  Map<String, dynamic> _campaignToRow(Campaign c) => {
    'id': c.id,
    'title': c.title,
    'type': c.type.name,
    'status': c.status.name,
    'start_date': c.startDate.toIso8601String(),
    'end_date': c.endDate.toIso8601String(),
    'budget': c.budget,
    'leads_generated': c.leadsGenerated,
    'conversions': c.conversions,
    'target_service': c.targetService,
  };
}
