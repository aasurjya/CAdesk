import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/transfer_pricing/domain/models/tp_study.dart';

/// A card tile displaying a TP study with progress steps indicator.
class TpStudyTile extends StatelessWidget {
  const TpStudyTile({super.key, required this.study});

  final TpStudy study;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');
    final amountFormat = NumberFormat.compactCurrency(
      locale: 'en_IN',
      symbol: '\u20B9',
      decimalDigits: 1,
    );

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
              // Top row: client name and transaction value
              Row(
                children: [
                  Expanded(
                    child: Text(
                      study.clientName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    amountFormat.format(study.transactionValue),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Badges row: study type, method, FY
              Row(
                children: [
                  _StudyTypeBadge(type: study.studyType),
                  const SizedBox(width: 8),
                  _MethodBadge(method: study.method),
                  const SizedBox(width: 8),
                  Text(
                    'FY ${study.financialYear}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Progress steps indicator
              _ProgressSteps(currentStatus: study.status),
              const SizedBox(height: 10),

              // Bottom row: analyst, due date
              Row(
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    size: 14,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    study.analystName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 12,
                    color: AppColors.neutral400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${dateFormat.format(study.dueDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                ],
              ),

              // Completed date if final
              if (study.completedDate != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Completed: ${dateFormat.format(study.completedDate!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Visual progress steps for TP study workflow.
class _ProgressSteps extends StatelessWidget {
  const _ProgressSteps({required this.currentStatus});

  final TpStudyStatus currentStatus;

  static const _steps = [
    'Not Started',
    'Data',
    'Analysis',
    'Draft',
    'Review',
    'Final',
  ];

  @override
  Widget build(BuildContext context) {
    final currentStep = currentStatus.stepIndex;

    return Row(
      children: List.generate(_steps.length, (index) {
        final isCompleted = index <= currentStep;
        final isCurrent = index == currentStep;
        final color = isCompleted ? currentStatus.color : AppColors.neutral200;

        return Expanded(
          child: Row(
            children: [
              // Step dot
              Container(
                width: isCurrent ? 14 : 10,
                height: isCurrent ? 14 : 10,
                decoration: BoxDecoration(
                  color: isCompleted ? color : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: isCurrent ? 2 : 1.5),
                ),
                child: isCurrent
                    ? Icon(currentStatus.icon, size: 8, color: Colors.white)
                    : null,
              ),
              // Connector line (except for last step)
              if (index < _steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: index < currentStep
                        ? currentStatus.color
                        : AppColors.neutral200,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

/// Badge for study type.
class _StudyTypeBadge extends StatelessWidget {
  const _StudyTypeBadge({required this.type});

  final TpStudyType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.secondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Badge for TP method.
class _MethodBadge extends StatelessWidget {
  const _MethodBadge({required this.method});

  final TpMethod method;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryVariant.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        method.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.primaryVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
