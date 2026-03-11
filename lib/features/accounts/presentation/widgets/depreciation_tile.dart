import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import '../../domain/models/depreciation_entry.dart';

/// Tile showing a depreciation entry with asset-block badge,
/// WDV progression bar, and key amounts.
class DepreciationTile extends StatelessWidget {
  const DepreciationTile({
    super.key,
    required this.entry,
    this.onTap,
  });

  final DepreciationEntry entry;
  final VoidCallback? onTap;

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
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: asset name + block badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.assetName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _AssetBlockBadge(block: entry.assetBlock),
                ],
              ),

              const SizedBox(height: 4),

              // Financial year + rate
              Text(
                '${entry.financialYear}  •  Rate: ${entry.rate.toStringAsFixed(0)}% WDV',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral400,
                ),
              ),

              const SizedBox(height: 10),

              // WDV progression bar
              _WDVProgressionBar(entry: entry),

              const SizedBox(height: 10),

              // Amounts row
              _AmountsRow(entry: entry),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _AssetBlockBadge extends StatelessWidget {
  const _AssetBlockBadge({required this.block});

  final AssetBlock block;

  Color get _color {
    switch (block) {
      case AssetBlock.building:
        return AppColors.primary;
      case AssetBlock.plant:
        return AppColors.secondary;
      case AssetBlock.furniture:
        return AppColors.accent;
      case AssetBlock.computer:
        return const Color(0xFF6366F1);
      case AssetBlock.vehicle:
        return const Color(0xFF0EA5E9);
      case AssetBlock.intangible:
        return AppColors.primaryVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        block.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}

class _WDVProgressionBar extends StatelessWidget {
  const _WDVProgressionBar({required this.entry});

  final DepreciationEntry entry;

  @override
  Widget build(BuildContext context) {
    final base = entry.openingWDV + entry.additions;
    final progress = base > 0 ? (entry.closingWDV / base).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Opening: ${CurrencyUtils.formatINRCompact(entry.openingWDV)}',
              style: const TextStyle(fontSize: 10, color: AppColors.neutral400),
            ),
            Text(
              'Closing: ${CurrencyUtils.formatINRCompact(entry.closingWDV)}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.neutral200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _AmountsRow extends StatelessWidget {
  const _AmountsRow({required this.entry});

  final DepreciationEntry entry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (entry.additions > 0) ...[
          _Cell(
            label: 'Additions',
            value: CurrencyUtils.formatINRCompact(entry.additions),
            color: AppColors.success,
          ),
          const _Separator(),
        ],
        if (entry.disposals > 0) ...[
          _Cell(
            label: 'Disposals',
            value: CurrencyUtils.formatINRCompact(entry.disposals),
            color: AppColors.error,
          ),
          const _Separator(),
        ],
        _Cell(
          label: 'Depreciation',
          value: CurrencyUtils.formatINRCompact(entry.depreciation),
          color: AppColors.warning,
        ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.neutral400),
        ),
      ],
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: AppColors.neutral200,
    );
  }
}
