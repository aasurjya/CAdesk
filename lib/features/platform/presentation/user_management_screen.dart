import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/platform/data/providers/platform_providers.dart';
import 'package:ca_app/features/platform/domain/models/app_user.dart';
import 'package:ca_app/features/platform/presentation/widgets/user_role_tile.dart';

/// Team members list with role filter chips and inline role-change bottom sheet.
class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  UserRole? _filterRole;

  @override
  Widget build(BuildContext context) {
    final allMembers = ref.watch(teamMembersProvider);
    final filtered = _filterRole == null
        ? allMembers
        : allMembers.where((u) => u.role == _filterRole).toList();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Team Members',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showInviteDialog(context),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Invite'),
      ),
      body: Column(
        children: [
          _RoleFilterBar(
            selectedRole: _filterRole,
            onRoleSelected: (role) => setState(() => _filterRole = role),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 720;
                if (isWide) {
                  return _TwoColumnMemberList(
                    members: filtered,
                    onMemberTap: (user) => _showRoleSheet(context, user),
                  );
                }
                return _MemberList(
                  members: filtered,
                  onMemberTap: (user) => _showRoleSheet(context, user),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showRoleSheet(BuildContext context, AppUser user) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _RoleChangeSheet(
        user: user,
        onRoleChanged: (newRole) {
          ref
              .read(teamMembersProvider.notifier)
              .updateRole(user.userId, newRole);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showInviteDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Invite Team Member'),
        content: const Text(
          'Invitation workflow coming soon.\n'
          'An email invite will be sent to the new user.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Role filter bar
// ---------------------------------------------------------------------------

class _RoleFilterBar extends StatelessWidget {
  const _RoleFilterBar({
    required this.selectedRole,
    required this.onRoleSelected,
  });

  final UserRole? selectedRole;
  final ValueChanged<UserRole?> onRoleSelected;

  static const _roles = [
    null,
    UserRole.superAdmin,
    UserRole.firmOwner,
    UserRole.partner,
    UserRole.manager,
    UserRole.articleClerk,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _roles.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final role = _roles[i];
          final label = role == null ? 'All' : _roleLabel(role);
          final selected = selectedRole == role;
          return ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => onRoleSelected(role),
          );
        },
      ),
    );
  }

  static String _roleLabel(UserRole r) {
    switch (r) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.firmOwner:
        return 'Firm Owner';
      case UserRole.partner:
        return 'Partner';
      case UserRole.manager:
        return 'Manager';
      case UserRole.articleClerk:
        return 'Article Clerk';
      default:
        return r.name;
    }
  }
}

// ---------------------------------------------------------------------------
// Member list widgets
// ---------------------------------------------------------------------------

class _MemberList extends StatelessWidget {
  const _MemberList({required this.members, required this.onMemberTap});

  final List<AppUser> members;
  final ValueChanged<AppUser> onMemberTap;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const Center(child: Text('No members match the selected filter.'));
    }
    return ListView.builder(
      itemCount: members.length,
      itemBuilder: (_, i) => Column(
        children: [
          UserRoleTile(user: members[i], onTap: () => onMemberTap(members[i])),
          if (i < members.length - 1)
            const Divider(indent: 72, height: 1),
        ],
      ),
    );
  }
}

class _TwoColumnMemberList extends StatelessWidget {
  const _TwoColumnMemberList({
    required this.members,
    required this.onMemberTap,
  });

  final List<AppUser> members;
  final ValueChanged<AppUser> onMemberTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3.5,
      ),
      itemCount: members.length,
      itemBuilder: (_, i) {
        final user = members[i];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.neutral200),
          ),
          child: UserRoleTile(user: user, onTap: () => onMemberTap(user)),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Role change bottom sheet
// ---------------------------------------------------------------------------

class _RoleChangeSheet extends StatelessWidget {
  const _RoleChangeSheet({required this.user, required this.onRoleChanged});

  final AppUser user;
  final ValueChanged<UserRole> onRoleChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Change Role — ${user.name}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Current: ${user.role.name}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
          const SizedBox(height: 16),
          ...UserRole.values.map(
            (role) => ListTile(
              leading: Icon(
                role == user.role
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: role == user.role
                    ? Theme.of(context).colorScheme.primary
                    : AppColors.neutral300,
              ),
              title: Text(role.name),
              onTap: () => onRoleChanged(role),
            ),
          ),
        ],
      ),
    );
  }
}
