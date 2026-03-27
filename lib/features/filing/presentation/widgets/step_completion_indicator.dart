import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/theme/app_spacing.dart';

/// A row of numbered dots showing wizard step completion status.
///
/// - Completed steps: filled primary circle
/// - Current step: filled accent circle (slightly larger)
/// - Future steps: outlined neutral circle
class StepCompletionIndicator extends StatelessWidget {
  const StepCompletionIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    required this.completedSteps,
  });

  /// Total number of steps in the wizard.
  final int totalSteps;

  /// Zero-based index of the currently visible step.
  final int currentStep;

  /// Set of zero-based step indices that the user has completed.
  final Set<int> completedSteps;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      color: AppColors.neutral100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps, (index) {
          final isCompleted = completedSteps.contains(index);
          final isCurrent = index == currentStep;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _StepDot(
              stepNumber: index + 1,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
            ),
          );
        }),
      ),
    );
  }
}

/// Individual step dot with a number inside.
class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.stepNumber,
    required this.isCompleted,
    required this.isCurrent,
  });

  final int stepNumber;
  final bool isCompleted;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final double size = isCurrent ? 26 : 22;

    final Color backgroundColor;
    final Color textColor;
    final Color borderColor;

    if (isCurrent) {
      backgroundColor = AppColors.accent;
      textColor = Colors.white;
      borderColor = AppColors.accent;
    } else if (isCompleted) {
      backgroundColor = AppColors.primary;
      textColor = Colors.white;
      borderColor = AppColors.primary;
    } else {
      backgroundColor = Colors.transparent;
      textColor = AppColors.neutral400;
      borderColor = AppColors.neutral400;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        '$stepNumber',
        style: TextStyle(
          fontSize: isCurrent ? 12 : 10,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
