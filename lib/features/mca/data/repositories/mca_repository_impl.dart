import 'package:ca_app/features/mca/data/datasources/mca_local_source.dart';
import 'package:ca_app/features/mca/data/datasources/mca_remote_source.dart';
import 'package:ca_app/features/mca/data/mappers/mca_mapper.dart';
import 'package:ca_app/features/mca/domain/models/mca_filing_data.dart';
import 'package:ca_app/features/mca/domain/repositories/mca_repository.dart';

/// Concrete [McaRepository] that reads from Supabase and falls back to the
/// local Drift cache on any network / server error.
class McaRepositoryImpl implements McaRepository {
  const McaRepositoryImpl({
    required this.remote,
    required this.local,
  });

  final McaRemoteSource remote;
  final McaLocalSource local;

  // ---------------------------------------------------------------------------
  // Insert
  // ---------------------------------------------------------------------------

  @override
  Future<String> insertMCAFiling(McaFilingData filing) async {
    try {
      final json = await remote.insert(McaMapper.toJson(filing));
      final created = McaMapper.fromJson(json);
      await local.insertMCAFiling(created);
      return created.id;
    } catch (_) {
      return local.insertMCAFiling(filing);
    }
  }

  // ---------------------------------------------------------------------------
  // Reads — remote-first with local fallback
  // ---------------------------------------------------------------------------

  @override
  Future<List<McaFilingData>> getMCAFilingsByClient(String clientId) async {
    try {
      final jsonList = await remote.fetchByClient(clientId);
      final filings = jsonList.map(McaMapper.fromJson).toList();
      for (final f in filings) {
        await local.updateMCAFiling(f);
      }
      return List.unmodifiable(filings);
    } catch (_) {
      return local.getMCAFilingsByClient(clientId);
    }
  }

  @override
  Future<List<McaFilingData>> getMCAFilingsByYear(
    String clientId,
    String year,
  ) async {
    try {
      final jsonList = await remote.fetchByYear(clientId, year);
      final filings = jsonList.map(McaMapper.fromJson).toList();
      for (final f in filings) {
        await local.updateMCAFiling(f);
      }
      return List.unmodifiable(filings);
    } catch (_) {
      return local.getMCAFilingsByYear(clientId, year);
    }
  }

  @override
  Future<List<McaFilingData>> getMCAFilingsByStatus(String status) async {
    try {
      final jsonList = await remote.fetchByStatus(status);
      final filings = jsonList.map(McaMapper.fromJson).toList();
      for (final f in filings) {
        await local.updateMCAFiling(f);
      }
      return List.unmodifiable(filings);
    } catch (_) {
      return local.getMCAFilingsByStatus(status);
    }
  }

  @override
  Future<List<McaFilingData>> getDueMCAFilings(int daysAhead) async {
    try {
      final jsonList = await remote.fetchDueFilings(daysAhead);
      final filings = jsonList.map(McaMapper.fromJson).toList();
      for (final f in filings) {
        await local.updateMCAFiling(f);
      }
      return List.unmodifiable(filings);
    } catch (_) {
      return local.getDueMCAFilings(daysAhead);
    }
  }

  @override
  Future<McaFilingData?> getMCAFilingById(String id) async {
    try {
      final json = await remote.fetchById(id);
      if (json == null) return null;
      final filing = McaMapper.fromJson(json);
      await local.updateMCAFiling(filing);
      return filing;
    } catch (_) {
      return local.getMCAFilingById(id);
    }
  }

  // ---------------------------------------------------------------------------
  // Update
  // ---------------------------------------------------------------------------

  @override
  Future<bool> updateMCAFiling(McaFilingData filing) async {
    try {
      final json = await remote.update(filing.id, McaMapper.toJson(filing));
      final updated = McaMapper.fromJson(json);
      return local.updateMCAFiling(updated);
    } catch (_) {
      return local.updateMCAFiling(filing);
    }
  }

  // ---------------------------------------------------------------------------
  // Stream
  // ---------------------------------------------------------------------------

  @override
  Stream<List<McaFilingData>> watchMCAFilingsByClient(String clientId) =>
      local.watchMCAFilingsByClient(clientId);
}
