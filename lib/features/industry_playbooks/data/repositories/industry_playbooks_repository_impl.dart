import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/features/industry_playbooks/domain/models/vertical_playbook.dart';
import 'package:ca_app/features/industry_playbooks/domain/models/service_bundle.dart';
import 'package:ca_app/features/industry_playbooks/domain/repositories/industry_playbooks_repository.dart';

/// Real implementation of [IndustryPlaybooksRepository] backed by Supabase.
///
/// Falls back to empty results on network errors to keep the UI responsive.
class IndustryPlaybooksRepositoryImpl implements IndustryPlaybooksRepository {
  const IndustryPlaybooksRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const _playbooksTable = 'vertical_playbooks';
  static const _bundlesTable = 'service_bundles';

  // -------------------------------------------------------------------------
  // VerticalPlaybook
  // -------------------------------------------------------------------------

  @override
  Future<List<VerticalPlaybook>> getPlaybooks() async {
    try {
      final rows = await _client.from(_playbooksTable).select();
      return List.unmodifiable((rows as List).map(_playbookFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<VerticalPlaybook?> getPlaybookById(String id) async {
    try {
      final row = await _client
          .from(_playbooksTable)
          .select()
          .eq('id', id)
          .single();
      return _playbookFromRow(row);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<VerticalPlaybook>> searchPlaybooks(String query) async {
    try {
      final rows = await _client
          .from(_playbooksTable)
          .select()
          .ilike('vertical', '%$query%');
      return List.unmodifiable((rows as List).map(_playbookFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<String> insertPlaybook(VerticalPlaybook playbook) async {
    final row = await _client
        .from(_playbooksTable)
        .insert(_playbookToRow(playbook))
        .select()
        .single();
    return row['id'] as String;
  }

  @override
  Future<bool> updatePlaybook(VerticalPlaybook playbook) async {
    try {
      await _client
          .from(_playbooksTable)
          .update(_playbookToRow(playbook))
          .eq('id', playbook.id);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deletePlaybook(String id) async {
    try {
      await _client.from(_playbooksTable).delete().eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // ServiceBundle
  // -------------------------------------------------------------------------

  @override
  Future<List<ServiceBundle>> getBundlesByVertical(String verticalId) async {
    try {
      final rows = await _client
          .from(_bundlesTable)
          .select()
          .eq('vertical_id', verticalId);
      return List.unmodifiable((rows as List).map(_bundleFromRow).toList());
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<String> insertBundle(ServiceBundle bundle) async {
    final row = await _client
        .from(_bundlesTable)
        .insert(_bundleToRow(bundle))
        .select()
        .single();
    return row['id'] as String;
  }

  @override
  Future<bool> updateBundle(ServiceBundle bundle) async {
    try {
      await _client
          .from(_bundlesTable)
          .update(_bundleToRow(bundle))
          .eq('id', bundle.id);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteBundle(String id) async {
    try {
      await _client.from(_bundlesTable).delete().eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // Mappers
  // -------------------------------------------------------------------------

  VerticalPlaybook _playbookFromRow(dynamic row) {
    final m = row as Map<String, dynamic>;
    return VerticalPlaybook(
      id: m['id'] as String,
      vertical: m['vertical'] as String,
      icon: m['icon'] as String,
      description: m['description'] as String,
      complianceChecklist: List<String>.from(m['compliance_checklist'] as List),
      typicalRisks: List<String>.from(m['typical_risks'] as List),
      activeClients: m['active_clients'] as int,
      avgRetainerValue: (m['avg_retainer_value'] as num).toDouble(),
      winRate: (m['win_rate'] as num).toDouble(),
      marginPercent: (m['margin_percent'] as num).toDouble(),
    );
  }

  Map<String, dynamic> _playbookToRow(VerticalPlaybook p) => {
    'id': p.id,
    'vertical': p.vertical,
    'icon': p.icon,
    'description': p.description,
    'compliance_checklist': p.complianceChecklist,
    'typical_risks': p.typicalRisks,
    'active_clients': p.activeClients,
    'avg_retainer_value': p.avgRetainerValue,
    'win_rate': p.winRate,
    'margin_percent': p.marginPercent,
  };

  ServiceBundle _bundleFromRow(dynamic row) {
    final m = row as Map<String, dynamic>;
    return ServiceBundle(
      id: m['id'] as String,
      verticalId: m['vertical_id'] as String,
      name: m['name'] as String,
      description: m['description'] as String,
      inclusions: List<String>.from(m['inclusions'] as List),
      pricePerMonth: (m['price_per_month'] as num).toDouble(),
      turnaroundDays: m['turnaround_days'] as int,
      slaLabel: m['sla_label'] as String,
      isPopular: m['is_popular'] as bool,
    );
  }

  Map<String, dynamic> _bundleToRow(ServiceBundle b) => {
    'id': b.id,
    'vertical_id': b.verticalId,
    'name': b.name,
    'description': b.description,
    'inclusions': b.inclusions,
    'price_per_month': b.pricePerMonth,
    'turnaround_days': b.turnaroundDays,
    'sla_label': b.slaLabel,
    'is_popular': b.isPopular,
  };
}
