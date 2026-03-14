import 'package:drift/drift.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/core/database/tables/documents_table.dart';

part 'documents_dao.g.dart';

@DriftAccessor(tables: [DocumentsTable])
class DocumentsDao extends DatabaseAccessor<AppDatabase>
    with _$DocumentsDaoMixin {
  DocumentsDao(super.db);

  /// Insert a new document and return its ID
  Future<String> insertDocument(DocumentsTableCompanion companion) async {
    await into(documentsTable).insert(companion);
    final rows =
        await (select(documentsTable)
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

  /// Get all documents for a client
  Future<List<DocumentRow>> getDocumentsByClient(String clientId) =>
      (select(documentsTable)..where((t) => t.clientId.equals(clientId))).get();

  /// Watch documents for a client
  Stream<List<DocumentRow>> watchDocumentsByClient(String clientId) => (select(
    documentsTable,
  )..where((t) => t.clientId.equals(clientId))).watch();

  /// Get all documents of a specific category
  Future<List<DocumentRow>> getDocumentsByCategory(String category) =>
      (select(documentsTable)..where((t) => t.category.equals(category))).get();

  /// Get a document by ID
  Future<DocumentRow?> getDocumentById(String documentId) => (select(
    documentsTable,
  )..where((t) => t.id.equals(documentId))).getSingleOrNull();

  /// Update a document
  Future<bool> updateDocument(DocumentsTableCompanion companion) =>
      update(documentsTable).replace(companion);

  /// Delete a document
  Future<bool> deleteDocument(String documentId) async {
    final result = await (delete(
      documentsTable,
    )..where((t) => t.id.equals(documentId))).go();
    return result > 0;
  }

  /// Search documents by title or tags
  Future<List<DocumentRow>> searchDocuments(String query) {
    final q = '%${query.toLowerCase()}%';
    return (select(
      documentsTable,
    )..where((t) => t.title.like(q) | t.tags.like(q))).get();
  }
}
