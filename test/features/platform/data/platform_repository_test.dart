import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/platform/domain/models/app_user.dart';
import 'package:ca_app/features/platform/domain/models/audit_log_entry.dart';
import 'package:ca_app/features/platform/domain/models/push_notification.dart';
import 'package:ca_app/features/platform/domain/models/sync_queue_item.dart';
import 'package:ca_app/features/platform/data/repositories/mock_platform_repository.dart';

void main() {
  group('MockPlatformRepository', () {
    late MockPlatformRepository repo;

    setUp(() {
      repo = MockPlatformRepository();
    });

    // -------------------------------------------------------------------------
    // AppUser
    // -------------------------------------------------------------------------

    group('AppUsers', () {
      test('getUsers returns seed items', () async {
        final users = await repo.getUsers();
        expect(users.length, greaterThanOrEqualTo(3));
      });

      test('getUserById returns matching user', () async {
        final all = await repo.getUsers();
        final first = all.first;
        final found = await repo.getUserById(first.userId);
        expect(found?.userId, first.userId);
      });

      test('getUserById returns null for unknown id', () async {
        final found = await repo.getUserById('no-such-user');
        expect(found, isNull);
      });

      test('insertUser adds user and returns id', () async {
        final user = AppUser(
          userId: 'user-new-001',
          email: 'new@example.com',
          name: 'New User',
          role: UserRole.junior,
          firmId: 'firm-001',
          mfaEnabled: false,
          isActive: true,
          createdAt: DateTime(2026, 1, 1),
        );
        final id = await repo.insertUser(user);
        expect(id, user.userId);

        final found = await repo.getUserById('user-new-001');
        expect(found, isNotNull);
      });

      test('updateUser updates existing user', () async {
        final all = await repo.getUsers();
        final first = all.first;
        final updated = first.copyWith(isActive: false);
        final success = await repo.updateUser(updated);
        expect(success, isTrue);

        final found = await repo.getUserById(first.userId);
        expect(found?.isActive, isFalse);
      });

      test('updateUser returns false for non-existent user', () async {
        final ghost = AppUser(
          userId: 'ghost-id',
          email: 'ghost@x.com',
          name: 'Ghost',
          role: UserRole.viewOnly,
          firmId: 'firm-x',
          mfaEnabled: false,
          isActive: false,
          createdAt: DateTime(2026),
        );
        final success = await repo.updateUser(ghost);
        expect(success, isFalse);
      });

      test('deleteUser removes user', () async {
        final all = await repo.getUsers();
        final first = all.first;
        final success = await repo.deleteUser(first.userId);
        expect(success, isTrue);

        final found = await repo.getUserById(first.userId);
        expect(found, isNull);
      });

      test('deleteUser returns false for non-existent id', () async {
        final success = await repo.deleteUser('no-such-user');
        expect(success, isFalse);
      });

      test('getUsersByFirm filters by firmId', () async {
        final all = await repo.getUsers();
        final firmId = all.first.firmId;
        final filtered = await repo.getUsersByFirm(firmId);
        expect(filtered.every((u) => u.firmId == firmId), isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // AuditLog
    // -------------------------------------------------------------------------

    group('AuditLog', () {
      test('getAuditLogs returns seed items', () async {
        final logs = await repo.getAuditLogs();
        expect(logs.length, greaterThanOrEqualTo(3));
      });

      test('getAuditLogsByUser filters by userId', () async {
        final all = await repo.getAuditLogs();
        final userId = all.first.userId;
        final filtered = await repo.getAuditLogsByUser(userId);
        expect(filtered.every((l) => l.userId == userId), isTrue);
      });

      test('insertAuditLog adds log entry', () async {
        final log = AuditLogEntry(
          logId: 'log-new-001',
          userId: 'user-001',
          userName: 'Test User',
          action: 'TEST_ACTION',
          timestamp: DateTime(2026, 1, 1),
          severity: LogSeverity.info,
          metadata: const {'key': 'value'},
        );
        final id = await repo.insertAuditLog(log);
        expect(id, log.logId);

        final all = await repo.getAuditLogs();
        expect(all.any((l) => l.logId == 'log-new-001'), isTrue);
      });

      test('getAuditLogsBySeverity filters correctly', () async {
        final logs = await repo.getAuditLogsBySeverity(LogSeverity.info);
        expect(logs.every((l) => l.severity == LogSeverity.info), isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // PushNotification
    // -------------------------------------------------------------------------

    group('PushNotifications', () {
      test('getNotifications returns seed items', () async {
        final notifications = await repo.getNotifications();
        expect(notifications.length, greaterThanOrEqualTo(3));
      });

      test('getNotificationsByUser filters by userId', () async {
        final all = await repo.getNotifications();
        final userId = all.first.userId;
        final filtered = await repo.getNotificationsByUser(userId);
        expect(filtered.every((n) => n.userId == userId), isTrue);
      });

      test('insertNotification adds notification', () async {
        final notification = PushNotification(
          notificationId: 'notif-new-001',
          userId: 'user-001',
          title: 'Test Notification',
          body: 'Body text',
          type: NotificationType.systemAlert,
          data: const {},
          sentAt: DateTime(2026, 1, 1),
        );
        final id = await repo.insertNotification(notification);
        expect(id, notification.notificationId);
      });

      test('markNotificationRead updates readAt', () async {
        final all = await repo.getNotifications();
        final unread = all.firstWhere((n) => !n.isRead);
        final success = await repo.markNotificationRead(unread.notificationId);
        expect(success, isTrue);
      });

      test('markNotificationRead returns false for unknown id', () async {
        final success = await repo.markNotificationRead('no-such-notif');
        expect(success, isFalse);
      });
    });

    // -------------------------------------------------------------------------
    // SyncQueueItem
    // -------------------------------------------------------------------------

    group('SyncQueue', () {
      test('getSyncQueueItems returns seed items', () async {
        final items = await repo.getSyncQueueItems();
        expect(items.length, greaterThanOrEqualTo(3));
      });

      test('getSyncQueueItemsByStatus filters correctly', () async {
        final items = await repo.getSyncQueueItemsByStatus(SyncStatus.pending);
        expect(items.every((i) => i.status == SyncStatus.pending), isTrue);
      });

      test('insertSyncQueueItem adds item', () async {
        final item = SyncQueueItem(
          itemId: 'sync-new-001',
          entityType: 'Client',
          entityId: 'client-001',
          operation: SyncOperation.create,
          payload: '{"id":"client-001"}',
          createdAt: DateTime(2026, 1, 1),
          status: SyncStatus.pending,
        );
        final id = await repo.insertSyncQueueItem(item);
        expect(id, item.itemId);
      });

      test('updateSyncQueueItemStatus updates status', () async {
        final all = await repo.getSyncQueueItems();
        final first = all.first;
        final success = await repo.updateSyncQueueItemStatus(
          first.itemId,
          SyncStatus.synced,
        );
        expect(success, isTrue);
      });

      test('updateSyncQueueItemStatus returns false for unknown id', () async {
        final success = await repo.updateSyncQueueItemStatus(
          'no-such-item',
          SyncStatus.synced,
        );
        expect(success, isFalse);
      });

      test('deleteSyncQueueItem removes item', () async {
        final all = await repo.getSyncQueueItems();
        final first = all.first;
        final success = await repo.deleteSyncQueueItem(first.itemId);
        expect(success, isTrue);
      });
    });
  });
}
