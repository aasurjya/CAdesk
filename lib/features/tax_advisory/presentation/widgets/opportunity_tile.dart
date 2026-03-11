import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/tax_advisory/domain/models/advisory_opportunity.dart';

/// A card tile displaying a single advisory opportunity with type icon,
/// priority badge, status chip, and top signals.
class OpportunityTile extends StatelessWidget {
  const OpportunityTile({super.key, required this.opportunity});

  final AdvisoryOpportunity opportunity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final type = opportunity.opportunityType;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leading: type icon
              _TypeIcon(type: type),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: client name + priority badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            opportunity.clientName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _PriorityBadge(priority: opportunity.priority),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Row 2: opportunity title
                    Text(
                      opportunity.title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral600,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Row 3: fee + status chip + timeAgo
                    Row(
                      children: [
                        Icon(
                          Icons.currency_rupee_rounded,
                          size: 12,
                          color: AppColors.success,
                        ),
                        Text(
                          opportunity.formattedFee,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusChip(status: opportunity.status),
                        const Spacer(),
                        Icon(
                          Icons.access_time_rounded,
                          size: 11,
                          color: AppColors.neutral400,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          opportunity.timeAgo,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral400,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),

                    // Row 4: top 2 signal chips (if any)
                    if (opportunity.signals.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: opportunity.signals
                            .take(2)
                            .map((signal) => _SignalChip(signal: signal))
                            .toList(),
                      ),
                    ],
                  ],
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

class _TypeIcon extends StatelessWidget {
  const _TypeIcon({required this.type});

  final OpportunityType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(type.icon, size: 22, color: type.color),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final OpportunityPriority priority;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: priority.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        priority.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: priority.color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final OpportunityStatus status;

  Color get _color {
    switch (status) {
      case OpportunityStatus.new_:
        return AppColors.primary;
      case OpportunityStatus.reviewed:
        return AppColors.secondary;
      case OpportunityStatus.proposalSent:
        return AppColors.accent;
      case OpportunityStatus.converted:
        return AppColors.success;
      case OpportunityStatus.dismissed:
        return AppColors.neutral400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withValues(alpha: 0.25)),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: _color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _SignalChip extends StatelessWidget {
  const _SignalChip({required this.signal});

  final String signal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 5, color: AppColors.neutral400),
          const SizedBox(width: 4),
          Text(
            signal,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.neutral600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
