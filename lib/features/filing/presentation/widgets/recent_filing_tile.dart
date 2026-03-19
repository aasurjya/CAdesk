import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/urgency_border_card.dart';
import 'package:ca_app/features/filing/domain/models/filing_hub_item.dart';

/// A ListTile-style widget for recently filed returns.
class RecentFilingTile extends StatelessWidget {
  const RecentFilingTile({super.key, required this.item, this.onTap});

  final FilingHubItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormatter = DateFormat('d MMM yyyy');

    return UrgencyBorderCard(
      urgencyColor: AppColors.success,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: item.status.color.withAlpha(26),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(item.status.icon, color: item.status.color, size: 22),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.clientName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _StatusBadge(status: item.status),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              '${item.filingType.label} · ${item.subType}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 12,
                  color: AppColors.neutral400,
                ),
                const SizedBox(width: 4),
                Text(
                  item.filedDate != null
                      ? 'Filed ${dateFormatter.format(item.filedDate!)}'
                      : 'Filed',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.confirmation_number_outlined,
                  size: 12,
                  color: AppColors.neutral400,
                ),
                const SizedBox(width: 4),
                Text(
                  'Ack. available',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.neutral400),
        onTap: onTap,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final FilingHubStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: status.color.withAlpha(26),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: status.color,
        ),
      ),
    );
  }
}
