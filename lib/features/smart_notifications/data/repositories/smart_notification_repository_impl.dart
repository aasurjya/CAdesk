import 'package:ca_app/features/smart_notifications/domain/models/smart_notification.dart';
import 'package:ca_app/features/smart_notifications/domain/repositories/smart_notification_repository.dart';

/// In-memory implementation of [SmartNotificationRepository].
///
/// Replace with Supabase + Drift implementation when persistence is needed.
class SmartNotificationRepositoryImpl implements SmartNotificationRepository {
  final List<SmartNotification> _notifications = [];

  @override
  Future<List<SmartNotification>> getAll() async {
    return List.unmodifiable(_notifications);
  }

  @override
  Future<List<SmartNotification>> getUnread() async {
    return List.unmodifiable(
      _notifications.where((n) => !n.isRead),
    );
  }

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
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
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
