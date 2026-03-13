import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for audit data (Supabase REST API).
class AuditRemoteSource {
  const AuditRemoteSource(this._client);

  final SupabaseClient _client;

  // ---------------------------------------------------------------------------
  // Audit Assignments
  // ---------------------------------------------------------------------------

  /// Insert a new audit assignment and return the server-side row.
  Future<Map<String, dynamic>> insertAuditAssignment(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from('audit_assignments')
        .insert(data)
        .select()
        .single();
    return response;
  }

  /// Fetch all audit assignments for a specific client.
  Future<List<Map<String, dynamic>>> fetchAuditsByClient(
    String clientId,
  ) async {
    final response = await _client
        .from('audit_assignments')
        .select()
        .eq('client_id', clientId)
        .order('created_at', ascending: false);
    return (response as List<dynamic>).cast<Map<String, dynamic>>();
  }

  /// Fetch all audit assignments for a specific auditor.
  Future<List<Map<String, dynamic>>> fetchAuditsByAuditor(
    String auditorId,
  ) async {
    final response = await _client
        .from('audit_assignments')
        .select()
        .eq('auditor_id', auditorId)
        .order('created_at', ascending: false);
    return (response as List<dynamic>).cast<Map<String, dynamic>>();
  }

  /// Update the status of an audit assignment.
  Future<Map<String, dynamic>> updateAuditStatus(
    String auditId,
    String status,
  ) async {
    final response = await _client
        .from('audit_assignments')
        .update({'status': status})
        .eq('id', auditId)
        .select()
        .single();
    return response;
  }

  // ---------------------------------------------------------------------------
  // Audit Reports
  // ---------------------------------------------------------------------------

  /// Insert a new audit report and return the server-side row.
  Future<Map<String, dynamic>> insertAuditReport(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from('audit_reports')
        .insert(data)
        .select()
        .single();
    return response;
  }

  /// Fetch the audit report for a specific client and financial year.
  Future<Map<String, dynamic>?> fetchAuditReportByClient(
    String clientId,
    int year,
  ) async {
    try {
      final response = await _client
          .from('audit_reports')
          .select()
          .eq('client_id', clientId)
          .eq('year', year)
          .maybeSingle();
      return response;
    } catch (_) {
      return null;
    }
  }
}
