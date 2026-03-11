import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/tax_advisory/domain/models/advisory_proposal.dart';

/// A card tile displaying a single advisory proposal with fee, scope, status,
/// and relative sent time.
class ProposalTile extends StatelessWidget {
  const ProposalTile({super.key, required this.proposal});

  final AdvisoryProposal proposal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = proposal.status;

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
                      proposal.clientName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(status: status),
                ],
              ),
              const SizedBox(height: 4),

              // Row 2: scope snippet (max 2 lines)
              Text(
                proposal.scope,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Row 3: proposed fee + sent timeAgo
              Row(
                children: [
                  Icon(
                    Icons.currency_rupee_rounded,
                    size: 13,
                    color: AppColors.success,
                  ),
                  Text(
                    proposal.formattedFee,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.schedule_rounded,
                    size: 12,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Sent ${proposal.timeAgo}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),

              // Row 4: accepted date (if applicable)
              if (proposal.acceptedAt != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 12,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Accepted on '
                      '${_formatDate(proposal.acceptedAt!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ProposalStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
