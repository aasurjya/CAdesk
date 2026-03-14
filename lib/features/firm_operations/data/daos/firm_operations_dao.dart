import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/firm_operations_table.dart';

part 'firm_operations_dao.g.dart';

@DriftAccessor(
  tables: [FirmInfoTable, TeamMembersTable, ClientAssignmentsTable],
)
class FirmOperationsDao extends DatabaseAccessor<AppDatabase>
    with _$FirmOperationsDaoMixin {
  FirmOperationsDao(super.db);

  // ---------------------------------------------------------------------------
  // FirmInfo
  // ---------------------------------------------------------------------------

  /// Returns the first firm info row, or null if none exists.
  Future<FirmInfoTableData?> getFirmInfo() async {
    final rows = await (select(firmInfoTable)..limit(1)).get();
    return rows.isEmpty ? null : rows.first;
  }

  /// Returns the firm info row by id, or null if not found.
  Future<FirmInfoTableData?> getFirmInfoById(String id) =>
      (select(firmInfoTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Upserts the firm info row (insert or replace on conflict).
  Future<void> upsertFirmInfo(FirmInfoTableCompanion companion) =>
      into(firmInfoTable).insertOnConflictUpdate(companion);

  // ---------------------------------------------------------------------------
  // TeamMembers
  // ---------------------------------------------------------------------------

  /// Inserts a new team member and returns its id.
  Future<String> insertTeamMember(TeamMembersTableCompanion companion) async {
    await into(teamMembersTable).insert(companion);
    final id = companion.id.value;
    return id;
  }

  /// Returns all team members for a firm, ordered by name.
  Future<List<TeamMembersTableData>> getTeamMembers(String firmId) =>
      (select(teamMembersTable)
            ..where((t) => t.firmId.equals(firmId))
            ..orderBy([(t) => OrderingTerm(expression: t.name)]))
          .get();

  /// Updates an existing team member. Returns true if a row was affected.
  Future<bool> updateTeamMember(TeamMembersTableCompanion companion) async {
    final rowsAffected = await (update(
      teamMembersTable,
    )..where((t) => t.id.equals(companion.id.value))).write(companion);
    return rowsAffected > 0;
  }

  /// Deletes a team member by id. Returns true if a row was deleted.
  Future<bool> deleteTeamMember(String memberId) async {
    final rowsAffected = await (delete(
      teamMembersTable,
    )..where((t) => t.id.equals(memberId))).go();
    return rowsAffected > 0;
  }

  /// Returns a single team member by id, or null if not found.
  Future<TeamMembersTableData?> getTeamMemberById(String memberId) => (select(
    teamMembersTable,
  )..where((t) => t.id.equals(memberId))).getSingleOrNull();

  // ---------------------------------------------------------------------------
  // ClientAssignments
  // ---------------------------------------------------------------------------

  /// Inserts a client assignment and returns its id.
  Future<String> assignClient(ClientAssignmentsTableCompanion companion) async {
    await into(clientAssignmentsTable).insert(companion);
    return companion.id.value;
  }

  /// Returns all assignments for a given team member, ordered by startDate.
  Future<List<ClientAssignmentsTableData>> getClientsAssignedTo(
    String memberId,
  ) =>
      (select(clientAssignmentsTable)
            ..where((t) => t.assignedToId.equals(memberId))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.startDate,
                mode: OrderingMode.desc,
              ),
            ]))
          .get();

  /// Returns all assignments for a given client.
  Future<List<ClientAssignmentsTableData>> getAssignmentsForClient(
    String clientId,
  ) => (select(
    clientAssignmentsTable,
  )..where((t) => t.clientId.equals(clientId))).get();
}
