import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/tp_transactions_table.dart';

part 'tp_dao.g.dart';

@DriftAccessor(tables: [TpTransactionsTable])
class TpDao extends DatabaseAccessor<AppDatabase> with _$TpDaoMixin {
  TpDao(super.db);

  Future<void> insertTransaction(TpTransactionsTableCompanion companion) =>
      into(tpTransactionsTable).insertOnConflictUpdate(companion);

  Future<List<TpTransactionRow>> getByClient(String clientId) => (select(
    tpTransactionsTable,
  )..where((t) => t.clientId.equals(clientId))).get();

  Future<List<TpTransactionRow>> getByYear(String assessmentYear) => (select(
    tpTransactionsTable,
  )..where((t) => t.assessmentYear.equals(assessmentYear))).get();

  Future<bool> updateStatus(String id, String status) async {
    final rowsUpdated =
        await (update(
          tpTransactionsTable,
        )..where((t) => t.id.equals(id))).write(
          TpTransactionsTableCompanion(
            status: Value(status),
            updatedAt: Value(DateTime.now()),
            isDirty: const Value(true),
          ),
        );
    return rowsUpdated > 0;
  }

  Future<List<TpTransactionRow>> getByMethod(String tpMethod) => (select(
    tpTransactionsTable,
  )..where((t) => t.tpMethod.equals(tpMethod))).get();

  Future<TpTransactionRow?> getById(String id) => (select(
    tpTransactionsTable,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> deleteTransaction(String id) =>
      (delete(tpTransactionsTable)..where((t) => t.id.equals(id))).go();

  Future<List<TpTransactionRow>> getDirty() =>
      (select(tpTransactionsTable)..where((t) => t.isDirty)).get();

  Future<void> markSynced(String id, DateTime syncedAt) =>
      (update(tpTransactionsTable)..where((t) => t.id.equals(id))).write(
        TpTransactionsTableCompanion(
          syncedAt: Value(syncedAt.toIso8601String()),
          isDirty: const Value(false),
        ),
      );
}
