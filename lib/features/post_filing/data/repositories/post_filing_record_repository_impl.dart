import 'package:ca_app/features/post_filing/data/datasources/post_filing_record_local_source.dart';
import 'package:ca_app/features/post_filing/data/datasources/post_filing_record_remote_source.dart';
import 'package:ca_app/features/post_filing/data/mappers/post_filing_record_mapper.dart';
import 'package:ca_app/features/post_filing/domain/models/post_filing_record.dart';
import 'package:ca_app/features/post_filing/domain/repositories/post_filing_record_repository.dart';

class PostFilingRecordRepositoryImpl implements PostFilingRecordRepository {
  const PostFilingRecordRepositoryImpl({
    required this.remote,
    required this.local,
  });

  final PostFilingRecordRemoteSource remote;
  final PostFilingRecordLocalSource local;

  @override
  Future<void> insert(PostFilingRecord record) async {
    try {
      final json = await remote.insert(PostFilingRecordMapper.toJson(record));
      final created = PostFilingRecordMapper.fromJson(json);
      await local.upsert(created);
    } catch (_) {
      await local.insert(record);
    }
  }

  @override
  Future<List<PostFilingRecord>> getByFiling(String filingId) async {
    try {
      final jsonList = await remote.fetchByFiling(filingId);
      final records = jsonList.map(PostFilingRecordMapper.fromJson).toList();
      for (final r in records) {
        await local.upsert(r);
      }
      return List.unmodifiable(records);
    } catch (_) {
      return local.getByFiling(filingId);
    }
  }

  @override
  Future<List<PostFilingRecord>> getByClient(String clientId) async {
    try {
      final jsonList = await remote.fetchByClient(clientId);
      final records = jsonList.map(PostFilingRecordMapper.fromJson).toList();
      for (final r in records) {
        await local.upsert(r);
      }
      return List.unmodifiable(records);
    } catch (_) {
      return local.getByClient(clientId);
    }
  }

  @override
  Future<bool> updateStatus(
    String id,
    PostFilingStatus status, {
    DateTime? completedAt,
    String? notes,
  }) async {
    try {
      await remote.updateStatus(
        id,
        status.name,
        completedAt: completedAt?.toIso8601String(),
        notes: notes,
      );
      return local.updateStatus(
        id,
        status,
        completedAt: completedAt,
        notes: notes,
      );
    } catch (_) {
      return local.updateStatus(
        id,
        status,
        completedAt: completedAt,
        notes: notes,
      );
    }
  }

  @override
  Future<List<PostFilingRecord>> getPending() async {
    try {
      final jsonList = await remote.fetchPending();
      return List.unmodifiable(
        jsonList.map(PostFilingRecordMapper.fromJson).toList(),
      );
    } catch (_) {
      return local.getPending();
    }
  }

  @override
  Future<PostFilingRecord?> getById(String id) async {
    try {
      final json = await remote.fetchById(id);
      if (json == null) return null;
      final record = PostFilingRecordMapper.fromJson(json);
      await local.upsert(record);
      return record;
    } catch (_) {
      return local.getById(id);
    }
  }

  @override
  Stream<List<PostFilingRecord>> watchByClient(String clientId) =>
      local.watchByClient(clientId);
}
