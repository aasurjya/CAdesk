import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../../domain/models/broker_feed.dart';

/// A card tile displaying a single broker feed with status and transaction info.
class BrokerFeedTile extends StatelessWidget {
  const BrokerFeedTile({super.key, required this.feed});

  final BrokerFeed feed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM, HH:mm');

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
              // Top row: avatar, client name, broker label, status chip
              Row(
                children: [
                  _BrokerAvatar(broker: feed.broker),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feed.clientName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          feed.broker.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _FeedStatusChip(status: feed.status),
                ],
              ),
              const SizedBox(height: 10),

              // Bottom row: capital gains, total transactions, last fetch
              Row(
                children: [
                  _MetaItem(
                    icon: Icons.trending_up_rounded,
                    label: 'Cap. Gains: ${feed.capitalGainsCount}',
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 16),
                  _MetaItem(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Transactions: ${feed.totalTransactions}',
                    color: AppColors.neutral600,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(feed.lastFetch),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),

              // PAN and account ID if present
              if (feed.pan != null || feed.accountId != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (feed.pan != null) ...[
                      Icon(
                        Icons.badge_rounded,
                        size: 12,
                        color: AppColors.neutral400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        feed.pan!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral400,
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ],
                    if (feed.pan != null && feed.accountId != null)
                      const SizedBox(width: 12),
                    if (feed.accountId != null) ...[
                      Icon(
                        Icons.tag_rounded,
                        size: 12,
                        color: AppColors.neutral400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        feed.accountId!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral400,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _BrokerAvatar extends StatelessWidget {
  const _BrokerAvatar({required this.broker});

  final BrokerName broker;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
      child: Text(
        broker.label[0],
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _FeedStatusChip extends StatelessWidget {
  const _FeedStatusChip({required this.status});

  final BrokerFeedStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
