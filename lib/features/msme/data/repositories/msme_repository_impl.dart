import 'package:ca_app/features/msme/data/datasources/msme_local_source.dart';
import 'package:ca_app/features/msme/data/datasources/msme_remote_source.dart';
import 'package:ca_app/features/msme/data/mappers/msme_mapper.dart';
import 'package:ca_app/features/msme/domain/models/msme_record.dart';
import 'package:ca_app/features/msme/domain/repositories/msme_repository.dart';

/// Concrete [MsmeRepository] — remote-first with local Drift cache fallback.
class MsmeRepositoryImpl implements MsmeRepository {
  const MsmeRepositoryImpl({
    required this.remote,
    required this.local,
  });

  final MsmeRemoteSource remote;
  final MsmeLocalSource local;

  @override
  Future<String> insert(MsmeRecord record) async {
    try {
      final json = await remote.insert(MsmeMapper.toJson(record));
      final created = MsmeMapper.fromJson(json);
      await local.insert(created);
      return created.id;
    } catch (_) {
      return local.insert(record);
    }
  }

  @override
  Future<List<MsmeRecord>> getByClient(String clientId) async {
    try {
      final jsonList = await remote.fetchByClient(clientId);
      final records = jsonList.map(MsmeMapper.fromJson).toList();
      for (final r in records) {
        await local.insert(r);
      }
      return List.unmodifiable(records);
    } catch (_) {
      return local.getByClient(clientId);
    }
  }

  @override
  Future<bool> update(MsmeRecord record) async {
    try {
      final json = await remote.update(record.id, MsmeMapper.toJson(record));
      final updated = MsmeMapper.fromJson(json);
      return local.update(updated);
    } catch (_) {
      return local.update(record);
    }
  }

  @override
  Future<List<MsmeRecord>> getByCategory(MsmeCategory category) async {
    try {
      final jsonList = await remote.fetchByCategory(category.name);
      final records = jsonList.map(MsmeMapper.fromJson).toList();
      return List.unmodifiable(records);
    } catch (_) {
      return local.getByCategory(category);
    }
  }

  @override
  Future<List<MsmeRecord>> getByStatus(String status) async {
    try {
      final jsonList = await remote.fetchByStatus(status);
      final records = jsonList.map(MsmeMapper.fromJson).toList();
      return List.unmodifiable(records);
    } catch (_) {
      return local.getByStatus(status);
    }
  }
}
