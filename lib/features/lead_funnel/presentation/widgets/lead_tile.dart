import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/lead_funnel/domain/models/lead.dart';

/// A card tile displaying a single lead with stage badge and key metrics.
class LeadTile extends StatelessWidget {
  const LeadTile({super.key, required this.lead});

  final Lead lead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = lead.daysSinceContact;
    final overdue = days != null && days > 7;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: source icon + name + stage badge
              Row(
                children: [
                  Icon(lead.source.icon, size: 18, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      lead.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StageBadge(stage: lead.stage),
                ],
              ),
              const SizedBox(height: 4),

              // Row 2: phone
              Text(
                lead.phone,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
              const SizedBox(height: 8),

              // Row 3: value, assigned to, contact warning
              Row(
                children: [
                  // Estimated value
                  Icon(
                    Icons.currency_rupee_rounded,
                    size: 13,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    lead.formattedValue,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Assigned to
                  Icon(
                    Icons.person_outline_rounded,
                    size: 12,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      lead.assignedTo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral400,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Contact warning
                  if (overdue) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 13,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${days}d ago',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ] else if (days != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: AppColors.neutral400,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${days}d ago',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(width: 8),
                    Text(
                      'Not contacted',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.neutral300,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),

              // Source label
              const SizedBox(height: 4),
              Text(
                lead.source.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral400,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _StageBadge extends StatelessWidget {
  const _StageBadge({required this.stage});

  final LeadStage stage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: stage.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(stage.icon, size: 11, color: stage.color),
          const SizedBox(width: 3),
          Text(
            stage.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: stage.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
