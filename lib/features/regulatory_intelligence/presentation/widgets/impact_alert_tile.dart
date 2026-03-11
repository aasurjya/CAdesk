import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/regulatory_intelligence/domain/models/client_impact_alert.dart';

/// List tile widget displaying a [ClientImpactAlert] with client details,
/// impact description, required action, and status/urgency indicators.
class ImpactAlertTile extends StatelessWidget {
  const ImpactAlertTile({
    super.key,
    required this.alert,
  });

  final ClientImpactAlert alert;

  /// Masks the last four characters of a PAN, e.g. "ABCDE1234F" → "ABCDE****".
  String _maskedPan(String pan) {
    if (pan.length <= 4) {
      return pan;
    }
    final visible = pan.substring(0, pan.length - 4);
    return '$visible****';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TileHeader(alert: alert, maskedPan: _maskedPan(alert.clientPan)),
            const SizedBox(height: 8),
            Text(
              alert.impactDescription,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    alert.actionRequired,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _TileFooter(alert: alert),
          ],
        ),
      ),
    );
  }
}

class _TileHeader extends StatelessWidget {
  const _TileHeader({
    required this.alert,
    required this.maskedPan,
  });

  final ClientImpactAlert alert;
  final String maskedPan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alert.clientName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'PAN: $maskedPan',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral400,
                  fontFamily: 'monospace',
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _UrgencyIndicator(urgency: alert.urgency),
      ],
    );
  }
}

class _UrgencyIndicator extends StatelessWidget {
  const _UrgencyIndicator({required this.urgency});

  final String urgency;

  Color get _color {
    switch (urgency) {
      case 'Urgent':
        return AppColors.error;
      case 'Normal':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  IconData get _icon {
    switch (urgency) {
      case 'Urgent':
        return Icons.priority_high_rounded;
      case 'Normal':
        return Icons.remove_rounded;
      default:
        return Icons.keyboard_arrow_down_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 12, color: _color),
          const SizedBox(width: 3),
          Text(
            urgency,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TileFooter extends StatelessWidget {
  const _TileFooter({required this.alert});

  final ClientImpactAlert alert;

  @override
  Widget build(BuildContext context) {
    final isUrgent = alert.urgency == 'Urgent';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: isUrgent
                ? AppColors.error.withAlpha(15)
                : AppColors.neutral100,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: isUrgent ? AppColors.error.withAlpha(60) : AppColors.neutral200,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 11,
                color: isUrgent ? AppColors.error : AppColors.neutral400,
              ),
              const SizedBox(width: 3),
              Text(
                alert.dueDate,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isUrgent ? AppColors.error : AppColors.neutral400,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        _StatusChip(status: alert.status),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  Color get _backgroundColor {
    switch (status) {
      case 'New':
        return AppColors.primary.withAlpha(20);
      case 'Reviewed':
        return AppColors.secondary.withAlpha(20);
      case 'Action Taken':
        return AppColors.success.withAlpha(20);
      default:
        return AppColors.neutral200;
    }
  }

  Color get _textColor {
    switch (status) {
      case 'New':
        return AppColors.primary;
      case 'Reviewed':
        return AppColors.secondary;
      case 'Action Taken':
        return AppColors.success;
      default:
        return AppColors.neutral600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _textColor,
        ),
      ),
    );
  }
}
