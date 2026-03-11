import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/staff_monitoring/domain/models/security_alert.dart';
import 'package:ca_app/features/staff_monitoring/data/providers/staff_monitoring_providers.dart';

class SecurityAlertTile extends ConsumerWidget {
  const SecurityAlertTile({super.key, required this.alert});

  final SecurityAlert alert;

  static const _alertTypeIcons = <AlertType, IconData>{
    AlertType.unusualLogin: Icons.location_searching,
    AlertType.offHoursAccess: Icons.nightlight_round,
    AlertType.sensitiveDownload: Icons.download_for_offline,
    AlertType.multipleFailedLogins: Icons.lock_clock,
    AlertType.locationChange: Icons.pin_drop_outlined,
  };

  static const _severityColors = <AlertSeverity, Color>{
    AlertSeverity.low: AppColors.success,
    AlertSeverity.medium: AppColors.warning,
    AlertSeverity.high: AppColors.accent,
    AlertSeverity.critical: AppColors.error,
  };

  String _formatTimestamp(DateTime ts) {
    final hour = ts.hour.toString().padLeft(2, '0');
    final minute = ts.minute.toString().padLeft(2, '0');
    final day = ts.day.toString().padLeft(2, '0');
    final month = ts.month.toString().padLeft(2, '0');
    return '$day/$month/${ts.year} $hour:$minute';
  }

  void _showResolveDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resolve Alert'),
        content: Text(
          'Mark this ${alert.severity.label} alert for ${alert.staffName} as resolved?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(allAlertsProvider.notifier)
                  .resolve(alert.id, 'CA Prakash Mehta');
              Navigator.pop(ctx);
            },
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final severityColor =
        _severityColors[alert.severity] ?? AppColors.neutral400;
    final alertIcon =
        _alertTypeIcons[alert.alertType] ?? Icons.warning_amber_outlined;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: severityColor, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: severityColor.withAlpha(24),
                shape: BoxShape.circle,
              ),
              child: Icon(alertIcon, size: 20, color: severityColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          alert.staffName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _SeverityBadge(
                        severity: alert.severity,
                        color: severityColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    alert.alertType.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.neutral600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: AppColors.neutral400,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _formatTimestamp(alert.timestamp),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.neutral400,
                        ),
                      ),
                      const Spacer(),
                      if (alert.isResolved)
                        _ResolvedChip(resolvedBy: alert.resolvedBy ?? 'Unknown')
                      else
                        TextButton.icon(
                          onPressed: () => _showResolveDialog(context, ref),
                          icon: const Icon(Icons.check_circle_outline, size: 14),
                          label: const Text('Resolve'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.success,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  const _SeverityBadge({required this.severity, required this.color});

  final AlertSeverity severity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        severity.label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ResolvedChip extends StatelessWidget {
  const _ResolvedChip({required this.resolvedBy});

  final String resolvedBy;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, size: 14, color: AppColors.success),
        const SizedBox(width: 3),
        Text(
          'Resolved by $resolvedBy',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.success,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
