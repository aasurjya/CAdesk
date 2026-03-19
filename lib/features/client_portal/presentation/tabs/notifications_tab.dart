import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/client_portal/domain/models/portal_notification.dart';
import 'package:ca_app/features/client_portal/data/providers/client_portal_providers.dart';

/// Tab displaying portal notifications with channel and type indicators.
class NotificationsTab extends ConsumerWidget {
  const NotificationsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(allNotificationsProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final automationSummary = ref.watch(portalAutomationSummaryProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF8FBFF), Color(0xFFF5FAF9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.neutral100),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.notifications_active_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alerts and follow-ups',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.neutral900,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Track automated reminders, document requests, signatures, and client-facing notices in one calm view.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.neutral600,
                                height: 1.4,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(
                '${notifications.length} notifications',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppColors.neutral400),
              ),
              const Spacer(),
              if (unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$unreadCount unread',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _SummaryStat(
                    label: 'AI follow-ups',
                    value: '${automationSummary['followUps'] ?? 0}',
                  ),
                  _SummaryStat(
                    label: 'Magic links',
                    value: '${automationSummary['magicLinks'] ?? 0}',
                  ),
                  _SummaryStat(
                    label: 'Pending sign',
                    value: '${automationSummary['pendingSignatures'] ?? 0}',
                  ),
                ],
              ),
            ),
          ),
        ),
        // Notifications list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: notifications.length,
            itemBuilder: (context, index) =>
                _NotificationTile(notification: notifications[index]),
          ),
        ),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final PortalNotification notification;

  Color get _typeColor {
    switch (notification.type) {
      case NotificationType.reminder:
        return AppColors.warning;
      case NotificationType.document:
        return AppColors.primary;
      case NotificationType.message:
        return AppColors.secondary;
      case NotificationType.payment:
        return AppColors.success;
      case NotificationType.deadline:
        return AppColors.error;
    }
  }

  IconData get _typeIcon {
    switch (notification.type) {
      case NotificationType.reminder:
        return Icons.alarm;
      case NotificationType.document:
        return Icons.description;
      case NotificationType.message:
        return Icons.chat;
      case NotificationType.payment:
        return Icons.payments;
      case NotificationType.deadline:
        return Icons.event;
    }
  }

  IconData get _channelIcon {
    switch (notification.channel) {
      case NotificationChannel.email:
        return Icons.email;
      case NotificationChannel.sms:
        return Icons.sms;
      case NotificationChannel.whatsapp:
        return Icons.chat_bubble;
      case NotificationChannel.inApp:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: notification.isRead ? null : AppColors.primary.withAlpha(5),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _typeColor.withAlpha(16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_typeIcon, size: 18, color: _typeColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                            color: AppColors.neutral900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(_channelIcon, size: 12, color: AppColors.neutral400),
                      const SizedBox(width: 4),
                      Text(
                        notification.channel.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.neutral400,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.access_time,
                        size: 12,
                        color: AppColors.neutral400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('d MMM, h:mm a').format(notification.sentAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.neutral400,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral400,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
