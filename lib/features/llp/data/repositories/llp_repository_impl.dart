import 'package:ca_app/features/llp/data/datasources/llp_local_source.dart';
import 'package:ca_app/features/llp/data/datasources/llp_remote_source.dart';
import 'package:ca_app/features/llp/data/mappers/llp_mapper.dart';
import 'package:ca_app/features/llp/domain/models/llp_filing.dart';
import 'package:ca_app/features/llp/domain/repositories/llp_repository.dart';

/// Concrete [LlpRepository] — remote-first with local Drift cache fallback.
class LlpRepositoryImpl implements LlpRepository {
  const LlpRepositoryImpl({
    required this.remote,
    required this.local,
  });

  final LlpRemoteSource remote;
  final LlpLocalSource local;

  @override
  Future<String> insertLlpFiling(LlpFiling filing) async {
    try {
      final json = await remote.insert(LlpMapper.toJson(filing));
      final created = LlpMapper.fromJson(json);
      await local.insertLlpFiling(created);
      return created.id;
    } catch (_) {
      return local.insertLlpFiling(filing);
    }
  }

  @override
  Future<List<LlpFiling>> getByClient(String clientId) async {
    try {
      final jsonList = await remote.fetchByClient(clientId);
      final filings = jsonList.map(LlpMapper.fromJson).toList();
      for (final f in filings) {
        await local.insertLlpFiling(f);
      }
      return List.unmodifiable(filings);
    } catch (_) {
      return local.getByClient(clientId);
    }
  }

  @override
  Future<List<LlpFiling>> getByYear(String clientId, String year) async {
    try {
      final jsonList = await remote.fetchByYear(clientId, year);
      final filings = jsonList.map(LlpMapper.fromJson).toList();
      for (final f in filings) {
        await local.insertLlpFiling(f);
      }
      return List.unmodifiable(filings);
    } catch (_) {
      return local.getByYear(clientId, year);
    }
  }

  @override
  Future<bool> updateStatus(String id, String status) async {
    try {
      await remote.updateStatus(id, status);
      return local.updateStatus(id, status);
    } catch (_) {
      return local.updateStatus(id, status);
    }
  }

  @override
  Future<List<LlpFiling>> getOverdue() async {
    try {
      final jsonList = await remote.fetchOverdue();
      final filings = jsonList.map(LlpMapper.fromJson).toList();
      return List.unmodifiable(filings);
    } catch (_) {
      return local.getOverdue();
    }
  }

  @override
  Future<List<LlpFiling>> getDue(int daysAhead) async {
    try {
      final jsonList = await remote.fetchDue(daysAhead);
      final filings = jsonList.map(LlpMapper.fromJson).toList();
      return List.unmodifiable(filings);
    } catch (_) {
      return local.getDue(daysAhead);
    }
  }
}
