import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/gst/data/providers/gstr3b_wizard_providers.dart';
import 'steps/gstr3b_period_step.dart';
import 'steps/gstr3b_liability_step.dart';
import 'steps/gstr3b_itc_step.dart';
import 'steps/gstr3b_exempt_step.dart';
import 'steps/gstr3b_payment_step.dart';

const _kTotalSteps = 5;

const _kStepTitles = <String>[
  'Period & GSTIN',
  'Tax Liability (3.1)',
  'ITC Claimed (4)',
  'Exempt Supplies (5)',
  'Payment & Summary',
];

class Gstr3bWizardScreen extends ConsumerStatefulWidget {
  const Gstr3bWizardScreen({super.key});

  @override
  ConsumerState<Gstr3bWizardScreen> createState() => _Gstr3bWizardScreenState();
}

class _Gstr3bWizardScreenState extends ConsumerState<Gstr3bWizardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gstr3bWizardStepProvider.notifier).reset();
    });
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('GSTR-3B draft saved'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = ref.watch(gstr3bWizardStepProvider);
    final formData = ref.watch(gstr3bFormDataProvider);
    final periodLabel = formData.gstin.isNotEmpty
        ? '${formData.periodLabel} - ${formData.gstin}'
        : 'GSTR-3B Wizard';

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
      0 => const Gstr3bPeriodStep(),
      1 => const Gstr3bLiabilityStep(),
      2 => const Gstr3bItcStep(),
      3 => const Gstr3bExemptStep(),
      4 => const Gstr3bPaymentStep(),
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
                        .read(gstr3bWizardStepProvider.notifier)
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
                    ref.read(gstr3bWizardStepProvider.notifier).goTo(step + 1),
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('Next'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              )
            else
              FilledButton.icon(
                onPressed: null, // Handled inside Gstr3bPaymentStep
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
