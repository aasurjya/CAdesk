import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/ocr_table.dart';

part 'ocr_dao.g.dart';

@DriftAccessor(tables: [OcrJobsTable])
class OcrDao extends DatabaseAccessor<AppDatabase> with _$OcrDaoMixin {
  OcrDao(super.db);

  Future<void> insert(OcrJobsTableCompanion companion) =>
      into(ocrJobsTable).insertOnConflictUpdate(companion);

  Future<List<OcrJobRow>> getByClient(String clientId) =>
      (select(ocrJobsTable)
            ..where((t) => t.clientId.equals(clientId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<List<OcrJobRow>> getByStatus(String status) =>
      (select(ocrJobsTable)
            ..where((t) => t.status.equals(status))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<bool> updateStatus(
    String id,
    String status, {
    DateTime? completedAt,
    String? errorMessage,
  }) async {
    final count = await (update(ocrJobsTable)..where((t) => t.id.equals(id)))
        .write(
          OcrJobsTableCompanion(
            status: Value(status),
            completedAt: Value(completedAt),
            errorMessage: Value(errorMessage),
          ),
        );
    return count > 0;
  }

  Future<bool> updateParsedData(
    String id,
    String parsedDataJson,
    double confidence,
  ) async {
    final count = await (update(ocrJobsTable)..where((t) => t.id.equals(id)))
        .write(
          OcrJobsTableCompanion(
            parsedData: Value(parsedDataJson),
            confidence: Value(confidence),
          ),
        );
    return count > 0;
  }

  Future<List<OcrJobRow>> getByDocType(String documentType) =>
      (select(ocrJobsTable)
            ..where((t) => t.documentType.equals(documentType))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<int> cleanup(DateTime beforeDate) => (delete(
    ocrJobsTable,
  )..where((t) => t.createdAt.isSmallerThan(Variable(beforeDate)))).go();
}
