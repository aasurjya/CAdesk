import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/features/platform/domain/models/app_user.dart';
import 'package:ca_app/features/platform/domain/models/audit_log_entry.dart';
import 'package:ca_app/features/platform/domain/models/mfa_setup.dart';
import 'package:ca_app/features/platform/domain/models/sync_queue_item.dart';
import 'package:ca_app/features/platform/domain/services/audit_trail_service.dart';
import 'package:ca_app/features/platform/domain/services/mfa_service.dart';
import 'package:ca_app/features/platform/domain/services/offline_sync_service.dart';
import 'package:ca_app/features/platform/domain/services/rbac_service.dart';

// ---------------------------------------------------------------------------
// Service providers
// ---------------------------------------------------------------------------

final rbacServiceProvider = Provider<RbacService>((_) => RbacService.instance);

final mfaServiceProvider = Provider<MfaService>((_) => MfaService.instance);

final auditTrailServiceProvider = Provider<AuditTrailService>(
  (_) => AuditTrailService(),
);

final offlineSyncServiceProvider = Provider<OfflineSyncService>(
  (_) => OfflineSyncService(),
);

// ---------------------------------------------------------------------------
// Current user role
// ---------------------------------------------------------------------------

final currentUserRoleProvider =
    NotifierProvider<CurrentUserRoleNotifier, UserRole>(
      CurrentUserRoleNotifier.new,
    );

class CurrentUserRoleNotifier extends Notifier<UserRole> {
  @override
  UserRole build() => UserRole.firmOwner;

  void update(UserRole role) => state = role;
}

// ---------------------------------------------------------------------------
// Team members
// ---------------------------------------------------------------------------

final teamMembersProvider =
    NotifierProvider<TeamMembersNotifier, List<AppUser>>(
      TeamMembersNotifier.new,
    );

class TeamMembersNotifier extends Notifier<List<AppUser>> {
  @override
  List<AppUser> build() => List.unmodifiable(_mockTeamMembers);

  void updateRole(String userId, UserRole newRole) {
    state = List.unmodifiable(
      state.map((u) => u.userId == userId ? u.copyWith(role: newRole) : u),
    );
  }

  void deactivate(String userId) {
    state = List.unmodifiable(
      state.map((u) => u.userId == userId ? u.copyWith(isActive: false) : u),
    );
  }
}

final _now = DateTime.now();

final _mockTeamMembers = <AppUser>[
  AppUser(
    userId: 'user-001',
    email: 'superadmin@cadeskindia.com',
    name: 'Ankit Gupta',
    role: UserRole.superAdmin,
    firmId: 'firm-001',
    mfaEnabled: true,
    isActive: true,
    createdAt: _now.subtract(const Duration(days: 365)),
    lastLoginAt: _now.subtract(const Duration(hours: 2)),
  ),
  AppUser(
    userId: 'user-002',
    email: 'owner@cadeskindia.com',
    name: 'Ramesh Iyer',
    role: UserRole.firmOwner,
    firmId: 'firm-001',
    mfaEnabled: true,
    isActive: true,
    createdAt: _now.subtract(const Duration(days: 300)),
    lastLoginAt: _now.subtract(const Duration(hours: 1)),
  ),
  AppUser(
    userId: 'user-003',
    email: 'partner@cadeskindia.com',
    name: 'Neha Kapoor',
    role: UserRole.partner,
    firmId: 'firm-001',
    mfaEnabled: false,
    isActive: true,
    createdAt: _now.subtract(const Duration(days: 200)),
    lastLoginAt: _now.subtract(const Duration(days: 1)),
  ),
  AppUser(
    userId: 'user-004',
    email: 'manager@cadeskindia.com',
    name: 'Amit Verma',
    role: UserRole.manager,
    firmId: 'firm-001',
    mfaEnabled: true,
    isActive: true,
    createdAt: _now.subtract(const Duration(days: 150)),
    lastLoginAt: _now.subtract(const Duration(hours: 5)),
  ),
  AppUser(
    userId: 'user-005',
    email: 'clerk@cadeskindia.com',
    name: 'Priya Nair',
    role: UserRole.articleClerk,
    firmId: 'firm-001',
    mfaEnabled: false,
    isActive: true,
    createdAt: _now.subtract(const Duration(days: 60)),
    lastLoginAt: _now.subtract(const Duration(days: 2)),
  ),
];

// ---------------------------------------------------------------------------
// Audit logs
// ---------------------------------------------------------------------------

final auditLogsProvider =
    NotifierProvider<AuditLogsNotifier, List<AuditLogEntry>>(
      AuditLogsNotifier.new,
    );

class AuditLogsNotifier extends Notifier<List<AuditLogEntry>> {
  @override
  List<AuditLogEntry> build() => List.unmodifiable(_mockAuditLogs);

  void refresh() {
    state = List.unmodifiable(
      _mockAuditLogs.toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp)),
    );
  }
}

final _mockAuditLogs = <AuditLogEntry>[
  AuditLogEntry(
    logId: 'log-001',
    userId: 'user-002',
    userName: 'Ramesh Iyer',
    action: 'USER_LOGIN',
    timestamp: _now.subtract(const Duration(hours: 1)),
    severity: LogSeverity.info,
    metadata: const {'ip': '192.168.1.1', 'device': 'MacBook Pro'},
    ipAddress: '192.168.1.1',
    resourceType: 'Session',
    resourceId: 'sess-001',
  ),
  AuditLogEntry(
    logId: 'log-002',
    userId: 'user-002',
    userName: 'Ramesh Iyer',
    action: 'ITR_FILED',
    timestamp: _now.subtract(const Duration(hours: 2)),
    severity: LogSeverity.info,
    metadata: const {'clientId': 'client-001', 'assessmentYear': 'AY 2026-27'},
    resourceType: 'FilingJob',
    resourceId: 'job-001',
  ),
  AuditLogEntry(
    logId: 'log-003',
    userId: 'user-003',
    userName: 'Neha Kapoor',
    action: 'CLIENT_CREATED',
    timestamp: _now.subtract(const Duration(hours: 3)),
    severity: LogSeverity.info,
    metadata: const {'clientName': 'Vikram Singh Rathore'},
    resourceType: 'Client',
    resourceId: 'client-015',
  ),
  AuditLogEntry(
    logId: 'log-004',
    userId: 'user-005',
    userName: 'Priya Nair',
    action: 'LOGIN_FAILED',
    timestamp: _now.subtract(const Duration(hours: 4)),
    severity: LogSeverity.warning,
    metadata: const {'attempts': '3', 'ip': '10.0.0.45'},
    ipAddress: '10.0.0.45',
    resourceType: 'Auth',
    resourceId: 'user-005',
  ),
  AuditLogEntry(
    logId: 'log-005',
    userId: 'user-004',
    userName: 'Amit Verma',
    action: 'DOCUMENT_SHARED',
    timestamp: _now.subtract(const Duration(hours: 6)),
    severity: LogSeverity.info,
    metadata: const {'documentId': 'doc-042', 'sharedWith': 'client-001'},
    resourceType: 'Document',
    resourceId: 'doc-042',
  ),
  AuditLogEntry(
    logId: 'log-006',
    userId: 'user-001',
    userName: 'Ankit Gupta',
    action: 'ROLE_CHANGED',
    timestamp: _now.subtract(const Duration(hours: 8)),
    severity: LogSeverity.warning,
    metadata: const {
      'targetUser': 'user-003',
      'from': 'manager',
      'to': 'partner',
    },
    resourceType: 'AppUser',
    resourceId: 'user-003',
  ),
  AuditLogEntry(
    logId: 'log-007',
    userId: 'user-002',
    userName: 'Ramesh Iyer',
    action: 'INVOICE_CREATED',
    timestamp: _now.subtract(const Duration(days: 1)),
    severity: LogSeverity.info,
    metadata: const {'invoiceId': 'INV-2026-042', 'amount': '25000'},
    resourceType: 'Invoice',
    resourceId: 'INV-2026-042',
  ),
  AuditLogEntry(
    logId: 'log-008',
    userId: 'user-005',
    userName: 'Priya Nair',
    action: 'UNAUTHORIZED_ACCESS',
    timestamp: _now.subtract(const Duration(days: 1, hours: 2)),
    severity: LogSeverity.critical,
    metadata: const {'attempted': 'admin.users', 'ip': '10.0.0.45'},
    ipAddress: '10.0.0.45',
    resourceType: 'Permission',
    resourceId: 'admin.users',
  ),
  AuditLogEntry(
    logId: 'log-009',
    userId: 'user-003',
    userName: 'Neha Kapoor',
    action: 'GST_RETURN_FILED',
    timestamp: _now.subtract(const Duration(days: 2)),
    severity: LogSeverity.info,
    metadata: const {
      'gstPeriod': 'Feb 2026',
      'clientId': 'client-003',
      'returnType': 'GSTR-3B',
    },
    resourceType: 'GstReturn',
    resourceId: 'gst-job-022',
  ),
  AuditLogEntry(
    logId: 'log-010',
    userId: 'user-001',
    userName: 'Ankit Gupta',
    action: 'DATA_EXPORT',
    timestamp: _now.subtract(const Duration(days: 3)),
    severity: LogSeverity.critical,
    metadata: const {
      'exportType': 'ClientList',
      'recordCount': '142',
      'format': 'CSV',
    },
    resourceType: 'Export',
    resourceId: 'export-001',
  ),
];

// ---------------------------------------------------------------------------
// Sync queue
// ---------------------------------------------------------------------------

final syncQueueProvider =
    NotifierProvider<SyncQueueNotifier, List<SyncQueueItem>>(
      SyncQueueNotifier.new,
    );

class SyncQueueNotifier extends Notifier<List<SyncQueueItem>> {
  @override
  List<SyncQueueItem> build() => List.unmodifiable(_mockSyncQueue);

  void retryItem(String itemId) {
    state = List.unmodifiable(
      state.map(
        (item) => item.itemId == itemId
            ? item.copyWith(status: SyncStatus.pending)
            : item,
      ),
    );
  }

  void markAllSynced() {
    final syncedAt = DateTime.now();
    state = List.unmodifiable(
      state.map(
        (item) => item.status == SyncStatus.pending
            ? item.copyWith(status: SyncStatus.synced, syncedAt: syncedAt)
            : item,
      ),
    );
  }
}

final _mockSyncQueue = <SyncQueueItem>[
  SyncQueueItem(
    itemId: 'sync-001',
    entityType: 'Client',
    entityId: 'client-015',
    operation: SyncOperation.create,
    payload: '{"name":"Vikram Singh Rathore","pan":"ABCDE1234F"}',
    createdAt: _now.subtract(const Duration(minutes: 15)),
    status: SyncStatus.pending,
  ),
  SyncQueueItem(
    itemId: 'sync-002',
    entityType: 'FilingJob',
    entityId: 'job-024',
    operation: SyncOperation.update,
    payload: '{"status":"filed","filedAt":"2026-03-12"}',
    createdAt: _now.subtract(const Duration(minutes: 30)),
    status: SyncStatus.failed,
  ),
  SyncQueueItem(
    itemId: 'sync-003',
    entityType: 'Invoice',
    entityId: 'INV-2026-042',
    operation: SyncOperation.create,
    payload: '{"amount":25000,"clientId":"client-002"}',
    createdAt: _now.subtract(const Duration(hours: 1)),
    status: SyncStatus.pending,
  ),
];

// ---------------------------------------------------------------------------
// MFA setup
// ---------------------------------------------------------------------------

final mfaSetupProvider = NotifierProvider<MfaSetupNotifier, MfaSetup?>(
  MfaSetupNotifier.new,
);

class MfaSetupNotifier extends Notifier<MfaSetup?> {
  @override
  MfaSetup? build() => null;

  void setSetup(MfaSetup? setup) => state = setup;
}
