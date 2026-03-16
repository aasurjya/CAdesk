import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/feature_flags/feature_flag_provider.dart';
import 'package:ca_app/features/smart_notifications/data/repositories/mock_smart_notification_repository.dart';
import 'package:ca_app/features/smart_notifications/data/repositories/smart_notification_repository_impl.dart';
import 'package:ca_app/features/smart_notifications/domain/models/smart_notification.dart';
import 'package:ca_app/features/smart_notifications/domain/repositories/smart_notification_repository.dart';
import 'package:ca_app/features/smart_notifications/domain/services/deadline_scanner.dart';
import 'package:ca_app/features/smart_notifications/domain/services/notification_prioritizer.dart';

/// Provides the [SmartNotificationRepository].
final smartNotificationRepositoryProvider =
    Provider<SmartNotificationRepository>((ref) {
  final flags = ref.watch(featureFlagProvider).asData?.value;
  final enabled = flags?.isEnabled('ai_notifications_enabled') ?? false;

  if (!enabled) return MockSmartNotificationRepository();
  return SmartNotificationRepositoryImpl();
});

/// Provides the [DeadlineScanner].
final deadlineScannerProvider = Provider<DeadlineScanner>(
  (_) => const DeadlineScanner(),
);

/// Provides the [NotificationPrioritizer].
final notificationPrioritizerProvider = Provider<NotificationPrioritizer>(
  (_) => const NotificationPrioritizer(),
);

/// Provides the prioritized list of smart notifications.
final smartNotificationsProvider =
    FutureProvider<List<SmartNotification>>((ref) async {
  final repository = ref.watch(smartNotificationRepositoryProvider);
  final prioritizer = ref.watch(notificationPrioritizerProvider);

  final notifications = await repository.getAll();
  return prioritizer.prioritize(notifications);
});

/// Provides the count of unread notifications.
final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(smartNotificationRepositoryProvider);
  final unread = await repository.getUnread();
  return unread.length;
});
