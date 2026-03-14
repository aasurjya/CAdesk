import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote (Supabase) data source for ESG disclosures and carbon metrics.
class EsgReportingRemoteSource {
  const EsgReportingRemoteSource(this._client);

  final SupabaseClient _client;

  static const _disclosureTable = 'esg_disclosures';
  static const _carbonTable = 'carbon_metrics';

  Future<List<Map<String, dynamic>>> fetchAllDisclosures() async {
    final response = await _client
        .from(_disclosureTable)
        .select()
        .order('reporting_year', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> insertDisclosure(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_disclosureTable)
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>> updateDisclosure(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_disclosureTable)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  Future<void> deleteDisclosure(String id) async {
    await _client.from(_disclosureTable).delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> fetchAllCarbonMetrics() async {
    final response = await _client
        .from(_carbonTable)
        .select()
        .order('reporting_year', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> insertCarbonMetric(
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_carbonTable)
        .insert(data)
        .select()
        .single();
    return response;
  }

  Future<Map<String, dynamic>> updateCarbonMetric(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(_carbonTable)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }

  Future<void> deleteCarbonMetric(String id) async {
    await _client.from(_carbonTable).delete().eq('id', id);
  }
}
