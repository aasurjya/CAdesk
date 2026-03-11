import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/virtual_cfo/domain/models/cfo_scenario.dart';

/// List tile displaying a Virtual CFO financial scenario with impact indicators.
class ScenarioTile extends StatelessWidget {
  const ScenarioTile({super.key, required this.scenario});

  final CfoScenario scenario;

  Color get _categoryColor {
    switch (scenario.category) {
      case 'Revenue':
        return AppColors.primary;
      case 'Cost':
        return AppColors.warning;
      case 'Funding':
        return AppColors.secondary;
      case 'Tax':
        return AppColors.accent;
      case 'Working Capital':
        return AppColors.neutral600;
      default:
        return AppColors.neutral400;
    }
  }

  Color get _impactColor =>
      scenario.isPositive ? AppColors.success : AppColors.error;

  IconData get _impactIcon => scenario.isPositive
      ? Icons.arrow_upward_rounded
      : Icons.arrow_downward_rounded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = _categoryColor;
    final impactColor = _impactColor;
    final absImpact = scenario.impactPercent.abs();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: scenario name + impact badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scenario.scenarioName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        scenario.clientName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Impact percentage badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: impactColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_impactIcon, size: 13, color: impactColor),
                      const SizedBox(width: 3),
                      Text(
                        '${absImpact.toStringAsFixed(1)}%',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: impactColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Row 2: category chip + time horizon
            Row(
              children: [
                _CategoryChip(
                  category: scenario.category,
                  color: categoryColor,
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.schedule_rounded,
                  size: 12,
                  color: AppColors.neutral400,
                ),
                const SizedBox(width: 3),
                Text(
                  scenario.timeHorizon,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral600,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Row 3: Baseline → Projected
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.neutral50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.neutral200),
              ),
              child: Row(
                children: [
                  _ValueLabel(
                    label: 'Baseline',
                    value: '₹${scenario.baselineValue.toStringAsFixed(0)}L',
                    color: AppColors.neutral600,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: AppColors.neutral400,
                    ),
                  ),
                  _ValueLabel(
                    label: 'Projected',
                    value: '₹${scenario.projectedValue.toStringAsFixed(0)}L',
                    color: impactColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Assumption text
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 13,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    scenario.assumption,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                      fontStyle: FontStyle.italic,
                      fontSize: 11,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
// Sub-widgets
// ---------------------------------------------------------------------------

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category, required this.color});

  final String category;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        category,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
      ),
    );
  }
}

class _ValueLabel extends StatelessWidget {
  const _ValueLabel({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.neutral400,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
