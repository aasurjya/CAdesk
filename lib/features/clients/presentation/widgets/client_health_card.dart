import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/clients/data/providers/client_providers.dart';

/// Displays the compliance health summary for a single client.
class ClientHealthCard extends ConsumerWidget {
  const ClientHealthCard({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(clientHealthScoreProvider(clientId));

    if (health == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final gradeColor = _gradeColor(health.grade);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Compliance Health',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                _GradeBadge(grade: health.grade, color: gradeColor),
              ],
            ),
            const SizedBox(height: 16),
            // Score circle + status rows side by side
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _ScoreCircle(score: health.overallScore, color: gradeColor),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatusRow(
                        label: 'ITR',
                        status: health.itrStatus,
                        icon: Icons.receipt_long,
                      ),
                      const SizedBox(height: 8),
                      _StatusRow(
                        label: 'GST',
                        status: health.gstStatus,
                        icon: Icons.receipt,
                      ),
                      const SizedBox(height: 8),
                      _StatusRow(
                        label: 'TDS',
                        status: health.tdsStatus,
                        icon: Icons.description,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (health.pendingActions.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Text(
                'Pending Actions',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral600,
                ),
              ),
              const SizedBox(height: 8),
              ...health.pendingActions.map(
                (action) => _PendingActionTile(action: action),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Last updated: ${health.lastUpdated}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'Healthy':
        return AppColors.success;
      case 'Attention':
        return AppColors.warning;
      default:
        return AppColors.error;
    }
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _GradeBadge extends StatelessWidget {
  const _GradeBadge({required this.grade, required this.color});

  final String grade;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80), width: 1),
      ),
      child: Text(
        grade,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ScoreCircle extends StatelessWidget {
  const _ScoreCircle({required this.score, required this.color});

  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 6,
            backgroundColor: color.withAlpha(40),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1,
                ),
              ),
              Text(
                '/100',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.neutral400,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.status,
    required this.icon,
  });

  final String label;
  final String status;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNA = status == 'N/A';
    final statusColor = _statusColor(status);
    final statusIcon = _statusIcon(status);

    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.neutral400),
        const SizedBox(width: 6),
        SizedBox(
          width: 32,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Icon(
          statusIcon,
          size: 13,
          color: isNA ? AppColors.neutral300 : statusColor,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            status,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isNA ? AppColors.neutral400 : statusColor,
              fontWeight: isNA ? FontWeight.w400 : FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Filed':
      case 'Compliant':
        return AppColors.success;
      case 'Pending':
      case 'Returns Pending':
      case 'Challan Due':
        return AppColors.warning;
      case 'Overdue':
      case 'Late Filed':
        return AppColors.error;
      default:
        return AppColors.neutral400;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Filed':
      case 'Compliant':
        return Icons.check_circle_outline;
      case 'Pending':
      case 'Returns Pending':
      case 'Challan Due':
        return Icons.schedule;
      case 'Overdue':
      case 'Late Filed':
        return Icons.error_outline;
      default:
        return Icons.remove;
    }
  }
}

class _PendingActionTile extends StatelessWidget {
  const _PendingActionTile({required this.action});

  final String action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 14,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              action,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
