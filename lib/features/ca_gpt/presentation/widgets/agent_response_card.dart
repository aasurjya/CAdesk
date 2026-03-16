import 'package:flutter/material.dart';

import 'package:ca_app/core/ai/models/ai_tool_call.dart';
import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/ca_gpt/domain/models/tax_citation.dart';
import 'package:ca_app/features/ca_gpt/presentation/widgets/citation_chip.dart';
import 'package:ca_app/features/ca_gpt/presentation/widgets/tool_execution_card.dart';

/// Rich chat response card: text + citations + tool traces + action suggestions.
class AgentResponseCard extends StatelessWidget {
  const AgentResponseCard({
    super.key,
    required this.text,
    this.citations = const [],
    this.toolCalls = const [],
  });

  final String text;
  final List<TaxCitation> citations;
  final List<AiToolCall> toolCalls;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tool traces (collapsible)
        if (toolCalls.isNotEmpty) ...[
          ToolExecutionCard(toolCalls: toolCalls),
          const SizedBox(height: 8),
        ],

        // Main response text
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.neutral900,
            height: 1.5,
          ),
        ),

        // Citations
        if (citations.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: citations.map((c) => CitationChip(citation: c)).toList(),
          ),
        ],
      ],
    );
  }
}
