import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/mca_table.dart';

part 'mca_dao.g.dart';

@DriftAccessor(tables: [MCAFilingsTable])
class McaDao extends DatabaseAccessor<AppDatabase> with _$McaDaoMixin {
  McaDao(super.db);

  // ---------------------------------------------------------------------------
  // Inserts
  // ---------------------------------------------------------------------------

  /// Insert a filing companion and return the row ID.
  Future<String> insertMCAFiling(MCAFilingsTableCompanion companion) async {
    await into(mCAFilingsTable).insert(companion);
    final rows = await (select(mCAFilingsTable)
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
  Future<List<MCAFilingsTableData>> getMCAFilingsByClient(
    String clientId,
  ) =>
      (select(mCAFilingsTable)
            ..where((t) => t.clientId.equals(clientId))
            ..orderBy([(t) => OrderingTerm(expression: t.dueDate)]))
          .get();

  /// Retrieve filings for a client in a specific financial year.
  Future<List<MCAFilingsTableData>> getMCAFilingsByYear(
    String clientId,
    String year,
  ) =>
      (select(mCAFilingsTable)
            ..where(
              (t) =>
                  t.clientId.equals(clientId) & t.financialYear.equals(year),
            )
            ..orderBy([(t) => OrderingTerm(expression: t.dueDate)]))
          .get();

  /// Retrieve filings by status.
  Future<List<MCAFilingsTableData>> getMCAFilingsByStatus(String status) =>
      (select(mCAFilingsTable)
            ..where((t) => t.status.equals(status))
            ..orderBy([(t) => OrderingTerm(expression: t.dueDate)]))
          .get();

  /// Retrieve filings due within [daysAhead] days from today (excluding already
  /// filed/approved).
  Future<List<MCAFilingsTableData>> getDueMCAFilings(int daysAhead) async {
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    final futureMidnight = todayMidnight.add(Duration(days: daysAhead));

    return (select(mCAFilingsTable)
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
  Future<MCAFilingsTableData?> getMCAFilingById(String id) =>
      (select(mCAFilingsTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  // ---------------------------------------------------------------------------
  // Updates
  // ---------------------------------------------------------------------------

  /// Replace a filing row and return true on success.
  Future<bool> updateMCAFiling(MCAFilingsTableCompanion companion) =>
      update(mCAFilingsTable).replace(companion);

  // ---------------------------------------------------------------------------
  // Streams
  // ---------------------------------------------------------------------------

  /// Watch filings for a client (emits on every change).
  Stream<List<MCAFilingsTableData>> watchMCAFilingsByClient(String clientId) =>
      (select(mCAFilingsTable)
            ..where((t) => t.clientId.equals(clientId))
            ..orderBy([(t) => OrderingTerm(expression: t.dueDate)]))
          .watch();
}
