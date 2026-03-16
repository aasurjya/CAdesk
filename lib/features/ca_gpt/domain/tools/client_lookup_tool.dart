import 'package:ca_app/features/ca_gpt/domain/tools/agent_tool.dart';

/// Queries client data for context-aware responses.
class ClientLookupTool implements AgentTool {
  const ClientLookupTool();

  @override
  String get name => 'client_lookup';

  @override
  String get description =>
      'Look up client information by name or PAN. '
      'Returns basic profile, filing status, and open notices.';

  @override
  Map<String, dynamic> get parameters => const {
        'type': 'object',
        'properties': {
          'query': {
            'type': 'string',
            'description': 'Client name or PAN to search for',
          },
        },
        'required': ['query'],
      };

  @override
  Future<String> execute(Map<String, dynamic> arguments) async {
    final query = arguments['query'] as String? ?? '';

    // TODO: Wire to ClientsDao when available
    return 'Client lookup for "$query": No client database connected. '
        'This feature requires the clients module to be active.';
  }
}
