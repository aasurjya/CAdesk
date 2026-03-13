import 'package:ca_app/features/startup/data/datasources/startup_local_source.dart';
import 'package:ca_app/features/startup/data/datasources/startup_remote_source.dart';
import 'package:ca_app/features/startup/data/mappers/startup_mapper.dart';
import 'package:ca_app/features/startup/domain/models/startup_record.dart';
import 'package:ca_app/features/startup/domain/repositories/startup_repository.dart';

/// Concrete [StartupRepository] — remote-first with local Drift cache fallback.
class StartupRepositoryImpl implements StartupRepository {
  const StartupRepositoryImpl({
    required this.remote,
    required this.local,
  });

  final StartupRemoteSource remote;
  final StartupLocalSource local;

  @override
  Future<String> insert(StartupRecord record) async {
    try {
      final json = await remote.insert(StartupMapper.toJson(record));
      final created = StartupMapper.fromJson(json);
      await local.insert(created);
      return created.id;
    } catch (_) {
      return local.insert(record);
    }
  }

  @override
  Future<List<StartupRecord>> getByClient(String clientId) async {
    try {
      final jsonList = await remote.fetchByClient(clientId);
      final records = jsonList.map(StartupMapper.fromJson).toList();
      for (final r in records) {
        await local.insert(r);
      }
      return List.unmodifiable(records);
    } catch (_) {
      return local.getByClient(clientId);
    }
  }

  @override
  Future<bool> update(StartupRecord record) async {
    try {
      final json = await remote.update(
        record.id,
        StartupMapper.toJson(record),
      );
      final updated = StartupMapper.fromJson(json);
      return local.update(updated);
    } catch (_) {
      return local.update(record);
    }
  }

  @override
  Future<List<StartupRecord>> getByStatus(String status) async {
    try {
      final jsonList = await remote.fetchByStatus(status);
      final records = jsonList.map(StartupMapper.fromJson).toList();
      return List.unmodifiable(records);
    } catch (_) {
      return local.getByStatus(status);
    }
  }

  @override
  Future<List<StartupRecord>> getEligibleForExemptions() async {
    try {
      final jsonList = await remote.fetchEligibleForExemptions();
      final records = jsonList.map(StartupMapper.fromJson).toList();
      return List.unmodifiable(records);
    } catch (_) {
      return local.getEligibleForExemptions();
    }
  }
}
