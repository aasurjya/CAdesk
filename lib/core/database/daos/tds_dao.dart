import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/tds_returns_table.dart';
import 'package:ca_app/core/database/tables/tds_challans_table.dart';

part 'tds_dao.g.dart';

@DriftAccessor(tables: [TdsReturnsTable, TdsChallansTable])
class TdsDao extends DatabaseAccessor<AppDatabase> with _$TdsDaoMixin {
  TdsDao(super.db);

  // --- TdsReturns ---

  Future<List<TdsReturnRow>> getAllReturns(String firmId) =>
      (select(tdsReturnsTable)..where((t) => t.firmId.equals(firmId))).get();

  Future<TdsReturnRow?> getReturnById(String id) => (select(
    tdsReturnsTable,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<TdsReturnRow>> getReturnsByFY(String firmId, String fy) =>
      (select(
            tdsReturnsTable,
          )..where((t) => t.firmId.equals(firmId) & t.financialYear.equals(fy)))
          .get();

  Future<List<TdsReturnRow>> getReturnsByDeductorId(String deductorId) =>
      (select(
        tdsReturnsTable,
      )..where((t) => t.deductorId.equals(deductorId))).get();

  Future<void> upsertReturn(TdsReturnsTableCompanion tdsReturn) =>
      into(tdsReturnsTable).insertOnConflictUpdate(tdsReturn);

  Future<void> deleteReturn(String id) =>
      (delete(tdsReturnsTable)..where((t) => t.id.equals(id))).go();

  Stream<List<TdsReturnRow>> watchAllReturns(String firmId) =>
      (select(tdsReturnsTable)..where((t) => t.firmId.equals(firmId))).watch();

  Future<List<TdsReturnRow>> getDirtyReturns() =>
      (select(tdsReturnsTable)..where((t) => t.isDirty)).get();

  Future<void> markReturnSynced(String id, DateTime syncedAt) =>
      (update(tdsReturnsTable)..where((t) => t.id.equals(id))).write(
        TdsReturnsTableCompanion(
          syncedAt: Value(syncedAt.toIso8601String()),
          isDirty: const Value(false),
        ),
      );

  // --- TdsChallans ---

  Future<List<TdsChallanRow>> getAllChallans(String firmId) =>
      (select(tdsChallansTable)..where((t) => t.firmId.equals(firmId))).get();

  Future<TdsChallanRow?> getChallanById(String id) => (select(
    tdsChallansTable,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<TdsChallanRow>> getChallansByDeductorId(String deductorId) =>
      (select(
        tdsChallansTable,
      )..where((t) => t.deductorId.equals(deductorId))).get();

  Future<void> upsertChallan(TdsChallansTableCompanion challan) =>
      into(tdsChallansTable).insertOnConflictUpdate(challan);

  Future<void> deleteChallan(String id) =>
      (delete(tdsChallansTable)..where((t) => t.id.equals(id))).go();

  Stream<List<TdsChallanRow>> watchAllChallans(String firmId) =>
      (select(tdsChallansTable)..where((t) => t.firmId.equals(firmId))).watch();

  Future<List<TdsChallanRow>> getDirtyChallans() =>
      (select(tdsChallansTable)..where((t) => t.isDirty)).get();

  Future<void> markChallanSynced(String id, DateTime syncedAt) =>
      (update(tdsChallansTable)..where((t) => t.id.equals(id))).write(
        TdsChallansTableCompanion(
          syncedAt: Value(syncedAt.toIso8601String()),
          isDirty: const Value(false),
        ),
      );
}
