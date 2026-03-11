import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/msme/domain/models/msme_vendor.dart';

/// A list tile displaying a single MSME vendor entry with classification
/// badge and outstanding amount.
class MsmeVendorTile extends StatelessWidget {
  const MsmeVendorTile({
    super.key,
    required this.vendor,
    this.onTap,
  });

  final MsmeVendor vendor;
  final VoidCallback? onTap;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: _classificationColor(vendor.classification),
                child: Text(
                  vendor.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor.vendorName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vendor.msmeRegistrationNumber,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                    if (vendor.daysPastDue > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${vendor.daysPastDue} days past due',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: vendor.section43BhAtRisk
                              ? AppColors.error
                              : AppColors.warning,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _ClassificationBadge(
                    classification: vendor.classification,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _currencyFormat.format(vendor.outstandingAmount),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: vendor.outstandingAmount > 0
                          ? AppColors.error
                          : AppColors.success,
                    ),
                  ),
                  if (!vendor.isVerified) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Unverified',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _classificationColor(MsmeClassification c) {
    switch (c) {
      case MsmeClassification.micro:
        return AppColors.secondary;
      case MsmeClassification.small:
        return AppColors.primaryVariant;
      case MsmeClassification.medium:
        return AppColors.primary;
    }
  }
}

class _ClassificationBadge extends StatelessWidget {
  const _ClassificationBadge({required this.classification});

  final MsmeClassification classification;

  @override
  Widget build(BuildContext context) {
    final color = _badgeColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        classification.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color get _badgeColor {
    switch (classification) {
      case MsmeClassification.micro:
        return AppColors.secondary;
      case MsmeClassification.small:
        return AppColors.primaryVariant;
      case MsmeClassification.medium:
        return AppColors.primary;
    }
  }
}
