import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import '../../data/providers/assessment_providers.dart';
import '../../domain/models/assessment_order.dart';

/// Shows a detailed bottom sheet for a single [AssessmentOrder].
///
/// Includes demand vs refund reconciliation and live interest
/// computation via [InterestCalculator234].
class AssessmentDetailSheet extends StatelessWidget {
  const AssessmentDetailSheet({super.key, required this.order});

  final AssessmentOrder order;

  static final _dateFormat = DateFormat('dd MMM yyyy');

  /// Opens the sheet using [showModalBottomSheet].
  static Future<void> show(BuildContext context, AssessmentOrder order) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AssessmentDetailSheet(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return _SheetContent(
          order: order,
          scrollController: scrollController,
          dateFormat: _dateFormat,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Sheet content
// ---------------------------------------------------------------------------

class _SheetContent extends StatelessWidget {
  const _SheetContent({
    required this.order,
    required this.scrollController,
    required this.dateFormat,
  });

  final AssessmentOrder order;
  final ScrollController scrollController;
  final DateFormat dateFormat;

  /// Derive plausible advance-tax instalments from the mock order data.
  ///
  /// In a real app these would come from the data layer.  Here we spread
  /// [order.taxAssessed] proportionally over the four instalment dates using
  /// the statutory percentages so the 234C computation is meaningful.
  AssessmentInterestSummary _computeInterest() {
    final tax = order.taxAssessed;
    // Assume TDS = 30% of tax assessed, advance tax = 55% of tax assessed.
    final tds = tax * 0.30;
    final advanceTax = tax * 0.55;
    // Instalments: assume taxpayer paid uniformly — slightly below threshold.
    return InterestCalculator234.computeAll(
      taxPayable: tax,
      advanceTaxPaid: advanceTax,
      tdsCredited: tds,
      advanceTaxByJun15: tax * 0.10, // paid 10% vs required 15%
      advanceTaxBySep15: tax * 0.40, // paid 40% vs required 45%
      advanceTaxByDec15: tax * 0.70, // paid 70% vs required 75%
      monthsLateFor234A: 3,
      monthsFor234B: 8,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final interest = _computeInterest();
    final hasDemand = order.demandAmount > 0;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _DragHandle(),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              children: [
                _Header(order: order, dateFormat: dateFormat, theme: theme),
                const SizedBox(height: 16),
                _DemandRefundCard(
                  demandAmount: order.demandAmount,
                  hasDemand: hasDemand,
                  interest: interest,
                ),
                const SizedBox(height: 16),
                _TaxComputationCard(order: order, interest: interest),
                const SizedBox(height: 16),
                _InterestCard(interest: interest),
                const SizedBox(height: 20),
                _ActionRow(order: order, interest: interest),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Drag handle
// ---------------------------------------------------------------------------

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.neutral300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header: name, PAN, AY, section, order date
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({
    required this.order,
    required this.dateFormat,
    required this.theme,
  });

  final AssessmentOrder order;
  final DateFormat dateFormat;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          order.clientName,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'PAN: ${order.pan}  •  ${order.assessmentYear}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.neutral400,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _Badge(
              label: order.section.fullLabel,
              color: _sectionColor(order.section),
            ),
            const SizedBox(width: 8),
            Text(
              'Dated: ${dateFormat.format(order.orderDate)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ),
        if (order.remarks != null) ...[
          const SizedBox(height: 8),
          Text(
            order.remarks!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral600,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  static Color _sectionColor(AssessmentSection s) {
    switch (s) {
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
}

// ---------------------------------------------------------------------------
// Demand vs refund card
// ---------------------------------------------------------------------------

class _DemandRefundCard extends StatelessWidget {
  const _DemandRefundCard({
    required this.demandAmount,
    required this.hasDemand,
    required this.interest,
  });

  final double demandAmount;
  final bool hasDemand;
  final AssessmentInterestSummary interest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = hasDemand ? AppColors.error : AppColors.success;
    final label = hasDemand ? 'Demand Outstanding' : 'Refund Due';
    final icon = hasDemand
        ? Icons.warning_amber_rounded
        : Icons.savings_rounded;
    final amount = hasDemand ? demandAmount : interest.refund;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  CurrencyUtils.formatINR(amount),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          if (hasDemand)
            const _Badge(label: 'Due: 30 days', color: AppColors.warning),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tax computation breakdown card
// ---------------------------------------------------------------------------

class _TaxComputationCard extends StatelessWidget {
  const _TaxComputationCard({required this.order, required this.interest});

  final AssessmentOrder order;
  final AssessmentInterestSummary interest;

  @override
  Widget build(BuildContext context) {
    // Derive figures from model fields for display.
    final tds = order.taxAssessed * 0.30;
    final advanceTax = order.taxAssessed * 0.55;
    final netBeforeInterest = order.taxAssessed - tds - advanceTax;
    final hasVariance = order.disallowances > 0;

    return _SectionCard(
      title: 'Tax Computation',
      icon: Icons.receipt_long_rounded,
      children: [
        _ComputationRow(
          label: 'Income per return',
          value: CurrencyUtils.formatINRCompact(
            order.incomeAssessed - order.disallowances,
          ),
        ),
        _ComputationRow(
          label: 'Income per assessment',
          value: CurrencyUtils.formatINRCompact(order.incomeAssessed),
          valueColor: hasVariance ? AppColors.error : null,
          trailing: hasVariance
              ? _Badge(
                  label:
                      '+${CurrencyUtils.formatINRCompact(order.disallowances)}',
                  color: AppColors.error,
                )
              : null,
        ),
        _Divider(),
        _ComputationRow(
          label: 'Tax on assessed income',
          value: CurrencyUtils.formatINR(order.taxAssessed),
          valueColor: AppColors.neutral900,
        ),
        _ComputationRow(
          label: 'Less: TDS / TCS credit',
          value: '- ${CurrencyUtils.formatINR(tds)}',
          valueColor: AppColors.success,
        ),
        _ComputationRow(
          label: 'Less: Advance tax paid',
          value: '- ${CurrencyUtils.formatINR(advanceTax)}',
          valueColor: AppColors.success,
        ),
        _Divider(),
        _ComputationRow(
          label: 'Net tax before interest',
          value: CurrencyUtils.formatINR(netBeforeInterest),
          valueColor: netBeforeInterest > 0
              ? AppColors.error
              : AppColors.success,
          bold: true,
        ),
        _ComputationRow(
          label: 'Add: Total interest',
          value: '+ ${CurrencyUtils.formatINR(interest.totalInterest)}',
          valueColor: AppColors.warning,
        ),
        _Divider(),
        _ComputationRow(
          label: 'Total demand',
          value: CurrencyUtils.formatINR(
            netBeforeInterest + interest.totalInterest,
          ),
          valueColor: AppColors.error,
          bold: true,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Interest section card
// ---------------------------------------------------------------------------

class _InterestCard extends StatelessWidget {
  const _InterestCard({required this.interest});

  final AssessmentInterestSummary interest;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Interest Computation',
      icon: Icons.calculate_rounded,
      children: [
        _InterestRow(
          label: 'Section 234A',
          subtitle: 'Late filing  •  1% p.m.  •  3 months',
          amount: interest.interest234A,
          color: AppColors.error,
        ),
        _InterestRow(
          label: 'Section 234B',
          subtitle: 'Short advance tax  •  1% p.m.  •  8 months',
          amount: interest.interest234B,
          color: AppColors.warning,
        ),
        _InterestRow(
          label: 'Section 234C',
          subtitle: 'Instalment deferment  •  1% p.m.  •  3 months each',
          amount: interest.interest234C,
          color: AppColors.accent,
        ),
        _Divider(),
        _InterestRow(
          label: 'Total interest',
          subtitle: '',
          amount: interest.totalInterest,
          color: AppColors.error,
          bold: true,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Action buttons row
// ---------------------------------------------------------------------------

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.order, required this.interest});

  final AssessmentOrder order;
  final AssessmentInterestSummary interest;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _ActionButton(
          label: 'File Rectification',
          icon: Icons.edit_note_rounded,
          color: AppColors.primary,
          onTap: () => _showSnack(context, 'Rectification petition initiated'),
        ),
        _ActionButton(
          label: 'Pay Demand',
          icon: Icons.account_balance_wallet_rounded,
          color: AppColors.error,
          onTap: () => _showSnack(
            context,
            'Redirecting to pay ${CurrencyUtils.formatINR(order.demandAmount)}',
          ),
        ),
        _ActionButton(
          label: 'Appeal to CIT(A)',
          icon: Icons.gavel_rounded,
          color: AppColors.secondary,
          onTap: () => _showSnack(context, 'CIT(A) appeal form opened'),
        ),
      ],
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable section card
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.neutral200),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small reusable row widgets
// ---------------------------------------------------------------------------

class _ComputationRow extends StatelessWidget {
  const _ComputationRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
    this.trailing,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral600,
                fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          if (trailing != null) ...[trailing!, const SizedBox(width: 6)],
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: valueColor ?? AppColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InterestRow extends StatelessWidget {
  const _InterestRow({
    required this.label,
    required this.subtitle,
    required this.amount,
    required this.color,
    this.bold = false,
  });

  final String label;
  final String subtitle;
  final double amount;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            CurrencyUtils.formatINR(amount),
            style: TextStyle(
              fontSize: 12,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Divider(height: 1, thickness: 1, color: AppColors.neutral200),
    );
  }
}

// ---------------------------------------------------------------------------
// Badge
// ---------------------------------------------------------------------------

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
