import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../../domain/models/gst_client.dart';
import '../../domain/models/gst_return.dart';

/// Formats a 15-character GSTIN as XX-XXXXXXXXXX-X-XX for readability.
String _formatGstin(String gstin) {
  if (gstin.length != 15) return gstin;
  return '${gstin.substring(0, 2)}-${gstin.substring(2, 12)}-'
      '${gstin.substring(12, 13)}-${gstin.substring(13)}';
}

/// A list tile showing a GST client with GSTIN, return-status chips,
/// and a linear compliance score bar.
class GstClientTile extends StatelessWidget {
  const GstClientTile({
    super.key,
    required this.client,
    required this.returns,
    this.onTap,
  });

  final GstClient client;

  /// Returns for the currently selected period belonging to this client.
  final List<GstReturn> returns;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutral200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: name + registration badge
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.businessName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatGstin(client.gstin),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral400,
                            fontFamily: 'monospace',
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _RegistrationBadge(type: client.registrationType),
                ],
              ),

              const SizedBox(height: 10),

              // Return status chips
              if (returns.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: returns.map(_buildReturnChip).toList(),
                )
              else
                Text(
                  'No returns for this period',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral400,
                    fontStyle: FontStyle.italic,
                  ),
                ),

              const SizedBox(height: 10),

              // Compliance score bar
              _ComplianceBar(score: client.complianceScore),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReturnChip(GstReturn r) {
    final now = DateTime(2026, 3, 10);
    final Color chipColor;
    final Color textColor;

    switch (r.status) {
      case GstReturnStatus.filed:
        chipColor = AppColors.success;
        textColor = AppColors.success;
      case GstReturnStatus.pending:
        // Due within 5 days = amber, already past = red
        final daysUntilDue = r.dueDate.difference(now).inDays;
        if (daysUntilDue < 0) {
          chipColor = AppColors.error;
          textColor = AppColors.error;
        } else if (daysUntilDue <= 5) {
          chipColor = AppColors.warning;
          textColor = AppColors.warning;
        } else {
          chipColor = AppColors.warning;
          textColor = AppColors.warning;
        }
      case GstReturnStatus.lateFiled:
        chipColor = AppColors.error;
        textColor = AppColors.error;
      case GstReturnStatus.notApplicable:
        chipColor = AppColors.neutral400;
        textColor = AppColors.neutral400;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(r.status.icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            r.returnType.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private helper widgets
// ---------------------------------------------------------------------------

class _RegistrationBadge extends StatelessWidget {
  const _RegistrationBadge({required this.type});

  final GstRegistrationType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryVariant.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type.label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryVariant,
        ),
      ),
    );
  }
}

class _ComplianceBar extends StatelessWidget {
  const _ComplianceBar({required this.score});

  final int score;

  Color get _barColor {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Compliance',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.neutral400,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 6,
              backgroundColor: AppColors.neutral200,
              valueColor: AlwaysStoppedAnimation<Color>(_barColor),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$score%',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: _barColor,
          ),
        ),
      ],
    );
  }
}
