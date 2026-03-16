import 'chunk.dart';

/// A retrieved chunk with similarity score and citation metadata.
class ScoredChunk {
  const ScoredChunk({
    required this.chunk,
    required this.score,
    this.source,
  });

  final Chunk chunk;
  final double score;
  final String? source;
}

/// The assembled context from RAG retrieval, ready to inject into a prompt.
class RagContext {
  RagContext({
    required List<ScoredChunk> chunks,
    required this.formattedPrompt,
    List<String> citations = const [],
  })  : chunks = List.unmodifiable(chunks),
        citations = List.unmodifiable(citations);

  final List<ScoredChunk> chunks;
  final String formattedPrompt;
  final List<String> citations;

  bool get isEmpty => chunks.isEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RagContext && other.formattedPrompt == formattedPrompt;
  }

  @override
  int get hashCode => formattedPrompt.hashCode;
}
