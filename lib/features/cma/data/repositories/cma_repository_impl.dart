import 'package:ca_app/features/cma/data/datasources/cma_local_source.dart';
import 'package:ca_app/features/cma/data/datasources/cma_remote_source.dart';
import 'package:ca_app/features/cma/data/mappers/cma_mapper.dart';
import 'package:ca_app/features/cma/domain/models/cma_report.dart';
import 'package:ca_app/features/cma/domain/repositories/cma_repository.dart';

/// Real implementation of [CmaRepository].
///
/// Attempts remote (Supabase) operations first; falls back to local cache
/// on any network error.
class CmaRepositoryImpl implements CmaRepository {
  const CmaRepositoryImpl({required this.remote, required this.local});

  final CmaRemoteSource remote;
  final CmaLocalSource local;

  @override
  Future<List<CmaReport>> getReportsByClient(String clientId) async {
    try {
      final jsonList = await remote.fetchByClient(clientId);
      final reports = jsonList.map(CmaMapper.fromJson).toList();
      for (final r in reports) {
        await local.insertReport(r);
      }
      return List.unmodifiable(reports);
    } catch (_) {
      return local.getByClient(clientId);
    }
  }

  @override
  Future<CmaReport?> getReportById(String id) async {
    try {
      final json = await remote.fetchById(id);
      if (json == null) return null;
      final report = CmaMapper.fromJson(json);
      await local.insertReport(report);
      return report;
    } catch (_) {
      return local.getById(id);
    }
  }

  @override
  Future<String> insertReport(CmaReport report) async {
    try {
      final json = await remote.insert(CmaMapper.toJson(report));
      final inserted = CmaMapper.fromJson(json);
      await local.insertReport(inserted);
      return inserted.id;
    } catch (_) {
      return local.insertReport(report);
    }
  }

  @override
  Future<bool> updateReport(CmaReport report) async {
    try {
      final json = await remote.update(report.id, CmaMapper.toJson(report));
      final updated = CmaMapper.fromJson(json);
      await local.updateReport(updated);
      return true;
    } catch (_) {
      return local.updateReport(report);
    }
  }

  @override
  Future<bool> deleteReport(String id) async {
    try {
      await remote.delete(id);
      await local.deleteReport(id);
      return true;
    } catch (_) {
      return local.deleteReport(id);
    }
  }

  @override
  Future<List<CmaReport>> getAllReports() async {
    try {
      final jsonList = await remote.fetchAll();
      final reports = jsonList.map(CmaMapper.fromJson).toList();
      for (final r in reports) {
        await local.insertReport(r);
      }
      return List.unmodifiable(reports);
    } catch (_) {
      return local.getAll();
    }
  }
}
