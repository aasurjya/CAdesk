import 'package:ca_app/features/platform/domain/models/app_user.dart';
import 'package:ca_app/features/platform/domain/models/audit_log_entry.dart';
import 'package:ca_app/features/platform/domain/models/push_notification.dart';
import 'package:ca_app/features/platform/domain/models/sync_queue_item.dart';

/// Abstract contract for platform data operations.
///
/// Covers users, audit logs, push notifications, and sync queue items.
abstract class PlatformRepository {
  // ---------------------------------------------------------------------------
  // AppUser
  // ---------------------------------------------------------------------------

  /// Returns all users.
  Future<List<AppUser>> getUsers();

  /// Returns the user for [userId], or null if not found.
  Future<AppUser?> getUserById(String userId);

  /// Returns all users belonging to [firmId].
  Future<List<AppUser>> getUsersByFirm(String firmId);

  /// Inserts a new [AppUser] and returns its ID.
  Future<String> insertUser(AppUser user);

  /// Updates an existing [AppUser]. Returns true on success.
  Future<bool> updateUser(AppUser user);

  /// Deletes the user identified by [userId]. Returns true on success.
  Future<bool> deleteUser(String userId);

  // ---------------------------------------------------------------------------
  // AuditLog
  // ---------------------------------------------------------------------------

  /// Returns all audit log entries.
  Future<List<AuditLogEntry>> getAuditLogs();

  /// Returns all audit log entries for [userId].
  Future<List<AuditLogEntry>> getAuditLogsByUser(String userId);

  /// Returns all audit log entries matching [severity].
  Future<List<AuditLogEntry>> getAuditLogsBySeverity(LogSeverity severity);

  /// Inserts a new [AuditLogEntry] and returns its ID.
  Future<String> insertAuditLog(AuditLogEntry entry);

  // ---------------------------------------------------------------------------
  // PushNotification
  // ---------------------------------------------------------------------------

  /// Returns all push notifications.
  Future<List<PushNotification>> getNotifications();

  /// Returns all notifications for [userId].
  Future<List<PushNotification>> getNotificationsByUser(String userId);

  /// Inserts a new [PushNotification] and returns its ID.
  Future<String> insertNotification(PushNotification notification);

  /// Marks the notification with [notificationId] as read.
  /// Returns true on success.
  Future<bool> markNotificationRead(String notificationId);

  // ---------------------------------------------------------------------------
  // SyncQueueItem
  // ---------------------------------------------------------------------------

  /// Returns all sync queue items.
  Future<List<SyncQueueItem>> getSyncQueueItems();

  /// Returns all sync queue items with [status].
  Future<List<SyncQueueItem>> getSyncQueueItemsByStatus(SyncStatus status);

  /// Inserts a new [SyncQueueItem] and returns its ID.
  Future<String> insertSyncQueueItem(SyncQueueItem item);

  /// Updates the [status] of the sync queue item identified by [itemId].
  /// Returns true on success.
  Future<bool> updateSyncQueueItemStatus(String itemId, SyncStatus status);

  /// Deletes the sync queue item identified by [itemId].
  /// Returns true on success.
  Future<bool> deleteSyncQueueItem(String itemId);
}
