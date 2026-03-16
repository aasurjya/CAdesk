import 'package:drift/drift.dart';

/// Drift table for caching embeddings locally for offline access.
///
/// Stores the vector as a JSON-encoded list of doubles.
class EmbeddingCacheTable extends Table {
  @override
  String get tableName => 'embedding_cache';

  TextColumn get chunkId => text().named('chunk_id')();
  TextColumn get documentId => text().named('document_id')();
  TextColumn get content => text()();
  TextColumn get vectorJson => text().named('vector_json')();
  TextColumn get section => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get source => text().nullable()();
  DateTimeColumn get cachedAt =>
      dateTime().named('cached_at').withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {chunkId};
}
