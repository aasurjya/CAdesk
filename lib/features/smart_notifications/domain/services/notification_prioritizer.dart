import 'package:ca_app/features/smart_notifications/domain/models/smart_notification.dart';

/// Ranks notifications by urgency and impact.
class NotificationPrioritizer {
  const NotificationPrioritizer();

  /// Returns a new sorted list — highest priority first, then by due date.
  List<SmartNotification> prioritize(List<SmartNotification> notifications) {
    final sorted = List<SmartNotification>.from(notifications);
    sorted.sort((a, b) {
      // First by priority (critical=0, low=3)
      final priorityComparison = a.priority.index.compareTo(b.priority.index);
      if (priorityComparison != 0) return priorityComparison;

      // Then by due date (soonest first)
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      if (a.dueDate != null) return -1;
      if (b.dueDate != null) return 1;

      // Finally by creation time (newest first)
      return b.createdAt.compareTo(a.createdAt);
    });

    return List.unmodifiable(sorted);
  }
}
