import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/gst/data/providers/gstr1_wizard_providers.dart';
import 'steps/gstr1_period_step.dart';
import 'steps/gstr1_b2b_step.dart';
import 'steps/gstr1_b2c_step.dart';
import 'steps/gstr1_cdnr_step.dart';
import 'steps/gstr1_exports_step.dart';
import 'steps/gstr1_advance_step.dart';
import 'steps/gstr1_summary_step.dart';

const _kTotalSteps = 8;

const _kStepTitles = <String>[
  'Period & GSTIN',
  'B2B Invoices (4A)',
  'B2C Invoices (5/7)',
  'Credit/Debit Notes (9)',
  'Exports (6A)',
  'Advance Tax (11)',
  'HSN Summary (12)',
  'Summary & Submit',
];

class Gstr1WizardScreen extends ConsumerStatefulWidget {
  const Gstr1WizardScreen({super.key});

  @override
  ConsumerState<Gstr1WizardScreen> createState() => _Gstr1WizardScreenState();
}

class _Gstr1WizardScreenState extends ConsumerState<Gstr1WizardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gstr1WizardStepProvider.notifier).reset();
    });
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('GSTR-1 draft saved'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = ref.watch(gstr1WizardStepProvider);
    final formData = ref.watch(gstr1FormDataProvider);
    final periodLabel = formData.gstin.isNotEmpty
        ? '${formData.periodLabel} - ${formData.gstin}'
        : 'GSTR-1 Wizard';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          periodLabel,
          style: const TextStyle(fontSize: 16),
          overflow: TextOverflow.ellipsis,
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
      0 => const Gstr1PeriodStep(),
      1 => const Gstr1B2bStep(),
      2 => const Gstr1B2cStep(),
      3 => const Gstr1CdnrStep(),
      4 => const Gstr1ExportsStep(),
      5 => const Gstr1AdvanceStep(),
      6 => const _Gstr1HsnPlaceholder(),
      7 => const Gstr1SummaryStep(),
      _ => const SizedBox.shrink(),
    };
  }
}

// ---------------------------------------------------------------------------
// HSN Summary placeholder (auto-generated from invoices)
// ---------------------------------------------------------------------------

class _Gstr1HsnPlaceholder extends ConsumerWidget {
  const _Gstr1HsnPlaceholder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.table_chart_rounded,
              size: 48,
              color: AppColors.neutral200,
            ),
            const SizedBox(height: 16),
            Text(
              'HSN Summary (Table 12)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'HSN-wise summary will be auto-generated\nfrom the invoices entered in previous steps.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.neutral400),
            ),
          ],
        ),
      ),
    );
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
                        .read(gstr1WizardStepProvider.notifier)
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
                    ref.read(gstr1WizardStepProvider.notifier).goTo(step + 1),
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('Next'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              )
            else
              FilledButton.icon(
                onPressed: null, // Handled inside Gstr1SummaryStep
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
