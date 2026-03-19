import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

enum PortalType { itd, gstn, traces, mca, epfo }

extension PortalTypeX on PortalType {
  String get label => switch (this) {
    PortalType.itd => 'Income Tax (ITD)',
    PortalType.gstn => 'GST Network',
    PortalType.traces => 'TRACES',
    PortalType.mca => 'MCA',
    PortalType.epfo => 'EPFO',
  };

  IconData get icon => switch (this) {
    PortalType.itd => Icons.account_balance_rounded,
    PortalType.gstn => Icons.receipt_long_rounded,
    PortalType.traces => Icons.content_paste_search_rounded,
    PortalType.mca => Icons.business_rounded,
    PortalType.epfo => Icons.people_alt_rounded,
  };

  Color get brandColor => switch (this) {
    PortalType.itd => const Color(0xFF1565C0),
    PortalType.gstn => const Color(0xFF2E7D32),
    PortalType.traces => const Color(0xFF6A1B9A),
    PortalType.mca => const Color(0xFFE65100),
    PortalType.epfo => const Color(0xFF00838F),
  };
}

enum ConnectionStatus { connected, disconnected, error }

extension ConnectionStatusX on ConnectionStatus {
  String get label => switch (this) {
    ConnectionStatus.connected => 'Connected',
    ConnectionStatus.disconnected => 'Disconnected',
    ConnectionStatus.error => 'Error',
  };

  Color get color => switch (this) {
    ConnectionStatus.connected => AppColors.success,
    ConnectionStatus.disconnected => AppColors.neutral400,
    ConnectionStatus.error => AppColors.error,
  };

  IconData get icon => switch (this) {
    ConnectionStatus.connected => Icons.check_circle_rounded,
    ConnectionStatus.disconnected => Icons.cancel_rounded,
    ConnectionStatus.error => Icons.error_rounded,
  };
}

class PortalConnection {
  const PortalConnection({
    required this.portal,
    required this.status,
    required this.userId,
    required this.lastSync,
    required this.autoSync,
  });

  final PortalType portal;
  final ConnectionStatus status;
  final String userId;
  final DateTime? lastSync;
  final bool autoSync;

  PortalConnection copyWith({ConnectionStatus? status, bool? autoSync}) =>
      PortalConnection(
        portal: portal,
        status: status ?? this.status,
        userId: userId,
        lastSync: lastSync,
        autoSync: autoSync ?? this.autoSync,
      );
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final _portalConnectionsProvider =
    NotifierProvider<_PortalConnectionsNotifier, List<PortalConnection>>(
      _PortalConnectionsNotifier.new,
    );

class _PortalConnectionsNotifier extends Notifier<List<PortalConnection>> {
  @override
  List<PortalConnection> build() => [
    PortalConnection(
      portal: PortalType.itd,
      status: ConnectionStatus.connected,
      userId: 'AAAPZ1234C',
      lastSync: DateTime.now().subtract(const Duration(minutes: 42)),
      autoSync: true,
    ),
    PortalConnection(
      portal: PortalType.gstn,
      status: ConnectionStatus.connected,
      userId: '27AAAPZ1234C1ZV',
      lastSync: DateTime.now().subtract(const Duration(hours: 3)),
      autoSync: true,
    ),
    const PortalConnection(
      portal: PortalType.traces,
      status: ConnectionStatus.disconnected,
      userId: 'AAAPZ1234C',
      lastSync: null,
      autoSync: false,
    ),
    PortalConnection(
      portal: PortalType.mca,
      status: ConnectionStatus.error,
      userId: 'user@firm.com',
      lastSync: DateTime.now().subtract(const Duration(days: 2, hours: 6)),
      autoSync: true,
    ),
    const PortalConnection(
      portal: PortalType.epfo,
      status: ConnectionStatus.disconnected,
      userId: '',
      lastSync: null,
      autoSync: false,
    ),
  ];

  void toggleAutoSync(PortalType portal) {
    state = [
      for (final c in state)
        if (c.portal == portal) c.copyWith(autoSync: !c.autoSync) else c,
    ];
  }

  void testConnection(PortalType portal) {
    state = [
      for (final c in state)
        if (c.portal == portal)
          c.copyWith(status: ConnectionStatus.connected)
        else
          c,
    ];
  }
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class PortalConnectorScreen extends ConsumerWidget {
  const PortalConnectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connections = ref.watch(_portalConnectionsProvider);
    final theme = Theme.of(context);

    final connected = connections
        .where((c) => c.status == ConnectionStatus.connected)
        .length;
    final errors = connections
        .where((c) => c.status == ConnectionStatus.error)
        .length;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portal Connector',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Manage government portal credentials',
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
          // Summary row
          Row(
            children: [
              _StatCard(
                label: 'Total',
                value: '${connections.length}',
                icon: Icons.cable_outlined,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              _StatCard(
                label: 'Connected',
                value: '$connected',
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              _StatCard(
                label: 'Errors',
                value: '$errors',
                icon: Icons.error_outline_rounded,
                color: AppColors.error,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Portal cards
          ...connections.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PortalCard(connection: c),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stat card
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Portal card
// ---------------------------------------------------------------------------

class _PortalCard extends ConsumerWidget {
  const _PortalCard({required this.connection});

  final PortalConnection connection;

  String _timeAgo(DateTime? dt) {
    if (dt == null) return 'Never';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final portal = connection.portal;
    final status = connection.status;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: portal.brandColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(portal.icon, color: portal.brandColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        portal.label,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (connection.userId.isNotEmpty)
                        Text(
                          _maskCredential(connection.userId),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(status.icon, size: 14, color: status.color),
                      const SizedBox(width: 4),
                      Text(
                        status.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: status.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Details row
            Row(
              children: [
                _DetailChip(
                  icon: Icons.sync_rounded,
                  label: 'Last sync: ${_timeAgo(connection.lastSync)}',
                ),
                const Spacer(),
                // Auto-sync toggle
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Auto-sync',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      height: 24,
                      child: Switch.adaptive(
                        value: connection.autoSync,
                        onChanged: (_) => ref
                            .read(_portalConnectionsProvider.notifier)
                            .toggleAutoSync(portal),
                        activeTrackColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => ref
                    .read(_portalConnectionsProvider.notifier)
                    .testConnection(portal),
                icon: const Icon(Icons.wifi_tethering_rounded, size: 16),
                label: const Text('Test Connection'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: portal.brandColor,
                  side: BorderSide(
                    color: portal.brandColor.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _maskCredential(String credential) {
    if (credential.length <= 4) return credential;
    final visible = credential.substring(0, 4);
    return '$visible${'*' * (credential.length - 4)}';
  }
}

// ---------------------------------------------------------------------------
// Detail chip
// ---------------------------------------------------------------------------

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.neutral400),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.neutral400),
        ),
      ],
    );
  }
}
