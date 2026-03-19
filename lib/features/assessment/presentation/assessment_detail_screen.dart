import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import '../data/providers/assessment_providers.dart';
import '../domain/models/assessment_order.dart';

final _dateFmt = DateFormat('dd MMM yyyy');

/// Full detail view for a single assessment order.
///
/// Route: `/assessment/detail/:orderId`
class AssessmentDetailScreen extends ConsumerWidget {
  const AssessmentDetailScreen({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(assessmentOrdersProvider);
    final order = orders.where((o) => o.id == orderId).firstOrNull;

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Assessment Detail')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search_off,
                size: 48,
                color: AppColors.neutral300,
              ),
              const SizedBox(height: 16),
              const Text('Assessment order not found'),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final interest = ref
        .watch(interestCalculationsProvider)
        .where((i) => i.orderId == orderId)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Order — ${order.clientName}',
          style: const TextStyle(fontSize: 16),
        ),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _OrderInfoCard(order: order),
            const SizedBox(height: 16),
            _TaxDemandCard(order: order),
            const SizedBox(height: 16),
            if (interest.isNotEmpty) ...[
              _InterestBreakdownCard(calculations: interest),
              const SizedBox(height: 16),
            ],
            _PenaltySection(order: order),
            const SizedBox(height: 16),
            _ResponseTimeline(order: order),
            const SizedBox(height: 24),
            _ActionButtons(order: order),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Order info card
// ---------------------------------------------------------------------------

class _OrderInfoCard extends StatelessWidget {
  const _OrderInfoCard({required this.order});

  final AssessmentOrder order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(order.verificationStatus);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.clientName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.verificationStatus.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DetailRow(label: 'PAN', value: order.pan),
            _DetailRow(label: 'Assessment Year', value: order.assessmentYear),
            _DetailRow(label: 'Section', value: order.section.fullLabel),
            _DetailRow(
              label: 'Order Date',
              value: _dateFmt.format(order.orderDate),
            ),
            _DetailRow(label: 'Assigned To', value: order.assignedTo),
            if (order.remarks != null)
              _DetailRow(label: 'Remarks', value: order.remarks!),
          ],
        ),
      ),
    );
  }

  Color _statusColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return AppColors.warning;
      case VerificationStatus.verified:
        return AppColors.success;
      case VerificationStatus.disputed:
        return AppColors.error;
      case VerificationStatus.rectified:
        return AppColors.primaryVariant;
    }
  }
}

// ---------------------------------------------------------------------------
// Tax demand card
// ---------------------------------------------------------------------------

class _TaxDemandCard extends StatelessWidget {
  const _TaxDemandCard({required this.order});

  final AssessmentOrder order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: order.demandAmount > 0
          ? AppColors.error.withValues(alpha: 0.04)
          : AppColors.success.withValues(alpha: 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: order.demandAmount > 0
              ? AppColors.error.withValues(alpha: 0.2)
              : AppColors.success.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tax & Demand Summary',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _AmountCell(
                  label: 'Income Assessed',
                  amount: order.incomeAssessed,
                  color: AppColors.neutral900,
                ),
                _AmountCell(
                  label: 'Tax Assessed',
                  amount: order.taxAssessed,
                  color: AppColors.primaryVariant,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _AmountCell(
                  label: 'Disallowances',
                  amount: order.disallowances,
                  color: AppColors.warning,
                ),
                _AmountCell(
                  label: 'Demand Amount',
                  amount: order.demandAmount,
                  color: order.demandAmount > 0
                      ? AppColors.error
                      : AppColors.success,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountCell extends StatelessWidget {
  const _AmountCell({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.neutral400),
          ),
          const SizedBox(height: 2),
          Text(
            CurrencyUtils.formatINRCompact(amount),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Interest breakdown
// ---------------------------------------------------------------------------

class _InterestBreakdownCard extends StatelessWidget {
  const _InterestBreakdownCard({required this.calculations});

  final List<dynamic> calculations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calculate_rounded,
                  size: 18,
                  color: AppColors.primaryVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Interest Breakdown',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...calculations.map(
              (calc) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      calc.isCorrect
                          ? Icons.check_circle_rounded
                          : Icons.error_rounded,
                      size: 16,
                      color: calc.isCorrect
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        calc.section.label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      CurrencyUtils.formatINRCompact(
                        calc.calculatedInterest as double,
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900,
                      ),
                    ),
                    if (!calc.isCorrect) ...[
                      const SizedBox(width: 8),
                      Text(
                        '(Dept: ${CurrencyUtils.formatINRCompact(calc.actualInterest as double)})',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Penalty section
// ---------------------------------------------------------------------------

class _PenaltySection extends StatelessWidget {
  const _PenaltySection({required this.order});

  final AssessmentOrder order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPenalty = order.hasErrors && order.demandAmount > 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: hasPenalty
              ? AppColors.warning.withValues(alpha: 0.3)
              : AppColors.neutral200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              hasPenalty ? Icons.gavel_rounded : Icons.verified_user_rounded,
              size: 24,
              color: hasPenalty ? AppColors.warning : AppColors.success,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasPenalty ? 'Penalty Applicable' : 'No Penalty',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: hasPenalty ? AppColors.warning : AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasPenalty
                        ? 'Errors detected in order computation. '
                              'Penalty proceedings may be initiated.'
                        : 'No computation errors found in this order.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Response timeline
// ---------------------------------------------------------------------------

class _ResponseTimeline extends StatelessWidget {
  const _ResponseTimeline({required this.order});

  final AssessmentOrder order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = _buildSteps(order);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Response Timeline',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 12),
            ...steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isLast = index == steps.length - 1;

              return _TimelineStep(
                title: step.title,
                subtitle: step.subtitle,
                isCompleted: step.isCompleted,
                isActive: step.isActive,
                isLast: isLast,
              );
            }),
          ],
        ),
      ),
    );
  }

  List<_StepData> _buildSteps(AssessmentOrder order) {
    final currentIndex = _statusIndex(order.verificationStatus);
    return [
      _StepData(
        title: 'Order Received',
        subtitle: _dateFmt.format(order.orderDate),
        isCompleted: currentIndex > 0,
        isActive: currentIndex == 0,
      ),
      _StepData(
        title: 'Under Verification',
        subtitle: 'Checking computation accuracy',
        isCompleted: currentIndex > 1,
        isActive: currentIndex == 1,
      ),
      _StepData(
        title: 'Response Filed',
        subtitle: order.verificationStatus == VerificationStatus.disputed
            ? 'Rectification / appeal filed'
            : 'Pending response',
        isCompleted: currentIndex > 2,
        isActive: currentIndex == 2,
      ),
      _StepData(
        title: 'Resolved',
        subtitle: order.verificationStatus == VerificationStatus.verified
            ? 'Order verified — no action needed'
            : 'Awaiting resolution',
        isCompleted: currentIndex >= 3,
        isActive: false,
      ),
    ];
  }

  int _statusIndex(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return 1;
      case VerificationStatus.disputed:
        return 2;
      case VerificationStatus.rectified:
        return 3;
      case VerificationStatus.verified:
        return 3;
    }
  }
}

class _StepData {
  const _StepData({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isActive,
  });

  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isActive;
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isActive,
    required this.isLast,
  });

  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isActive;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = isCompleted
        ? AppColors.success
        : isActive
        ? AppColors.primary
        : AppColors.neutral300;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isCompleted || isActive ? color : AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 10, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted
                          ? AppColors.success
                          : AppColors.neutral200,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isCompleted || isActive
                          ? AppColors.neutral900
                          : AppColors.neutral400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action buttons
// ---------------------------------------------------------------------------

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.order});

  final AssessmentOrder order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (order.demandAmount > 0) ...[
          FilledButton.icon(
            onPressed: () => _showSnack(context, 'Appeal filing initiated'),
            icon: const Icon(Icons.gavel_rounded, size: 18),
            label: const Text('File Appeal'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 10),
        ],
        OutlinedButton.icon(
          onPressed: () => _showSnack(context, 'Extension request submitted'),
          icon: const Icon(Icons.schedule_rounded, size: 18),
          label: const Text('Request Extension'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryVariant,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _showSnack(context, 'Order marked as resolved'),
          icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
          label: const Text('Mark Resolved'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.success,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared detail row
// ---------------------------------------------------------------------------

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 128,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.neutral600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
