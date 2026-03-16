import 'package:ca_app/core/ai/rag/pipeline/rag_pipeline.dart';
import 'package:ca_app/features/ca_gpt/domain/tools/agent_tool.dart';

/// RAG search over regulatory circulars.
class CircularSearchTool implements AgentTool {
  const CircularSearchTool({required this.ragPipeline});

  final RagPipeline ragPipeline;

  @override
  String get name => 'circular_search';

  @override
  String get description =>
      'Search CBDT/GSTN circulars and notifications for specific topics. '
      'Uses semantic search over the regulatory circular database.';

  @override
  Map<String, dynamic> get parameters => const {
    'type': 'object',
    'properties': {
      'query': {
        'type': 'string',
        'description': 'Topic or circular number to search for',
      },
    },
    'required': ['query'],
  };

  @override
  Future<String> execute(Map<String, dynamic> arguments) async {
    final query = arguments['query'] as String? ?? '';
    final context = await ragPipeline.retrieve(query);

    if (context.isEmpty) {
      return 'No matching circulars found for "$query".';
    }

    final buffer = StringBuffer();
    buffer.writeln('Found ${context.chunks.length} relevant circulars:');
    for (var i = 0; i < context.chunks.length; i++) {
      final chunk = context.chunks[i];
      buffer.writeln();
      buffer.writeln('[${i + 1}] ${chunk.source ?? "Circular"}');
      buffer.writeln('Relevance: ${(chunk.score * 100).toStringAsFixed(1)}%');
      buffer.writeln(chunk.chunk.text);
    }
    return buffer.toString();
  }
}
