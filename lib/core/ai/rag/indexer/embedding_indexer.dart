import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ca_app/core/ai/gateway/ai_gateway.dart';
import 'package:ca_app/core/ai/rag/pipeline/document_chunker.dart';

/// Batch-embeds documents and upserts them to the pgvector store.
class EmbeddingIndexer {
  const EmbeddingIndexer({
    required this.gateway,
    this.chunker = const DocumentChunker(),
  });

  final AiGateway gateway;
  final DocumentChunker chunker;

  /// Chunks and embeds a document, then upserts to Supabase.
  ///
  /// Returns the number of chunks indexed.
  Future<int> indexDocument({
    required String documentId,
    required String text,
    String? section,
    String? category,
    String? source,
  }) async {
    final chunks = chunker.chunk(
      documentId: documentId,
      text: text,
      section: section,
      category: category,
    );

    if (chunks.isEmpty) return 0;

    final client = Supabase.instance.client;

    for (final chunk in chunks) {
      final embedding = await gateway.embed(chunk.text);

      await client.from('ai_embeddings').upsert({
        'chunk_id': chunk.chunkId,
        'document_id': chunk.documentId,
        'content': chunk.text,
        'embedding': embedding,
        'section': chunk.section,
        'category': chunk.category,
        'source': source,
        'metadata': {
          'start_offset': chunk.startOffset,
          'end_offset': chunk.endOffset,
          'token_estimate': chunk.tokenEstimate,
        },
      }, onConflict: 'chunk_id');
    }

    return chunks.length;
  }

  /// Indexes multiple documents in batch.
  Future<int> indexBatch(List<DocumentInput> documents) async {
    var totalChunks = 0;
    for (final doc in documents) {
      totalChunks += await indexDocument(
        documentId: doc.documentId,
        text: doc.text,
        section: doc.section,
        category: doc.category,
        source: doc.source,
      );
    }
    return totalChunks;
  }
}

/// Input for batch indexing.
class DocumentInput {
  const DocumentInput({
    required this.documentId,
    required this.text,
    this.section,
    this.category,
    this.source,
  });

  final String documentId;
  final String text;
  final String? section;
  final String? category;
  final String? source;
}
