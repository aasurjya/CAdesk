import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/smart_notifications/data/providers/smart_notification_providers.dart';
import 'package:ca_app/features/smart_notifications/presentation/widgets/smart_notification_tile.dart';

/// Full-screen display of prioritized smart notifications.
class SmartNotificationsScreen extends ConsumerWidget {
  const SmartNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notificationsAsync = ref.watch(smartNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Smart Notifications',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final repo = ref.read(smartNotificationRepositoryProvider);
              await repo.markAllAsRead();
              ref.invalidate(smartNotificationsProvider);
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load notifications: $err',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.neutral600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 56,
                    color: AppColors.neutral300,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'All caught up!',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.neutral600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No pending notifications',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            itemCount: notifications.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return SmartNotificationTile(notification: notifications[index]);
            },
          );
        },
      ),
    );
  }
}
