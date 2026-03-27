import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';

/// Visual timeline showing the lifecycle of an e-invoice.
///
/// Steps: Created -> Validated -> IRN Generated -> (Cancelled)
/// Current step is highlighted; completed steps show green ticks.
class EinvoiceStatusTimeline extends StatelessWidget {
  const EinvoiceStatusTimeline({
    super.key,
    required this.status,
    this.createdDate,
    this.validatedDate,
    this.irnGeneratedDate,
    this.cancelledDate,
  });

  /// Lifecycle status: Generated | Cancelled | Pending | Overdue
  final String status;

  final String? createdDate;
  final String? validatedDate;
  final String? irnGeneratedDate;
  final String? cancelledDate;

  int get _currentStepIndex {
    switch (status) {
      case 'Generated':
        return 2;
      case 'Cancelled':
        return 3;
      case 'Overdue':
      case 'Pending':
        return 0;
      default:
        return 0;
    }
  }

  bool get _isCancelled => status == 'Cancelled';

  @override
  Widget build(BuildContext context) {
    final steps = <_TimelineStep>[
      _TimelineStep(
        label: 'Created',
        date: createdDate,
        index: 0,
        currentStep: _currentStepIndex,
        isCancelled: false,
      ),
      _TimelineStep(
        label: 'Validated',
        date: validatedDate,
        index: 1,
        currentStep: _currentStepIndex,
        isCancelled: false,
      ),
      _TimelineStep(
        label: 'IRN Generated',
        date: irnGeneratedDate,
        index: 2,
        currentStep: _currentStepIndex,
        isCancelled: false,
      ),
      if (_isCancelled)
        _TimelineStep(
          label: 'Cancelled',
          date: cancelledDate,
          index: 3,
          currentStep: _currentStepIndex,
          isCancelled: true,
        ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            if (i > 0)
              Expanded(
                child: Container(
                  height: 2,
                  color: i <= _currentStepIndex
                      ? (_isCancelled && i == steps.length - 1
                            ? AppColors.error
                            : AppColors.success)
                      : AppColors.neutral200,
                ),
              ),
            steps[i],
          ],
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.label,
    required this.date,
    required this.index,
    required this.currentStep,
    required this.isCancelled,
  });

  final String label;
  final String? date;
  final int index;
  final int currentStep;
  final bool isCancelled;

  bool get _isCompleted => index < currentStep;
  bool get _isCurrent => index == currentStep;

  Color get _color {
    if (isCancelled) return AppColors.error;
    if (_isCompleted) return AppColors.success;
    if (_isCurrent) return AppColors.primary;
    return AppColors.neutral300;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _isCompleted || _isCurrent ? _color : AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: _color, width: 2),
          ),
          child: Center(
            child: _isCompleted
                ? Icon(
                    isCancelled ? Icons.close : Icons.check,
                    size: 16,
                    color: Colors.white,
                  )
                : _isCurrent
                ? Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: _isCurrent ? FontWeight.w700 : FontWeight.w500,
            color: _isCurrent ? _color : AppColors.neutral400,
          ),
        ),
        if (date != null)
          Text(
            date!,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 9,
              color: AppColors.neutral400,
            ),
          ),
      ],
    );
  }
}
