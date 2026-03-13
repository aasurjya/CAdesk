import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/platform/domain/models/app_user.dart';

/// ListTile showing a team member with avatar initials, role chip, and last
/// active relative time.
class UserRoleTile extends StatelessWidget {
  const UserRoleTile({super.key, required this.user, this.onTap});

  final AppUser user;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _initials(user.name);
    final roleColor = _roleColor(user.role);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: roleColor.withValues(alpha: 0.15),
        child: Text(
          initials,
          style: theme.textTheme.labelLarge?.copyWith(
            color: roleColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      title: Text(
        user.name,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.neutral900,
        ),
      ),
      subtitle: Text(
        user.email,
        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.neutral400),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _RoleChip(role: user.role),
          const SizedBox(height: 4),
          Text(
            _relativeTime(user.lastLoginAt),
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  static String _relativeTime(DateTime? dt) {
    if (dt == null) return 'Never';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  static Color _roleColor(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return AppColors.error;
      case UserRole.firmOwner:
        return AppColors.primary;
      case UserRole.partner:
        return AppColors.secondary;
      case UserRole.manager:
        return AppColors.accent;
      case UserRole.senior:
      case UserRole.junior:
        return AppColors.success;
      case UserRole.articleClerk:
        return AppColors.neutral600;
      case UserRole.viewOnly:
        return AppColors.neutral400;
    }
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = UserRoleTile._roleColor(role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _roleLabel(role),
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.firmOwner:
        return 'Firm Owner';
      case UserRole.partner:
        return 'Partner';
      case UserRole.manager:
        return 'Manager';
      case UserRole.senior:
        return 'Senior';
      case UserRole.junior:
        return 'Junior';
      case UserRole.articleClerk:
        return 'Article Clerk';
      case UserRole.viewOnly:
        return 'View Only';
    }
  }
}
