import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/clients_table.dart';

part 'clients_dao.g.dart';

@DriftAccessor(tables: [ClientsTable])
class ClientsDao extends DatabaseAccessor<AppDatabase> with _$ClientsDaoMixin {
  ClientsDao(super.db);

  Future<List<ClientRow>> getAllClients(String firmId) =>
      (select(clientsTable)..where((t) => t.firmId.equals(firmId))).get();

  Future<ClientRow?> getClientById(String id) =>
      (select(clientsTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsertClient(ClientsTableCompanion client) =>
      into(clientsTable).insertOnConflictUpdate(client);

  Future<void> deleteClient(String id) =>
      (delete(clientsTable)..where((t) => t.id.equals(id))).go();

  Stream<List<ClientRow>> watchAllClients(String firmId) =>
      (select(clientsTable)..where((t) => t.firmId.equals(firmId))).watch();

  Future<List<ClientRow>> searchClients(String firmId, String query) {
    final q = '%${query.toLowerCase()}%';
    return (select(clientsTable)..where(
          (t) =>
              t.firmId.equals(firmId) &
              (t.name.lower().like(q) |
                  t.pan.lower().like(q) |
                  t.email.lower().like(q) |
                  t.phone.like(q)),
        ))
        .get();
  }

  Future<List<ClientRow>> getDirtyClients() =>
      (select(clientsTable)..where((t) => t.isDirty)).get();

  Future<void> markClientSynced(String id, DateTime syncedAt) =>
      (update(clientsTable)..where((t) => t.id.equals(id))).write(
        ClientsTableCompanion(
          syncedAt: Value(syncedAt.toIso8601String()),
          isDirty: const Value(false),
        ),
      );
}
