import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote Supabase data source for firm operations.
///
/// All methods talk directly to the Supabase REST API.  The caller is
/// responsible for error handling / fallback logic.
class FirmOperationsRemoteSource {
  const FirmOperationsRemoteSource(this._client);

  final SupabaseClient _client;

  // ---------------------------------------------------------------------------
  // FirmInfo
  // ---------------------------------------------------------------------------

  /// Fetches the firm info row for the given firm.  Returns null if not found.
  Future<Map<String, dynamic>?> fetchFirmInfo(String firmId) async {
    final response = await _client
        .from('firm_info')
        .select()
        .eq('id', firmId)
        .maybeSingle();
    return response;
  }

  /// Upserts the firm info row.  Returns the persisted record.
  Future<Map<String, dynamic>> upsertFirmInfo(Map<String, dynamic> data) async {
    final response = await _client
        .from('firm_info')
        .upsert(data)
        .select()
        .single();
    return response;
  }

  // ---------------------------------------------------------------------------
  // TeamMembers
  // ---------------------------------------------------------------------------

  /// Fetches all team members for a firm.
  Future<List<Map<String, dynamic>>> fetchTeamMembers(String firmId) async {
    final response = await _client
        .from('team_members')
        .select()
        .eq('firm_id', firmId)
        .order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  /// Inserts a new team member.  Returns the created record.
  Future<Map<String, dynamic>> insertTeamMember(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from('team_members')
        .insert(data)
        .select()
        .single();
    return response;
  }

  /// Updates an existing team member.  Returns the updated record.
  Future<Map<String, dynamic>> updateTeamMember(
    String memberId,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from('team_members')
        .update(data)
        .eq('id', memberId)
        .select()
        .single();
    return response;
  }

  /// Deletes a team member by id.
  Future<void> deleteTeamMember(String memberId) async {
    await _client.from('team_members').delete().eq('id', memberId);
  }

  // ---------------------------------------------------------------------------
  // ClientAssignments
  // ---------------------------------------------------------------------------

  /// Inserts a client assignment.  Returns the created record.
  Future<Map<String, dynamic>> assignClient(Map<String, dynamic> data) async {
    final response = await _client
        .from('client_assignments')
        .insert(data)
        .select()
        .single();
    return response;
  }

  /// Fetches all client assignments for a given team member.
  Future<List<Map<String, dynamic>>> fetchClientsAssignedTo(
    String memberId,
  ) async {
    final response = await _client
        .from('client_assignments')
        .select()
        .eq('assigned_to_id', memberId)
        .order('start_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }
}
