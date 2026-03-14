import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/vda_records_table.dart';

part 'vda_dao.g.dart';

@DriftAccessor(tables: [VdaRecordsTable])
class VdaDao extends DatabaseAccessor<AppDatabase> with _$VdaDaoMixin {
  VdaDao(super.db);

  Future<void> insertRecord(VdaRecordsTableCompanion companion) =>
      into(vdaRecordsTable).insertOnConflictUpdate(companion);

  Future<List<VdaRecordRow>> getByClient(String clientId) => (select(
    vdaRecordsTable,
  )..where((t) => t.clientId.equals(clientId))).get();

  Future<List<VdaRecordRow>> getByYear(String assessmentYear) => (select(
    vdaRecordsTable,
  )..where((t) => t.assessmentYear.equals(assessmentYear))).get();

  /// Computes total gain/loss for a client in a given assessment year.
  Future<double> getTotalGainLoss(
    String clientId,
    String assessmentYear,
  ) async {
    final rows =
        await (select(vdaRecordsTable)..where(
              (t) =>
                  t.clientId.equals(clientId) &
                  t.assessmentYear.equals(assessmentYear),
            ))
            .get();
    var total = 0.0;
    for (final r in rows) {
      total += r.gainLoss;
    }
    return total;
  }

  /// Computes total TDS deducted for a client in a given assessment year.
  Future<double> getTdsDeducted(String clientId, String assessmentYear) async {
    final rows =
        await (select(vdaRecordsTable)..where(
              (t) =>
                  t.clientId.equals(clientId) &
                  t.assessmentYear.equals(assessmentYear),
            ))
            .get();
    var total = 0.0;
    for (final r in rows) {
      total += r.tdsDeducted;
    }
    return total;
  }

  Future<VdaRecordRow?> getById(String id) => (select(
    vdaRecordsTable,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> deleteRecord(String id) =>
      (delete(vdaRecordsTable)..where((t) => t.id.equals(id))).go();

  Future<List<VdaRecordRow>> getDirty() =>
      (select(vdaRecordsTable)..where((t) => t.isDirty)).get();

  Future<void> markSynced(String id, DateTime syncedAt) =>
      (update(vdaRecordsTable)..where((t) => t.id.equals(id))).write(
        VdaRecordsTableCompanion(
          syncedAt: Value(syncedAt.toIso8601String()),
          isDirty: const Value(false),
        ),
      );
}
