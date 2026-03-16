import 'package:ca_app/features/smart_notifications/domain/models/follow_up_action.dart';
import 'package:ca_app/features/smart_notifications/domain/models/smart_notification.dart';
import 'package:ca_app/features/smart_notifications/domain/repositories/smart_notification_repository.dart';

/// Mock repository with static sample notifications for development.
class MockSmartNotificationRepository implements SmartNotificationRepository {
  final List<SmartNotification> _notifications = List.of(_sampleNotifications);

  @override
  Future<List<SmartNotification>> getAll() async =>
      List.unmodifiable(_notifications);

  @override
  Future<List<SmartNotification>> getUnread() async =>
      List.unmodifiable(_notifications.where((n) => !n.isRead));

  @override
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index >= 0) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  @override
  Future<void> save(SmartNotification notification) async {
    final index = _notifications.indexWhere((n) => n.id == notification.id);
    if (index >= 0) {
      _notifications[index] = notification;
    } else {
      _notifications.add(notification);
    }
  }

  @override
  Future<void> saveAll(List<SmartNotification> notifications) async {
    for (final n in notifications) {
      await save(n);
    }
  }

  @override
  Future<void> delete(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
  }
}

final _now = DateTime.now();

final _sampleNotifications = <SmartNotification>[
  SmartNotification(
    id: 'sn_tds_march',
    type: NotificationType.deadlineApproaching,
    title: 'TDS Deposit — 2 days left',
    body:
        'March TDS must be deposited by April 7. '
        '12 clients have pending challans totalling ₹4.8 lakh.',
    priority: NotificationPriority.critical,
    createdAt: _now,
    dueDate: DateTime(_now.year, _now.month, _now.day + 2),
    suggestedActions: [
      FollowUpAction(
        type: ActionType.navigateTo,
        label: 'View TDS Module',
        route: '/tds',
      ),
      FollowUpAction(
        type: ActionType.email,
        label: 'Send Bulk Reminder',
        route: '/communication',
      ),
    ],
  ),
  SmartNotification(
    id: 'sn_gstr1_overdue',
    type: NotificationType.complianceGap,
    title: 'GSTR-1 overdue for 5 clients',
    body:
        'February GSTR-1 was due on March 11. '
        'Late fee accrual of ₹200/day applies.',
    priority: NotificationPriority.high,
    createdAt: _now,
    suggestedActions: [
      FollowUpAction(
        type: ActionType.navigateTo,
        label: 'View GST Module',
        route: '/gst',
      ),
    ],
  ),
  SmartNotification(
    id: 'sn_notice_sharma',
    type: NotificationType.overdueNotice,
    title: 'Notice reply due — Sharma & Associates',
    body:
        'Section 143(1) intimation requires response by March 25. '
        'Discrepancy in TDS credit of ₹1.2 lakh.',
    priority: NotificationPriority.high,
    createdAt: _now,
    clientName: 'Sharma & Associates',
    dueDate: DateTime(_now.year, 3, 25),
    suggestedActions: [
      FollowUpAction(
        type: ActionType.navigateTo,
        label: 'Draft Reply',
        route: '/ca-gpt',
        parameters: {'tab': 'notices'},
      ),
    ],
  ),
  SmartNotification(
    id: 'sn_advance_tax',
    type: NotificationType.actionRequired,
    title: 'Advance Tax — Final Installment',
    body:
        'March 15 is the last date for 100% advance tax payment. '
        'Review client portfolios for shortfall estimation.',
    priority: NotificationPriority.medium,
    createdAt: _now,
    dueDate: DateTime(_now.year, 3, 15),
    suggestedActions: [
      FollowUpAction(
        type: ActionType.navigateTo,
        label: 'Review Clients',
        route: '/clients',
      ),
    ],
  ),
];
