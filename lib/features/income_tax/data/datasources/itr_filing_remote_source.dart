import 'package:supabase_flutter/supabase_flutter.dart';

class ItrFilingRemoteSource {
  const ItrFilingRemoteSource(this._client);

  final SupabaseClient _client;

  static const _table = 'itr_filings';

  Future<List<Map<String, dynamic>>> fetchAll({String? firmId}) async {
    if (firmId != null) {
      final response = await _client
          .from(_table)
          .select()
          .eq('firm_id', firmId)
          .order('name');
      return List<Map<String, dynamic>>.from(response);
    }
    final response = await _client.from(_table).select().order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> fetchById(String id) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final response = await _client.from(_table).insert(data).select().single();
    return response;
  }

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

  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> search(
    String query, {
    String? firmId,
  }) async {
    if (firmId != null) {
      final response = await _client
          .from(_table)
          .select()
          .eq('firm_id', firmId)
          .or(
            'name.ilike.%$query%,pan.ilike.%$query%,assessment_year.ilike.%$query%',
          )
          .order('name');
      return List<Map<String, dynamic>>.from(response);
    }
    final response = await _client
        .from(_table)
        .select()
        .or(
          'name.ilike.%$query%,pan.ilike.%$query%,assessment_year.ilike.%$query%',
        )
        .order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getByAssessmentYear(
    String ay, {
    String? firmId,
  }) async {
    if (firmId != null) {
      final response = await _client
          .from(_table)
          .select()
          .eq('firm_id', firmId)
          .eq('assessment_year', ay)
          .order('name');
      return List<Map<String, dynamic>>.from(response);
    }
    final response = await _client
        .from(_table)
        .select()
        .eq('assessment_year', ay)
        .order('name');
    return List<Map<String, dynamic>>.from(response);
  }
}
