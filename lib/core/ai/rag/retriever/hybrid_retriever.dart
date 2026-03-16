import 'package:ca_app/core/ai/rag/models/rag_context.dart';
import 'package:ca_app/core/ai/rag/retriever/vector_retriever.dart';

/// Combines vector + keyword retrievers, deduplicates, and reranks.
class HybridRetriever implements VectorRetriever {
  const HybridRetriever({
    required this.vectorRetriever,
    required this.keywordRetriever,
    this.vectorWeight = 0.7,
    this.keywordWeight = 0.3,
  });

  final VectorRetriever vectorRetriever;
  final VectorRetriever keywordRetriever;
  final double vectorWeight;
  final double keywordWeight;

  @override
  Future<List<ScoredChunk>> retrieve(String query, {int topK = 5}) async {
    // Run both retrievers in parallel
    final results = await Future.wait([
      vectorRetriever.retrieve(query, topK: topK),
      keywordRetriever.retrieve(query, topK: topK),
    ]);

    final vectorResults = results[0];
    final keywordResults = results[1];

    // Merge and deduplicate by chunkId
    final merged = <String, ScoredChunk>{};

    for (final chunk in vectorResults) {
      final key = chunk.chunk.chunkId;
      final weightedScore = chunk.score * vectorWeight;
      merged[key] = ScoredChunk(
        chunk: chunk.chunk,
        score: weightedScore,
        source: chunk.source,
      );
    }

    for (final chunk in keywordResults) {
      final key = chunk.chunk.chunkId;
      if (merged.containsKey(key)) {
        // Combine scores (reciprocal rank fusion)
        final existing = merged[key]!;
        merged[key] = ScoredChunk(
          chunk: existing.chunk,
          score: existing.score + (chunk.score * keywordWeight),
          source: existing.source ?? chunk.source,
        );
      } else {
        merged[key] = ScoredChunk(
          chunk: chunk.chunk,
          score: chunk.score * keywordWeight,
          source: chunk.source,
        );
      }
    }

    // Sort by combined score descending, take topK
    final sorted = merged.values.toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    return sorted.take(topK).toList();
  }
}
