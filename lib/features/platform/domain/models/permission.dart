// ignore_for_file: public_member_api_docs

/// Roles available in the CA firm hierarchy.
enum UserRole {
  superAdmin,
  firmOwner,
  partner,
  manager,
  senior,
  junior,
  articleClerk,
  viewOnly,
}

/// Granular access levels for a permission.
enum PermissionLevel { view, edit, file, admin }

/// A single permission granted to a role.
final class Permission {
  const Permission({
    required this.code,
    required this.module,
    required this.level,
    required this.description,
  });

  final String code;
  final String module;
  final PermissionLevel level;
  final String description;

  Permission copyWith({
    String? code,
    String? module,
    PermissionLevel? level,
    String? description,
  }) {
    return Permission(
      code: code ?? this.code,
      module: module ?? this.module,
      level: level ?? this.level,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Permission &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() =>
      'Permission(code: $code, module: $module, level: $level)';
}

/// Canonical mapping of [UserRole] to the set of permission codes it grants.
///
/// Used by both [RbacService] and [AppUser] to avoid circular imports.
const Map<UserRole, Set<String>> kRolePermissions = {
  UserRole.superAdmin: {
    'itr.view', 'itr.edit', 'itr.file',
    'gst.view', 'gst.edit', 'gst.file',
    'tds.view', 'tds.edit', 'tds.file',
    'admin.users', 'admin.firm',
  },
  UserRole.firmOwner: {
    'itr.view', 'itr.edit', 'itr.file',
    'gst.view', 'gst.edit', 'gst.file',
    'tds.view', 'tds.edit', 'tds.file',
    'admin.users', 'admin.firm',
  },
  UserRole.partner: {
    'itr.view', 'itr.edit', 'itr.file',
    'gst.view', 'gst.edit', 'gst.file',
    'tds.view', 'tds.edit', 'tds.file',
  },
  UserRole.manager: {
    'itr.view', 'itr.edit', 'itr.file',
    'gst.view', 'gst.edit', 'gst.file',
    'tds.view', 'tds.edit', 'tds.file',
  },
  UserRole.senior: {
    'itr.view', 'itr.edit', 'itr.file',
    'gst.view', 'gst.edit', 'gst.file',
    'tds.view', 'tds.edit',
  },
  UserRole.junior: {
    'itr.view', 'itr.edit',
    'gst.view', 'gst.edit',
    'tds.view', 'tds.edit',
  },
  UserRole.articleClerk: {
    'itr.view',
    'gst.view',
    'tds.view',
  },
  UserRole.viewOnly: {
    'itr.view',
    'gst.view',
    'tds.view',
  },
};
