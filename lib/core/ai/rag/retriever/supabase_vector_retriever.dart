import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ca_app/core/ai/gateway/ai_gateway.dart';
import 'package:ca_app/core/ai/rag/models/chunk.dart';
import 'package:ca_app/core/ai/rag/models/rag_context.dart';
import 'package:ca_app/core/ai/rag/retriever/vector_retriever.dart';

/// pgvector similarity search via Supabase RPC.
class SupabaseVectorRetriever implements VectorRetriever {
  const SupabaseVectorRetriever({
    required this.gateway,
  });

  final AiGateway gateway;

  @override
  Future<List<ScoredChunk>> retrieve(String query, {int topK = 5}) async {
    final queryEmbedding = await gateway.embed(query);
    final client = Supabase.instance.client;

    final response = await client.rpc('match_documents', params: {
      'query_embedding': queryEmbedding,
      'match_count': topK,
      'match_threshold': 0.3,
    });

    final results = response as List<dynamic>;

    return results.map((row) {
      final data = row as Map<String, dynamic>;
      return ScoredChunk(
        chunk: Chunk(
          chunkId: data['chunk_id'] as String? ?? '',
          documentId: data['document_id'] as String? ?? '',
          text: data['content'] as String? ?? '',
          startOffset: 0,
          endOffset: 0,
          section: data['section'] as String?,
          category: data['category'] as String?,
        ),
        score: (data['similarity'] as num?)?.toDouble() ?? 0.0,
        source: data['source'] as String?,
      );
    }).toList();
  }
}
