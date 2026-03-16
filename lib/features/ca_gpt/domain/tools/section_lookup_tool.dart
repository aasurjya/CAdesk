import 'package:ca_app/features/ca_gpt/domain/services/section_lookup_service.dart';
import 'package:ca_app/features/ca_gpt/domain/tools/agent_tool.dart';

/// Wraps SectionLookupService for agent tool calling.
class SectionLookupTool implements AgentTool {
  const SectionLookupTool();

  @override
  String get name => 'section_lookup';

  @override
  String get description =>
      'Look up an Indian tax section by number or keyword. '
      'Returns matching provisions from the Income Tax Act, GST Act, etc.';

  @override
  Map<String, dynamic> get parameters => const {
    'type': 'object',
    'properties': {
      'query': {
        'type': 'string',
        'description':
            'Section number (e.g., "194C") or keyword (e.g., "presumptive taxation")',
      },
    },
    'required': ['query'],
  };

  @override
  Future<String> execute(Map<String, dynamic> arguments) async {
    final query = arguments['query'] as String? ?? '';
    final results = SectionLookupService.lookupSection(query);

    if (results.isEmpty) {
      return 'No matching sections found for "$query".';
    }

    final buffer = StringBuffer();
    for (final article in results) {
      buffer.writeln(article.title);
      buffer.writeln('Sections: ${article.sections.join(", ")}');
      buffer.writeln(article.content);
      buffer.writeln();
    }
    return buffer.toString();
  }
}
