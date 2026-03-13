import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/gst_clients_table.dart';
import 'package:ca_app/core/database/tables/gst_returns_table.dart';

part 'gst_dao.g.dart';

@DriftAccessor(tables: [GstClientsTable, GstReturnsTable])
class GstDao extends DatabaseAccessor<AppDatabase> with _$GstDaoMixin {
  GstDao(super.db);

  // --- GstClients ---

  Future<List<GstClientRow>> getAllClients(String firmId) =>
      (select(gstClientsTable)..where((t) => t.firmId.equals(firmId))).get();

  Future<GstClientRow?> getClientById(String id) => (select(
    gstClientsTable,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<GstClientRow?> getByGstin(String gstin) => (select(
    gstClientsTable,
  )..where((t) => t.gstin.equals(gstin))).getSingleOrNull();

  Future<void> upsertClient(GstClientsTableCompanion client) =>
      into(gstClientsTable).insertOnConflictUpdate(client);

  Future<void> deleteClient(String id) =>
      (delete(gstClientsTable)..where((t) => t.id.equals(id))).go();

  Stream<List<GstClientRow>> watchAllClients(String firmId) =>
      (select(gstClientsTable)..where((t) => t.firmId.equals(firmId))).watch();

  Future<List<GstClientRow>> getDirtyClients() =>
      (select(gstClientsTable)..where((t) => t.isDirty)).get();

  Future<void> markClientSynced(String id, DateTime syncedAt) =>
      (update(gstClientsTable)..where((t) => t.id.equals(id))).write(
        GstClientsTableCompanion(
          syncedAt: Value(syncedAt.toIso8601String()),
          isDirty: const Value(false),
        ),
      );

  // --- GstReturns ---

  Future<List<GstReturnRow>> getAllReturns(String firmId) =>
      (select(gstReturnsTable)..where((t) => t.firmId.equals(firmId))).get();

  Future<GstReturnRow?> getReturnById(String id) => (select(
    gstReturnsTable,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<GstReturnRow>> getReturnsByClientId(String clientId) => (select(
    gstReturnsTable,
  )..where((t) => t.clientId.equals(clientId))).get();

  Future<List<GstReturnRow>> getReturnsByPeriod(
    String firmId,
    int month,
    int year,
  ) =>
      (select(gstReturnsTable)..where(
            (t) =>
                t.firmId.equals(firmId) &
                t.periodMonth.equals(month) &
                t.periodYear.equals(year),
          ))
          .get();

  Future<void> upsertReturn(GstReturnsTableCompanion gstReturn) =>
      into(gstReturnsTable).insertOnConflictUpdate(gstReturn);

  Future<void> deleteReturn(String id) =>
      (delete(gstReturnsTable)..where((t) => t.id.equals(id))).go();

  Stream<List<GstReturnRow>> watchAllReturns(String firmId) =>
      (select(gstReturnsTable)..where((t) => t.firmId.equals(firmId))).watch();

  Future<List<GstReturnRow>> getDirtyReturns() =>
      (select(gstReturnsTable)..where((t) => t.isDirty)).get();

  Future<void> markReturnSynced(String id, DateTime syncedAt) =>
      (update(gstReturnsTable)..where((t) => t.id.equals(id))).write(
        GstReturnsTableCompanion(
          syncedAt: Value(syncedAt.toIso8601String()),
          isDirty: const Value(false),
        ),
      );
}
