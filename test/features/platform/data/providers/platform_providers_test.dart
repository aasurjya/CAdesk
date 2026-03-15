import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/platform/data/providers/platform_providers.dart';
import 'package:ca_app/features/platform/domain/models/app_user.dart';
import 'package:ca_app/features/platform/domain/models/sync_queue_item.dart';
import 'package:ca_app/features/platform/domain/services/audit_trail_service.dart';
import 'package:ca_app/features/platform/domain/services/mfa_service.dart';
import 'package:ca_app/features/platform/domain/services/offline_sync_service.dart';
import 'package:ca_app/features/platform/domain/services/rbac_service.dart';

void main() {
  group('Service providers', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('rbacServiceProvider returns RbacService instance', () {
      final service = container.read(rbacServiceProvider);
      expect(service, isA<RbacService>());
    });

    test('mfaServiceProvider returns MfaService instance', () {
      final service = container.read(mfaServiceProvider);
      expect(service, isA<MfaService>());
    });

    test('auditTrailServiceProvider returns AuditTrailService instance', () {
      final service = container.read(auditTrailServiceProvider);
      expect(service, isA<AuditTrailService>());
    });

    test('offlineSyncServiceProvider returns OfflineSyncService instance', () {
      final service = container.read(offlineSyncServiceProvider);
      expect(service, isA<OfflineSyncService>());
    });
  });

  group('CurrentUserRoleNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial role is firmOwner', () {
      expect(container.read(currentUserRoleProvider), UserRole.firmOwner);
    });

    test('can be changed to partner', () {
      container.read(currentUserRoleProvider.notifier).update(UserRole.partner);
      expect(container.read(currentUserRoleProvider), UserRole.partner);
    });

    test('can be changed to articleClerk', () {
      container
          .read(currentUserRoleProvider.notifier)
          .update(UserRole.articleClerk);
      expect(
        container.read(currentUserRoleProvider),
        UserRole.articleClerk,
      );
    });
  });

  group('TeamMembersNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state has 5 team members', () {
      final members = container.read(teamMembersProvider);
      expect(members.length, 5);
    });

    test('all members have non-empty userIds', () {
      final members = container.read(teamMembersProvider);
      expect(members.every((m) => m.userId.isNotEmpty), isTrue);
    });

    test('updateRole changes role of matching user', () {
      container
          .read(teamMembersProvider.notifier)
          .updateRole('user-003', UserRole.manager);
      final updated = container
          .read(teamMembersProvider)
          .firstWhere((m) => m.userId == 'user-003');
      expect(updated.role, UserRole.manager);
    });

    test('deactivate marks user as inactive', () {
      container.read(teamMembersProvider.notifier).deactivate('user-005');
      final deactivated = container
          .read(teamMembersProvider)
          .firstWhere((m) => m.userId == 'user-005');
      expect(deactivated.isActive, isFalse);
    });

    test('list is unmodifiable', () {
      final members = container.read(teamMembersProvider);
      expect(() => (members as dynamic).add(null), throwsA(isA<Error>()));
    });
  });

  group('AuditLogsNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state has 10 audit log entries', () {
      final logs = container.read(auditLogsProvider);
      expect(logs.length, 10);
    });

    test('all logs have non-empty logIds', () {
      final logs = container.read(auditLogsProvider);
      expect(logs.every((l) => l.logId.isNotEmpty), isTrue);
    });

    test('list is unmodifiable', () {
      final logs = container.read(auditLogsProvider);
      expect(() => (logs as dynamic).add(null), throwsA(isA<Error>()));
    });
  });

  group('SyncQueueNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state has 3 sync queue items', () {
      final queue = container.read(syncQueueProvider);
      expect(queue.length, 3);
    });

    test('retryItem sets failed item back to pending', () {
      container.read(syncQueueProvider.notifier).retryItem('sync-002');
      final item = container
          .read(syncQueueProvider)
          .firstWhere((i) => i.itemId == 'sync-002');
      expect(item.status, SyncStatus.pending);
    });
  });

  group('MfaSetupNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(mfaSetupProvider), isNull);
    });

    test('can be cleared to null after being set', () {
      container.read(mfaSetupProvider.notifier).setSetup(null);
      expect(container.read(mfaSetupProvider), isNull);
    });
  });
}
