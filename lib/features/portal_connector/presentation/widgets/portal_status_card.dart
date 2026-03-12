import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/portal_connector/data/providers/portal_connector_providers.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_request.dart';

/// Card displaying a portal's connection status with action buttons.
class PortalStatusCard extends StatelessWidget {
  const PortalStatusCard({
    super.key,
    required this.info,
    required this.onTestConnection,
    required this.onConfigure,
  });

  final PortalConnectionInfo info;
  final VoidCallback onTestConnection;
  final VoidCallback onConfigure;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _portalColor(info.portal).withAlpha(18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _portalIcon(info.portal),
                    color: _portalColor(info.portal),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _portalDisplayName(info.portal),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _portalDescription(info.portal),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _StatusDot(status: info.status),
              ],
            ),
            const SizedBox(height: 12),
            if (info.lastSyncAt != null) ...[
              Text(
                'Last sync: ${_formatRelativeTime(info.lastSyncAt!)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (info.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  info.errorMessage!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onTestConnection,
                    icon: const Icon(Icons.wifi_tethering_rounded, size: 16),
                    label: const Text('Test'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      textStyle: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onConfigure,
                    icon: const Icon(Icons.settings_rounded, size: 16),
                    label: const Text('Config'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      textStyle: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status dot indicator
// ---------------------------------------------------------------------------

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});

  final PortalConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _dotColor,
        boxShadow: [
          BoxShadow(
            color: _dotColor.withAlpha(60),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  Color get _dotColor {
    switch (status) {
      case PortalConnectionStatus.connected:
        return AppColors.success;
      case PortalConnectionStatus.error:
        return AppColors.error;
      case PortalConnectionStatus.disconnected:
        return AppColors.neutral300;
    }
  }
}

// ---------------------------------------------------------------------------
// Helper functions
// ---------------------------------------------------------------------------

String _portalDisplayName(Portal portal) {
  switch (portal) {
    case Portal.itd:
      return 'Income Tax (ITD)';
    case Portal.gstn:
      return 'GST Network';
    case Portal.traces:
      return 'TRACES';
    case Portal.mca:
      return 'MCA Portal';
    case Portal.epfo:
      return 'EPFO';
    case Portal.nic:
      return 'NIC';
  }
}

String _portalDescription(Portal portal) {
  switch (portal) {
    case Portal.itd:
      return 'Income Tax Department';
    case Portal.gstn:
      return 'GST Returns & ITC';
    case Portal.traces:
      return 'TDS/TCS Statements';
    case Portal.mca:
      return 'Company Affairs';
    case Portal.epfo:
      return 'Provident Fund';
    case Portal.nic:
      return 'National Informatics';
  }
}

IconData _portalIcon(Portal portal) {
  switch (portal) {
    case Portal.itd:
      return Icons.account_balance_rounded;
    case Portal.gstn:
      return Icons.receipt_long_rounded;
    case Portal.traces:
      return Icons.description_rounded;
    case Portal.mca:
      return Icons.business_rounded;
    case Portal.epfo:
      return Icons.people_rounded;
    case Portal.nic:
      return Icons.dns_rounded;
  }
}

Color _portalColor(Portal portal) {
  switch (portal) {
    case Portal.itd:
      return AppColors.primary;
    case Portal.gstn:
      return AppColors.secondary;
    case Portal.traces:
      return const Color(0xFF7C3AED);
    case Portal.mca:
      return AppColors.accent;
    case Portal.epfo:
      return const Color(0xFF2196F3);
    case Portal.nic:
      return const Color(0xFF00897B);
  }
}

String _formatRelativeTime(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
