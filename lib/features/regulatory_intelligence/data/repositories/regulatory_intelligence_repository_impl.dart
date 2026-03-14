import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/features/regulatory_intelligence/domain/models/client_impact_alert.dart';
import 'package:ca_app/features/regulatory_intelligence/domain/models/compliance_alert.dart';
import 'package:ca_app/features/regulatory_intelligence/domain/models/regulatory_circular.dart';
import 'package:ca_app/features/regulatory_intelligence/domain/models/regulatory_update.dart';
import 'package:ca_app/features/regulatory_intelligence/domain/repositories/regulatory_intelligence_repository.dart';

/// Real implementation of [RegulatoryIntelligenceRepository] backed by Supabase.
class RegulatoryIntelligenceRepositoryImpl
    implements RegulatoryIntelligenceRepository {
  const RegulatoryIntelligenceRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const _updatesTable = 'regulatory_updates';
  static const _alertsTable = 'compliance_alerts';
  static const _circularsTable = 'regulatory_circulars';
  static const _impactTable = 'client_impact_alerts';

  // ---------------------------------------------------------------------------
  // RegulatoryUpdate
  // ---------------------------------------------------------------------------

  @override
  Future<List<RegulatoryUpdate>> getUpdates() async {
    final response = await _client
        .from(_updatesTable)
        .select()
        .order('publication_date', ascending: false);
    return List<Map<String, dynamic>>.from(
      response,
    ).map(_updateFromJson).toList();
  }

  @override
  Future<RegulatoryUpdate?> getUpdateById(String id) async {
    final response = await _client
        .from(_updatesTable)
        .select()
        .eq('update_id', id)
        .maybeSingle();
    if (response == null) return null;
    return _updateFromJson(response);
  }

  @override
  Future<List<RegulatoryUpdate>> getUpdatesBySource(RegSource source) async {
    final response = await _client
        .from(_updatesTable)
        .select()
        .eq('source', source.name);
    return List<Map<String, dynamic>>.from(
      response,
    ).map(_updateFromJson).toList();
  }

  @override
  Future<List<RegulatoryUpdate>> getUpdatesByImpactLevel(
    ImpactLevel impactLevel,
  ) async {
    final response = await _client
        .from(_updatesTable)
        .select()
        .eq('impact_level', impactLevel.name);
    return List<Map<String, dynamic>>.from(
      response,
    ).map(_updateFromJson).toList();
  }

  @override
  Future<String> insertUpdate(RegulatoryUpdate update) async {
    final response = await _client
        .from(_updatesTable)
        .insert(_updateToJson(update))
        .select()
        .single();
    return response['update_id'] as String;
  }

  @override
  Future<bool> markUpdateAsRead(String id) async {
    await _client
        .from(_updatesTable)
        .update({'is_read': true})
        .eq('update_id', id);
    return true;
  }

  @override
  Future<bool> deleteUpdate(String id) async {
    await _client.from(_updatesTable).delete().eq('update_id', id);
    return true;
  }

  // ---------------------------------------------------------------------------
  // ComplianceAlert
  // ---------------------------------------------------------------------------

  @override
  Future<List<ComplianceAlert>> getAlerts() async {
    final response = await _client.from(_alertsTable).select();
    return List<Map<String, dynamic>>.from(
      response,
    ).map(_alertFromJson).toList();
  }

  @override
  Future<ComplianceAlert?> getAlertById(String id) async {
    final response = await _client
        .from(_alertsTable)
        .select()
        .eq('alert_id', id)
        .maybeSingle();
    if (response == null) return null;
    return _alertFromJson(response);
  }

  @override
  Future<List<ComplianceAlert>> getAlertsByPriority(
    AlertPriority priority,
  ) async {
    final response = await _client
        .from(_alertsTable)
        .select()
        .eq('priority', priority.name);
    return List<Map<String, dynamic>>.from(
      response,
    ).map(_alertFromJson).toList();
  }

  @override
  Future<String> insertAlert(ComplianceAlert alert) async {
    final response = await _client
        .from(_alertsTable)
        .insert(_alertToJson(alert))
        .select()
        .single();
    return response['alert_id'] as String;
  }

  @override
  Future<bool> deleteAlert(String id) async {
    await _client.from(_alertsTable).delete().eq('alert_id', id);
    return true;
  }

  // ---------------------------------------------------------------------------
  // RegulatoryCircular
  // ---------------------------------------------------------------------------

  @override
  Future<List<RegulatoryCircular>> getCirculars() async {
    final response = await _client
        .from(_circularsTable)
        .select()
        .order('issue_date', ascending: false);
    return List<Map<String, dynamic>>.from(
      response,
    ).map(_circularFromJson).toList();
  }

  @override
  Future<RegulatoryCircular?> getCircularById(String id) async {
    final response = await _client
        .from(_circularsTable)
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return _circularFromJson(response);
  }

  @override
  Future<String> insertCircular(RegulatoryCircular circular) async {
    final response = await _client
        .from(_circularsTable)
        .insert(_circularToJson(circular))
        .select()
        .single();
    return response['id'] as String;
  }

  @override
  Future<bool> deleteCircular(String id) async {
    await _client.from(_circularsTable).delete().eq('id', id);
    return true;
  }

  // ---------------------------------------------------------------------------
  // ClientImpactAlert
  // ---------------------------------------------------------------------------

  @override
  Future<List<ClientImpactAlert>> getClientImpactAlerts() async {
    final response = await _client.from(_impactTable).select();
    return List<Map<String, dynamic>>.from(
      response,
    ).map(_impactFromJson).toList();
  }

  @override
  Future<List<ClientImpactAlert>> getClientImpactAlertsByCircular(
    String circularId,
  ) async {
    final response = await _client
        .from(_impactTable)
        .select()
        .eq('circular_id', circularId);
    return List<Map<String, dynamic>>.from(
      response,
    ).map(_impactFromJson).toList();
  }

  @override
  Future<String> insertClientImpactAlert(ClientImpactAlert alert) async {
    final response = await _client
        .from(_impactTable)
        .insert(_impactToJson(alert))
        .select()
        .single();
    return response['id'] as String;
  }

  @override
  Future<bool> updateClientImpactAlertStatus(String id, String status) async {
    await _client.from(_impactTable).update({'status': status}).eq('id', id);
    return true;
  }

  // ---------------------------------------------------------------------------
  // Mappers
  // ---------------------------------------------------------------------------

  RegulatoryUpdate _updateFromJson(Map<String, dynamic> j) => RegulatoryUpdate(
    updateId: j['update_id'] as String,
    title: j['title'] as String,
    summary: j['summary'] as String,
    source: RegSource.values.firstWhere((s) => s.name == j['source'] as String),
    category: UpdateCategory.values.firstWhere(
      (c) => c.name == j['category'] as String,
    ),
    publicationDate: DateTime.parse(j['publication_date'] as String),
    effectiveDate: j['effective_date'] != null
        ? DateTime.parse(j['effective_date'] as String)
        : null,
    impactLevel: ImpactLevel.values.firstWhere(
      (i) => i.name == j['impact_level'] as String,
    ),
    affectedSections: List<String>.from(j['affected_sections'] as List),
    url: j['url'] as String?,
    isRead: j['is_read'] as bool,
  );

  Map<String, dynamic> _updateToJson(RegulatoryUpdate u) => {
    'update_id': u.updateId,
    'title': u.title,
    'summary': u.summary,
    'source': u.source.name,
    'category': u.category.name,
    'publication_date': u.publicationDate.toIso8601String(),
    'effective_date': u.effectiveDate?.toIso8601String(),
    'impact_level': u.impactLevel.name,
    'affected_sections': u.affectedSections,
    'url': u.url,
    'is_read': u.isRead,
  };

  ComplianceAlert _alertFromJson(Map<String, dynamic> j) => ComplianceAlert(
    alertId: j['alert_id'] as String,
    title: j['title'] as String,
    description: j['description'] as String,
    alertType: AlertType.values.firstWhere(
      (t) => t.name == j['alert_type'] as String,
    ),
    dueDate: j['due_date'] != null
        ? DateTime.parse(j['due_date'] as String)
        : null,
    daysRemaining: j['days_remaining'] as int?,
    applicableTo: List<String>.from(j['applicable_to'] as List),
    penaltyIfMissed: j['penalty_if_missed'] as String?,
    priority: AlertPriority.values.firstWhere(
      (p) => p.name == j['priority'] as String,
    ),
  );

  Map<String, dynamic> _alertToJson(ComplianceAlert a) => {
    'alert_id': a.alertId,
    'title': a.title,
    'description': a.description,
    'alert_type': a.alertType.name,
    'due_date': a.dueDate?.toIso8601String(),
    'days_remaining': a.daysRemaining,
    'applicable_to': a.applicableTo,
    'penalty_if_missed': a.penaltyIfMissed,
    'priority': a.priority.name,
  };

  RegulatoryCircular _circularFromJson(Map<String, dynamic> j) =>
      RegulatoryCircular(
        id: j['id'] as String,
        circularNumber: j['circular_number'] as String,
        issuingBody: j['issuing_body'] as String,
        title: j['title'] as String,
        summary: j['summary'] as String,
        issueDate: j['issue_date'] as String,
        effectiveDate: j['effective_date'] as String,
        category: j['category'] as String,
        impactLevel: j['impact_level'] as String,
        affectedClientsCount: j['affected_clients_count'] as int,
        keyChanges: List<String>.from(j['key_changes'] as List),
      );

  Map<String, dynamic> _circularToJson(RegulatoryCircular c) => {
    'id': c.id,
    'circular_number': c.circularNumber,
    'issuing_body': c.issuingBody,
    'title': c.title,
    'summary': c.summary,
    'issue_date': c.issueDate,
    'effective_date': c.effectiveDate,
    'category': c.category,
    'impact_level': c.impactLevel,
    'affected_clients_count': c.affectedClientsCount,
    'key_changes': c.keyChanges,
  };

  ClientImpactAlert _impactFromJson(Map<String, dynamic> j) =>
      ClientImpactAlert(
        id: j['id'] as String,
        circularId: j['circular_id'] as String,
        clientName: j['client_name'] as String,
        clientPan: j['client_pan'] as String,
        impactDescription: j['impact_description'] as String,
        actionRequired: j['action_required'] as String,
        dueDate: j['due_date'] as String,
        status: j['status'] as String,
        urgency: j['urgency'] as String,
      );

  Map<String, dynamic> _impactToJson(ClientImpactAlert a) => {
    'id': a.id,
    'circular_id': a.circularId,
    'client_name': a.clientName,
    'client_pan': a.clientPan,
    'impact_description': a.impactDescription,
    'action_required': a.actionRequired,
    'due_date': a.dueDate,
    'status': a.status,
    'urgency': a.urgency,
  };
}
