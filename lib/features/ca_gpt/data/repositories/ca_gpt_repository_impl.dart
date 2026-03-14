import 'package:ca_app/features/ca_gpt/data/datasources/ca_gpt_local_source.dart';
import 'package:ca_app/features/ca_gpt/data/datasources/ca_gpt_remote_source.dart';
import 'package:ca_app/features/ca_gpt/data/mappers/ca_gpt_mapper.dart';
import 'package:ca_app/features/ca_gpt/domain/models/tax_query.dart';
import 'package:ca_app/features/ca_gpt/domain/repositories/ca_gpt_repository.dart';

/// Real implementation of [CaGptRepository].
///
/// Attempts remote (Supabase) operations first; falls back to local cache
/// on any network error.
class CaGptRepositoryImpl implements CaGptRepository {
  const CaGptRepositoryImpl({required this.remote, required this.local});

  final CaGptRemoteSource remote;
  final CaGptLocalSource local;

  @override
  Future<List<TaxQuery>> getAllQueries() async {
    try {
      final jsonList = await remote.fetchAll();
      final queries = jsonList.map(CaGptMapper.fromJson).toList();
      for (final q in queries) {
        await local.insertQuery(q);
      }
      return List.unmodifiable(queries);
    } catch (_) {
      return local.getAll();
    }
  }

  @override
  Future<TaxQuery?> getQueryById(String queryId) async {
    try {
      final json = await remote.fetchById(queryId);
      if (json == null) return null;
      final query = CaGptMapper.fromJson(json);
      await local.insertQuery(query);
      return query;
    } catch (_) {
      return local.getById(queryId);
    }
  }

  @override
  Future<List<TaxQuery>> getQueriesByType(QueryType queryType) async {
    try {
      final jsonList = await remote.fetchByType(queryType.name);
      final queries = jsonList.map(CaGptMapper.fromJson).toList();
      for (final q in queries) {
        await local.insertQuery(q);
      }
      return List.unmodifiable(queries);
    } catch (_) {
      return local.getByType(queryType);
    }
  }

  @override
  Future<String> insertQuery(TaxQuery query) async {
    try {
      final json = await remote.insert(CaGptMapper.toJson(query));
      final inserted = CaGptMapper.fromJson(json);
      await local.insertQuery(inserted);
      return inserted.queryId;
    } catch (_) {
      return local.insertQuery(query);
    }
  }

  @override
  Future<bool> updateQuery(TaxQuery query) async {
    try {
      final json = await remote.update(
        query.queryId,
        CaGptMapper.toJson(query),
      );
      final updated = CaGptMapper.fromJson(json);
      await local.updateQuery(updated);
      return true;
    } catch (_) {
      return local.updateQuery(query);
    }
  }

  @override
  Future<bool> deleteQuery(String queryId) async {
    try {
      await remote.delete(queryId);
      await local.deleteQuery(queryId);
      return true;
    } catch (_) {
      return local.deleteQuery(queryId);
    }
  }
}
