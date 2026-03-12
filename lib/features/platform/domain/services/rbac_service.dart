import 'package:ca_app/features/platform/domain/models/app_user.dart';
import 'package:ca_app/features/platform/domain/models/permission.dart';

/// Stateless singleton that owns the RBAC permission matrix for CADesk.
///
/// Permission codes follow the "{module}.{level}" convention:
///   e.g. "itr.view", "gst.edit", "tds.file", "admin.users"
class RbacService {
  RbacService._();

  static final RbacService instance = RbacService._();

  // ---------------------------------------------------------------------------
  // Permission catalogue
  // ---------------------------------------------------------------------------

  static const Permission _itrView = Permission(
    code: 'itr.view',
    description: 'View Income Tax Returns',
    module: 'ITR',
    level: PermissionLevel.view,
  );
  static const Permission _itrEdit = Permission(
    code: 'itr.edit',
    description: 'Edit Income Tax Returns',
    module: 'ITR',
    level: PermissionLevel.edit,
  );
  static const Permission _itrFile = Permission(
    code: 'itr.file',
    description: 'File Income Tax Returns',
    module: 'ITR',
    level: PermissionLevel.file,
  );
  static const Permission _gstView = Permission(
    code: 'gst.view',
    description: 'View GST Returns',
    module: 'GST',
    level: PermissionLevel.view,
  );
  static const Permission _gstEdit = Permission(
    code: 'gst.edit',
    description: 'Edit GST Returns',
    module: 'GST',
    level: PermissionLevel.edit,
  );
  static const Permission _gstFile = Permission(
    code: 'gst.file',
    description: 'File GST Returns',
    module: 'GST',
    level: PermissionLevel.file,
  );
  static const Permission _tdsView = Permission(
    code: 'tds.view',
    description: 'View TDS Returns',
    module: 'TDS',
    level: PermissionLevel.view,
  );
  static const Permission _tdsEdit = Permission(
    code: 'tds.edit',
    description: 'Edit TDS Returns',
    module: 'TDS',
    level: PermissionLevel.edit,
  );
  static const Permission _tdsFile = Permission(
    code: 'tds.file',
    description: 'File TDS Returns',
    module: 'TDS',
    level: PermissionLevel.file,
  );
  static const Permission _adminUsers = Permission(
    code: 'admin.users',
    description: 'Manage firm users',
    module: 'admin',
    level: PermissionLevel.admin,
  );
  static const Permission _adminFirm = Permission(
    code: 'admin.firm',
    description: 'Manage firm settings',
    module: 'admin',
    level: PermissionLevel.admin,
  );

  // ---------------------------------------------------------------------------
  // RBAC Matrix
  // ---------------------------------------------------------------------------

  static const List<Permission> _viewOnlyPermissions = [
    _itrView,
    _gstView,
    _tdsView,
  ];

  static const List<Permission> _articleClerkPermissions = [
    _itrView,
    _gstView,
    _tdsView,
  ];

  static const List<Permission> _juniorPermissions = [
    _itrView,
    _itrEdit,
    _gstView,
    _gstEdit,
    _tdsView,
    _tdsEdit,
  ];

  static const List<Permission> _seniorPermissions = [
    _itrView,
    _itrEdit,
    _itrFile,
    _gstView,
    _gstEdit,
    _gstFile,
    _tdsView,
    _tdsEdit,
    _tdsFile,
  ];

  static const List<Permission> _managerPermissions = [
    _itrView,
    _itrEdit,
    _itrFile,
    _gstView,
    _gstEdit,
    _gstFile,
    _tdsView,
    _tdsEdit,
    _tdsFile,
  ];

  static const List<Permission> _partnerPermissions = [
    _itrView,
    _itrEdit,
    _itrFile,
    _gstView,
    _gstEdit,
    _gstFile,
    _tdsView,
    _tdsEdit,
    _tdsFile,
  ];

  static const List<Permission> _firmOwnerPermissions = [
    _itrView,
    _itrEdit,
    _itrFile,
    _gstView,
    _gstEdit,
    _gstFile,
    _tdsView,
    _tdsEdit,
    _tdsFile,
    _adminUsers,
    _adminFirm,
  ];

  static const List<Permission> _superAdminPermissions = [
    _itrView,
    _itrEdit,
    _itrFile,
    _gstView,
    _gstEdit,
    _gstFile,
    _tdsView,
    _tdsEdit,
    _tdsFile,
    _adminUsers,
    _adminFirm,
  ];

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns the list of [Permission] objects for a given [role].
  List<Permission> getPermissions(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return _superAdminPermissions;
      case UserRole.firmOwner:
        return _firmOwnerPermissions;
      case UserRole.partner:
        return _partnerPermissions;
      case UserRole.manager:
        return _managerPermissions;
      case UserRole.senior:
        return _seniorPermissions;
      case UserRole.junior:
        return _juniorPermissions;
      case UserRole.articleClerk:
        return _articleClerkPermissions;
      case UserRole.viewOnly:
        return _viewOnlyPermissions;
    }
  }

  /// Returns true when [user] is active and their role grants [permissionCode].
  bool hasPermission(AppUser user, String permissionCode) {
    if (!user.isActive) return false;
    return getPermissions(user.role).any((p) => p.code == permissionCode);
  }

  /// Returns true when [user] can perform [action] on [module].
  ///
  /// Constructs a permission code as "{module.toLowerCase()}.{action}" and
  /// delegates to [hasPermission].
  bool canAccess(AppUser user, String module, String action) {
    final code = '${module.toLowerCase()}.$action';
    return hasPermission(user, code);
  }
}
