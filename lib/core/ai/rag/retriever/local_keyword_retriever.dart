import 'package:ca_app/core/ai/rag/models/chunk.dart';
import 'package:ca_app/core/ai/rag/models/rag_context.dart';
import 'package:ca_app/core/ai/rag/retriever/vector_retriever.dart';
import 'package:ca_app/features/ca_gpt/domain/services/section_lookup_service.dart';

/// BM25-inspired keyword retrieval using the existing SectionLookupService.
///
/// Falls back to this when vector search is unavailable (offline, no embeddings).
class LocalKeywordRetriever implements VectorRetriever {
  const LocalKeywordRetriever();

  @override
  Future<List<ScoredChunk>> retrieve(String query, {int topK = 5}) async {
    final articles = SectionLookupService.lookupSection(query);

    final scored = <ScoredChunk>[];

    for (var i = 0; i < articles.length && i < topK; i++) {
      final article = articles[i];
      // Simple relevance scoring based on position
      final score = 1.0 - (i * 0.1);

      scored.add(
        ScoredChunk(
          chunk: Chunk(
            chunkId: '${article.articleId}_full',
            documentId: article.articleId,
            text: article.content,
            startOffset: 0,
            endOffset: article.content.length,
            section: article.sections.isNotEmpty
                ? article.sections.first
                : null,
            category: article.category.name,
          ),
          score: score.clamp(0.0, 1.0),
          source: article.title,
        ),
      );
    }

    return scored;
  }
}
