import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/reconciliation/data/providers/reconciliation_providers.dart';

/// A list tile for a single reconciliation line-item.
///
/// Shows the income type icon, source description, three columns for
/// 26AS / AIS / ITR amounts, and a color-coded status badge.
class ReconEntryTile extends StatelessWidget {
  const ReconEntryTile({super.key, required this.entry, this.onTap});

  final ReconEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _IncomeTypeIcon(incomeType: entry.incomeType),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.source,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutral900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          entry.incomeType,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.neutral400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: entry.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _AmountColumn(
                    label: '26AS',
                    amountPaise: entry.amount26as,
                    status: entry.status,
                  ),
                  _AmountColumn(
                    label: 'AIS',
                    amountPaise: entry.amountAis,
                    status: entry.status,
                  ),
                  _AmountColumn(
                    label: 'ITR',
                    amountPaise: entry.amountItr,
                    status: entry.status,
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

class _IncomeTypeIcon extends StatelessWidget {
  const _IncomeTypeIcon({required this.incomeType});

  final String incomeType;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _resolveIcon(incomeType);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  static (IconData, Color) _resolveIcon(String type) {
    return switch (type.toLowerCase()) {
      'salary' => (Icons.work_rounded, AppColors.primary),
      'interest' => (Icons.savings_rounded, AppColors.secondary),
      'tds' => (Icons.receipt_long_rounded, AppColors.accent),
      'capital gains' => (Icons.trending_up_rounded, const Color(0xFF7C3AED)),
      'dividend' => (Icons.pie_chart_rounded, const Color(0xFF2196F3)),
      'rent' => (Icons.home_rounded, const Color(0xFF00897B)),
      _ => (Icons.attach_money_rounded, AppColors.neutral400),
    };
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ReconEntryStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, color) = _resolve(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static (String, Color) _resolve(ReconEntryStatus status) {
    return switch (status) {
      ReconEntryStatus.matched => ('Matched', AppColors.success),
      ReconEntryStatus.mismatched => ('Mismatch', AppColors.warning),
      ReconEntryStatus.missingIn26as => ('No 26AS', AppColors.error),
      ReconEntryStatus.missingInAis => ('No AIS', AppColors.error),
      ReconEntryStatus.missingInItr => ('No ITR', AppColors.error),
    };
  }
}

class _AmountColumn extends StatelessWidget {
  const _AmountColumn({
    required this.label,
    required this.amountPaise,
    required this.status,
  });

  final String label;
  final int amountPaise;
  final ReconEntryStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isZero = amountPaise == 0;

    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral400,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isZero ? '--' : _formatInr(amountPaise),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: isZero ? AppColors.error : AppColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatInr(int paise) {
    final rupees = paise ~/ 100;
    if (rupees >= 10000000) {
      return '${(rupees / 10000000).toStringAsFixed(2)}Cr';
    }
    if (rupees >= 100000) {
      return '${(rupees / 100000).toStringAsFixed(2)}L';
    }
    if (rupees >= 1000) {
      return '${(rupees / 1000).toStringAsFixed(1)}K';
    }
    return '$rupees';
  }
}
