import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/features/sme_cfo/domain/models/cfo_deliverable.dart';
import 'package:ca_app/features/sme_cfo/domain/models/cfo_retainer.dart';
import 'package:ca_app/features/sme_cfo/domain/repositories/sme_cfo_repository.dart';

/// Real implementation of [SmeCfoRepository] backed by Supabase.
class SmeCfoRepositoryImpl implements SmeCfoRepository {
  const SmeCfoRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const _deliverablesTable = 'cfo_deliverables';
  static const _retainersTable = 'cfo_retainers';

  // ---------------------------------------------------------------------------
  // CfoDeliverable
  // ---------------------------------------------------------------------------

  @override
  Future<List<CfoDeliverable>> getDeliverables() async {
    final response =
        await _client.from(_deliverablesTable).select().order('due_date');
    return List<Map<String, dynamic>>.from(response)
        .map(_deliverableFromJson)
        .toList();
  }

  @override
  Future<CfoDeliverable?> getDeliverableById(String id) async {
    final response = await _client
        .from(_deliverablesTable)
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return _deliverableFromJson(response);
  }

  @override
  Future<List<CfoDeliverable>> getDeliverablesByRetainer(
    String retainerId,
  ) async {
    final response = await _client
        .from(_deliverablesTable)
        .select()
        .eq('retainer_id', retainerId)
        .order('due_date');
    return List<Map<String, dynamic>>.from(response)
        .map(_deliverableFromJson)
        .toList();
  }

  @override
  Future<List<CfoDeliverable>> getDeliverablesByStatus(
    DeliverableStatus status,
  ) async {
    final response = await _client
        .from(_deliverablesTable)
        .select()
        .eq('status', status.name);
    return List<Map<String, dynamic>>.from(response)
        .map(_deliverableFromJson)
        .toList();
  }

  @override
  Future<String> insertDeliverable(CfoDeliverable deliverable) async {
    final response = await _client
        .from(_deliverablesTable)
        .insert(_deliverableToJson(deliverable))
        .select()
        .single();
    return response['id'] as String;
  }

  @override
  Future<bool> updateDeliverable(CfoDeliverable deliverable) async {
    await _client
        .from(_deliverablesTable)
        .update(_deliverableToJson(deliverable))
        .eq('id', deliverable.id);
    return true;
  }

  @override
  Future<bool> deleteDeliverable(String id) async {
    await _client.from(_deliverablesTable).delete().eq('id', id);
    return true;
  }

  // ---------------------------------------------------------------------------
  // CfoRetainer
  // ---------------------------------------------------------------------------

  @override
  Future<List<CfoRetainer>> getRetainers() async {
    final response = await _client.from(_retainersTable).select();
    return List<Map<String, dynamic>>.from(response)
        .map(_retainerFromJson)
        .toList();
  }

  @override
  Future<CfoRetainer?> getRetainerById(String id) async {
    final response = await _client
        .from(_retainersTable)
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return _retainerFromJson(response);
  }

  @override
  Future<List<CfoRetainer>> getRetainersByStatus(
    CfoRetainerStatus status,
  ) async {
    final response = await _client
        .from(_retainersTable)
        .select()
        .eq('status', status.name);
    return List<Map<String, dynamic>>.from(response)
        .map(_retainerFromJson)
        .toList();
  }

  @override
  Future<String> insertRetainer(CfoRetainer retainer) async {
    final response = await _client
        .from(_retainersTable)
        .insert(_retainerToJson(retainer))
        .select()
        .single();
    return response['id'] as String;
  }

  @override
  Future<bool> updateRetainer(CfoRetainer retainer) async {
    await _client
        .from(_retainersTable)
        .update(_retainerToJson(retainer))
        .eq('id', retainer.id);
    return true;
  }

  @override
  Future<bool> deleteRetainer(String id) async {
    await _client.from(_retainersTable).delete().eq('id', id);
    return true;
  }

  // ---------------------------------------------------------------------------
  // Mappers
  // ---------------------------------------------------------------------------

  CfoDeliverable _deliverableFromJson(Map<String, dynamic> j) =>
      CfoDeliverable(
        id: j['id'] as String,
        retainerId: j['retainer_id'] as String,
        clientName: j['client_name'] as String,
        title: j['title'] as String,
        deliverableType: DeliverableType.values
            .firstWhere((t) => t.name == j['deliverable_type'] as String),
        dueDate: DateTime.parse(j['due_date'] as String),
        status: DeliverableStatus.values
            .firstWhere((s) => s.name == j['status'] as String),
        completedAt: j['completed_at'] != null
            ? DateTime.parse(j['completed_at'] as String)
            : null,
      );

  Map<String, dynamic> _deliverableToJson(CfoDeliverable d) => {
        'id': d.id,
        'retainer_id': d.retainerId,
        'client_name': d.clientName,
        'title': d.title,
        'deliverable_type': d.deliverableType.name,
        'due_date': d.dueDate.toIso8601String(),
        'status': d.status.name,
        'completed_at': d.completedAt?.toIso8601String(),
      };

  CfoRetainer _retainerFromJson(Map<String, dynamic> j) => CfoRetainer(
        id: j['id'] as String,
        clientId: j['client_id'] as String,
        clientName: j['client_name'] as String,
        industry: j['industry'] as String,
        monthlyFee: (j['monthly_fee'] as num).toDouble(),
        startDate: DateTime.parse(j['start_date'] as String),
        nextReviewDate: DateTime.parse(j['next_review_date'] as String),
        deliverables: List<String>.from(j['deliverables'] as List),
        status: CfoRetainerStatus.values
            .firstWhere((s) => s.name == j['status'] as String),
        assignedPartner: j['assigned_partner'] as String,
        healthScore: j['health_score'] as int,
      );

  Map<String, dynamic> _retainerToJson(CfoRetainer r) => {
        'id': r.id,
        'client_id': r.clientId,
        'client_name': r.clientName,
        'industry': r.industry,
        'monthly_fee': r.monthlyFee,
        'start_date': r.startDate.toIso8601String(),
        'next_review_date': r.nextReviewDate.toIso8601String(),
        'deliverables': r.deliverables,
        'status': r.status.name,
        'assigned_partner': r.assignedPartner,
        'health_score': r.healthScore,
      };
}
