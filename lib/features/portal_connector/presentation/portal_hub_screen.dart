import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/portal_connector/data/providers/portal_connector_providers.dart';
import 'package:ca_app/features/portal_connector/presentation/widgets/portal_status_card.dart';

/// Hub screen showing all government portal connections in a grid.
class PortalHubScreen extends ConsumerWidget {
  const PortalHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connections = ref.watch(portalConnectionsProvider);
    final connectedCount = ref.watch(connectedPortalCountProvider);
    final allHealthy = ref.watch(allPortalsHealthyProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portal Connections',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Government portal integrations',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.neutral50, Color(0xFFF9FBFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SyncStatusBar(
              connectedCount: connectedCount,
              totalCount: connections.length,
              allHealthy: allHealthy,
            ),
            const SizedBox(height: 16),
            const _SectionHeader(
              title: 'Connected Portals',
              icon: Icons.hub_rounded,
            ),
            const SizedBox(height: 10),
            _PortalGrid(connections: connections),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sync status bar
// ---------------------------------------------------------------------------

class _SyncStatusBar extends StatelessWidget {
  const _SyncStatusBar({
    required this.connectedCount,
    required this.totalCount,
    required this.allHealthy,
  });

  final int connectedCount;
  final int totalCount;
  final bool allHealthy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = allHealthy ? AppColors.success : AppColors.warning;
    final statusText = allHealthy
        ? 'All portals connected'
        : '$connectedCount of $totalCount connected';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withAlpha(12), statusColor.withAlpha(6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withAlpha(30)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withAlpha(18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              allHealthy
                  ? Icons.check_circle_rounded
                  : Icons.warning_amber_rounded,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Sync health overview',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
          ),
          // Progress indicator
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: totalCount > 0 ? connectedCount / totalCount : 0,
                  strokeWidth: 4,
                  backgroundColor: AppColors.neutral100,
                  color: statusColor,
                ),
                Text(
                  '$connectedCount/$totalCount',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Portal grid
// ---------------------------------------------------------------------------

class _PortalGrid extends ConsumerWidget {
  const _PortalGrid({required this.connections});

  final List<PortalConnectionInfo> connections;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: connections.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) {
        final info = connections[index];
        return PortalStatusCard(
          info: info,
          onTestConnection: () {
            ref
                .read(portalConnectionsProvider.notifier)
                .testConnection(info.portal);
          },
          onConfigure: () {
            ref.read(selectedPortalProvider.notifier).select(info.portal);
            context.go('/portals/config');
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
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
