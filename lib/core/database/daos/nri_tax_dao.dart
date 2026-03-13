import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/nri_tax_table.dart';

part 'nri_tax_dao.g.dart';

@DriftAccessor(tables: [NriTaxTable])
class NriTaxDao extends DatabaseAccessor<AppDatabase> with _$NriTaxDaoMixin {
  NriTaxDao(super.db);

  Future<void> insertRecord(NriTaxTableCompanion companion) =>
      into(nriTaxTable).insertOnConflictUpdate(companion);

  Future<List<NriTaxRow>> getByClient(String clientId) =>
      (select(nriTaxTable)..where((t) => t.clientId.equals(clientId))).get();

  Future<List<NriTaxRow>> getByYear(String assessmentYear) => (select(
    nriTaxTable,
  )..where((t) => t.assessmentYear.equals(assessmentYear))).get();

  Future<bool> updateStatus(String id, String status) async {
    final rowsUpdated = await (update(nriTaxTable)
          ..where((t) => t.id.equals(id)))
        .write(
          NriTaxTableCompanion(
            status: Value(status),
            updatedAt: Value(DateTime.now()),
            isDirty: const Value(true),
          ),
        );
    return rowsUpdated > 0;
  }

  Future<List<NriTaxRow>> getScheduleFARequired() => (select(
    nriTaxTable,
  )..where((t) => t.scheduleFA.equals(true))).get();

  Future<NriTaxRow?> getById(String id) =>
      (select(nriTaxTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> deleteRecord(String id) =>
      (delete(nriTaxTable)..where((t) => t.id.equals(id))).go();

  Future<List<NriTaxRow>> getDirty() =>
      (select(nriTaxTable)..where((t) => t.isDirty)).get();

  Future<void> markSynced(String id, DateTime syncedAt) =>
      (update(nriTaxTable)..where((t) => t.id.equals(id))).write(
        NriTaxTableCompanion(
          syncedAt: Value(syncedAt.toIso8601String()),
          isDirty: const Value(false),
        ),
      );
}
