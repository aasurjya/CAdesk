import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/portal_imports_table.dart';

part 'portal_imports_dao.g.dart';

@DriftAccessor(tables: [PortalImportsTable])
class PortalImportsDao extends DatabaseAccessor<AppDatabase>
    with _$PortalImportsDaoMixin {
  PortalImportsDao(super.db);

  /// Insert a new portal import, returning its ID.
  Future<String> insertImport(PortalImportsTableCompanion companion) async {
    await into(portalImportsTable).insert(companion);
    final rows = await (select(portalImportsTable)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ])
          ..limit(1))
        .get();
    return rows.isNotEmpty ? rows.first.id : '';
  }

  /// Get all imports for a client.
  Future<List<PortalImportRow>> getByClient(String clientId) =>
      (select(portalImportsTable)
            ..where((t) => t.clientId.equals(clientId))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.importDate,
                mode: OrderingMode.desc,
              ),
            ]))
          .get();

  /// Watch imports for a client (reactive).
  Stream<List<PortalImportRow>> watchByClient(String clientId) =>
      (select(portalImportsTable)..where((t) => t.clientId.equals(clientId)))
          .watch();

  /// Get imports by type.
  Future<List<PortalImportRow>> getByType(String importType) =>
      (select(portalImportsTable)
            ..where((t) => t.importType.equals(importType))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.importDate,
                mode: OrderingMode.desc,
              ),
            ]))
          .get();

  /// Get the most recent import for a specific client and type.
  Future<PortalImportRow?> getLatest(
    String clientId,
    String importType,
  ) async {
    final rows = await (select(portalImportsTable)
          ..where(
            (t) =>
                t.clientId.equals(clientId) & t.importType.equals(importType),
          )
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.importDate,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(1))
        .get();
    return rows.isNotEmpty ? rows.first : null;
  }

  /// Update status (and optional fields). Returns true if updated.
  Future<bool> updateStatus(
    String id,
    String status, {
    int? parsedRecords,
    String? errorMessage,
  }) async {
    final rowsAffected = await (update(portalImportsTable)
          ..where((t) => t.id.equals(id)))
        .write(
          PortalImportsTableCompanion(
            status: Value(status),
            parsedRecords: Value(parsedRecords),
            errorMessage: Value(errorMessage),
            isDirty: const Value(true),
          ),
        );
    return rowsAffected > 0;
  }

  /// Get a single import by ID.
  Future<PortalImportRow?> getById(String id) =>
      (select(portalImportsTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  /// Upsert a portal import.
  Future<void> upsert(PortalImportsTableCompanion companion) =>
      into(portalImportsTable).insertOnConflictUpdate(companion);
}
