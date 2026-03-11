import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import '../../domain/models/assessment_order.dart';

/// Tile showing an assessment order with section badge,
/// demand amount, and error indicator.
class AssessmentOrderTile extends StatelessWidget {
  const AssessmentOrderTile({
    super.key,
    required this.order,
    this.onTap,
  });

  final AssessmentOrder order;
  final VoidCallback? onTap;

  static final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: order.hasErrors
              ? AppColors.error.withValues(alpha: 0.35)
              : AppColors.neutral200,
          width: order.hasErrors ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: client name + error indicator
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.clientName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'PAN: ${order.pan}  •  ${order.assessmentYear}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral400,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (order.hasErrors)
                    const _ErrorBadge()
                  else
                    const _NoBadge(),
                ],
              ),

              const SizedBox(height: 10),

              // Section badge + verification status + date
              Row(
                children: [
                  _SectionBadge(section: order.section),
                  const SizedBox(width: 8),
                  _VerificationBadge(status: order.verificationStatus),
                  const Spacer(),
                  Text(
                    _dateFormat.format(order.orderDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Figures row
              _FiguresRow(order: order),

              // Remarks (if any)
              if (order.remarks != null) ...[
                const SizedBox(height: 8),
                Text(
                  order.remarks!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral400,
                    fontStyle: FontStyle.italic,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 6),

              // Assigned to
              Text(
                'Assigned to: ${order.assignedTo}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.neutral400,
                  fontSize: 10,
                ),
              ),
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

class _ErrorBadge extends StatelessWidget {
  const _ErrorBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, size: 11, color: AppColors.error),
          SizedBox(width: 3),
          Text(
            'Errors Found',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoBadge extends StatelessWidget {
  const _NoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline_rounded,
              size: 11, color: AppColors.success),
          SizedBox(width: 3),
          Text(
            'No Errors',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionBadge extends StatelessWidget {
  const _SectionBadge({required this.section});

  final AssessmentSection section;

  Color get _color {
    switch (section) {
      case AssessmentSection.section143_1:
        return AppColors.primary;
      case AssessmentSection.section143_3:
        return AppColors.primaryVariant;
      case AssessmentSection.section147:
        return AppColors.warning;
      case AssessmentSection.section153A:
        return AppColors.error;
      case AssessmentSection.section154:
        return AppColors.secondary;
      case AssessmentSection.appealEffect:
        return AppColors.accent;
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
        section.fullLabel,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}

class _VerificationBadge extends StatelessWidget {
  const _VerificationBadge({required this.status});

  final VerificationStatus status;

  Color get _color {
    switch (status) {
      case VerificationStatus.pending:
        return AppColors.warning;
      case VerificationStatus.verified:
        return AppColors.success;
      case VerificationStatus.disputed:
        return AppColors.error;
      case VerificationStatus.rectified:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withValues(alpha: 0.25)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}

class _FiguresRow extends StatelessWidget {
  const _FiguresRow({required this.order});

  final AssessmentOrder order;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Cell(
          label: 'Demand',
          value: CurrencyUtils.formatINRCompact(order.demandAmount),
          color: order.demandAmount > 0 ? AppColors.error : AppColors.success,
        ),
        const _Separator(),
        _Cell(
          label: 'Tax Assessed',
          value: CurrencyUtils.formatINRCompact(order.taxAssessed),
          color: AppColors.primary,
        ),
        const _Separator(),
        _Cell(
          label: 'Disallowances',
          value: CurrencyUtils.formatINRCompact(order.disallowances),
          color: order.disallowances > 0 ? AppColors.warning : AppColors.neutral400,
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
    return Expanded(
      child: Column(
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
      ),
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
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: AppColors.neutral200,
    );
  }
}
