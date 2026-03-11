import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/staff_monitoring/domain/models/activity_log.dart';

class ActivityLogTile extends StatelessWidget {
  const ActivityLogTile({super.key, required this.log});

  final ActivityLog log;

  static const _typeIcons = <ActivityType, IconData>{
    ActivityType.login: Icons.login,
    ActivityType.logout: Icons.logout,
    ActivityType.fileAccess: Icons.folder_open,
    ActivityType.documentDownload: Icons.download,
    ActivityType.settingsChange: Icons.settings,
    ActivityType.clientView: Icons.person_outline,
    ActivityType.reportGenerate: Icons.bar_chart,
  };

  static const _typeColors = <ActivityType, Color>{
    ActivityType.login: AppColors.success,
    ActivityType.logout: AppColors.neutral400,
    ActivityType.fileAccess: AppColors.primary,
    ActivityType.documentDownload: AppColors.accent,
    ActivityType.settingsChange: AppColors.warning,
    ActivityType.clientView: AppColors.secondary,
    ActivityType.reportGenerate: AppColors.primaryVariant,
  };

  String _formatTimestamp(DateTime ts) {
    final hour = ts.hour.toString().padLeft(2, '0');
    final minute = ts.minute.toString().padLeft(2, '0');
    final day = ts.day.toString().padLeft(2, '0');
    final month = ts.month.toString().padLeft(2, '0');
    return '$day/$month/${ts.year} $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = _typeIcons[log.activityType] ?? Icons.circle;
    final color = _typeColors[log.activityType] ?? AppColors.primary;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: log.isAnomalous
            ? const BorderSide(color: AppColors.error, width: 1.5)
            : BorderSide.none,
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
                color: color.withAlpha(24),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
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
                          log.staffName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _TypeBadge(label: log.activityType.label, color: color),
                      if (log.isAnomalous) ...[
                        const SizedBox(width: 6),
                        const _AnomalyBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    log.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    children: [
                      _MetaChip(
                        icon: Icons.access_time,
                        label: _formatTimestamp(log.timestamp),
                      ),
                      _MetaChip(
                        icon: Icons.location_on_outlined,
                        label: log.location,
                      ),
                      _MetaChip(
                        icon: Icons.computer_outlined,
                        label: log.deviceName,
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

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.label, required this.color});

  final String label;
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
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AnomalyBadge extends StatelessWidget {
  const _AnomalyBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(24),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber, size: 10, color: AppColors.error),
          SizedBox(width: 2),
          Text(
            'Anomaly',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.neutral400),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.neutral400),
        ),
      ],
    );
  }
}
