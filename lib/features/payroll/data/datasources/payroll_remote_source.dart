import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for payroll entries backed by Supabase.
///
/// Operates against the `payroll_entries` table.
class PayrollRemoteSource {
  const PayrollRemoteSource(this._client);

  final SupabaseClient _client;

  static const _table = 'payroll_entries';

  /// Fetch all payroll entries for a [clientId] in a [year].
  Future<List<Map<String, dynamic>>> fetchByClient(
    String clientId,
    int year,
  ) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('client_id', clientId)
        .eq('year', year)
        .order('month');
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch all payroll entries for an [employeeId] in a [year].
  Future<List<Map<String, dynamic>>> fetchByEmployee(
    String employeeId,
    int year,
  ) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('employee_id', employeeId)
        .eq('year', year)
        .order('month');
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch all payroll entries for a [clientId] in a specific [month]/[year].
  Future<List<Map<String, dynamic>>> fetchByMonth(
    String clientId,
    int month,
    int year,
  ) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('client_id', clientId)
        .eq('month', month)
        .eq('year', year);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Insert a new payroll entry. Returns the persisted row.
  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final response = await _client.from(_table).insert(data).select().single();
    return response;
  }

  /// Update an existing payroll entry by [id]. Returns the updated row.
  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_table)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  /// Delete a payroll entry by [id].
  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}
