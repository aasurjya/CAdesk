import 'package:ca_app/features/platform/domain/models/app_user.dart';
import 'package:ca_app/features/platform/domain/models/audit_log_entry.dart';
import 'package:ca_app/features/platform/domain/models/push_notification.dart';
import 'package:ca_app/features/platform/domain/models/sync_queue_item.dart';
import 'package:ca_app/features/platform/domain/repositories/platform_repository.dart';

/// In-memory mock implementation of [PlatformRepository].
///
/// Seeded with realistic sample data for development and testing.
class MockPlatformRepository implements PlatformRepository {
  static final List<AppUser> _userSeed = [
    AppUser(
      userId: 'user-001',
      email: 'ca.sharma@cadesks.com',
      name: 'CA Rajesh Sharma',
      role: UserRole.firmOwner,
      firmId: 'firm-001',
      mfaEnabled: true,
      isActive: true,
      createdAt: DateTime(2024, 1, 15),
      lastLoginAt: DateTime(2026, 3, 10),
    ),
    AppUser(
      userId: 'user-002',
      email: 'priya.patel@cadesks.com',
      name: 'Priya Patel',
      role: UserRole.manager,
      firmId: 'firm-001',
      mfaEnabled: true,
      isActive: true,
      createdAt: DateTime(2024, 6, 1),
      lastLoginAt: DateTime(2026, 3, 9),
    ),
    AppUser(
      userId: 'user-003',
      email: 'arun.reddy@cadesks.com',
      name: 'Arun Reddy',
      role: UserRole.articleClerk,
      firmId: 'firm-001',
      mfaEnabled: false,
      isActive: true,
      createdAt: DateTime(2025, 8, 1),
    ),
  ];

  static final List<AuditLogEntry> _auditSeed = [
    AuditLogEntry(
      logId: 'log-001',
      userId: 'user-001',
      userName: 'CA Rajesh Sharma',
      action: 'ITR_FILED',
      timestamp: DateTime(2026, 3, 10, 9, 30),
      severity: LogSeverity.info,
      metadata: const {'clientId': 'mock-client-001', 'year': '2024'},
      resourceType: 'ITR',
      resourceId: 'itr-001',
      ipAddress: '192.168.1.1',
    ),
    AuditLogEntry(
      logId: 'log-002',
      userId: 'user-002',
      userName: 'Priya Patel',
      action: 'CLIENT_CREATED',
      timestamp: DateTime(2026, 3, 9, 14, 0),
      severity: LogSeverity.info,
      metadata: const {'clientName': 'New Corp'},
      resourceType: 'Client',
    ),
    AuditLogEntry(
      logId: 'log-003',
      userId: 'user-001',
      userName: 'CA Rajesh Sharma',
      action: 'UNAUTHORIZED_ACCESS_ATTEMPT',
      timestamp: DateTime(2026, 3, 8, 22, 15),
      severity: LogSeverity.warning,
      metadata: const {'resource': '/admin/users'},
      ipAddress: '10.0.0.5',
    ),
  ];

  static final List<PushNotification> _notifSeed = [
    PushNotification(
      notificationId: 'notif-001',
      userId: 'user-001',
      title: 'ITR Filing Deadline Tomorrow',
      body: '5 clients have ITR due tomorrow. File immediately.',
      type: NotificationType.deadlineAlert,
      data: const {'route': '/itr', 'count': '5'},
      sentAt: DateTime(2026, 3, 13, 8, 0),
    ),
    PushNotification(
      notificationId: 'notif-002',
      userId: 'user-001',
      title: 'GST Return Filed Successfully',
      body: 'GSTR-3B for Sharma Industries filed and accepted.',
      type: NotificationType.filingComplete,
      data: const {'clientId': 'mock-client-001'},
      sentAt: DateTime(2026, 3, 11, 16, 30),
      readAt: DateTime(2026, 3, 11, 17, 0),
    ),
    PushNotification(
      notificationId: 'notif-003',
      userId: 'user-002',
      title: 'New Message from Client',
      body: 'Patel Exports has sent you a document.',
      type: NotificationType.newMessage,
      data: const {'clientId': 'mock-client-002'},
      sentAt: DateTime(2026, 3, 10, 11, 0),
    ),
  ];

  static final List<SyncQueueItem> _syncSeed = [
    SyncQueueItem(
      itemId: 'sync-001',
      entityType: 'Client',
      entityId: 'mock-client-004',
      operation: SyncOperation.create,
      payload: '{"name":"Offline Client","pan":"ZZZZZ0000Z"}',
      createdAt: DateTime(2026, 3, 12, 10, 0),
      status: SyncStatus.pending,
    ),
    SyncQueueItem(
      itemId: 'sync-002',
      entityType: 'FilingJob',
      entityId: 'filing-job-005',
      operation: SyncOperation.update,
      payload: '{"status":"filed","filedAt":"2026-03-11"}',
      createdAt: DateTime(2026, 3, 11, 15, 30),
      status: SyncStatus.synced,
      syncedAt: DateTime(2026, 3, 11, 16, 0),
    ),
    SyncQueueItem(
      itemId: 'sync-003',
      entityType: 'PayrollEntry',
      entityId: 'payroll-099',
      operation: SyncOperation.delete,
      payload: '{}',
      createdAt: DateTime(2026, 3, 10, 9, 0),
      status: SyncStatus.failed,
    ),
  ];

  final List<AppUser> _userState = List.of(_userSeed);
  final List<AuditLogEntry> _auditState = List.of(_auditSeed);
  final List<PushNotification> _notifState = List.of(_notifSeed);
  final List<SyncQueueItem> _syncState = List.of(_syncSeed);

  // ---------------------------------------------------------------------------
  // AppUser
  // ---------------------------------------------------------------------------

  @override
  Future<List<AppUser>> getUsers() async => List.unmodifiable(_userState);

  @override
  Future<AppUser?> getUserById(String userId) async {
    final idx = _userState.indexWhere((u) => u.userId == userId);
    return idx == -1 ? null : _userState[idx];
  }

  @override
  Future<List<AppUser>> getUsersByFirm(String firmId) async =>
      List.unmodifiable(_userState.where((u) => u.firmId == firmId).toList());

  @override
  Future<String> insertUser(AppUser user) async {
    _userState.add(user);
    return user.userId;
  }

  @override
  Future<bool> updateUser(AppUser user) async {
    final idx = _userState.indexWhere((u) => u.userId == user.userId);
    if (idx == -1) return false;
    final updated = List<AppUser>.of(_userState)..[idx] = user;
    _userState
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteUser(String userId) async {
    final before = _userState.length;
    _userState.removeWhere((u) => u.userId == userId);
    return _userState.length < before;
  }

  // ---------------------------------------------------------------------------
  // AuditLog
  // ---------------------------------------------------------------------------

  @override
  Future<List<AuditLogEntry>> getAuditLogs() async =>
      List.unmodifiable(_auditState);

  @override
  Future<List<AuditLogEntry>> getAuditLogsByUser(String userId) async =>
      List.unmodifiable(_auditState.where((l) => l.userId == userId).toList());

  @override
  Future<List<AuditLogEntry>> getAuditLogsBySeverity(
    LogSeverity severity,
  ) async => List.unmodifiable(
    _auditState.where((l) => l.severity == severity).toList(),
  );

  @override
  Future<String> insertAuditLog(AuditLogEntry entry) async {
    _auditState.add(entry);
    return entry.logId;
  }

  // ---------------------------------------------------------------------------
  // PushNotification
  // ---------------------------------------------------------------------------

  @override
  Future<List<PushNotification>> getNotifications() async =>
      List.unmodifiable(_notifState);

  @override
  Future<List<PushNotification>> getNotificationsByUser(String userId) async =>
      List.unmodifiable(_notifState.where((n) => n.userId == userId).toList());

  @override
  Future<String> insertNotification(PushNotification notification) async {
    _notifState.add(notification);
    return notification.notificationId;
  }

  @override
  Future<bool> markNotificationRead(String notificationId) async {
    final idx = _notifState.indexWhere(
      (n) => n.notificationId == notificationId,
    );
    if (idx == -1) return false;
    final updated = List<PushNotification>.of(_notifState)
      ..[idx] = _notifState[idx].copyWith(readAt: DateTime.now());
    _notifState
      ..clear()
      ..addAll(updated);
    return true;
  }

  // ---------------------------------------------------------------------------
  // SyncQueueItem
  // ---------------------------------------------------------------------------

  @override
  Future<List<SyncQueueItem>> getSyncQueueItems() async =>
      List.unmodifiable(_syncState);

  @override
  Future<List<SyncQueueItem>> getSyncQueueItemsByStatus(
    SyncStatus status,
  ) async =>
      List.unmodifiable(_syncState.where((i) => i.status == status).toList());

  @override
  Future<String> insertSyncQueueItem(SyncQueueItem item) async {
    _syncState.add(item);
    return item.itemId;
  }

  @override
  Future<bool> updateSyncQueueItemStatus(
    String itemId,
    SyncStatus status,
  ) async {
    final idx = _syncState.indexWhere((i) => i.itemId == itemId);
    if (idx == -1) return false;
    final updated = List<SyncQueueItem>.of(_syncState)
      ..[idx] = _syncState[idx].copyWith(status: status);
    _syncState
      ..clear()
      ..addAll(updated);
    return true;
  }

  @override
  Future<bool> deleteSyncQueueItem(String itemId) async {
    final before = _syncState.length;
    _syncState.removeWhere((i) => i.itemId == itemId);
    return _syncState.length < before;
  }
}
