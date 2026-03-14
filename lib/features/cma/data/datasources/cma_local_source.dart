import 'package:ca_app/features/cma/domain/models/cma_report.dart';

/// Local data source for CMA reports.
///
/// Uses an in-memory cache as a fallback when Supabase is unavailable.
class CmaLocalSource {
  CmaLocalSource();

  final List<CmaReport> _cache = [];

  /// Insert or replace a [CmaReport] in the local cache.
  Future<String> insertReport(CmaReport report) async {
    final idx = _cache.indexWhere((r) => r.id == report.id);
    if (idx >= 0) {
      final updated = List<CmaReport>.of(_cache)..[idx] = report;
      _cache
        ..clear()
        ..addAll(updated);
    } else {
      _cache.add(report);
    }
    return report.id;
  }

  /// Retrieve all cached reports for [clientId].
  Future<List<CmaReport>> getByClient(String clientId) async {
    return List.unmodifiable(
      _cache.where((r) => r.clientId == clientId).toList(),
    );
  }

  /// Retrieve a cached report by [id].
  Future<CmaReport?> getById(String id) async {
    try {
      return _cache.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Retrieve all cached reports.
  Future<List<CmaReport>> getAll() async {
    return List.unmodifiable(_cache);
  }

  /// Update a cached [CmaReport].
  Future<bool> updateReport(CmaReport report) async {
    final idx = _cache.indexWhere((r) => r.id == report.id);
    if (idx == -1) return false;
    final updated = List<CmaReport>.of(_cache)..[idx] = report;
    _cache
      ..clear()
      ..addAll(updated);
    return true;
  }

  /// Delete a cached report by [id].
  Future<bool> deleteReport(String id) async {
    final before = _cache.length;
    _cache.removeWhere((r) => r.id == id);
    return _cache.length < before;
  }
}
