import 'package:ca_app/features/ca_gpt/domain/services/notice_drafting_service.dart';
import 'package:ca_app/features/ca_gpt/domain/tools/agent_tool.dart';

/// Wraps NoticeDraftingService for agent tool calling.
class NoticeDraftingTool implements AgentTool {
  const NoticeDraftingTool();

  @override
  String get name => 'notice_drafting';

  @override
  String get description =>
      'Draft a reply to an income tax notice. Supports 143(1), 143(3), '
      'appeal, rectification, condonation, penalty, and revision notices.';

  @override
  Map<String, dynamic> get parameters => const {
    'type': 'object',
    'properties': {
      'notice_type': {
        'type': 'string',
        'description':
            'Type of notice: 143_1, 143_3, appeal, rectification, '
            'condonation, penalty, revision',
      },
      'taxpayer_name': {'type': 'string', 'description': 'Name of taxpayer'},
      'pan': {'type': 'string', 'description': 'PAN of taxpayer'},
      'assessment_year': {
        'type': 'string',
        'description': 'Assessment year (e.g., 2025-26)',
      },
      'grounds': {
        'type': 'string',
        'description': 'Grounds of appeal or reply (comma-separated)',
      },
    },
    'required': ['notice_type'],
  };

  @override
  Future<String> execute(Map<String, dynamic> arguments) async {
    final noticeType = arguments['notice_type'] as String? ?? '143_1';
    final facts = <String, String>{
      'taxpayerName': arguments['taxpayer_name'] as String? ?? '[Taxpayer]',
      'pan': arguments['pan'] as String? ?? '[PAN]',
      'assessmentYear': arguments['assessment_year'] as String? ?? '2025-26',
      'groundsOfAppeal': arguments['grounds'] as String? ?? '',
      'reliefSought': 'As per grounds stated above',
    };

    final draft = NoticeDraftingService.draftReply(noticeType, facts);
    return 'Notice Draft (${draft.noticeType.name}):\n\n${draft.draftText}';
  }
}
