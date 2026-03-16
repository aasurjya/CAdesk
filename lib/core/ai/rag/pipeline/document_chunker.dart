import 'package:ca_app/core/ai/rag/models/chunk.dart';

/// Splits documents into overlapping chunks for embedding.
///
/// Default: 512 tokens per chunk, 128 token overlap.
class DocumentChunker {
  const DocumentChunker({
    this.maxTokensPerChunk = 512,
    this.overlapTokens = 128,
  });

  final int maxTokensPerChunk;
  final int overlapTokens;

  /// Characters per token estimate (English text average).
  static const _charsPerToken = 4;

  /// Splits [text] from document [documentId] into overlapping chunks.
  List<Chunk> chunk({
    required String documentId,
    required String text,
    String? section,
    String? category,
  }) {
    if (text.trim().isEmpty) return const [];

    final maxChars = maxTokensPerChunk * _charsPerToken;
    final overlapChars = overlapTokens * _charsPerToken;
    final chunks = <Chunk>[];

    var start = 0;
    var index = 0;

    while (start < text.length) {
      var end = start + maxChars;
      if (end > text.length) {
        end = text.length;
      } else {
        // Try to break at a sentence boundary
        final lastPeriod = text.lastIndexOf('. ', end);
        if (lastPeriod > start + (maxChars ~/ 2)) {
          end = lastPeriod + 1;
        }
      }

      final chunkText = text.substring(start, end).trim();
      if (chunkText.isNotEmpty) {
        chunks.add(
          Chunk(
            chunkId: '${documentId}_chunk_$index',
            documentId: documentId,
            text: chunkText,
            startOffset: start,
            endOffset: end,
            section: section,
            category: category,
          ),
        );
        index++;
      }

      // Advance with overlap
      start = end - overlapChars;
      if (start <= chunks.last.startOffset) {
        // Prevent infinite loop on very small texts
        break;
      }
    }

    return List.unmodifiable(chunks);
  }
}
