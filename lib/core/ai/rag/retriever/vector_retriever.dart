import 'package:ca_app/core/ai/rag/models/rag_context.dart';

/// Abstract interface for vector similarity search.
abstract class VectorRetriever {
  /// Retrieves the top [topK] chunks most similar to [query].
  Future<List<ScoredChunk>> retrieve(String query, {int topK = 5});
}
