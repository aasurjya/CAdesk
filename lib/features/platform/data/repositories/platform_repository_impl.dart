import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ca_app/features/platform/domain/models/app_user.dart';
import 'package:ca_app/features/platform/domain/models/audit_log_entry.dart';
import 'package:ca_app/features/platform/domain/models/push_notification.dart';
import 'package:ca_app/features/platform/domain/models/sync_queue_item.dart';
import 'package:ca_app/features/platform/domain/repositories/platform_repository.dart';

/// Real implementation of [PlatformRepository] backed by Supabase.
class PlatformRepositoryImpl implements PlatformRepository {
  const PlatformRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const _usersTable = 'app_users';
  static const _auditTable = 'audit_logs';
  static const _notifTable = 'push_notifications';
  static const _syncTable = 'sync_queue';

  // ---------------------------------------------------------------------------
  // AppUser
  // ---------------------------------------------------------------------------

  @override
  Future<List<AppUser>> getUsers() async {
    final response = await _client.from(_usersTable).select();
    return List<Map<String, dynamic>>.from(response)
        .map(_userFromJson)
        .toList();
  }

  @override
  Future<AppUser?> getUserById(String userId) async {
    final response = await _client
        .from(_usersTable)
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (response == null) return null;
    return _userFromJson(response);
  }

  @override
  Future<List<AppUser>> getUsersByFirm(String firmId) async {
    final response = await _client
        .from(_usersTable)
        .select()
        .eq('firm_id', firmId);
    return List<Map<String, dynamic>>.from(response)
        .map(_userFromJson)
        .toList();
  }

  @override
  Future<String> insertUser(AppUser user) async {
    final response = await _client
        .from(_usersTable)
        .insert(_userToJson(user))
        .select()
        .single();
    return response['user_id'] as String;
  }

  @override
  Future<bool> updateUser(AppUser user) async {
    await _client
        .from(_usersTable)
        .update(_userToJson(user))
        .eq('user_id', user.userId);
    return true;
  }

  @override
  Future<bool> deleteUser(String userId) async {
    await _client.from(_usersTable).delete().eq('user_id', userId);
    return true;
  }

  // ---------------------------------------------------------------------------
  // AuditLog
  // ---------------------------------------------------------------------------

  @override
  Future<List<AuditLogEntry>> getAuditLogs() async {
    final response =
        await _client.from(_auditTable).select().order('timestamp');
    return List<Map<String, dynamic>>.from(response)
        .map(_auditFromJson)
        .toList();
  }

  @override
  Future<List<AuditLogEntry>> getAuditLogsByUser(String userId) async {
    final response = await _client
        .from(_auditTable)
        .select()
        .eq('user_id', userId)
        .order('timestamp');
    return List<Map<String, dynamic>>.from(response)
        .map(_auditFromJson)
        .toList();
  }

  @override
  Future<List<AuditLogEntry>> getAuditLogsBySeverity(
    LogSeverity severity,
  ) async {
    final response = await _client
        .from(_auditTable)
        .select()
        .eq('severity', severity.name)
        .order('timestamp');
    return List<Map<String, dynamic>>.from(response)
        .map(_auditFromJson)
        .toList();
  }

  @override
  Future<String> insertAuditLog(AuditLogEntry entry) async {
    final response = await _client
        .from(_auditTable)
        .insert(_auditToJson(entry))
        .select()
        .single();
    return response['log_id'] as String;
  }

  // ---------------------------------------------------------------------------
  // PushNotification
  // ---------------------------------------------------------------------------

  @override
  Future<List<PushNotification>> getNotifications() async {
    final response =
        await _client.from(_notifTable).select().order('sent_at');
    return List<Map<String, dynamic>>.from(response)
        .map(_notifFromJson)
        .toList();
  }

  @override
  Future<List<PushNotification>> getNotificationsByUser(String userId) async {
    final response = await _client
        .from(_notifTable)
        .select()
        .eq('user_id', userId)
        .order('sent_at');
    return List<Map<String, dynamic>>.from(response)
        .map(_notifFromJson)
        .toList();
  }

  @override
  Future<String> insertNotification(PushNotification notification) async {
    final response = await _client
        .from(_notifTable)
        .insert(_notifToJson(notification))
        .select()
        .single();
    return response['notification_id'] as String;
  }

  @override
  Future<bool> markNotificationRead(String notificationId) async {
    await _client
        .from(_notifTable)
        .update({'read_at': DateTime.now().toIso8601String()})
        .eq('notification_id', notificationId);
    return true;
  }

  // ---------------------------------------------------------------------------
  // SyncQueueItem
  // ---------------------------------------------------------------------------

  @override
  Future<List<SyncQueueItem>> getSyncQueueItems() async {
    final response =
        await _client.from(_syncTable).select().order('created_at');
    return List<Map<String, dynamic>>.from(response)
        .map(_syncFromJson)
        .toList();
  }

  @override
  Future<List<SyncQueueItem>> getSyncQueueItemsByStatus(
    SyncStatus status,
  ) async {
    final response = await _client
        .from(_syncTable)
        .select()
        .eq('status', status.name);
    return List<Map<String, dynamic>>.from(response)
        .map(_syncFromJson)
        .toList();
  }

  @override
  Future<String> insertSyncQueueItem(SyncQueueItem item) async {
    final response = await _client
        .from(_syncTable)
        .insert(_syncToJson(item))
        .select()
        .single();
    return response['item_id'] as String;
  }

  @override
  Future<bool> updateSyncQueueItemStatus(
    String itemId,
    SyncStatus status,
  ) async {
    await _client
        .from(_syncTable)
        .update({'status': status.name})
        .eq('item_id', itemId);
    return true;
  }

  @override
  Future<bool> deleteSyncQueueItem(String itemId) async {
    await _client.from(_syncTable).delete().eq('item_id', itemId);
    return true;
  }

  // ---------------------------------------------------------------------------
  // Mappers
  // ---------------------------------------------------------------------------

  AppUser _userFromJson(Map<String, dynamic> j) => AppUser(
        userId: j['user_id'] as String,
        email: j['email'] as String,
        name: j['name'] as String,
        role: UserRole.values
            .firstWhere((r) => r.name == j['role'] as String),
        firmId: j['firm_id'] as String,
        mfaEnabled: j['mfa_enabled'] as bool,
        isActive: j['is_active'] as bool,
        createdAt: DateTime.parse(j['created_at'] as String),
        lastLoginAt: j['last_login_at'] != null
            ? DateTime.parse(j['last_login_at'] as String)
            : null,
      );

  Map<String, dynamic> _userToJson(AppUser u) => {
        'user_id': u.userId,
        'email': u.email,
        'name': u.name,
        'role': u.role.name,
        'firm_id': u.firmId,
        'mfa_enabled': u.mfaEnabled,
        'is_active': u.isActive,
        'created_at': u.createdAt.toIso8601String(),
        'last_login_at': u.lastLoginAt?.toIso8601String(),
      };

  AuditLogEntry _auditFromJson(Map<String, dynamic> j) => AuditLogEntry(
        logId: j['log_id'] as String,
        userId: j['user_id'] as String,
        userName: j['user_name'] as String,
        action: j['action'] as String,
        resourceType: j['resource_type'] as String?,
        resourceId: j['resource_id'] as String?,
        timestamp: DateTime.parse(j['timestamp'] as String),
        ipAddress: j['ip_address'] as String?,
        metadata: Map<String, String>.from(
          (j['metadata'] as Map<String, dynamic>?) ?? {},
        ),
        severity: LogSeverity.values
            .firstWhere((s) => s.name == j['severity'] as String),
      );

  Map<String, dynamic> _auditToJson(AuditLogEntry e) => {
        'log_id': e.logId,
        'user_id': e.userId,
        'user_name': e.userName,
        'action': e.action,
        'resource_type': e.resourceType,
        'resource_id': e.resourceId,
        'timestamp': e.timestamp.toIso8601String(),
        'ip_address': e.ipAddress,
        'metadata': e.metadata,
        'severity': e.severity.name,
      };

  PushNotification _notifFromJson(Map<String, dynamic> j) => PushNotification(
        notificationId: j['notification_id'] as String,
        userId: j['user_id'] as String,
        title: j['title'] as String,
        body: j['body'] as String,
        type: NotificationType.values
            .firstWhere((t) => t.name == j['type'] as String),
        data: Map<String, String>.from(
          (j['data'] as Map<String, dynamic>?) ?? {},
        ),
        sentAt: DateTime.parse(j['sent_at'] as String),
        readAt: j['read_at'] != null
            ? DateTime.parse(j['read_at'] as String)
            : null,
      );

  Map<String, dynamic> _notifToJson(PushNotification n) => {
        'notification_id': n.notificationId,
        'user_id': n.userId,
        'title': n.title,
        'body': n.body,
        'type': n.type.name,
        'data': n.data,
        'sent_at': n.sentAt.toIso8601String(),
        'read_at': n.readAt?.toIso8601String(),
      };

  SyncQueueItem _syncFromJson(Map<String, dynamic> j) => SyncQueueItem(
        itemId: j['item_id'] as String,
        entityType: j['entity_type'] as String,
        entityId: j['entity_id'] as String,
        operation: SyncOperation.values
            .firstWhere((o) => o.name == j['operation'] as String),
        payload: j['payload'] as String,
        createdAt: DateTime.parse(j['created_at'] as String),
        syncedAt: j['synced_at'] != null
            ? DateTime.parse(j['synced_at'] as String)
            : null,
        status: SyncStatus.values
            .firstWhere((s) => s.name == j['status'] as String),
        conflictResolution: j['conflict_resolution'] != null
            ? ConflictResolution.values.firstWhere(
                (r) => r.name == j['conflict_resolution'] as String,
              )
            : null,
      );

  Map<String, dynamic> _syncToJson(SyncQueueItem i) => {
        'item_id': i.itemId,
        'entity_type': i.entityType,
        'entity_id': i.entityId,
        'operation': i.operation.name,
        'payload': i.payload,
        'created_at': i.createdAt.toIso8601String(),
        'synced_at': i.syncedAt?.toIso8601String(),
        'status': i.status.name,
        'conflict_resolution': i.conflictResolution?.name,
      };
}
