import 'package:flutter/material.dart';

import 'package:ca_app/core/theme/app_colors.dart';

/// A single step in the status timeline.
class TimelineStep {
  const TimelineStep({
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
    this.isActive = false,
  });

  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isActive;
}

/// Reusable vertical timeline widget with checkmarks and dots.
///
/// Each [TimelineStep] is rendered as a row with a connector line,
/// a status indicator (checkmark / active dot / inactive dot),
/// and the step title + subtitle.
class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.steps});

  final List<TimelineStep> steps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicator column
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    _StepIndicator(
                      isCompleted: step.isCompleted,
                      isActive: step.isActive,
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: step.isCompleted
                              ? AppColors.success
                              : AppColors.neutral200,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Content column
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: step.isActive || step.isCompleted
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: step.isActive || step.isCompleted
                              ? AppColors.neutral900
                              : AppColors.neutral400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        step.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
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
      }),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.isCompleted, required this.isActive});

  final bool isCompleted;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
      );
    }

    if (isActive) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(25),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: Center(
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.neutral200, width: 2),
      ),
    );
  }
}
