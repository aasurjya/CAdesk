import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';

/// A date-range / period selector that shows the current selection and
/// opens a popup menu to switch periods.
///
/// Commonly used for financial year selection (e.g. 'FY 2024-25').
class PeriodSelector extends StatelessWidget {
  const PeriodSelector({
    super.key,
    required this.selected,
    required this.periods,
    required this.onChanged,
  });

  final String selected;
  final List<String> periods;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<String>(
      onSelected: onChanged,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) => [
        for (final period in periods)
          PopupMenuItem<String>(
            value: period,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    period,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: period == selected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: period == selected
                          ? AppColors.primary
                          : AppColors.neutral900,
                    ),
                  ),
                ),
                if (period == selected)
                  const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.neutral200),
          borderRadius: BorderRadius.circular(10),
          color: AppColors.surface,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selected,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: AppColors.neutral400,
            ),
          ],
        ),
      ),
    );
  }
}
