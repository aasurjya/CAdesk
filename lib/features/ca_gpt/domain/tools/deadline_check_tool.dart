import 'package:ca_app/features/ca_gpt/domain/services/tax_calendar_service.dart';
import 'package:ca_app/features/ca_gpt/domain/tools/agent_tool.dart';

/// Wraps TaxCalendarService for agent tool calling.
class DeadlineCheckTool implements AgentTool {
  const DeadlineCheckTool();

  @override
  String get name => 'deadline_check';

  @override
  String get description =>
      'Check upcoming tax compliance deadlines within a number of days. '
      'Returns ITR, GST, TDS, and advance tax deadlines.';

  @override
  Map<String, dynamic> get parameters => const {
    'type': 'object',
    'properties': {
      'days_ahead': {
        'type': 'integer',
        'description': 'Number of days to look ahead (default: 30)',
      },
    },
    'required': [],
  };

  @override
  Future<String> execute(Map<String, dynamic> arguments) async {
    final daysAhead = arguments['days_ahead'] as int? ?? 30;
    final now = DateTime.now();
    final fy = now.month >= 4 ? now.year : now.year - 1;

    final deadlines = TaxCalendarService.getUpcomingDeadlines(
      fy,
      now,
      days: daysAhead,
    );

    if (deadlines.isEmpty) {
      return 'No upcoming deadlines in the next $daysAhead days.';
    }

    final buffer = StringBuffer();
    buffer.writeln('Upcoming deadlines (next $daysAhead days):');
    for (final d in deadlines) {
      final daysLeft = d.date.difference(now).inDays;
      buffer.writeln(
        '• ${d.description} — ${d.date.day}/${d.date.month}/${d.date.year} '
        '($daysLeft days, ${d.category})',
      );
    }
    return buffer.toString();
  }
}
