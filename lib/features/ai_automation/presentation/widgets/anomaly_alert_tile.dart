import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/ai_automation/domain/models/anomaly_alert.dart';

/// Alert card displaying an anomaly detection result with severity coloring.
class AnomalyAlertTile extends StatelessWidget {
  const AnomalyAlertTile({
    super.key,
    required this.alert,
    this.onTap,
    this.onResolve,
  });

  final AnomalyAlert alert;
  final VoidCallback? onTap;
  final VoidCallback? onResolve;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severityColor = alert.severity.color;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: alert.isResolved
              ? AppColors.neutral200
              : severityColor.withAlpha(80),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: severity icon + type + resolved badge
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: severityColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      alert.severity.icon,
                      color: severityColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _SeverityBadge(severity: alert.severity),
                            const SizedBox(width: 8),
                            Icon(
                              alert.alertType.icon,
                              size: 14,
                              color: AppColors.neutral400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              alert.alertType.label,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.neutral400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          alert.clientName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (alert.isResolved)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(26),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Resolved',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              // Description
              Text(
                alert.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral600,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              // Footer: amount + time ago + resolve button
              Row(
                children: [
                  Text(
                    alert.formattedAmount,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    alert.timeAgo,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                  const Spacer(),
                  if (!alert.isResolved && onResolve != null)
                    TextButton.icon(
                      onPressed: onResolve,
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: const Text('Resolve'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  const _SeverityBadge({required this.severity});

  final AlertSeverity severity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: severity.color.withAlpha(26),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        severity.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: severity.color,
        ),
      ),
    );
  }
}
