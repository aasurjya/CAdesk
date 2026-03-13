import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/portal_parser/data/mappers/portal_import_mapper.dart';
import 'package:ca_app/features/portal_parser/domain/models/portal_import.dart';

class PortalImportLocalSource {
  const PortalImportLocalSource(this._db);

  final AppDatabase _db;

  Future<void> insert(PortalImport import) async {
    await _db.portalImportsDao.insertImport(
      PortalImportMapper.toCompanion(import),
    );
  }

  Future<List<PortalImport>> getByClient(String clientId) async {
    final rows = await _db.portalImportsDao.getByClient(clientId);
    return rows.map(PortalImportMapper.fromRow).toList();
  }

  Stream<List<PortalImport>> watchByClient(String clientId) {
    return _db.portalImportsDao
        .watchByClient(clientId)
        .map((rows) => rows.map(PortalImportMapper.fromRow).toList());
  }

  Future<List<PortalImport>> getByType(ImportType type) async {
    final rows = await _db.portalImportsDao.getByType(type.name);
    return rows.map(PortalImportMapper.fromRow).toList();
  }

  Future<PortalImport?> getLatest(String clientId, ImportType type) async {
    final row = await _db.portalImportsDao.getLatest(clientId, type.name);
    return row != null ? PortalImportMapper.fromRow(row) : null;
  }

  Future<bool> updateStatus(
    String id,
    ImportStatus status, {
    int? parsedRecords,
    String? errorMessage,
  }) =>
      _db.portalImportsDao.updateStatus(
        id,
        status.name,
        parsedRecords: parsedRecords,
        errorMessage: errorMessage,
      );

  Future<PortalImport?> getById(String id) async {
    final row = await _db.portalImportsDao.getById(id);
    return row != null ? PortalImportMapper.fromRow(row) : null;
  }

  Future<void> upsert(PortalImport import) async {
    await _db.portalImportsDao.upsert(PortalImportMapper.toCompanion(import));
  }
}
