// ignore_for_file: public_member_api_docs

import 'package:ca_app/features/platform/domain/models/app_user.dart';
import 'package:ca_app/features/platform/domain/models/permission.dart';

/// Role-Based Access Control service.
///
/// Stateless singleton — use [RbacService.instance].
final class RbacService {
  RbacService._();

  static final RbacService instance = RbacService._();

  // ---------------------------------------------------------------------------
  // Permission catalogue
  // ---------------------------------------------------------------------------

  static const List<Permission> _allPermissions = [
    // ITR
    Permission(
      code: 'itr.view',
      module: 'ITR',
      level: PermissionLevel.view,
      description: 'View ITR filings',
    ),
    Permission(
      code: 'itr.edit',
      module: 'ITR',
      level: PermissionLevel.edit,
      description: 'Edit ITR filings',
    ),
    Permission(
      code: 'itr.file',
      module: 'ITR',
      level: PermissionLevel.file,
      description: 'File ITR returns',
    ),
    // GST
    Permission(
      code: 'gst.view',
      module: 'GST',
      level: PermissionLevel.view,
      description: 'View GST returns',
    ),
    Permission(
      code: 'gst.edit',
      module: 'GST',
      level: PermissionLevel.edit,
      description: 'Edit GST returns',
    ),
    Permission(
      code: 'gst.file',
      module: 'GST',
      level: PermissionLevel.file,
      description: 'File GST returns',
    ),
    // TDS
    Permission(
      code: 'tds.view',
      module: 'TDS',
      level: PermissionLevel.view,
      description: 'View TDS entries',
    ),
    Permission(
      code: 'tds.edit',
      module: 'TDS',
      level: PermissionLevel.edit,
      description: 'Edit TDS entries',
    ),
    Permission(
      code: 'tds.file',
      module: 'TDS',
      level: PermissionLevel.file,
      description: 'File TDS returns',
    ),
    // Admin
    Permission(
      code: 'admin.users',
      module: 'admin',
      level: PermissionLevel.admin,
      description: 'Manage firm users',
    ),
    Permission(
      code: 'admin.firm',
      module: 'admin',
      level: PermissionLevel.admin,
      description: 'Manage firm settings',
    ),
  ];

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns the [Permission] objects granted to [role].
  List<Permission> getPermissions(UserRole role) {
    final codes = kRolePermissions[role] ?? const {};
    return _allPermissions.where((p) => codes.contains(p.code)).toList();
  }

  /// Returns `true` when [user] is active and holds [permissionCode].
  bool hasPermission(AppUser user, String permissionCode) {
    if (!user.isActive) return false;
    final codes = kRolePermissions[user.role] ?? const {};
    return codes.contains(permissionCode);
  }

  /// Returns `true` when [user] can perform [action] on [module].
  ///
  /// The permission code is derived as `<module.toLowerCase()>.<action>`.
  bool canAccess(AppUser user, String module, String action) {
    final code = '${module.toLowerCase()}.$action';
    return hasPermission(user, code);
  }
}
