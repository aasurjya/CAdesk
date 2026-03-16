import 'package:ca_app/features/ca_gpt/domain/services/tax_calendar_service.dart';
import 'package:ca_app/features/smart_notifications/domain/models/follow_up_action.dart';
import 'package:ca_app/features/smart_notifications/domain/models/smart_notification.dart';

/// Scans for approaching tax deadlines and generates notifications.
class DeadlineScanner {
  const DeadlineScanner();

  /// Returns notifications for deadlines within the next [daysAhead].
  List<SmartNotification> scan({int daysAhead = 7}) {
    final now = DateTime.now();
    final fy = now.month >= 4 ? now.year : now.year - 1;
    final deadlines = TaxCalendarService.getUpcomingDeadlines(
      fy,
      now,
      days: daysAhead,
    );

    return deadlines.map((deadline) {
      final daysLeft = deadline.date.difference(now).inDays;
      final priority = daysLeft <= 2
          ? NotificationPriority.critical
          : daysLeft <= 5
          ? NotificationPriority.high
          : NotificationPriority.medium;

      return SmartNotification(
        id: 'deadline_${deadline.date.toIso8601String()}_${deadline.category}',
        type: NotificationType.deadlineApproaching,
        title: '${deadline.category} deadline in $daysLeft days',
        body: deadline.description,
        priority: priority,
        createdAt: now,
        dueDate: deadline.date,
        suggestedActions: [
          FollowUpAction(
            type: ActionType.navigateTo,
            label: 'View Calendar',
            route: '/ca-gpt',
            parameters: {'tab': 'calendar'},
          ),
          FollowUpAction(
            type: ActionType.createTask,
            label: 'Create Task',
            route: '/tasks',
            parameters: {'title': deadline.description},
          ),
        ],
      );
    }).toList();
  }
}
