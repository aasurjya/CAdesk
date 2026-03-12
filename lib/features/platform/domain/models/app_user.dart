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
  const AppUser({
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
    required this.firmId,
    required this.mfaEnabled,
    required this.isActive,
    required this.createdAt,
    this.lastLoginAt,
  });

  final String userId;
  final String email;
  final String name;
  final UserRole role;
  final String firmId;
  final bool mfaEnabled;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime createdAt;

  /// Permission codes derived from the user's role via [RbacService].
  List<String> get permissions {
    return RbacService.instance
        .getPermissions(role)
        .map((p) => p.code)
        .toList(growable: false);
  }

  AppUser copyWith({
    String? userId,
    String? email,
    String? name,
    UserRole? role,
    String? firmId,
    bool? mfaEnabled,
    bool? isActive,
    DateTime? lastLoginAt,
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
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() =>
      'AppUser(userId: $userId, email: $email, role: $role, isActive: $isActive)';
}
