import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/filing/data/providers/filing_job_providers.dart';
import 'package:ca_app/features/filing/data/services/draft_storage_service.dart';
import 'package:ca_app/features/filing/presentation/itr1/steps/personal_info_step.dart';
import 'package:ca_app/features/filing/presentation/itr1/steps/salary_income_step.dart';
import 'package:ca_app/features/filing/presentation/itr1/steps/house_property_step.dart';
import 'package:ca_app/features/filing/presentation/itr1/steps/other_sources_step.dart';
import 'package:ca_app/features/filing/presentation/itr1/steps/deductions_step.dart';
import 'package:ca_app/features/filing/presentation/itr1/steps/tax_computation_step.dart';
import 'package:ca_app/features/filing/presentation/itr1/steps/review_export_step.dart';
import 'package:ca_app/features/filing/presentation/itr1/steps/tds_taxes_paid_step.dart';
import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/filing/presentation/widgets/floating_tax_bar.dart';
import 'package:ca_app/features/filing/presentation/widgets/step_completion_indicator.dart';

const _kTotalSteps = 8;

const _kStepTitles = <String>[
  'Personal Info',
  'Salary Income',
  'House Property',
  'Other Sources',
  'Deductions',
  'Tax Computation',
  'TDS & Taxes Paid',
  'Review & Export',
];

class Itr1WizardScreen extends ConsumerStatefulWidget {
  const Itr1WizardScreen({required this.jobId, super.key});

  final String jobId;

  @override
  ConsumerState<Itr1WizardScreen> createState() => _Itr1WizardScreenState();
}

class _Itr1WizardScreenState extends ConsumerState<Itr1WizardScreen> {
  /// Tracks which wizard steps the user has navigated past (completed).
  Set<int> _completedSteps = const {};

  void _markStepCompleted(int step) {
    if (!_completedSteps.contains(step)) {
      setState(() {
        _completedSteps = {..._completedSteps, step};
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Activate the job and load any saved draft.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeFilingJobIdProvider.notifier).set(widget.jobId);
      ref.read(wizardStepProvider.notifier).reset();
      ref.read(itr1FormDataProvider.notifier).loadDraft(widget.jobId);
    });
  }

  @override
  void dispose() {
    // Clear active job when leaving the wizard.
    ref.read(activeFilingJobIdProvider.notifier).set(null);
    super.dispose();
  }

  Future<void> _saveDraft() async {
    final formData = ref.read(itr1FormDataProvider);
    // Persist to SharedPreferences
    await DraftStorageService.saveDraft(widget.jobId, formData);
    // Also update in-memory job if present
    final job = ref.read(activeFilingJobProvider);
    if (job != null) {
      final updated = job.copyWith(
        itr1Data: formData,
        updatedAt: DateTime.now(),
      );
      ref.read(filingJobsProvider.notifier).update(updated);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draft saved'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = ref.watch(wizardStepProvider);
    final job = ref.watch(activeFilingJobProvider);
    final formData = ref.watch(itr1FormDataProvider);
    final taxResult = ref.watch(liveTaxComputationProvider);

    // Compute tax payable based on selected regime.
    final taxPayable = formData.selectedRegime == TaxRegime.newRegime
        ? taxResult.newRegimeTax
        : taxResult.oldRegimeTax;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          job != null ? 'ITR-1 — ${job.clientName}' : 'ITR-1 Wizard',
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
          StepCompletionIndicator(
            totalSteps: _kTotalSteps,
            currentStep: step,
            completedSteps: _completedSteps,
          ),
          _StepHeader(step: step),
          Expanded(child: _StepBody(step: step)),
          FloatingTaxBar(
            grossIncome: formData.grossTotalIncome,
            deductions: formData.allowableDeductions,
            taxPayable: taxPayable,
          ),
          const Divider(height: 1),
          _WizardNavBar(
            step: step,
            totalSteps: _kTotalSteps,
            onStepChange: _markStepCompleted,
          ),
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
      0 => const PersonalInfoStep(),
      1 => const SalaryIncomeStep(),
      2 => const HousePropertyStep(),
      3 => const OtherSourcesStep(),
      4 => const DeductionsStep(),
      5 => const TaxComputationStep(),
      6 => const TdsTaxesPaidStep(),
      7 => const ReviewExportStep(),
      _ => const SizedBox.shrink(),
    };
  }
}

// ---------------------------------------------------------------------------
// Navigation bar
// ---------------------------------------------------------------------------

class _WizardNavBar extends ConsumerWidget {
  const _WizardNavBar({
    required this.step,
    required this.totalSteps,
    required this.onStepChange,
  });

  final int step;
  final int totalSteps;

  /// Called with the current step index when the user navigates away from it.
  final ValueChanged<int> onStepChange;

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
                  : () {
                      onStepChange(step);
                      ref.read(wizardStepProvider.notifier).goTo(step - 1);
                    },
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Back'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
            const Spacer(),
            if (!isLast)
              FilledButton.icon(
                onPressed: () {
                  onStepChange(step);
                  ref.read(wizardStepProvider.notifier).goTo(step + 1);
                },
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
