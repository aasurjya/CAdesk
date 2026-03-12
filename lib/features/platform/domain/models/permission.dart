/// Access level granted by a permission.
enum PermissionLevel { view, edit, file, admin }

/// Immutable model representing a single permission in the RBAC system.
class Permission {
  const Permission({
    required this.code,
    required this.description,
    required this.module,
    required this.level,
  });

  /// Permission code in "{module}.{level}" format, e.g. "itr.view", "admin.users".
  final String code;
  final String description;

  /// Module name, e.g. "ITR", "GST", "TDS", "admin".
  final String module;
  final PermissionLevel level;

  Permission copyWith({
    String? code,
    String? description,
    String? module,
    PermissionLevel? level,
  }) {
    return Permission(
      code: code ?? this.code,
      description: description ?? this.description,
      module: module ?? this.module,
      level: level ?? this.level,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Permission && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'Permission(code: $code, module: $module, level: $level)';
}
