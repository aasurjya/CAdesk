import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/filing/data/providers/filing_job_providers.dart';
import 'package:ca_app/features/filing/data/providers/itr4_form_data_providers.dart';
import 'package:ca_app/features/filing/presentation/itr1/steps/personal_info_step.dart';
import 'package:ca_app/features/filing/presentation/itr4/steps/business_income_step.dart';
import 'package:ca_app/features/filing/presentation/itr4/steps/profession_income_step.dart';
import 'package:ca_app/features/filing/presentation/itr1/steps/other_sources_step.dart';
import 'package:ca_app/features/filing/presentation/itr1/steps/deductions_step.dart';
import 'package:ca_app/features/filing/presentation/itr4/steps/itr4_tax_computation_step.dart';

const _kTotalSteps = 6;

const _kStepTitles = <String>[
  'Personal Info',
  'Business Income (44AD)',
  'Professional Income (44ADA)',
  'Other Sources',
  'Deductions',
  'Tax Computation & Review',
];

class Itr4WizardScreen extends ConsumerStatefulWidget {
  const Itr4WizardScreen({required this.jobId, super.key});

  final String jobId;

  @override
  ConsumerState<Itr4WizardScreen> createState() => _Itr4WizardScreenState();
}

class _Itr4WizardScreenState extends ConsumerState<Itr4WizardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeFilingJobIdProvider.notifier).set(widget.jobId);
      ref.read(itr4WizardStepProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeFilingJobIdProvider.notifier).set(null);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = ref.watch(itr4WizardStepProvider);
    final job = ref.watch(activeFilingJobProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          job != null ? 'ITR-4 — ${job.clientName}' : 'ITR-4 Wizard',
          style: const TextStyle(fontSize: 16),
        ),
        leading: BackButton(onPressed: () => context.pop()),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: (step + 1) / _kTotalSteps,
            backgroundColor: AppColors.primaryVariant,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            minHeight: 6,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.neutral100,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              'Step ${step + 1} of $_kTotalSteps  •  ${_kStepTitles[step]}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.neutral600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: _stepBody(step)),
          const Divider(height: 1),
          _Itr4NavBar(step: step, totalSteps: _kTotalSteps),
        ],
      ),
    );
  }

  Widget _stepBody(int step) {
    return switch (step) {
      0 => const PersonalInfoStep(),
      1 => const BusinessIncomeStep(),
      2 => const ProfessionIncomeStep(),
      3 => const OtherSourcesStep(),
      4 => const DeductionsStep(),
      5 => const Itr4TaxComputationStep(),
      _ => const SizedBox.shrink(),
    };
  }
}

class _Itr4NavBar extends ConsumerWidget {
  const _Itr4NavBar({required this.step, required this.totalSteps});

  final int step;
  final int totalSteps;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFirst = step == 0;
    final isLast = step == totalSteps - 1;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            OutlinedButton.icon(
              onPressed: isFirst
                  ? null
                  : () => ref
                        .read(itr4WizardStepProvider.notifier)
                        .goTo(step - 1),
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Back'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
            const Spacer(),
            if (!isLast)
              FilledButton.icon(
                onPressed: () =>
                    ref.read(itr4WizardStepProvider.notifier).goTo(step + 1),
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('Next'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              )
            else
              FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label: const Text('Done'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
