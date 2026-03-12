import 'package:ca_app/features/platform/domain/models/app_user.dart';
import 'package:ca_app/features/platform/domain/models/permission.dart';
import 'package:ca_app/features/platform/domain/services/rbac_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = RbacService.instance;

  AppUser makeUser({
    required UserRole role,
    bool isActive = true,
  }) {
    return AppUser(
      userId: 'user-1',
      email: 'test@example.com',
      name: 'Test User',
      role: role,
      firmId: 'firm-1',
      mfaEnabled: false,
      isActive: isActive,
      createdAt: DateTime(2025, 1, 1),
    );
  }

  group('RbacService.getPermissions', () {
    test('superAdmin receives all permission codes including admin.firm', () {
      final perms = service.getPermissions(UserRole.superAdmin);
      final codes = perms.map((p) => p.code).toSet();

      expect(codes, contains('itr.view'));
      expect(codes, contains('itr.edit'));
      expect(codes, contains('itr.file'));
      expect(codes, contains('gst.edit'));
      expect(codes, contains('tds.file'));
      expect(codes, contains('admin.users'));
      expect(codes, contains('admin.firm'));
    });

    test('firmOwner has all permissions except superAdmin-only codes', () {
      final perms = service.getPermissions(UserRole.firmOwner);
      final codes = perms.map((p) => p.code).toSet();

      expect(codes, contains('itr.file'));
      expect(codes, contains('admin.users'));
      expect(codes, contains('admin.firm'));
    });

    test('partner cannot manage users or firm settings', () {
      final perms = service.getPermissions(UserRole.partner);
      final codes = perms.map((p) => p.code).toSet();

      expect(codes, contains('itr.file'));
      expect(codes, contains('gst.edit'));
      expect(codes, isNot(contains('admin.users')));
      expect(codes, isNot(contains('admin.firm')));
    });

    test('manager can file but cannot manage admin', () {
      final perms = service.getPermissions(UserRole.manager);
      final codes = perms.map((p) => p.code).toSet();

      expect(codes, contains('itr.file'));
      expect(codes, contains('tds.file'));
      expect(codes, isNot(contains('admin.users')));
    });

    test('senior can edit and file but not admin', () {
      final perms = service.getPermissions(UserRole.senior);
      final codes = perms.map((p) => p.code).toSet();

      expect(codes, contains('itr.file'));
      expect(codes, contains('gst.edit'));
      expect(codes, isNot(contains('admin.users')));
    });

    test('junior can edit but cannot file itr or tds', () {
      final perms = service.getPermissions(UserRole.junior);
      final codes = perms.map((p) => p.code).toSet();

      expect(codes, contains('itr.edit'));
      expect(codes, contains('gst.edit'));
      expect(codes, isNot(contains('itr.file')));
      expect(codes, isNot(contains('tds.file')));
    });

    test('articleClerk can only view and not edit', () {
      final perms = service.getPermissions(UserRole.articleClerk);
      final codes = perms.map((p) => p.code).toSet();

      expect(codes, contains('itr.view'));
      expect(codes, isNot(contains('itr.edit')));
      expect(codes, isNot(contains('gst.edit')));
    });

    test('viewOnly has only view permissions', () {
      final perms = service.getPermissions(UserRole.viewOnly);
      final codes = perms.map((p) => p.code).toSet();

      expect(codes, contains('itr.view'));
      expect(codes, isNot(contains('itr.edit')));
      expect(codes, isNot(contains('itr.file')));
    });

    test('returns Permission objects with correct fields', () {
      final perms = service.getPermissions(UserRole.superAdmin);
      final itrView = perms.firstWhere((p) => p.code == 'itr.view');

      expect(itrView.module, 'ITR');
      expect(itrView.level, PermissionLevel.view);
      expect(itrView.description, isNotEmpty);
    });
  });

  group('RbacService.hasPermission', () {
    test('returns true when user has the permission code', () {
      final user = makeUser(role: UserRole.superAdmin);
      expect(service.hasPermission(user, 'itr.file'), isTrue);
    });

    test('returns false when user does not have the permission', () {
      final user = makeUser(role: UserRole.viewOnly);
      expect(service.hasPermission(user, 'itr.edit'), isFalse);
    });

    test('returns false for inactive user even with valid role', () {
      final user = makeUser(role: UserRole.superAdmin, isActive: false);
      expect(service.hasPermission(user, 'itr.view'), isFalse);
    });

    test('returns false for non-existent permission code', () {
      final user = makeUser(role: UserRole.superAdmin);
      expect(service.hasPermission(user, 'nonexistent.permission'), isFalse);
    });
  });

  group('RbacService.canAccess', () {
    test('firmOwner can access ITR module with edit action', () {
      final user = makeUser(role: UserRole.firmOwner);
      expect(service.canAccess(user, 'ITR', 'edit'), isTrue);
    });

    test('articleClerk cannot edit GST module', () {
      final user = makeUser(role: UserRole.articleClerk);
      expect(service.canAccess(user, 'GST', 'edit'), isFalse);
    });

    test('articleClerk can view ITR module', () {
      final user = makeUser(role: UserRole.articleClerk);
      expect(service.canAccess(user, 'ITR', 'view'), isTrue);
    });

    test('partner cannot access admin module with users action', () {
      final user = makeUser(role: UserRole.partner);
      expect(service.canAccess(user, 'admin', 'users'), isFalse);
    });

    test('manager can file TDS', () {
      final user = makeUser(role: UserRole.manager);
      expect(service.canAccess(user, 'tds', 'file'), isTrue);
    });
  });

  group('AppUser permissions computed from role', () {
    test('superAdmin user permissions include all codes', () {
      final user = makeUser(role: UserRole.superAdmin);
      expect(user.permissions, contains('itr.file'));
      expect(user.permissions, contains('admin.users'));
    });

    test('viewOnly user permissions contain only view codes', () {
      final user = makeUser(role: UserRole.viewOnly);
      expect(user.permissions, contains('itr.view'));
      expect(user.permissions, isNot(contains('itr.edit')));
    });
  });
}
