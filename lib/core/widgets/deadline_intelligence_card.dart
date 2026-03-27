import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/status_badge.dart';

/// Risk-scored deadline card — a CompuOffice / CADesk differentiator.
///
/// Displays a deadline with urgency coloring based on [riskScore],
/// a countdown to [dueDate], optional penalty warning, and category badge.
class DeadlineIntelligenceCard extends StatelessWidget {
  const DeadlineIntelligenceCard({
    super.key,
    required this.title,
    required this.dueDate,
    required this.riskScore,
    this.penaltyAmount,
    this.category,
    this.onTap,
  });

  final String title;
  final DateTime dueDate;
  final double riskScore; // 0.0 to 1.0
  final double? penaltyAmount;
  final String? category;
  final VoidCallback? onTap;

  Color get _urgencyColor {
    if (riskScore >= 0.75) return AppColors.error;
    if (riskScore >= 0.5) return AppColors.warning;
    if (riskScore >= 0.25) return AppColors.accent;
    return AppColors.success;
  }

  String get _countdown {
    final now = DateTime.now();
    final diff = dueDate.difference(now);

    if (diff.isNegative) {
      return 'Overdue by ${diff.inDays.abs()} day${diff.inDays.abs() == 1 ? '' : 's'}';
    }
    if (diff.inDays == 0) return 'Due today';
    if (diff.inDays == 1) return 'Due tomorrow';
    return '${diff.inDays} days left';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatPenalty(double amount) {
    if (amount >= 100000) {
      return '\u20B9${(amount / 100000).toStringAsFixed(1)}L';
    }
    if (amount >= 1000) {
      return '\u20B9${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '\u20B9${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _urgencyColor;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withAlpha(50)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme, color),
              const SizedBox(height: 8),
              _buildCountdown(theme, color),
              if (penaltyAmount != null) ...[
                const SizedBox(height: 6),
                _buildPenaltyWarning(theme),
              ],
              const SizedBox(height: 4),
              _buildRiskBar(color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
        ),
        if (category != null) StatusBadge(label: category!, color: color),
      ],
    );
  }

  Widget _buildCountdown(ThemeData theme, Color color) {
    return Row(
      children: [
        Icon(Icons.schedule_rounded, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          _countdown,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          _formatDate(dueDate),
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
      ],
    );
  }

  Widget _buildPenaltyWarning(ThemeData theme) {
    return Row(
      children: [
        const Icon(
          Icons.warning_amber_rounded,
          size: 14,
          color: AppColors.warning,
        ),
        const SizedBox(width: 4),
        Text(
          'Penalty risk: ${_formatPenalty(penaltyAmount!)}',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildRiskBar(Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: LinearProgressIndicator(
        value: riskScore.clamp(0.0, 1.0),
        minHeight: 4,
        backgroundColor: AppColors.neutral100,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
