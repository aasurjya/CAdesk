import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/core/widgets/widgets.dart';
import 'package:ca_app/features/tds/data/providers/fvu_providers.dart';
import 'package:ca_app/features/tds/data/providers/tds_providers.dart';
import 'package:ca_app/features/tds/domain/models/tds_deductor.dart';
import 'package:ca_app/features/tds/domain/models/tds_return.dart';
import 'package:ca_app/features/tds/domain/models/fvu/fvu_file_structure.dart';
import 'package:ca_app/features/tds/domain/services/fvu_generation_service.dart';
import 'package:ca_app/features/tds/domain/services/fvu_pre_scrutiny_service.dart';
import 'widgets/fvu_challan_tile.dart';
import 'widgets/fvu_deductee_tile.dart';
import 'widgets/fvu_validation_card.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const _stepLabels = <String>[
  'Setup',
  'Deductees',
  'Challans',
  'Validate',
  'Generate',
];

/// FVU file generation wizard — 5 steps from deductor selection to download.
class FvuGenerationScreen extends ConsumerStatefulWidget {
  const FvuGenerationScreen({super.key});

  @override
  ConsumerState<FvuGenerationScreen> createState() =>
      _FvuGenerationScreenState();
}

class _FvuGenerationScreenState extends ConsumerState<FvuGenerationScreen> {
  @override
  Widget build(BuildContext context) {
    final currentStep = ref.watch(fvuWizardStepProvider);
    final deductees = ref.watch(fvuDeducteeRecordsProvider);
    final challans = ref.watch(fvuChallanRecordsProvider);
    final totalTds = deductees.fold(0.0, (sum, d) => sum + d.tdsAmount);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const BackButton(color: AppColors.primary),
        title: const Text(
          'FVU File Generation',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // Summary cards
          _SummaryRow(
            deducteeCount: deductees.length,
            totalTds: totalTds,
            challanCount: challans.length,
          ),
          // Stepper
          _StepIndicator(currentStep: currentStep),
          // Step content
          Expanded(child: _buildStepContent(currentStep)),
          // Navigation
          _NavigationBar(currentStep: currentStep),
        ],
      ),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return const _SetupStep();
      case 1:
        return const _DeducteesStep();
      case 2:
        return const _ChallansStep();
      case 3:
        return const _ValidationStep();
      case 4:
        return const _GenerateStep();
      default:
        return const SizedBox.shrink();
    }
  }
}

// ---------------------------------------------------------------------------
// Summary row
// ---------------------------------------------------------------------------

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.deducteeCount,
    required this.totalTds,
    required this.challanCount,
  });

  final int deducteeCount;
  final double totalTds;
  final int challanCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          SummaryCard(
            label: 'Deductees',
            value: '$deducteeCount',
            icon: Icons.people_alt_rounded,
            color: AppColors.primary,
          ),
          SummaryCard(
            label: 'Total TDS',
            value: CurrencyUtils.formatINRCompact(totalTds),
            icon: Icons.currency_rupee_rounded,
            color: AppColors.success,
          ),
          SummaryCard(
            label: 'Challans',
            value: '$challanCount',
            icon: Icons.receipt_long_rounded,
            color: AppColors.secondary,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step indicator
// ---------------------------------------------------------------------------

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(_stepLabels.length, (index) {
          final isActive = index == currentStep;
          final isCompleted = index < currentStep;
          final color = isActive
              ? AppColors.primary
              : isCompleted
              ? AppColors.success
              : AppColors.neutral300;

          return Expanded(
            child: Row(
              children: [
                if (index > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted
                          ? AppColors.success
                          : AppColors.neutral200,
                    ),
                  ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isActive || isCompleted
                            ? color
                            : AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: 2),
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isActive
                                      ? Colors.white
                                      : AppColors.neutral400,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _stepLabels[index],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.neutral400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 1: Setup
// ---------------------------------------------------------------------------

class _SetupStep extends ConsumerWidget {
  const _SetupStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deductors = ref.watch(tdsDeductorsProvider);
    final selectedDeductor = ref.watch(fvuSelectedDeductorProvider);
    final formType = ref.watch(fvuFormTypeProvider);
    final quarter = ref.watch(fvuQuarterProvider);
    final fy = ref.watch(selectedFinancialYearProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSection(
            title: 'Deductor & Period',
            icon: Icons.business_rounded,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedDeductor?.id,
                decoration: const InputDecoration(
                  labelText: 'Select Deductor',
                  prefixIcon: Icon(Icons.business_rounded),
                ),
                items: deductors
                    .map(
                      (d) => DropdownMenuItem(
                        value: d.id,
                        child: Text(
                          d.deductorName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    final deductor = deductors.firstWhere((d) => d.id == value);
                    ref
                        .read(fvuSelectedDeductorProvider.notifier)
                        .select(deductor);
                  }
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<TdsFormType>(
                      initialValue: formType,
                      decoration: const InputDecoration(
                        labelText: 'Form Type',
                        prefixIcon: Icon(Icons.description_rounded),
                      ),
                      items: TdsFormType.values
                          .map(
                            (f) => DropdownMenuItem(
                              value: f,
                              child: Text(f.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(fvuFormTypeProvider.notifier).select(value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<TdsQuarter>(
                      initialValue: quarter,
                      decoration: const InputDecoration(
                        labelText: 'Quarter',
                        prefixIcon: Icon(Icons.date_range_rounded),
                      ),
                      items: TdsQuarter.values
                          .map(
                            (q) => DropdownMenuItem(
                              value: q,
                              child: Text('${q.label} (${q.description})'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(fvuQuarterProvider.notifier).select(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Financial Year',
                  prefixIcon: Icon(Icons.calendar_today_rounded),
                ),
                child: Text('FY $fy'),
              ),
            ],
          ),
          if (selectedDeductor != null) ...[
            const SizedBox(height: 20),
            _DeductorInfoCard(deductor: selectedDeductor, theme: theme),
          ],
        ],
      ),
    );
  }
}

class _DeductorInfoCard extends StatelessWidget {
  const _DeductorInfoCard({required this.deductor, required this.theme});

  final TdsDeductor deductor;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              deductor.deductorName,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            _InfoRow(label: 'TAN', value: deductor.tan),
            _InfoRow(label: 'PAN', value: deductor.pan),
            _InfoRow(label: 'Type', value: deductor.deductorType.label),
            _InfoRow(label: 'Person', value: deductor.responsiblePerson),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.neutral400),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2: Deductees
// ---------------------------------------------------------------------------

class _DeducteesStep extends ConsumerWidget {
  const _DeducteesStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deductees = ref.watch(fvuDeducteeRecordsProvider);
    final validationIssues = ref.watch(fvuValidationResultProvider);

    if (deductees.isEmpty) {
      return const EmptyState(
        message: 'No deductee records',
        subtitle: 'Select a deductor in the setup step to load records.',
        icon: Icons.people_outline_rounded,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: deductees.length,
      itemBuilder: (context, index) {
        final record = deductees[index];
        final isValid = !validationIssues.any(
          (i) => i.fieldReference.contains('deductee[$index]'),
        );
        return FvuDeducteeTile(record: record, isValid: isValid);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Step 3: Challans
// ---------------------------------------------------------------------------

class _ChallansStep extends ConsumerWidget {
  const _ChallansStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challans = ref.watch(fvuChallanRecordsProvider);
    final validationIssues = ref.watch(fvuValidationResultProvider);

    if (challans.isEmpty) {
      return const EmptyState(
        message: 'No challan records',
        subtitle: 'Select a deductor in the setup step to load challans.',
        icon: Icons.receipt_long_rounded,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: challans.length,
      itemBuilder: (context, index) {
        final record = challans[index];
        final isValid = !validationIssues.any(
          (i) => i.fieldReference.contains('challan[$index]'),
        );
        return FvuChallanTile(record: record, isValid: isValid);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Step 4: Validation
// ---------------------------------------------------------------------------

class _ValidationStep extends ConsumerWidget {
  const _ValidationStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issues = ref.watch(fvuValidationResultProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: FvuValidationCard(issues: issues),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 5: Generate
// ---------------------------------------------------------------------------

class _GenerateStep extends ConsumerWidget {
  const _GenerateStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(fvuGenerationStatusProvider);
    final structure = ref.watch(fvuFileStructureProvider);
    final issues = ref.watch(fvuValidationResultProvider);
    final theme = Theme.of(context);

    final hasErrors = issues.any(
      (i) => i.severity == ScrutinyIssueSeverity.error,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.neutral200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildStatusIcon(status, hasErrors),
                  const SizedBox(height: 12),
                  Text(
                    _statusTitle(status, hasErrors),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _statusSubtitle(status, hasErrors),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Generate button
          FilledButton.icon(
            onPressed: hasErrors || structure == null
                ? null
                : () => _generate(ref, structure),
            icon: const Icon(Icons.file_download_rounded),
            label: const Text('Generate FVU File'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
          // CSI file button
          OutlinedButton.icon(
            onPressed: status == FvuGenerationStatus.success ? () {} : null,
            icon: const Icon(Icons.verified_rounded),
            label: const Text('Download CSI File'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          if (status == FvuGenerationStatus.success) ...[
            const SizedBox(height: 16),
            Text(
              'Files generated successfully. Upload the .fvu file to '
              'TRACES or TIN-NSDL for processing.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _generate(WidgetRef ref, FvuFileStructure structure) {
    ref.read(fvuGenerationStatusProvider.notifier).setGenerating();

    // Simulate generation (in production, this would write to file system).
    FvuGenerationService.generate(structure);

    ref.read(fvuGenerationStatusProvider.notifier).setSuccess();
  }

  Widget _buildStatusIcon(FvuGenerationStatus status, bool hasErrors) {
    if (hasErrors) {
      return const Icon(Icons.block_rounded, size: 48, color: AppColors.error);
    }
    switch (status) {
      case FvuGenerationStatus.idle:
        return const Icon(
          Icons.file_present_rounded,
          size: 48,
          color: AppColors.neutral300,
        );
      case FvuGenerationStatus.generating:
        return const SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(strokeWidth: 3),
        );
      case FvuGenerationStatus.success:
        return const Icon(
          Icons.check_circle_rounded,
          size: 48,
          color: AppColors.success,
        );
      case FvuGenerationStatus.error:
        return const Icon(
          Icons.error_rounded,
          size: 48,
          color: AppColors.error,
        );
    }
  }

  String _statusTitle(FvuGenerationStatus status, bool hasErrors) {
    if (hasErrors) return 'Cannot Generate';
    switch (status) {
      case FvuGenerationStatus.idle:
        return 'Ready to Generate';
      case FvuGenerationStatus.generating:
        return 'Generating...';
      case FvuGenerationStatus.success:
        return 'Generation Complete';
      case FvuGenerationStatus.error:
        return 'Generation Failed';
    }
  }

  String _statusSubtitle(FvuGenerationStatus status, bool hasErrors) {
    if (hasErrors) {
      return 'Fix pre-scrutiny errors before generating the FVU file.';
    }
    switch (status) {
      case FvuGenerationStatus.idle:
        return 'Click the button below to generate the FVU text file '
            'and CSI verification file.';
      case FvuGenerationStatus.generating:
        return 'Building fixed-width records and computing checksums...';
      case FvuGenerationStatus.success:
        return 'FVU and CSI files are ready for download.';
      case FvuGenerationStatus.error:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}

// ---------------------------------------------------------------------------
// Navigation bar
// ---------------------------------------------------------------------------

class _NavigationBar extends ConsumerWidget {
  const _NavigationBar({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.neutral200)),
      ),
      child: Row(
        children: [
          if (currentStep > 0)
            OutlinedButton.icon(
              onPressed: () {
                ref.read(fvuWizardStepProvider.notifier).previous();
              },
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Back'),
            ),
          const Spacer(),
          if (currentStep < 4)
            FilledButton.icon(
              onPressed: () {
                ref.read(fvuWizardStepProvider.notifier).next();
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text(_stepLabels[currentStep + 1]),
            ),
        ],
      ),
    );
  }
}
