import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/fee_leakage/domain/models/engagement.dart';

/// A card tile displaying a single engagement with leakage and utilization.
class EngagementTile extends StatelessWidget {
  const EngagementTile({super.key, required this.engagement});

  final Engagement engagement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final leakageColor = engagement.leakageAmount > 0
        ? AppColors.error
        : AppColors.success;

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
              // Row 1: client name + status badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      engagement.clientName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(status: engagement.status),
                ],
              ),
              const SizedBox(height: 4),

              // Row 2: service type
              Text(
                engagement.serviceType,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
              const SizedBox(height: 10),

              // Row 3: leakage amount + utilization bar
              Row(
                children: [
                  // Leakage
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Leakage',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        engagement.formattedLeakage,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: leakageColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Utilization bar
                  Expanded(
                    child: _UtilizationBar(engagement: engagement),
                  ),
                ],
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final EngagementStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 11, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: status.color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _UtilizationBar extends StatelessWidget {
  const _UtilizationBar({required this.engagement});

  final Engagement engagement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = engagement.utilizationPct.clamp(0.0, 150.0);
    final displayPct = pct.clamp(0.0, 100.0);
    final isOver = engagement.isOverScope;
    final barColor = isOver ? AppColors.error : AppColors.success;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Utilisation',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
            Text(
              '${engagement.actualHours.toStringAsFixed(0)}h / '
              '${engagement.budgetHours.toStringAsFixed(0)}h '
              '(${pct.toStringAsFixed(0)}%)',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isOver ? AppColors.error : AppColors.neutral600,
                fontWeight: isOver ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: displayPct / 100,
            backgroundColor: AppColors.neutral200,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
