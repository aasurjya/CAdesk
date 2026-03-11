import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/nri_tax/domain/models/foreign_asset.dart';

/// A card tile displaying a single foreign asset with type, country, value,
/// and Schedule FA / reporting status.
class ForeignAssetTile extends StatelessWidget {
  const ForeignAssetTile({super.key, required this.asset});

  final ForeignAsset asset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: asset type icon + client name + value
              Row(
                children: [
                  _AssetTypeIcon(assetType: asset.assetType),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.clientName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          asset.assetType.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        asset.formattedValue,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      if (asset.isHighValue) ...[
                        const SizedBox(height: 2),
                        Text(
                          'High Value',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.warning,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Row 2: country + Schedule FA badge + reported indicator
              Row(
                children: [
                  Icon(
                    Icons.public_rounded,
                    size: 13,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    asset.country,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  if (asset.scheduleFARequired) ...[
                    const _ScheduleFABadge(),
                    const SizedBox(width: 8),
                  ],
                  _ReportedIndicator(reported: asset.reportedInItr),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _AssetTypeIcon extends StatelessWidget {
  const _AssetTypeIcon({required this.assetType});

  final ForeignAssetType assetType;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        assetType.icon,
        size: 20,
        color: AppColors.secondary,
      ),
    );
  }
}

class _ScheduleFABadge extends StatelessWidget {
  const _ScheduleFABadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Schedule FA',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _ReportedIndicator extends StatelessWidget {
  const _ReportedIndicator({required this.reported});

  final bool reported;

  @override
  Widget build(BuildContext context) {
    final color = reported ? AppColors.success : AppColors.error;
    final label = reported ? 'Reported' : 'Unreported';
    final icon =
        reported ? Icons.check_circle_outline_rounded : Icons.cancel_outlined;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
