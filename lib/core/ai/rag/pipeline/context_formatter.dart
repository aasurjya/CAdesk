import 'package:ca_app/core/ai/rag/models/rag_context.dart';

/// Formats retrieved RAG chunks into a system prompt with numbered citations.
class ContextFormatter {
  const ContextFormatter();

  /// Builds a [RagContext] from scored chunks with citation numbering.
  RagContext format(List<ScoredChunk> chunks) {
    if (chunks.isEmpty) {
      return RagContext(
        chunks: const [],
        formattedPrompt: '',
        citations: const [],
      );
    }

    final buffer = StringBuffer();
    final citations = <String>[];

    buffer.writeln(
      'Use the following reference materials to answer the question.',
    );
    buffer.writeln('Cite sources using [1], [2], etc. notation.');
    buffer.writeln();

    for (var i = 0; i < chunks.length; i++) {
      final chunk = chunks[i];
      final citationNumber = i + 1;
      final source = chunk.source ?? 'Document ${chunk.chunk.documentId}';
      final section = chunk.chunk.section;

      final citationLabel = section != null
          ? '[$citationNumber] $source — $section'
          : '[$citationNumber] $source';

      citations.add(citationLabel);

      buffer.writeln('---');
      buffer.writeln(
        'Source $citationLabel (relevance: '
        '${(chunk.score * 100).toStringAsFixed(1)}%):',
      );
      buffer.writeln(chunk.chunk.text);
      buffer.writeln();
    }

    return RagContext(
      chunks: chunks,
      formattedPrompt: buffer.toString(),
      citations: citations,
    );
  }
}
