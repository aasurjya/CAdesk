import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/sebi_compliance_table.dart';

part 'sebi_dao.g.dart';

@DriftAccessor(tables: [SebiComplianceTable])
class SebiDao extends DatabaseAccessor<AppDatabase> with _$SebiDaoMixin {
  SebiDao(super.db);

  // ---------------------------------------------------------------------------
  // Inserts
  // ---------------------------------------------------------------------------

  /// Insert a compliance companion and return the row ID.
  Future<String> insertSebiCompliance(
    SebiComplianceTableCompanion companion,
  ) async {
    await into(sebiComplianceTable).insert(companion);
    final rows =
        await (select(sebiComplianceTable)
              ..orderBy([
                (t) => OrderingTerm(
                  expression: t.createdAt,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .get();
    return rows.isNotEmpty ? rows.first.id : '';
  }

  // ---------------------------------------------------------------------------
  // Reads
  // ---------------------------------------------------------------------------

  /// Retrieve all records for a given client.
  Future<List<SebiComplianceTableData>> getSebiComplianceByClient(
    String clientId,
  ) =>
      (select(sebiComplianceTable)
            ..where((t) => t.clientId.equals(clientId))
            ..orderBy([(t) => OrderingTerm(expression: t.dueDate)]))
          .get();

  /// Retrieve records by compliance type.
  Future<List<SebiComplianceTableData>> getSebiComplianceByType(
    String complianceType,
  ) =>
      (select(sebiComplianceTable)
            ..where((t) => t.complianceType.equals(complianceType))
            ..orderBy([(t) => OrderingTerm(expression: t.dueDate)]))
          .get();

  /// Retrieve overdue records (past due date, not yet filed).
  Future<List<SebiComplianceTableData>> getOverdueSebiCompliance() async {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    return (select(sebiComplianceTable)
          ..where(
            (t) =>
                t.dueDate.isSmallerThanValue(todayMidnight) &
                t.status.isNotValue('filed') &
                t.status.isNotValue('exempted'),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.dueDate)]))
        .get();
  }

  /// Retrieve a single record by ID.
  Future<SebiComplianceTableData?> getSebiComplianceById(String id) => (select(
    sebiComplianceTable,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  // ---------------------------------------------------------------------------
  // Updates
  // ---------------------------------------------------------------------------

  /// Update the status field, returning true on success.
  Future<bool> updateSebiComplianceStatus(String id, String status) async {
    final count =
        await (update(
          sebiComplianceTable,
        )..where((t) => t.id.equals(id))).write(
          SebiComplianceTableCompanion(
            status: Value(status),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return count > 0;
  }

  // ---------------------------------------------------------------------------
  // Streams
  // ---------------------------------------------------------------------------

  /// Watch records for a client (emits on every change).
  Stream<List<SebiComplianceTableData>> watchSebiComplianceByClient(
    String clientId,
  ) =>
      (select(sebiComplianceTable)
            ..where((t) => t.clientId.equals(clientId))
            ..orderBy([(t) => OrderingTerm(expression: t.dueDate)]))
          .watch();
}
