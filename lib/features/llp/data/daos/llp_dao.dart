import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/llp_filings_table.dart';

part 'llp_dao.g.dart';

@DriftAccessor(tables: [LlpFilingsTable])
class LlpDao extends DatabaseAccessor<AppDatabase> with _$LlpDaoMixin {
  LlpDao(super.db);

  // ---------------------------------------------------------------------------
  // Inserts
  // ---------------------------------------------------------------------------

  /// Insert a filing companion and return the row ID.
  Future<String> insertLlpFiling(LlpFilingsTableCompanion companion) async {
    await into(llpFilingsTable).insert(companion);
    final rows =
        await (select(llpFilingsTable)
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

  /// Retrieve all filings for a given client.
  Future<List<LlpFilingsTableData>> getLlpFilingsByClient(String clientId) =>
      (select(llpFilingsTable)
            ..where((t) => t.clientId.equals(clientId))
            ..orderBy([(t) => OrderingTerm(expression: t.dueDate)]))
          .get();

  /// Retrieve filings for a client in a specific financial year.
  Future<List<LlpFilingsTableData>> getLlpFilingsByYear(
    String clientId,
    String year,
  ) =>
      (select(llpFilingsTable)
            ..where(
              (t) => t.clientId.equals(clientId) & t.financialYear.equals(year),
            )
            ..orderBy([(t) => OrderingTerm(expression: t.dueDate)]))
          .get();

  /// Retrieve overdue filings (past due date, not yet filed/approved).
  Future<List<LlpFilingsTableData>> getOverdueLlpFilings() async {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    return (select(llpFilingsTable)
          ..where(
            (t) =>
                t.dueDate.isSmallerThanValue(todayMidnight) &
                t.status.isNotValue('filed') &
                t.status.isNotValue('approved'),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.dueDate)]))
        .get();
  }

  /// Retrieve filings due within [daysAhead] days from today.
  Future<List<LlpFilingsTableData>> getDueLlpFilings(int daysAhead) async {
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    final futureMidnight = todayMidnight.add(Duration(days: daysAhead));
    return (select(llpFilingsTable)
          ..where(
            (t) =>
                t.dueDate.isBetweenValues(todayMidnight, futureMidnight) &
                t.status.isNotValue('filed') &
                t.status.isNotValue('approved'),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.dueDate)]))
        .get();
  }

  /// Retrieve a single filing by ID.
  Future<LlpFilingsTableData?> getLlpFilingById(String id) => (select(
    llpFilingsTable,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  // ---------------------------------------------------------------------------
  // Updates
  // ---------------------------------------------------------------------------

  /// Update the status field for a filing, returning true on success.
  Future<bool> updateLlpFilingStatus(String id, String status) async {
    final count = await (update(llpFilingsTable)..where((t) => t.id.equals(id)))
        .write(
          LlpFilingsTableCompanion(
            status: Value(status),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return count > 0;
  }

  // ---------------------------------------------------------------------------
  // Streams
  // ---------------------------------------------------------------------------

  /// Watch filings for a client (emits on every change).
  Stream<List<LlpFilingsTableData>> watchLlpFilingsByClient(String clientId) =>
      (select(llpFilingsTable)
            ..where((t) => t.clientId.equals(clientId))
            ..orderBy([(t) => OrderingTerm(expression: t.dueDate)]))
          .watch();
}
