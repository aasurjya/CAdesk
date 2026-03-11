import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/ecosystem/domain/models/marketplace_app.dart';

/// A card tile displaying a single marketplace app with rating and install status.
class MarketplaceAppTile extends StatelessWidget {
  const MarketplaceAppTile({super.key, required this.app});

  final MarketplaceApp app;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarColor = app.iconColor ?? AppColors.primary;

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
              // Top row: avatar, name/vendor, status chip
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: avatarColor.withValues(alpha: 0.15),
                    child: Text(
                      app.name.isNotEmpty ? app.name[0].toUpperCase() : '?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: avatarColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          app.vendor,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _InstallStatusChip(status: app.installStatus),
                ],
              ),
              const SizedBox(height: 10),

              // Bottom row: rating + review count + price + category chip
              Row(
                children: [
                  Icon(Icons.star_rounded, size: 14, color: AppColors.accent),
                  const SizedBox(width: 3),
                  Text(
                    app.rating.toStringAsFixed(1),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral900,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${app.reviewCount})',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    app.isFree
                        ? 'Free'
                        : '\u20B9${app.pricePerMonth!.toStringAsFixed(0)}/mo',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: app.isFree ? AppColors.success : AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  _CategoryChip(category: app.category),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstallStatusChip extends StatelessWidget {
  const _InstallStatusChip({required this.status});

  final AppInstallStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: status.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final AppCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.secondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
