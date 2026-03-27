import 'package:flutter/material.dart';

import 'package:ca_app/core/ai/models/ai_tool_call.dart';
import 'package:ca_app/core/theme/app_colors.dart';

/// A collapsible card showing the agent's tool execution trace.
class ToolExecutionCard extends StatefulWidget {
  const ToolExecutionCard({super.key, required this.toolCalls});

  final List<AiToolCall> toolCalls;

  @override
  State<ToolExecutionCard> createState() => _ToolExecutionCardState();
}

class _ToolExecutionCardState extends State<ToolExecutionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.build_circle_outlined,
                    size: 16,
                    color: AppColors.neutral600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.toolCalls.length} tool${widget.toolCalls.length == 1 ? "" : "s"} used',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.neutral600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 18,
                    color: AppColors.neutral400,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            for (final call in widget.toolCalls) _ToolCallRow(call: call),
          ],
        ],
      ),
    );
  }
}

class _ToolCallRow extends StatelessWidget {
  const _ToolCallRow({required this.call});

  final AiToolCall call;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(16),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  call.toolName,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (call.result != null)
                const Icon(
                  Icons.check_circle,
                  size: 14,
                  color: AppColors.success,
                ),
            ],
          ),
          if (call.result != null) ...[
            const SizedBox(height: 6),
            Text(
              call.result!.length > 200
                  ? '${call.result!.substring(0, 200)}...'
                  : call.result!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral600,
                height: 1.4,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
