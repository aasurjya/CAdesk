import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/renewal_expiry/domain/models/retainer_contract.dart';

/// A card tile displaying a single retainer contract.
class RetainerContractTile extends StatelessWidget {
  const RetainerContractTile({super.key, required this.contract});

  final RetainerContract contract;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');

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
              // Leading retainer icon
              _RetainerIcon(status: contract.status),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: client name and status badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            contract.clientName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(status: contract.status),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Row 2: service scope
                    Text(
                      contract.serviceScope,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Row 3: fees row
                    Row(
                      children: [
                        _FeeTag(
                          label: contract.formattedMonthlyFee,
                          sublabel: '/month',
                        ),
                        const SizedBox(width: 8),
                        _FeeTag(
                          label: contract.formattedAnnualValue,
                          sublabel: '/year',
                          muted: true,
                        ),
                        const Spacer(),
                        if (contract.autoRenew) ...[
                          Icon(
                            Icons.autorenew_rounded,
                            size: 14,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Auto-renew',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Row 4: end date and days indicator
                    Row(
                      children: [
                        Icon(
                          Icons.event_rounded,
                          size: 12,
                          color: contract.status == RetainerStatus.expired
                              ? AppColors.error
                              : AppColors.neutral400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Ends: ${dateFormat.format(contract.endDate)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: contract.status == RetainerStatus.expired
                                ? AppColors.error
                                : AppColors.neutral600,
                            fontSize: 11,
                            fontWeight:
                                contract.status == RetainerStatus.expired
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _ExpiryBadge(contract: contract),
                      ],
                    ),
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

class _RetainerIcon extends StatelessWidget {
  const _RetainerIcon({required this.status});

  final RetainerStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.handshake_rounded, size: 22, color: status.color),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final RetainerStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: status.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FeeTag extends StatelessWidget {
  const _FeeTag({
    required this.label,
    required this.sublabel,
    this.muted = false,
  });

  final String label;
  final String sublabel;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = muted ? AppColors.neutral400 : AppColors.neutral900;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
            fontSize: 13,
          ),
        ),
        Text(
          sublabel,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.neutral400,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _ExpiryBadge extends StatelessWidget {
  const _ExpiryBadge({required this.contract});

  final RetainerContract contract;

  @override
  Widget build(BuildContext context) {
    if (contract.status == RetainerStatus.active && !contract.isExpiringSoon) {
      return const SizedBox.shrink();
    }
    if (contract.status == RetainerStatus.paused) {
      return const SizedBox.shrink();
    }

    final days = contract.daysToExpiry;
    final Color color;
    final String label;

    if (contract.status == RetainerStatus.expired || days < 0) {
      color = AppColors.error;
      label = '${days.abs()}d ago';
    } else if (contract.isExpiringSoon) {
      color = AppColors.warning;
      label = '${days}d left';
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}
