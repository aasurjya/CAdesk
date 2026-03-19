import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/filing/data/providers/filing_job_providers.dart';
import 'package:ca_app/features/filing/data/providers/itr2_form_providers.dart';
import 'package:ca_app/features/filing/presentation/itr2/steps/personal_info_step.dart';
import 'package:ca_app/features/filing/presentation/itr2/steps/salary_income_step.dart';
import 'package:ca_app/features/filing/presentation/itr2/steps/house_property_step.dart';
import 'package:ca_app/features/filing/presentation/itr2/steps/other_sources_step.dart';
import 'package:ca_app/features/filing/presentation/itr2/steps/capital_gains_step.dart';
import 'package:ca_app/features/filing/presentation/itr2/steps/foreign_assets_step.dart';
import 'package:ca_app/features/filing/presentation/itr2/steps/schedule_al_step.dart';
import 'package:ca_app/features/filing/presentation/itr2/steps/deductions_step.dart';
import 'package:ca_app/features/filing/presentation/itr2/steps/tax_computation_step.dart';
import 'package:ca_app/features/filing/presentation/itr2/steps/review_export_step.dart';

const _kTotalSteps = 10;

const _kStepTitles = <String>[
  'Personal Info',
  'Salary Income',
  'House Property',
  'Other Sources',
  'Capital Gains',
  'Foreign Assets',
  'Assets & Liabilities',
  'Deductions',
  'Tax Computation',
  'Review & Export',
];

class Itr2WizardScreen extends ConsumerStatefulWidget {
  const Itr2WizardScreen({required this.jobId, super.key});

  final String jobId;

  @override
  ConsumerState<Itr2WizardScreen> createState() => _Itr2WizardScreenState();
}

class _Itr2WizardScreenState extends ConsumerState<Itr2WizardScreen> {
  // Cache notifier reference so dispose() can call it safely after unmount.
  late final _activeJobNotifier = ref.read(activeFilingJobIdProvider.notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeFilingJobIdProvider.notifier).set(widget.jobId);
      ref.read(itr2WizardStepProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _activeJobNotifier.set(null);
    super.dispose();
  }

  void _saveDraft() {
    final job = ref.read(activeFilingJobProvider);
    if (job == null) return;
    final formData = ref.read(itr2FormDataProvider);
    final updated = job.copyWith(itr2Data: formData, updatedAt: DateTime.now());
    ref.read(filingJobsProvider.notifier).update(updated);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Draft saved')));
  }

  @override
  Widget build(BuildContext context) {
    final step = ref.watch(itr2WizardStepProvider);
    final job = ref.watch(activeFilingJobProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          job != null ? 'ITR-2 — ${job.clientName}' : 'ITR-2 Wizard',
          style: const TextStyle(fontSize: 16),
        ),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          TextButton.icon(
            onPressed: _saveDraft,
            icon: const Icon(
              Icons.save_outlined,
              size: 16,
              color: Colors.white,
            ),
            label: const Text(
              'Save Draft',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8),
          child: _WizardProgressBar(step: step, totalSteps: _kTotalSteps),
        ),
      ),
      body: Column(
        children: [
          _StepHeader(step: step),
          Expanded(child: _StepBody(step: step)),
          const Divider(height: 1),
          _WizardNavBar(step: step, totalSteps: _kTotalSteps),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Progress bar
// ---------------------------------------------------------------------------

class _WizardProgressBar extends StatelessWidget {
  const _WizardProgressBar({required this.step, required this.totalSteps});

  final int step;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: (step + 1) / totalSteps,
      backgroundColor: AppColors.primaryVariant,
      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
      minHeight: 8,
    );
  }
}

// ---------------------------------------------------------------------------
// Step header
// ---------------------------------------------------------------------------

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.neutral100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        'Step ${step + 1} of $_kTotalSteps  •  ${_kStepTitles[step]}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.neutral600,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step body switcher
// ---------------------------------------------------------------------------

class _StepBody extends StatelessWidget {
  const _StepBody({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return switch (step) {
      0 => const Itr2PersonalInfoStep(),
      1 => const Itr2SalaryIncomeStep(),
      2 => const Itr2HousePropertyStep(),
      3 => const Itr2OtherSourcesStep(),
      4 => const CapitalGainsStep(),
      5 => const ForeignAssetsStep(),
      6 => const ScheduleAlStep(),
      7 => const Itr2DeductionsStep(),
      8 => const Itr2TaxComputationStep(),
      9 => const Itr2ReviewExportStep(),
      _ => const SizedBox.shrink(),
    };
  }
}

// ---------------------------------------------------------------------------
// Navigation bar
// ---------------------------------------------------------------------------

class _WizardNavBar extends ConsumerWidget {
  const _WizardNavBar({required this.step, required this.totalSteps});

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
                        .read(itr2WizardStepProvider.notifier)
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
                    ref.read(itr2WizardStepProvider.notifier).goTo(step + 1),
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('Next'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              )
            else
              FilledButton.icon(
                onPressed: null, // Handled inside ReviewExportStep
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
