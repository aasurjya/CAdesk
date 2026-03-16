import 'package:ca_app/features/smart_notifications/domain/models/follow_up_action.dart';
import 'package:ca_app/features/smart_notifications/domain/models/smart_notification.dart';

/// Scans for client health issues: overdue filings, open notices, compliance gaps.
class ClientHealthScanner {
  const ClientHealthScanner();

  /// Generates mock notifications for demo. Wire to real client data when available.
  List<SmartNotification> scan() {
    final now = DateTime.now();

    // Static demo notifications — replace with real client queries
    return [
      SmartNotification(
        id: 'health_overdue_gstr3b',
        type: NotificationType.complianceGap,
        title: 'GSTR-3B overdue for 3 clients',
        body: 'February GSTR-3B was due on March 20. '
            'Clients: ABC Traders, XYZ Corp, PQR Services.',
        priority: NotificationPriority.high,
        createdAt: now,
        suggestedActions: [
          FollowUpAction(
            type: ActionType.navigateTo,
            label: 'View GST Module',
            route: '/gst',
          ),
          FollowUpAction(
            type: ActionType.email,
            label: 'Send Reminder',
            route: '/communication',
            parameters: {'template': 'gst_reminder'},
          ),
        ],
      ),
      SmartNotification(
        id: 'health_open_notice',
        type: NotificationType.overdueNotice,
        title: 'Open notice pending reply',
        body: 'Section 143(1) intimation for client Sharma & Associates '
            'requires response by March 25.',
        priority: NotificationPriority.high,
        createdAt: now,
        dueDate: DateTime(now.year, now.month, 25),
        clientName: 'Sharma & Associates',
        suggestedActions: [
          FollowUpAction(
            type: ActionType.navigateTo,
            label: 'Draft Reply',
            route: '/ca-gpt',
            parameters: {'tab': 'notices'},
          ),
        ],
      ),
    ];
  }
}
