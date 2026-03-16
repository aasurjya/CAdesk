import 'package:ca_app/features/smart_notifications/domain/models/follow_up_action.dart';
import 'package:ca_app/features/smart_notifications/domain/models/smart_notification.dart';

/// Generates follow-up actions based on notification type and context.
class ActionGenerator {
  const ActionGenerator();

  /// Returns suggested actions for a given notification type.
  List<FollowUpAction> generate(SmartNotification notification) {
    return switch (notification.type) {
      NotificationType.deadlineApproaching => [
        FollowUpAction(
          type: ActionType.createTask,
          label: 'Create reminder task',
          route: '/tasks',
        ),
        if (notification.clientName != null)
          FollowUpAction(
            type: ActionType.whatsapp,
            label: 'Remind ${notification.clientName}',
            route: '/communication',
            parameters: {'client': notification.clientName!},
          ),
      ],
      NotificationType.complianceGap => [
        FollowUpAction(
          type: ActionType.navigateTo,
          label: 'View compliance dashboard',
          route: '/compliance',
        ),
      ],
      NotificationType.overdueNotice => [
        FollowUpAction(
          type: ActionType.navigateTo,
          label: 'Draft reply',
          route: '/ca-gpt',
          parameters: {'tab': 'notices'},
        ),
      ],
      NotificationType.clientHealthAlert => [
        FollowUpAction(
          type: ActionType.scheduleCall,
          label: 'Schedule call',
          route: '/calendar',
        ),
      ],
      NotificationType.regulatoryUpdate => [
        FollowUpAction(
          type: ActionType.navigateTo,
          label: 'Read update',
          route: '/regulatory',
        ),
      ],
      NotificationType.actionRequired => [
        FollowUpAction(
          type: ActionType.navigateTo,
          label: 'Take action',
          route: '/tasks',
        ),
      ],
    };
  }
}
