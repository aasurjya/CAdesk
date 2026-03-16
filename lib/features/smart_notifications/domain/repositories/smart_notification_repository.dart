import 'package:ca_app/features/smart_notifications/domain/models/smart_notification.dart';

/// Abstract contract for smart notification persistence.
abstract class SmartNotificationRepository {
  Future<List<SmartNotification>> getAll();
  Future<List<SmartNotification>> getUnread();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> save(SmartNotification notification);
  Future<void> saveAll(List<SmartNotification> notifications);
  Future<void> delete(String notificationId);
}
