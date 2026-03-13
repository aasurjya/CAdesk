import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/itr_filings_table.dart';

part 'itr_filings_dao.g.dart';

@DriftAccessor(tables: [ItrFilingsTable])
class ItrFilingsDao extends DatabaseAccessor<AppDatabase>
    with _$ItrFilingsDaoMixin {
  ItrFilingsDao(super.db);

  Future<List<ItrFilingRow>> getAll(String firmId) =>
      (select(itrFilingsTable)..where((t) => t.firmId.equals(firmId))).get();

  Future<ItrFilingRow?> getById(String id) => (select(
    itrFilingsTable,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsert(ItrFilingsTableCompanion filing) =>
      into(itrFilingsTable).insertOnConflictUpdate(filing);

  Future<void> deleteRecord(String id) =>
      (delete(itrFilingsTable)..where((t) => t.id.equals(id))).go();

  Stream<List<ItrFilingRow>> watchAll(String firmId) =>
      (select(itrFilingsTable)..where((t) => t.firmId.equals(firmId))).watch();

  Future<List<ItrFilingRow>> searchFilings(String firmId, String query) {
    final q = '%${query.toLowerCase()}%';
    return (select(itrFilingsTable)..where(
          (t) =>
              t.firmId.equals(firmId) &
              (t.name.lower().like(q) |
                  t.pan.lower().like(q) |
                  t.assessmentYear.lower().like(q)),
        ))
        .get();
  }

  Future<List<ItrFilingRow>> getByAssessmentYear(
    String firmId,
    String assessmentYear,
  ) =>
      (select(itrFilingsTable)..where(
            (t) =>
                t.firmId.equals(firmId) &
                t.assessmentYear.equals(assessmentYear),
          ))
          .get();

  Future<List<ItrFilingRow>> getDirty() =>
      (select(itrFilingsTable)..where((t) => t.isDirty)).get();

  Future<void> markSynced(String id, DateTime syncedAt) =>
      (update(itrFilingsTable)..where((t) => t.id.equals(id))).write(
        ItrFilingsTableCompanion(
          syncedAt: Value(syncedAt.toIso8601String()),
          isDirty: const Value(false),
        ),
      );
}
