import 'follow_up_action.dart';

/// Priority level for smart notifications.
enum NotificationPriority { critical, high, medium, low }

/// Category of smart notification.
enum NotificationType {
  deadlineApproaching,
  complianceGap,
  overdueNotice,
  clientHealthAlert,
  regulatoryUpdate,
  actionRequired,
}

/// An immutable smart notification with context and suggested actions.
class SmartNotification {
  SmartNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.priority,
    required this.createdAt,
    this.clientId,
    this.clientName,
    this.dueDate,
    this.isRead = false,
    List<FollowUpAction> suggestedActions = const [],
    Map<String, dynamic> context = const {},
  }) : suggestedActions = List.unmodifiable(suggestedActions),
       context = Map.unmodifiable(context);

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final NotificationPriority priority;
  final DateTime createdAt;
  final String? clientId;
  final String? clientName;
  final DateTime? dueDate;
  final bool isRead;
  final List<FollowUpAction> suggestedActions;
  final Map<String, dynamic> context;

  int get daysUntilDue {
    if (dueDate == null) return -1;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  SmartNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    NotificationPriority? priority,
    DateTime? createdAt,
    String? clientId,
    String? clientName,
    DateTime? dueDate,
    bool? isRead,
    List<FollowUpAction>? suggestedActions,
    Map<String, dynamic>? context,
  }) {
    return SmartNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      dueDate: dueDate ?? this.dueDate,
      isRead: isRead ?? this.isRead,
      suggestedActions: suggestedActions ?? this.suggestedActions,
      context: context ?? this.context,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SmartNotification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
