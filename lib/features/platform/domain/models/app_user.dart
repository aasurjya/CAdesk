<<<<<<< HEAD
// ignore_for_file: public_member_api_docs

import 'package:ca_app/features/platform/domain/models/permission.dart';

/// Represents an authenticated user within the CA firm application.
final class AppUser {
=======
import 'package:ca_app/features/platform/domain/services/rbac_service.dart';

/// Role hierarchy for CA firm staff.
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

/// Immutable model representing an authenticated user of the CADesk platform.
class AppUser {
>>>>>>> worktree-agent-ad3dc1f5
  const AppUser({
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
    required this.firmId,
    required this.mfaEnabled,
    required this.isActive,
    required this.createdAt,
<<<<<<< HEAD
=======
    this.lastLoginAt,
>>>>>>> worktree-agent-ad3dc1f5
  });

  final String userId;
  final String email;
  final String name;
  final UserRole role;
  final String firmId;
  final bool mfaEnabled;
  final bool isActive;
<<<<<<< HEAD
  final DateTime createdAt;

  /// Convenience: set of permission codes derived from [role].
  ///
  /// Returns an empty set when the user is inactive.
  Set<String> get permissions {
    if (!isActive) return const {};
    return kRolePermissions[role] ?? const {};
=======
  final DateTime? lastLoginAt;
  final DateTime createdAt;

  /// Permission codes derived from the user's role via [RbacService].
  List<String> get permissions {
    return RbacService.instance
        .getPermissions(role)
        .map((p) => p.code)
        .toList(growable: false);
>>>>>>> worktree-agent-ad3dc1f5
  }

  AppUser copyWith({
    String? userId,
    String? email,
    String? name,
    UserRole? role,
    String? firmId,
    bool? mfaEnabled,
    bool? isActive,
<<<<<<< HEAD
=======
    DateTime? lastLoginAt,
>>>>>>> worktree-agent-ad3dc1f5
    DateTime? createdAt,
  }) {
    return AppUser(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      firmId: firmId ?? this.firmId,
      mfaEnabled: mfaEnabled ?? this.mfaEnabled,
      isActive: isActive ?? this.isActive,
<<<<<<< HEAD
=======
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
>>>>>>> worktree-agent-ad3dc1f5
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
<<<<<<< HEAD
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          runtimeType == other.runtimeType &&
          userId == other.userId;
=======
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser && other.userId == userId;
  }
>>>>>>> worktree-agent-ad3dc1f5

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() =>
      'AppUser(userId: $userId, email: $email, role: $role, isActive: $isActive)';
}
