import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/features/regulatory_trust/domain/models/security_control.dart';
import 'package:ca_app/features/regulatory_trust/domain/models/vapt_scan.dart';
import 'package:ca_app/features/regulatory_trust/domain/repositories/regulatory_trust_repository.dart';

/// Real implementation of [RegulatoryTrustRepository] backed by Supabase.
class RegulatoryTrustRepositoryImpl implements RegulatoryTrustRepository {
  const RegulatoryTrustRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const _controlsTable = 'security_controls';
  static const _scansTable = 'vapt_scans';

  // ---------------------------------------------------------------------------
  // SecurityControl
  // ---------------------------------------------------------------------------

  @override
  Future<List<SecurityControl>> getSecurityControls() async {
    final response = await _client.from(_controlsTable).select();
    return List<Map<String, dynamic>>.from(
      response,
    ).map(_controlFromJson).toList();
  }

  @override
  Future<SecurityControl?> getSecurityControlById(String id) async {
    final response = await _client
        .from(_controlsTable)
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return _controlFromJson(response);
  }

  @override
  Future<List<SecurityControl>> getSecurityControlsByCategory(
    SecurityControlCategory category,
  ) async {
    final response = await _client
        .from(_controlsTable)
        .select()
        .eq('category', category.name);
    return List<Map<String, dynamic>>.from(
      response,
    ).map(_controlFromJson).toList();
  }

  @override
  Future<List<SecurityControl>> getSecurityControlsByStatus(
    SecurityControlStatus status,
  ) async {
    final response = await _client
        .from(_controlsTable)
        .select()
        .eq('status', status.name);
    return List<Map<String, dynamic>>.from(
      response,
    ).map(_controlFromJson).toList();
  }

  @override
  Future<String> insertSecurityControl(SecurityControl control) async {
    final response = await _client
        .from(_controlsTable)
        .insert(_controlToJson(control))
        .select()
        .single();
    return response['id'] as String;
  }

  @override
  Future<bool> updateSecurityControl(SecurityControl control) async {
    await _client
        .from(_controlsTable)
        .update(_controlToJson(control))
        .eq('id', control.id);
    return true;
  }

  @override
  Future<bool> deleteSecurityControl(String id) async {
    await _client.from(_controlsTable).delete().eq('id', id);
    return true;
  }

  // ---------------------------------------------------------------------------
  // VaptScan
  // ---------------------------------------------------------------------------

  @override
  Future<List<VaptScan>> getVaptScans() async {
    final response = await _client
        .from(_scansTable)
        .select()
        .order('scan_date', ascending: false);
    return List<Map<String, dynamic>>.from(
      response,
    ).map(_scanFromJson).toList();
  }

  @override
  Future<VaptScan?> getVaptScanById(String id) async {
    final response = await _client
        .from(_scansTable)
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return _scanFromJson(response);
  }

  @override
  Future<List<VaptScan>> getVaptScansByStatus(VaptScanStatus status) async {
    final response = await _client
        .from(_scansTable)
        .select()
        .eq('status', status.name);
    return List<Map<String, dynamic>>.from(
      response,
    ).map(_scanFromJson).toList();
  }

  @override
  Future<String> insertVaptScan(VaptScan scan) async {
    final response = await _client
        .from(_scansTable)
        .insert(_scanToJson(scan))
        .select()
        .single();
    return response['id'] as String;
  }

  @override
  Future<bool> updateVaptScan(VaptScan scan) async {
    await _client.from(_scansTable).update(_scanToJson(scan)).eq('id', scan.id);
    return true;
  }

  @override
  Future<bool> deleteVaptScan(String id) async {
    await _client.from(_scansTable).delete().eq('id', id);
    return true;
  }

  // ---------------------------------------------------------------------------
  // Mappers
  // ---------------------------------------------------------------------------

  SecurityControl _controlFromJson(Map<String, dynamic> j) => SecurityControl(
    id: j['id'] as String,
    title: j['title'] as String,
    category: SecurityControlCategory.values.firstWhere(
      (c) => c.name == j['category'] as String,
    ),
    status: SecurityControlStatus.values.firstWhere(
      (s) => s.name == j['status'] as String,
    ),
    severity: ControlSeverity.values.firstWhere(
      (s) => s.name == j['severity'] as String,
    ),
    lastAssessmentDate: DateTime.parse(j['last_assessment_date'] as String),
    nextDueDate: DateTime.parse(j['next_due_date'] as String),
    owner: j['owner'] as String?,
    notes: j['notes'] as String?,
  );

  Map<String, dynamic> _controlToJson(SecurityControl c) => {
    'id': c.id,
    'title': c.title,
    'category': c.category.name,
    'status': c.status.name,
    'severity': c.severity.name,
    'last_assessment_date': c.lastAssessmentDate.toIso8601String(),
    'next_due_date': c.nextDueDate.toIso8601String(),
    'owner': c.owner,
    'notes': c.notes,
  };

  VaptScan _scanFromJson(Map<String, dynamic> j) => VaptScan(
    id: j['id'] as String,
    title: j['title'] as String,
    scanDate: DateTime.parse(j['scan_date'] as String),
    status: VaptScanStatus.values.firstWhere(
      (s) => s.name == j['status'] as String,
    ),
    criticalFindings: j['critical_findings'] as int,
    highFindings: j['high_findings'] as int,
    mediumFindings: j['medium_findings'] as int,
    lowFindings: j['low_findings'] as int,
    remediationDeadline: j['remediation_deadline'] != null
        ? DateTime.parse(j['remediation_deadline'] as String)
        : null,
    vendor: j['vendor'] as String?,
    scope: j['scope'] as String?,
  );

  Map<String, dynamic> _scanToJson(VaptScan s) => {
    'id': s.id,
    'title': s.title,
    'scan_date': s.scanDate.toIso8601String(),
    'status': s.status.name,
    'critical_findings': s.criticalFindings,
    'high_findings': s.highFindings,
    'medium_findings': s.mediumFindings,
    'low_findings': s.lowFindings,
    'remediation_deadline': s.remediationDeadline?.toIso8601String(),
    'vendor': s.vendor,
    'scope': s.scope,
  };
}
