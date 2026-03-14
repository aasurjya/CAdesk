import 'package:ca_app/features/portal_parser/data/datasources/portal_import_local_source.dart';
import 'package:ca_app/features/portal_parser/data/datasources/portal_import_remote_source.dart';
import 'package:ca_app/features/portal_parser/data/mappers/portal_import_mapper.dart';
import 'package:ca_app/features/portal_parser/domain/models/portal_import.dart';
import 'package:ca_app/features/portal_parser/domain/repositories/portal_import_repository.dart';

class PortalImportRepositoryImpl implements PortalImportRepository {
  const PortalImportRepositoryImpl({required this.remote, required this.local});

  final PortalImportRemoteSource remote;
  final PortalImportLocalSource local;

  @override
  Future<void> insert(PortalImport import) async {
    try {
      final json = await remote.insert(PortalImportMapper.toJson(import));
      final created = PortalImportMapper.fromJson(json);
      await local.upsert(created);
    } catch (_) {
      await local.insert(import);
    }
  }

  @override
  Future<List<PortalImport>> getByClient(String clientId) async {
    try {
      final jsonList = await remote.fetchByClient(clientId);
      final imports = jsonList.map(PortalImportMapper.fromJson).toList();
      for (final i in imports) {
        await local.upsert(i);
      }
      return List.unmodifiable(imports);
    } catch (_) {
      return local.getByClient(clientId);
    }
  }

  @override
  Future<List<PortalImport>> getByType(ImportType type) async {
    try {
      final jsonList = await remote.fetchByType(type.name);
      return List.unmodifiable(
        jsonList.map(PortalImportMapper.fromJson).toList(),
      );
    } catch (_) {
      return local.getByType(type);
    }
  }

  @override
  Future<PortalImport?> getLatest(String clientId, ImportType type) async {
    try {
      final json = await remote.fetchLatest(clientId, type.name);
      if (json == null) return null;
      final import = PortalImportMapper.fromJson(json);
      await local.upsert(import);
      return import;
    } catch (_) {
      return local.getLatest(clientId, type);
    }
  }

  @override
  Future<bool> updateStatus(
    String id,
    ImportStatus status, {
    int? parsedRecords,
    String? errorMessage,
  }) async {
    try {
      await remote.updateStatus(
        id,
        status.name,
        parsedRecords: parsedRecords,
        errorMessage: errorMessage,
      );
      return local.updateStatus(
        id,
        status,
        parsedRecords: parsedRecords,
        errorMessage: errorMessage,
      );
    } catch (_) {
      return local.updateStatus(
        id,
        status,
        parsedRecords: parsedRecords,
        errorMessage: errorMessage,
      );
    }
  }

  @override
  Future<PortalImport?> getById(String id) async {
    try {
      final json = await remote.fetchById(id);
      if (json == null) return null;
      final import = PortalImportMapper.fromJson(json);
      await local.upsert(import);
      return import;
    } catch (_) {
      return local.getById(id);
    }
  }

  @override
  Stream<List<PortalImport>> watchByClient(String clientId) =>
      local.watchByClient(clientId);
}
