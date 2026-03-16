import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/ca_gpt/domain/models/tax_citation.dart';

/// A tappable citation chip linking to the source document.
class CitationChip extends StatelessWidget {
  const CitationChip({super.key, required this.citation});

  final TaxCitation citation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: citation.summary,
      child: InkWell(
        onTap: citation.url != null ? () => _openSource(context) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.secondary.withAlpha(14),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.secondary.withAlpha(50)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _iconForType(citation.type),
                size: 14,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 4),
              Text(
                citation.reference,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSource(BuildContext context) {
    // TODO: Navigate to source document or open external URL
  }

  IconData _iconForType(CitationType type) {
    return switch (type) {
      CitationType.section => Icons.gavel_rounded,
      CitationType.rule => Icons.rule_rounded,
      CitationType.circular => Icons.description_outlined,
      CitationType.notification => Icons.notifications_outlined,
      CitationType.caselaw => Icons.balance_rounded,
      CitationType.cbdtInstruction => Icons.policy_rounded,
    };
  }
}
