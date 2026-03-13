import 'package:ca_app/features/portal_parser/domain/models/portal_import.dart';

abstract class PortalImportRepository {
  Future<void> insert(PortalImport import);
  Future<List<PortalImport>> getByClient(String clientId);
  Future<List<PortalImport>> getByType(ImportType type);
  Future<PortalImport?> getLatest(String clientId, ImportType type);
  Future<bool> updateStatus(
    String id,
    ImportStatus status, {
    int? parsedRecords,
    String? errorMessage,
  });
  Future<PortalImport?> getById(String id);
  Stream<List<PortalImport>> watchByClient(String clientId);
}
