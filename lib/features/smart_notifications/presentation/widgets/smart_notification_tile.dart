import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/smart_notifications/domain/models/follow_up_action.dart';
import 'package:ca_app/features/smart_notifications/domain/models/smart_notification.dart';

/// A notification tile with context preview and action chips.
class SmartNotificationTile extends StatelessWidget {
  const SmartNotificationTile({super.key, required this.notification});

  final SmartNotification notification;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colorForPriority(notification.priority);

    return Container(
      decoration: BoxDecoration(
        color: notification.isRead ? AppColors.surface : AppColors.neutral50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead
              ? AppColors.neutral100
              : color.withAlpha(50),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: priority dot + title + due badge
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    notification.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                  ),
                ),
                if (notification.daysUntilDue >= 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: color.withAlpha(16),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      notification.daysUntilDue == 0
                          ? 'Today'
                          : '${notification.daysUntilDue}d left',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Body
            Text(
              notification.body,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral600,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            // Client name
            if (notification.clientName != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 14,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    notification.clientName!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            ],

            // Action chips
            if (notification.suggestedActions.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: notification.suggestedActions
                    .map((a) => _ActionChip(action: a))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _colorForPriority(NotificationPriority priority) {
    return switch (priority) {
      NotificationPriority.critical => AppColors.error,
      NotificationPriority.high => AppColors.accent,
      NotificationPriority.medium => AppColors.primary,
      NotificationPriority.low => AppColors.neutral400,
    };
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.action});

  final FollowUpAction action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ActionChip(
      avatar: Icon(_iconForType(action.type), size: 14),
      label: Text(
        action.label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: () => context.go(action.route),
      visualDensity: VisualDensity.compact,
    );
  }

  IconData _iconForType(ActionType type) {
    return switch (type) {
      ActionType.whatsapp => Icons.chat_outlined,
      ActionType.email => Icons.email_outlined,
      ActionType.createTask => Icons.add_task_rounded,
      ActionType.scheduleCall => Icons.phone_outlined,
      ActionType.navigateTo => Icons.open_in_new_rounded,
    };
  }
}
