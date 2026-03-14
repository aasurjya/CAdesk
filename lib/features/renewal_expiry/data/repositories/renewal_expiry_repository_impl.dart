import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/features/renewal_expiry/domain/models/renewal_item.dart';
import 'package:ca_app/features/renewal_expiry/domain/models/retainer_contract.dart';
import 'package:ca_app/features/renewal_expiry/domain/repositories/renewal_expiry_repository.dart';

/// Real implementation of [RenewalExpiryRepository] backed by Supabase.
class RenewalExpiryRepositoryImpl implements RenewalExpiryRepository {
  const RenewalExpiryRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const _renewalTable = 'renewal_items';
  static const _contractTable = 'retainer_contracts';

  // ---------------------------------------------------------------------------
  // RenewalItem
  // ---------------------------------------------------------------------------

  @override
  Future<List<RenewalItem>> getRenewalItems() async {
    final response =
        await _client.from(_renewalTable).select().order('due_date');
    return List<Map<String, dynamic>>.from(response)
        .map(_renewalFromJson)
        .toList();
  }

  @override
  Future<RenewalItem?> getRenewalItemById(String id) async {
    final response = await _client
        .from(_renewalTable)
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return _renewalFromJson(response);
  }

  @override
  Future<List<RenewalItem>> getRenewalItemsByClient(String clientId) async {
    final response = await _client
        .from(_renewalTable)
        .select()
        .eq('client_id', clientId)
        .order('due_date');
    return List<Map<String, dynamic>>.from(response)
        .map(_renewalFromJson)
        .toList();
  }

  @override
  Future<List<RenewalItem>> getRenewalItemsByStatus(
    RenewalStatus status,
  ) async {
    final response = await _client
        .from(_renewalTable)
        .select()
        .eq('status', status.name);
    return List<Map<String, dynamic>>.from(response)
        .map(_renewalFromJson)
        .toList();
  }

  @override
  Future<String> insertRenewalItem(RenewalItem item) async {
    final response = await _client
        .from(_renewalTable)
        .insert(_renewalToJson(item))
        .select()
        .single();
    return response['id'] as String;
  }

  @override
  Future<bool> updateRenewalItem(RenewalItem item) async {
    await _client
        .from(_renewalTable)
        .update(_renewalToJson(item))
        .eq('id', item.id);
    return true;
  }

  @override
  Future<bool> deleteRenewalItem(String id) async {
    await _client.from(_renewalTable).delete().eq('id', id);
    return true;
  }

  // ---------------------------------------------------------------------------
  // RetainerContract
  // ---------------------------------------------------------------------------

  @override
  Future<List<RetainerContract>> getRetainerContracts() async {
    final response = await _client
        .from(_contractTable)
        .select()
        .order('end_date');
    return List<Map<String, dynamic>>.from(response)
        .map(_contractFromJson)
        .toList();
  }

  @override
  Future<RetainerContract?> getRetainerContractById(String id) async {
    final response = await _client
        .from(_contractTable)
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return _contractFromJson(response);
  }

  @override
  Future<List<RetainerContract>> getRetainerContractsByClient(
    String clientId,
  ) async {
    final response = await _client
        .from(_contractTable)
        .select()
        .eq('client_id', clientId);
    return List<Map<String, dynamic>>.from(response)
        .map(_contractFromJson)
        .toList();
  }

  @override
  Future<String> insertRetainerContract(RetainerContract contract) async {
    final response = await _client
        .from(_contractTable)
        .insert(_contractToJson(contract))
        .select()
        .single();
    return response['id'] as String;
  }

  @override
  Future<bool> updateRetainerContract(RetainerContract contract) async {
    await _client
        .from(_contractTable)
        .update(_contractToJson(contract))
        .eq('id', contract.id);
    return true;
  }

  @override
  Future<bool> deleteRetainerContract(String id) async {
    await _client.from(_contractTable).delete().eq('id', id);
    return true;
  }

  // ---------------------------------------------------------------------------
  // Mappers
  // ---------------------------------------------------------------------------

  RenewalItem _renewalFromJson(Map<String, dynamic> j) => RenewalItem(
        id: j['id'] as String,
        clientId: j['client_id'] as String,
        clientName: j['client_name'] as String,
        itemType: RenewalItemType.values
            .firstWhere((t) => t.name == j['item_type'] as String),
        dueDate: DateTime.parse(j['due_date'] as String),
        renewedDate: j['renewed_date'] != null
            ? DateTime.parse(j['renewed_date'] as String)
            : null,
        status: RenewalStatus.values
            .firstWhere((s) => s.name == j['status'] as String),
        fee: (j['fee'] as num).toDouble(),
        reminderSentAt: j['reminder_sent_at'] != null
            ? DateTime.parse(j['reminder_sent_at'] as String)
            : null,
        notes: j['notes'] as String? ?? '',
      );

  Map<String, dynamic> _renewalToJson(RenewalItem i) => {
        'id': i.id,
        'client_id': i.clientId,
        'client_name': i.clientName,
        'item_type': i.itemType.name,
        'due_date': i.dueDate.toIso8601String(),
        'renewed_date': i.renewedDate?.toIso8601String(),
        'status': i.status.name,
        'fee': i.fee,
        'reminder_sent_at': i.reminderSentAt?.toIso8601String(),
        'notes': i.notes,
      };

  RetainerContract _contractFromJson(Map<String, dynamic> j) =>
      RetainerContract(
        id: j['id'] as String,
        clientId: j['client_id'] as String,
        clientName: j['client_name'] as String,
        serviceScope: j['service_scope'] as String,
        monthlyFee: (j['monthly_fee'] as num).toDouble(),
        startDate: DateTime.parse(j['start_date'] as String),
        endDate: DateTime.parse(j['end_date'] as String),
        autoRenew: j['auto_renew'] as bool,
        status: RetainerStatus.values
            .firstWhere((s) => s.name == j['status'] as String),
      );

  Map<String, dynamic> _contractToJson(RetainerContract c) => {
        'id': c.id,
        'client_id': c.clientId,
        'client_name': c.clientName,
        'service_scope': c.serviceScope,
        'monthly_fee': c.monthlyFee,
        'start_date': c.startDate.toIso8601String(),
        'end_date': c.endDate.toIso8601String(),
        'auto_renew': c.autoRenew,
        'status': c.status.name,
      };
}
