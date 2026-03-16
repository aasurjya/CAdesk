import 'package:ca_app/core/ai/rag/pipeline/rag_pipeline.dart';
import 'package:ca_app/features/ca_gpt/domain/tools/agent_tool.dart';

/// RAG search over case law and precedents.
class PrecedentSearchTool implements AgentTool {
  const PrecedentSearchTool({required this.ragPipeline});

  final RagPipeline ragPipeline;

  @override
  String get name => 'precedent_search';

  @override
  String get description =>
      'Search case law and tax tribunal precedents. '
      'Finds relevant judgments for legal arguments and notice replies.';

  @override
  Map<String, dynamic> get parameters => const {
    'type': 'object',
    'properties': {
      'query': {
        'type': 'string',
        'description': 'Legal issue or case reference to search for',
      },
    },
    'required': ['query'],
  };

  @override
  Future<String> execute(Map<String, dynamic> arguments) async {
    final query = arguments['query'] as String? ?? '';
    final context = await ragPipeline.retrieve(query);

    if (context.isEmpty) {
      return 'No matching precedents found for "$query".';
    }

    final buffer = StringBuffer();
    buffer.writeln('Found ${context.chunks.length} relevant precedents:');
    for (var i = 0; i < context.chunks.length; i++) {
      final chunk = context.chunks[i];
      buffer.writeln();
      buffer.writeln('[${i + 1}] ${chunk.source ?? "Precedent"}');
      buffer.writeln('Relevance: ${(chunk.score * 100).toStringAsFixed(1)}%');
      buffer.writeln(chunk.chunk.text);
    }
    return buffer.toString();
  }
}
