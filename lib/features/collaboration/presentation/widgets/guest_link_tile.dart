import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/collaboration/domain/models/guest_link.dart';

/// A card tile displaying a single guest link with access level and status.
class GuestLinkTile extends StatelessWidget {
  const GuestLinkTile({super.key, required this.link});

  final GuestLink link;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: title and status chip
              Row(
                children: [
                  Expanded(
                    child: Text(
                      link.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(status: link.status),
                ],
              ),
              const SizedBox(height: 4),

              // Row 2: client name
              Text(
                link.clientName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
              const SizedBox(height: 8),

              // Row 3: access level badge, expiry, view count
              Row(
                children: [
                  _AccessLevelBadge(accessLevel: link.accessLevel),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 12,
                    color: link.isExpired
                        ? AppColors.error
                        : AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Expires: ${dateFormat.format(link.expiresAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: link.isExpired
                          ? AppColors.error
                          : AppColors.neutral400,
                      fontSize: 11,
                      fontWeight: link.isExpired
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.visibility_rounded,
                    size: 12,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Views: ${link.viewCount}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),

              // Purpose row (if available)
              if (link.purpose != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.label_outline_rounded,
                      size: 12,
                      color: AppColors.neutral400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      link.purpose!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral400,
                        fontSize: 11,
                      ),
                    ),
                    if (link.createdBy != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.person_outline_rounded,
                        size: 12,
                        color: AppColors.neutral400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        link.createdBy!,
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
// Private widgets
// ---------------------------------------------------------------------------

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final GuestLinkStatus status;

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

class _AccessLevelBadge extends StatelessWidget {
  const _AccessLevelBadge({required this.accessLevel});

  final GuestAccessLevel accessLevel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        accessLevel.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
