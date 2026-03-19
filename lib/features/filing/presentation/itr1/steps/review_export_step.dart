import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/core/utils/file_saver.dart' as file_saver;
import 'package:ca_app/features/filing/data/providers/filing_job_providers.dart';
import 'package:ca_app/features/filing/domain/models/filing_job.dart';
import 'package:ca_app/features/filing/domain/models/itr1/itr1_form_data.dart';
import 'package:ca_app/features/portal_autosubmit/data/providers/submission_repository_providers.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_job.dart';
import 'package:ca_app/features/portal_autosubmit/domain/models/submission_step.dart';
import 'package:ca_app/features/portal_connector/domain/models/portal_credential.dart';
import 'package:ca_app/features/portal_export/itr_export/services/itr1_export_service.dart';
import 'package:ca_app/features/portal_export/itr_export/services/itr_schema_validator.dart';

class ReviewExportStep extends ConsumerWidget {
  const ReviewExportStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formData = ref.watch(itr1FormDataProvider);
    final taxResult = ref.watch(liveTaxComputationProvider);
    final job = ref.watch(activeFilingJobProvider);

    final selectedTax = formData.selectedRegime == TaxRegime.newRegime
        ? taxResult.newRegimeTax
        : taxResult.oldRegimeTax;

    final tds = formData.tdsPaymentSummary;
    final balancePayable = selectedTax - tds.totalTaxesPaid;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummarySection(
            title: 'Personal Information',
            icon: Icons.person_outline,
            rows: [
              ('Name', formData.personalInfo.fullName),
              ('PAN', formData.personalInfo.pan),
              (
                'DOB',
                '${formData.personalInfo.dateOfBirth.day.toString().padLeft(2, '0')}/'
                    '${formData.personalInfo.dateOfBirth.month.toString().padLeft(2, '0')}/'
                    '${formData.personalInfo.dateOfBirth.year}',
              ),
              ('Mobile', formData.personalInfo.mobile),
              ('Email', formData.personalInfo.email),
            ],
          ),
          _SummarySection(
            title: 'Income Summary',
            icon: Icons.account_balance_wallet_outlined,
            rows: [
              (
                'Net Salary',
                CurrencyUtils.formatINR(formData.salaryIncome.netSalary),
              ),
              (
                'House Property',
                CurrencyUtils.formatINR(
                  formData.housePropertyIncome.incomeFromHouseProperty,
                ),
              ),
              (
                'Other Sources',
                CurrencyUtils.formatINR(formData.otherSourceIncome.total),
              ),
              (
                'Gross Total Income',
                CurrencyUtils.formatINR(formData.grossTotalIncome),
              ),
            ],
          ),
          _SummarySection(
            title: 'Deductions (Chapter VI-A)',
            icon: Icons.remove_circle_outline,
            rows: [
              ('80C', CurrencyUtils.formatINR(formData.deductions.section80C)),
              (
                '80CCD(1B)',
                CurrencyUtils.formatINR(formData.deductions.section80CCD1B),
              ),
              (
                '80D Self',
                CurrencyUtils.formatINR(formData.deductions.section80DSelf),
              ),
              (
                '80D Parents',
                CurrencyUtils.formatINR(formData.deductions.section80DParents),
              ),
              ('80E', CurrencyUtils.formatINR(formData.deductions.section80E)),
              (
                'Total Deductions',
                CurrencyUtils.formatINR(formData.deductions.totalDeductions),
              ),
            ],
          ),
          _SummarySection(
            title: 'Tax Computation',
            icon: Icons.calculate_outlined,
            rows: [
              ('Selected Regime', formData.selectedRegime.label),
              (
                'Taxable Income',
                CurrencyUtils.formatINR(
                  formData.selectedRegime == TaxRegime.newRegime
                      ? taxResult.newRegimeTaxableIncome
                      : taxResult.oldRegimeTaxableIncome,
                ),
              ),
              ('Total Tax Payable', CurrencyUtils.formatINR(selectedTax)),
              (
                'Recommended Regime',
                '${taxResult.recommendedRegime.label} '
                    '(saves ${CurrencyUtils.formatINR(taxResult.savings)})',
              ),
            ],
          ),
          _SummarySection(
            title: 'TDS & Taxes Paid',
            icon: Icons.receipt_long_outlined,
            rows: [
              ('TDS on Salary', CurrencyUtils.formatINR(tds.tdsOnSalary)),
              (
                'TDS on Other Income',
                CurrencyUtils.formatINR(tds.tdsOnOtherIncome),
              ),
              ('Advance Tax', CurrencyUtils.formatINR(tds.totalAdvanceTax)),
              (
                'Self-Assessment Tax',
                CurrencyUtils.formatINR(tds.selfAssessmentTax),
              ),
              ('Total Taxes Paid', CurrencyUtils.formatINR(tds.totalTaxesPaid)),
              (
                balancePayable >= 0 ? 'Balance Tax Payable' : 'Refund Due',
                CurrencyUtils.formatINR(balancePayable.abs()),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (job != null) ...[
            _StatusTransitionButtons(job: job, ref: ref),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _handleExport(context, formData),
              icon: const Icon(Icons.download_outlined),
              label: const Text('Export & Save JSON'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _handleFileOnPortal(context, ref),
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text('File on IT Portal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExport(
    BuildContext context,
    Itr1FormData formData,
  ) async {
    try {
      // Derive AY from PAN-based naming (use "2026-27" format for ITD)
      const assessmentYear = '2026-27';
      final result = Itr1ExportService.export(formData, assessmentYear);

      // Validate before saving
      final errors = ItrSchemaValidator.validate(result);
      if (errors.isNotEmpty) {
        if (!context.mounted) return;
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Validation Errors'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final error in errors)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              error,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      final pan = formData.personalInfo.pan.isNotEmpty
          ? formData.personalInfo.pan
          : 'UNKNOWN';
      final fileName = 'ITR1_${pan}_AY$assessmentYear.json';

      // Pretty-print the JSON for readability
      final prettyJson = const JsonEncoder.withIndent(
        '  ',
      ).convert(jsonDecode(result.jsonPayload));

      await file_saver.saveFile(prettyJson, fileName);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            kIsWeb ? 'JSON downloaded: $fileName' : 'JSON saved: $fileName',
          ),
          backgroundColor: AppColors.success,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _handleFileOnPortal(BuildContext context, WidgetRef ref) {
    final formData = ref.read(itr1FormDataProvider);
    final job = ref.read(activeFilingJobProvider);

    // Create a submission job from the current ITR-1 form data.
    final submissionJob = SubmissionJob(
      id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
      clientId: job?.clientId ?? 'unknown',
      clientName: job?.clientName ?? formData.personalInfo.fullName,
      portalType: PortalType.itd,
      returnType: 'ITR-1',
      currentStep: SubmissionStep.pending,
      retryCount: 0,
      createdAt: DateTime.now(),
    );

    // Enqueue the job so the automation queue picks it up.
    final orchestrator = ref.read(submissionOrchestratorProvider);
    orchestrator.enqueue(submissionJob);

    // Navigate to the queue screen where the job is now visible.
    context.push('/portal-autosubmit');
  }
}

// ---------------------------------------------------------------------------
// Status transition buttons
// ---------------------------------------------------------------------------

class _StatusTransitionButtons extends StatelessWidget {
  const _StatusTransitionButtons({required this.job, required this.ref});

  final FilingJob job;
  final WidgetRef ref;

  void _updateStatus(FilingJobStatus newStatus) {
    final updated = job.copyWith(status: newStatus, updatedAt: DateTime.now());
    ref.read(filingJobsProvider.notifier).update(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (job.status == FilingJobStatus.draft)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _updateStatus(FilingJobStatus.review),
              icon: const Icon(Icons.rate_review_outlined, size: 16),
              label: const Text('Mark as Review'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryVariant,
              ),
            ),
          ),
        if (job.status == FilingJobStatus.review) ...[
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _updateStatus(FilingJobStatus.ready),
              icon: const Icon(Icons.task_alt_outlined, size: 16),
              label: const Text('Mark as Ready'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.warning),
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Summary section widget
// ---------------------------------------------------------------------------

class _SummarySection extends StatelessWidget {
  const _SummarySection({
    required this.title,
    required this.icon,
    required this.rows,
  });

  final String title;
  final IconData icon;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const Divider(height: 12),
            for (final (label, value) in rows) _row(label, value),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.neutral600),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
