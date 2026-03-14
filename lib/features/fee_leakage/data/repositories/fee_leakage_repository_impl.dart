import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/features/fee_leakage/domain/models/engagement.dart';
import 'package:ca_app/features/fee_leakage/domain/models/scope_item.dart';
import 'package:ca_app/features/fee_leakage/domain/repositories/fee_leakage_repository.dart';

/// Real implementation of [FeeLeakageRepository] backed by Supabase.
///
/// Falls back to empty results on network errors to keep the UI responsive.
class FeeLeakageRepositoryImpl implements FeeLeakageRepository {
  const FeeLeakageRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const _engagementsTable = 'engagements';
  static const _scopeItemsTable = 'scope_items';

  // -------------------------------------------------------------------------
  // Engagement
  // -------------------------------------------------------------------------

  @override
  Future<List<Engagement>> getEngagements() async {
    try {
      final rows = await _client.from(_engagementsTable).select();
      return List.unmodifiable((rows as List).map(_engagementFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<Engagement>> getEngagementsByClient(String clientId) async {
    try {
      final rows = await _client
          .from(_engagementsTable)
          .select()
          .eq('client_id', clientId);
      return List.unmodifiable((rows as List).map(_engagementFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<Engagement>> getEngagementsByStatus(
    EngagementStatus status,
  ) async {
    try {
      final rows = await _client
          .from(_engagementsTable)
          .select()
          .eq('status', status.name);
      return List.unmodifiable((rows as List).map(_engagementFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<String> insertEngagement(Engagement engagement) async {
    final row = await _client
        .from(_engagementsTable)
        .insert(_engagementToRow(engagement))
        .select()
        .single();
    return row['id'] as String;
  }

  @override
  Future<bool> updateEngagement(Engagement engagement) async {
    try {
      await _client
          .from(_engagementsTable)
          .update(_engagementToRow(engagement))
          .eq('id', engagement.id);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteEngagement(String id) async {
    try {
      await _client.from(_engagementsTable).delete().eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // ScopeItem
  // -------------------------------------------------------------------------

  @override
  Future<List<ScopeItem>> getScopeItems() async {
    try {
      final rows = await _client.from(_scopeItemsTable).select();
      return List.unmodifiable((rows as List).map(_scopeItemFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<ScopeItem>> getScopeItemsByEngagement(String engagementId) async {
    try {
      final rows = await _client
          .from(_scopeItemsTable)
          .select()
          .eq('engagement_id', engagementId);
      return List.unmodifiable((rows as List).map(_scopeItemFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<String> insertScopeItem(ScopeItem item) async {
    final row = await _client
        .from(_scopeItemsTable)
        .insert(_scopeItemToRow(item))
        .select()
        .single();
    return row['id'] as String;
  }

  @override
  Future<bool> updateScopeItem(ScopeItem item) async {
    try {
      await _client
          .from(_scopeItemsTable)
          .update(_scopeItemToRow(item))
          .eq('id', item.id);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteScopeItem(String id) async {
    try {
      await _client.from(_scopeItemsTable).delete().eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // Mappers
  // -------------------------------------------------------------------------

  Engagement _engagementFromRow(dynamic row) {
    final m = row as Map<String, dynamic>;
    return Engagement(
      id: m['id'] as String,
      clientId: m['client_id'] as String,
      clientName: m['client_name'] as String,
      serviceType: m['service_type'] as String,
      agreedFee: (m['agreed_fee'] as num).toDouble(),
      billedAmount: (m['billed_amount'] as num).toDouble(),
      actualHours: (m['actual_hours'] as num).toDouble(),
      budgetHours: (m['budget_hours'] as num).toDouble(),
      status: EngagementStatus.values.firstWhere((e) => e.name == m['status']),
    );
  }

  Map<String, dynamic> _engagementToRow(Engagement e) => {
    'id': e.id,
    'client_id': e.clientId,
    'client_name': e.clientName,
    'service_type': e.serviceType,
    'agreed_fee': e.agreedFee,
    'billed_amount': e.billedAmount,
    'actual_hours': e.actualHours,
    'budget_hours': e.budgetHours,
    'status': e.status.name,
  };

  ScopeItem _scopeItemFromRow(dynamic row) {
    final m = row as Map<String, dynamic>;
    return ScopeItem(
      id: m['id'] as String,
      engagementId: m['engagement_id'] as String,
      description: m['description'] as String,
      isInScope: m['is_in_scope'] as bool,
      addedAt: DateTime.parse(m['added_at'] as String),
      billedExtra: m['billed_extra'] as bool,
    );
  }

  Map<String, dynamic> _scopeItemToRow(ScopeItem s) => {
    'id': s.id,
    'engagement_id': s.engagementId,
    'description': s.description,
    'is_in_scope': s.isInScope,
    'added_at': s.addedAt.toIso8601String(),
    'billed_extra': s.billedExtra,
  };
}
