import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/platform/domain/models/audit_log_entry.dart';

/// ListTile showing an audit log entry with severity icon, action, user,
/// resource, and timestamp.
class AuditLogTile extends StatelessWidget {
  const AuditLogTile({super.key, required this.entry});

  final AuditLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, iconColor) = _severityIcon(entry.severity);
    final resource = [entry.resourceType, entry.resourceId]
        .whereType<String>()
        .join(' · ');
    final subtitle =
        '${entry.userName} · ${resource.isNotEmpty ? resource : 'N/A'}';

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        _formatAction(entry.action),
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.neutral900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.neutral400),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _relativeTime(entry.timestamp),
        style: theme.textTheme.labelSmall?.copyWith(
          color: AppColors.neutral400,
        ),
      ),
    );
  }

  static (IconData, Color) _severityIcon(LogSeverity severity) {
    switch (severity) {
      case LogSeverity.info:
        return (Icons.info_outline_rounded, AppColors.secondary);
      case LogSeverity.warning:
        return (Icons.warning_amber_rounded, AppColors.warning);
      case LogSeverity.critical:
        return (Icons.gpp_bad_rounded, AppColors.error);
    }
  }

  static String _formatAction(String action) {
    return action
        .split('_')
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  static String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}
