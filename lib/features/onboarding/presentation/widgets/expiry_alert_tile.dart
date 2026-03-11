import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/onboarding/domain/models/document_expiry.dart';

/// Displays a document expiry tile with color-coded urgency.
class ExpiryAlertTile extends StatelessWidget {
  const ExpiryAlertTile({super.key, required this.expiry});

  final DocumentExpiry expiry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final urgencyColor = _urgencyColor(expiry.status);
    final daysRemaining = expiry.daysRemaining;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: urgencyColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Urgency indicator
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: urgencyColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _statusIcon(expiry.status),
                color: urgencyColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expiry.clientName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    expiry.documentType.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.event_outlined,
                        size: 12,
                        color: AppColors.neutral400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(expiry.expiryDate),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                      if (expiry.reminderSentAt != null) ...[
                        const SizedBox(width: 10),
                        Icon(
                          Icons.notifications_outlined,
                          size: 12,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Reminded',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Days remaining badge
            _DaysRemainingBadge(
              days: daysRemaining,
              status: expiry.status,
              color: urgencyColor,
            ),
          ],
        ),
      ),
    );
  }

  Color _urgencyColor(ExpiryStatus status) {
    switch (status) {
      case ExpiryStatus.valid:
        return AppColors.success;
      case ExpiryStatus.expiringSoon:
        return AppColors.warning;
      case ExpiryStatus.expired:
        return AppColors.error;
    }
  }

  IconData _statusIcon(ExpiryStatus status) {
    switch (status) {
      case ExpiryStatus.valid:
        return Icons.verified_outlined;
      case ExpiryStatus.expiringSoon:
        return Icons.warning_amber_rounded;
      case ExpiryStatus.expired:
        return Icons.error_outline_rounded;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

/// Badge showing days remaining or "Expired".
class _DaysRemainingBadge extends StatelessWidget {
  const _DaysRemainingBadge({
    required this.days,
    required this.status,
    required this.color,
  });

  final int days;
  final ExpiryStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final label = status == ExpiryStatus.expired
        ? 'Expired'
        : days == 0
        ? 'Today'
        : '$days days';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status != ExpiryStatus.expired)
            Text(
              days.toString(),
              style: theme.textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
