import 'package:ca_app/core/ai/gateway/ai_gateway.dart';
import 'package:ca_app/core/ai/rag/models/rag_context.dart';
import 'package:ca_app/core/ai/rag/pipeline/context_formatter.dart';
import 'package:ca_app/core/ai/rag/retriever/hybrid_retriever.dart';

/// Orchestrates the RAG pipeline: query → embed → retrieve → rerank → format.
class RagPipeline {
  const RagPipeline({
    required this.gateway,
    required this.retriever,
    this.formatter = const ContextFormatter(),
    this.topK = 5,
    this.minScore = 0.3,
  });

  final AiGateway gateway;
  final HybridRetriever retriever;
  final ContextFormatter formatter;
  final int topK;
  final double minScore;

  /// Retrieves and formats context for the given [query].
  Future<RagContext> retrieve(String query) async {
    final chunks = await retriever.retrieve(query, topK: topK);

    // Filter by minimum relevance score
    final filtered = chunks.where((c) => c.score >= minScore).toList();

    return formatter.format(filtered);
  }

  /// Embeds a single [text] using the gateway's embedding model.
  Future<List<double>> embed(String text) => gateway.embed(text);
}
