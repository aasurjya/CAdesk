import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/esg_reporting/domain/models/carbon_metric.dart';

/// ListTile-style widget displaying a single carbon metric with a progress bar.
class CarbonMetricTile extends StatelessWidget {
  const CarbonMetricTile({super.key, required this.metric});

  final CarbonMetric metric;

  // -----------------------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------------------

  Color _scopeColor(String scope) {
    if (scope.startsWith('Scope 1')) {
      return AppColors.error;
    } else if (scope.startsWith('Scope 2')) {
      return AppColors.warning;
    } else {
      return AppColors.accent;
    }
  }

  String _formattedEmissions(double tonnes) {
    if (tonnes >= 1000000) {
      return '${(tonnes / 1000000).toStringAsFixed(2)} MtCO2e';
    } else if (tonnes >= 1000) {
      return '${(tonnes / 1000).toStringAsFixed(1)} ktCO2e';
    } else {
      return '${tonnes.toStringAsFixed(0)} ${metric.unit}';
    }
  }

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scopeColor = _scopeColor(metric.scope);
    final progress = (metric.achievedPercent / metric.reductionTargetPercent)
        .clamp(0.0, 1.0);

    return Card(
      color: AppColors.surface,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ScopeDot(color: scopeColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metric.scope,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scopeColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    metric.clientName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ProgressBar(
                    progress: progress,
                    achievedPercent: metric.achievedPercent,
                    targetPercent: metric.reductionTargetPercent,
                    color: scopeColor,
                    theme: theme,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _EmissionsLabel(
              value: _formattedEmissions(metric.emissionsTonnes),
              year: metric.reportingYear,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _ScopeDot extends StatelessWidget {
  const _ScopeDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.progress,
    required this.achievedPercent,
    required this.targetPercent,
    required this.color,
    required this.theme,
  });

  final double progress;
  final double achievedPercent;
  final double targetPercent;
  final Color color;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.neutral100,
            valueColor: AlwaysStoppedAnimation<Color>(color.withAlpha(204)),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${achievedPercent.toStringAsFixed(0)}% of '
          '${targetPercent.toStringAsFixed(0)}% reduction target achieved',
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
      ],
    );
  }
}

class _EmissionsLabel extends StatelessWidget {
  const _EmissionsLabel({
    required this.value,
    required this.year,
    required this.theme,
  });

  final String value;
  final String year;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          year,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
      ],
    );
  }
}
