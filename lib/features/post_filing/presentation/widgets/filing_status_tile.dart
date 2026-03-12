import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/post_filing/domain/models/filing_status.dart';

/// Maps a [FilingType] to a display-friendly form name.
String _formName(FilingStatus filing) {
  switch (filing.filingType) {
    case FilingType.itr:
      return 'ITR — AY ${filing.period}';
    case FilingType.gst:
      return 'GST — ${filing.period}';
    case FilingType.tds:
      return 'TDS — ${filing.period}';
    case FilingType.mca:
      return 'MCA — ${filing.period}';
  }
}

/// Returns a color for the filing state chip.
Color _stateColor(FilingState state) {
  switch (state) {
    case FilingState.draft:
    case FilingState.submitted:
      return AppColors.neutral400;
    case FilingState.eVerificationPending:
      return AppColors.warning;
    case FilingState.eVerified:
    case FilingState.processing:
      return AppColors.secondary;
    case FilingState.processed:
      return AppColors.success;
    case FilingState.refundInitiated:
      return AppColors.primary;
    case FilingState.demandRaised:
    case FilingState.defective:
      return AppColors.error;
    case FilingState.intimationIssued:
      return AppColors.accent;
  }
}

/// Returns an icon for the filing type.
IconData _filingIcon(FilingType type) {
  switch (type) {
    case FilingType.itr:
      return Icons.receipt_long_rounded;
    case FilingType.gst:
      return Icons.local_shipping_rounded;
    case FilingType.tds:
      return Icons.account_balance_rounded;
    case FilingType.mca:
      return Icons.business_rounded;
  }
}

/// Formats paise to INR display string (e.g. 4500000 → "₹45,000").
String formatPaise(int paise) {
  final rupees = paise ~/ 100;
  if (rupees >= 10000000) {
    return '₹${(rupees / 10000000).toStringAsFixed(2)} Cr';
  }
  if (rupees >= 100000) {
    return '₹${(rupees / 100000).toStringAsFixed(2)} L';
  }
  return '₹${_indianFormat(rupees)}';
}

String _indianFormat(int number) {
  if (number < 0) return '-${_indianFormat(-number)}';
  final str = number.toString();
  if (str.length <= 3) return str;

  final last3 = str.substring(str.length - 3);
  var rest = str.substring(0, str.length - 3);

  final parts = <String>[];
  while (rest.length > 2) {
    parts.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) {
    parts.insert(0, rest);
  }

  return '${parts.join(',')},$last3';
}

/// A tile displaying a filing's type, client PAN, period, status chip,
/// and optional refund/demand amount.
class FilingStatusTile extends StatelessWidget {
  const FilingStatusTile({
    super.key,
    required this.filing,
    this.refundAmountPaise,
    this.demandAmountPaise,
    this.onTap,
  });

  final FilingStatus filing;
  final int? refundAmountPaise;
  final int? demandAmountPaise;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = _stateColor(filing.currentState);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Filing type icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: chipColor.withAlpha(18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _filingIcon(filing.filingType),
                  color: chipColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              // Title & subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formName(filing),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      filing.pan,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                  ],
                ),
              ),
              // Amount if applicable
              if (refundAmountPaise != null) ...[
                Text(
                  formatPaise(refundAmountPaise!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (demandAmountPaise != null) ...[
                Text(
                  formatPaise(demandAmountPaise!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              // Status chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: chipColor.withAlpha(18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  filing.currentState.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: chipColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
