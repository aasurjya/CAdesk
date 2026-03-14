import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/tax_notices_table.dart';

part 'tax_notices_dao.g.dart';

@DriftAccessor(tables: [TaxNoticesTable])
class TaxNoticesDao extends DatabaseAccessor<AppDatabase>
    with _$TaxNoticesDaoMixin {
  TaxNoticesDao(super.db);

  Future<void> insertNotice(TaxNoticesTableCompanion companion) =>
      into(taxNoticesTable).insertOnConflictUpdate(companion);

  Future<List<TaxNoticeRow>> getByClient(String clientId) => (select(
    taxNoticesTable,
  )..where((t) => t.clientId.equals(clientId))).get();

  Future<List<TaxNoticeRow>> getByType(String noticeType) => (select(
    taxNoticesTable,
  )..where((t) => t.noticeType.equals(noticeType))).get();

  Future<List<TaxNoticeRow>> getByStatus(String status) =>
      (select(taxNoticesTable)..where((t) => t.status.equals(status))).get();

  Future<bool> updateStatus(String id, String status) async {
    final rowsUpdated =
        await (update(taxNoticesTable)..where((t) => t.id.equals(id))).write(
          TaxNoticesTableCompanion(
            status: Value(status),
            updatedAt: Value(DateTime.now()),
            isDirty: const Value(true),
          ),
        );
    return rowsUpdated > 0;
  }

  /// Returns all notices where [dueDate] < [asOf] and status is NOT disposed.
  Future<List<TaxNoticeRow>> getOverdue(DateTime asOf) async {
    final asOfStr = asOf.toIso8601String();
    final allNonDisposed = await (select(
      taxNoticesTable,
    )..where((t) => t.status.isNotValue('disposed'))).get();
    return allNonDisposed
        .where((r) => r.dueDate.compareTo(asOfStr) < 0)
        .toList();
  }

  Future<TaxNoticeRow?> getById(String id) => (select(
    taxNoticesTable,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> deleteNotice(String id) =>
      (delete(taxNoticesTable)..where((t) => t.id.equals(id))).go();

  Future<List<TaxNoticeRow>> getDirty() =>
      (select(taxNoticesTable)..where((t) => t.isDirty)).get();

  Future<void> markSynced(String id, DateTime syncedAt) =>
      (update(taxNoticesTable)..where((t) => t.id.equals(id))).write(
        TaxNoticesTableCompanion(
          syncedAt: Value(syncedAt.toIso8601String()),
          isDirty: const Value(false),
        ),
      );
}
