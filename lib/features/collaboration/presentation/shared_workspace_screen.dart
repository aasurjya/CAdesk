import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

enum DocPermission { view, edit, comment }

extension DocPermissionX on DocPermission {
  String get label => switch (this) {
    DocPermission.view => 'View',
    DocPermission.edit => 'Edit',
    DocPermission.comment => 'Comment',
  };

  Color get color => switch (this) {
    DocPermission.view => AppColors.neutral400,
    DocPermission.edit => AppColors.primary,
    DocPermission.comment => AppColors.secondary,
  };
}

class WorkspaceUser {
  const WorkspaceUser({
    required this.name,
    required this.role,
    required this.isOnline,
    required this.avatarColor,
  });

  final String name;
  final String role;
  final bool isOnline;
  final Color avatarColor;
}

class SharedDocument {
  const SharedDocument({
    required this.name,
    required this.type,
    required this.sharedBy,
    required this.permission,
    required this.updatedAt,
  });

  final String name;
  final String type;
  final String sharedBy;
  final DocPermission permission;
  final DateTime updatedAt;
}

class ActivityItem {
  const ActivityItem({
    required this.user,
    required this.action,
    required this.timestamp,
    required this.icon,
    required this.color,
  });

  final String user;
  final String action;
  final DateTime timestamp;
  final IconData icon;
  final Color color;
}

class WorkspaceDetail {
  const WorkspaceDetail({
    required this.id,
    required this.name,
    required this.clientName,
    required this.users,
    required this.documents,
    required this.activities,
  });

  final String id;
  final String name;
  final String clientName;
  final List<WorkspaceUser> users;
  final List<SharedDocument> documents;
  final List<ActivityItem> activities;
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final _workspaceProvider = Provider.family<WorkspaceDetail, String>((
  ref,
  workspaceId,
) {
  return WorkspaceDetail(
    id: workspaceId,
    name: 'ITR Filing FY25-26',
    clientName: 'Rajesh Kumar',
    users: [
      WorkspaceUser(
        name: 'Amit Patel',
        role: 'CA Partner',
        isOnline: true,
        avatarColor: AppColors.primary,
      ),
      WorkspaceUser(
        name: 'Sneha Gupta',
        role: 'Tax Associate',
        isOnline: true,
        avatarColor: AppColors.secondary,
      ),
      WorkspaceUser(
        name: 'Vikram Singh',
        role: 'Article Clerk',
        isOnline: false,
        avatarColor: AppColors.warning,
      ),
    ],
    documents: [
      SharedDocument(
        name: 'Form 16 - Rajesh Kumar',
        type: 'PDF',
        sharedBy: 'Amit Patel',
        permission: DocPermission.view,
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      SharedDocument(
        name: 'ITR-1 Draft Computation',
        type: 'XLSX',
        sharedBy: 'Sneha Gupta',
        permission: DocPermission.edit,
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      SharedDocument(
        name: 'Form 26AS Reconciliation',
        type: 'PDF',
        sharedBy: 'Vikram Singh',
        permission: DocPermission.comment,
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      SharedDocument(
        name: 'Bank Statement FY25-26',
        type: 'PDF',
        sharedBy: 'Amit Patel',
        permission: DocPermission.view,
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ],
    activities: [
      ActivityItem(
        user: 'Sneha Gupta',
        action: 'Updated ITR-1 Draft Computation',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        icon: Icons.edit_rounded,
        color: AppColors.primary,
      ),
      ActivityItem(
        user: 'Amit Patel',
        action: 'Added comment on Form 26AS',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        icon: Icons.comment_rounded,
        color: AppColors.secondary,
      ),
      ActivityItem(
        user: 'Vikram Singh',
        action: 'Uploaded Form 26AS Reconciliation',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        icon: Icons.upload_file_rounded,
        color: AppColors.success,
      ),
      ActivityItem(
        user: 'Amit Patel',
        action: 'Created workspace',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        icon: Icons.add_circle_rounded,
        color: AppColors.warning,
      ),
    ],
  );
});

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class SharedWorkspaceScreen extends ConsumerWidget {
  const SharedWorkspaceScreen({super.key, required this.workspaceId});

  final String workspaceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(_workspaceProvider(workspaceId));
    final theme = Theme.of(context);

    final onlineCount = workspace.users.where((u) => u.isOnline).length;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workspace.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              workspace.clientName,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Active users
          _SectionHeader(
            title: 'Team ($onlineCount online)',
            icon: Icons.people_rounded,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: workspace.users.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _UserAvatar(user: workspace.users[index]),
            ),
          ),
          const SizedBox(height: 20),

          // Shared documents
          _SectionHeader(
            title: 'Documents (${workspace.documents.length})',
            icon: Icons.folder_shared_rounded,
          ),
          const SizedBox(height: 10),
          ...workspace.documents.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _DocumentTile(document: d),
            ),
          ),
          const SizedBox(height: 16),

          // Activity feed
          _SectionHeader(title: 'Activity', icon: Icons.history_rounded),
          const SizedBox(height: 10),
          ...workspace.activities.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ActivityTile(activity: a),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// User avatar
// ---------------------------------------------------------------------------

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.user});

  final WorkspaceUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = user.name.split(' ').map((w) => w[0]).take(2).join();

    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: user.avatarColor.withValues(alpha: 0.15),
              child: Text(
                initials,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: user.avatarColor,
                  fontSize: 14,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: user.isOnline
                      ? AppColors.success
                      : AppColors.neutral300,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          user.name.split(' ').first,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Document tile
// ---------------------------------------------------------------------------

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({required this.document});

  final SharedDocument document;

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  IconData _fileIcon(String type) => switch (type) {
    'PDF' => Icons.picture_as_pdf_rounded,
    'XLSX' => Icons.table_chart_rounded,
    _ => Icons.insert_drive_file_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _fileIcon(document.type),
            size: 18,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          document.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${document.sharedBy} - ${_timeAgo(document.updatedAt)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: document.permission.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            document.permission.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: document.permission.color,
            ),
          ),
        ),
        dense: true,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Activity tile
// ---------------------------------------------------------------------------

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});

  final ActivityItem activity;

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: activity.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(activity.icon, size: 14, color: activity.color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: theme.textTheme.bodySmall,
                  children: [
                    TextSpan(
                      text: activity.user,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: ' ${activity.action}'),
                  ],
                ),
              ),
              Text(
                _timeAgo(activity.timestamp),
                style: TextStyle(fontSize: 11, color: AppColors.neutral400),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}
