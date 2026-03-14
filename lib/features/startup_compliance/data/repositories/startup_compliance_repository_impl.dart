import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/features/startup_compliance/domain/models/startup_entity.dart';
import 'package:ca_app/features/startup_compliance/domain/models/startup_filing.dart';
import 'package:ca_app/features/startup_compliance/domain/repositories/startup_compliance_repository.dart';

/// Real implementation of [StartupComplianceRepository] backed by Supabase.
class StartupComplianceRepositoryImpl implements StartupComplianceRepository {
  const StartupComplianceRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const _entitiesTable = 'startup_entities';
  static const _filingsTable = 'startup_filings';

  // ---------------------------------------------------------------------------
  // StartupEntity
  // ---------------------------------------------------------------------------

  @override
  Future<List<StartupEntity>> getStartupEntities() async {
    final response = await _client.from(_entitiesTable).select();
    return List<Map<String, dynamic>>.from(response)
        .map(_entityFromJson)
        .toList();
  }

  @override
  Future<StartupEntity?> getStartupEntityById(String id) async {
    final response = await _client
        .from(_entitiesTable)
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return _entityFromJson(response);
  }

  @override
  Future<List<StartupEntity>> getStartupEntitiesByRecognitionStatus(
    RecognitionStatus status,
  ) async {
    final response = await _client
        .from(_entitiesTable)
        .select()
        .eq('recognition_status', status.name);
    return List<Map<String, dynamic>>.from(response)
        .map(_entityFromJson)
        .toList();
  }

  @override
  Future<String> insertStartupEntity(StartupEntity entity) async {
    final response = await _client
        .from(_entitiesTable)
        .insert(_entityToJson(entity))
        .select()
        .single();
    return response['id'] as String;
  }

  @override
  Future<bool> updateStartupEntity(StartupEntity entity) async {
    await _client
        .from(_entitiesTable)
        .update(_entityToJson(entity))
        .eq('id', entity.id);
    return true;
  }

  @override
  Future<bool> deleteStartupEntity(String id) async {
    await _client.from(_entitiesTable).delete().eq('id', id);
    return true;
  }

  // ---------------------------------------------------------------------------
  // StartupFiling
  // ---------------------------------------------------------------------------

  @override
  Future<List<StartupFiling>> getStartupFilings() async {
    final response =
        await _client.from(_filingsTable).select().order('due_date');
    return List<Map<String, dynamic>>.from(response)
        .map(_filingFromJson)
        .toList();
  }

  @override
  Future<StartupFiling?> getStartupFilingById(String id) async {
    final response = await _client
        .from(_filingsTable)
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return _filingFromJson(response);
  }

  @override
  Future<List<StartupFiling>> getStartupFilingsByStartup(
    String startupId,
  ) async {
    final response = await _client
        .from(_filingsTable)
        .select()
        .eq('startup_id', startupId)
        .order('due_date');
    return List<Map<String, dynamic>>.from(response)
        .map(_filingFromJson)
        .toList();
  }

  @override
  Future<List<StartupFiling>> getStartupFilingsByStatus(
    StartupFilingStatus status,
  ) async {
    final response = await _client
        .from(_filingsTable)
        .select()
        .eq('status', status.name);
    return List<Map<String, dynamic>>.from(response)
        .map(_filingFromJson)
        .toList();
  }

  @override
  Future<String> insertStartupFiling(StartupFiling filing) async {
    final response = await _client
        .from(_filingsTable)
        .insert(_filingToJson(filing))
        .select()
        .single();
    return response['id'] as String;
  }

  @override
  Future<bool> updateStartupFiling(StartupFiling filing) async {
    await _client
        .from(_filingsTable)
        .update(_filingToJson(filing))
        .eq('id', filing.id);
    return true;
  }

  @override
  Future<bool> deleteStartupFiling(String id) async {
    await _client.from(_filingsTable).delete().eq('id', id);
    return true;
  }

  // ---------------------------------------------------------------------------
  // Mappers
  // ---------------------------------------------------------------------------

  StartupEntity _entityFromJson(Map<String, dynamic> j) => StartupEntity(
        id: j['id'] as String,
        entityName: j['entity_name'] as String,
        dpiitNumber: j['dpiit_number'] as String,
        incorporationDate:
            DateTime.parse(j['incorporation_date'] as String),
        sector: j['sector'] as String,
        turnover: (j['turnover'] as num).toDouble(),
        isBelow100Cr: j['is_below_100cr'] as bool,
        section80IACStatus: Section80IACStatus.values
            .firstWhere((s) => s.name == j['section_80iac_status'] as String),
        taxHolidayStartYear: j['tax_holiday_start_year'] as int?,
        taxHolidayEndYear: j['tax_holiday_end_year'] as int?,
        recognitionStatus: RecognitionStatus.values
            .firstWhere((s) => s.name == j['recognition_status'] as String),
        investmentRounds: const [],
      );

  Map<String, dynamic> _entityToJson(StartupEntity e) => {
        'id': e.id,
        'entity_name': e.entityName,
        'dpiit_number': e.dpiitNumber,
        'incorporation_date': e.incorporationDate.toIso8601String(),
        'sector': e.sector,
        'turnover': e.turnover,
        'is_below_100cr': e.isBelow100Cr,
        'section_80iac_status': e.section80IACStatus.name,
        'tax_holiday_start_year': e.taxHolidayStartYear,
        'tax_holiday_end_year': e.taxHolidayEndYear,
        'recognition_status': e.recognitionStatus.name,
      };

  StartupFiling _filingFromJson(Map<String, dynamic> j) => StartupFiling(
        id: j['id'] as String,
        startupId: j['startup_id'] as String,
        entityName: j['entity_name'] as String,
        filingType: StartupFilingType.values
            .firstWhere((t) => t.name == j['filing_type'] as String),
        dueDate: DateTime.parse(j['due_date'] as String),
        filedDate: j['filed_date'] != null
            ? DateTime.parse(j['filed_date'] as String)
            : null,
        status: StartupFilingStatus.values
            .firstWhere((s) => s.name == j['status'] as String),
        remarks: j['remarks'] as String?,
      );

  Map<String, dynamic> _filingToJson(StartupFiling f) => {
        'id': f.id,
        'startup_id': f.startupId,
        'entity_name': f.entityName,
        'filing_type': f.filingType.name,
        'due_date': f.dueDate.toIso8601String(),
        'filed_date': f.filedDate?.toIso8601String(),
        'status': f.status.name,
        'remarks': f.remarks,
      };
}
