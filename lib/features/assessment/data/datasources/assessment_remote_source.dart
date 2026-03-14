import 'package:supabase_flutter/supabase_flutter.dart';

class AssessmentRemoteSource {
  const AssessmentRemoteSource(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> fetchByClient(String clientId) async {
    final response = await _client
        .from('assessment_cases')
        .select()
        .eq('client_id', clientId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchByYear(String assessmentYear) async {
    final response = await _client
        .from('assessment_cases')
        .select()
        .eq('assessment_year', assessmentYear)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchByType(String caseType) async {
    final response = await _client
        .from('assessment_cases')
        .select()
        .eq('case_type', caseType)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchByStatus(String status) async {
    final response = await _client
        .from('assessment_cases')
        .select()
        .eq('status', status)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final response = await _client
        .from('assessment_cases')
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from('assessment_cases')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }
}
