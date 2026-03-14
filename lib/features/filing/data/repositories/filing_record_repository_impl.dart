import 'package:ca_app/features/filing/data/datasources/filing_record_local_source.dart';
import 'package:ca_app/features/filing/data/datasources/filing_record_remote_source.dart';
import 'package:ca_app/features/filing/data/mappers/filing_record_mapper.dart';
import 'package:ca_app/features/filing/domain/models/filing_record.dart';
import 'package:ca_app/features/filing/domain/repositories/filing_record_repository.dart';

class FilingRecordRepositoryImpl implements FilingRecordRepository {
  const FilingRecordRepositoryImpl({required this.remote, required this.local});

  final FilingRecordRemoteSource remote;
  final FilingRecordLocalSource local;

  @override
  Future<void> insert(FilingRecord record) async {
    try {
      final json = await remote.insert(FilingRecordMapper.toJson(record));
      final created = FilingRecordMapper.fromJson(json);
      await local.upsert(created);
    } catch (_) {
      await local.insert(record);
    }
  }

  @override
  Future<List<FilingRecord>> getByClient(String clientId) async {
    try {
      final jsonList = await remote.fetchByClient(clientId);
      final records = jsonList.map(FilingRecordMapper.fromJson).toList();
      for (final r in records) {
        await local.upsert(r);
      }
      return List.unmodifiable(records);
    } catch (_) {
      return local.getByClient(clientId);
    }
  }

  @override
  Future<List<FilingRecord>> getByType(FilingType type) async {
    try {
      final jsonList = await remote.fetchByType(type.name);
      return List.unmodifiable(
        jsonList.map(FilingRecordMapper.fromJson).toList(),
      );
    } catch (_) {
      return local.getByType(type);
    }
  }

  @override
  Future<List<FilingRecord>> getByStatus(FilingStatus status) async {
    try {
      final jsonList = await remote.fetchByStatus(status.name);
      return List.unmodifiable(
        jsonList.map(FilingRecordMapper.fromJson).toList(),
      );
    } catch (_) {
      return local.getByStatus(status);
    }
  }

  @override
  Future<bool> updateStatus(String id, FilingStatus status) async {
    try {
      await remote.updateStatus(id, status.name);
      return local.updateStatus(id, status);
    } catch (_) {
      return local.updateStatus(id, status);
    }
  }

  @override
  Future<List<FilingRecord>> getOverdue() async {
    try {
      final jsonList = await remote.fetchOverdue();
      return List.unmodifiable(
        jsonList.map(FilingRecordMapper.fromJson).toList(),
      );
    } catch (_) {
      return local.getOverdue();
    }
  }

  @override
  Future<FilingRecord?> getById(String id) async {
    try {
      final json = await remote.fetchById(id);
      if (json == null) return null;
      final record = FilingRecordMapper.fromJson(json);
      await local.upsert(record);
      return record;
    } catch (_) {
      return local.getById(id);
    }
  }

  @override
  Stream<List<FilingRecord>> watchByClient(String clientId) =>
      local.watchByClient(clientId);
}
