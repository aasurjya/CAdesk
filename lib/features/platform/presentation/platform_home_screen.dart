import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/platform/data/providers/platform_providers.dart';

/// Platform admin home with cards for Team & Roles, Security & MFA,
/// Audit Trail, and Sync Status.
class PlatformHomeScreen extends ConsumerWidget {
  const PlatformHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncItems = ref.watch(syncQueueProvider);
    final pendingCount = syncItems
        .where((i) => i.status.name == 'pending' || i.status.name == 'failed')
        .length;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Platform Admin',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Users, security, audit & sync',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;
          final cards = _buildCards(context, pendingCount);
          if (isWide) {
            return GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2.4,
              children: cards,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cards.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, i) => cards[i],
          );
        },
      ),
    );
  }

  List<Widget> _buildCards(BuildContext context, int pendingCount) {
    return [
      _PlatformCard(
        icon: Icons.group_rounded,
        iconColor: AppColors.primary,
        title: 'Team & Roles',
        subtitle: 'Manage firm users and role-based permissions',
        onTap: () => context.push('/platform/users'),
      ),
      _PlatformCard(
        icon: Icons.security_rounded,
        iconColor: AppColors.secondary,
        title: 'Security & MFA',
        subtitle: 'Set up multi-factor authentication',
        onTap: () => context.push('/platform/mfa'),
      ),
      _PlatformCard(
        icon: Icons.history_rounded,
        iconColor: AppColors.accent,
        title: 'Audit Trail',
        subtitle: 'Review user actions and security events',
        onTap: () => context.push('/platform/audit'),
      ),
      _PlatformCard(
        icon: Icons.cloud_sync_rounded,
        iconColor: AppColors.success,
        title: 'Sync Status',
        subtitle: 'Monitor offline sync queue',
        badge: pendingCount > 0 ? '$pendingCount pending' : null,
        onTap: () => context.push('/platform/sync'),
      ),
    ];
  }
}

class _PlatformCard extends StatelessWidget {
  const _PlatformCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutral900,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badge!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.neutral300,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
