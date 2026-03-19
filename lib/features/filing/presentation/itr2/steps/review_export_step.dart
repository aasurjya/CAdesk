import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/filing/data/providers/filing_job_providers.dart';
import 'package:ca_app/features/filing/data/providers/itr2_form_providers.dart';
import 'package:ca_app/features/filing/domain/models/filing_job.dart';

/// ITR-2 review and export step — shows all sections in summary cards.
class Itr2ReviewExportStep extends ConsumerWidget {
  const Itr2ReviewExportStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formData = ref.watch(itr2FormDataProvider);
    final job = ref.watch(activeFilingJobProvider);
    final cg = formData.scheduleCg;
    final fa = formData.foreignAssetSchedule;
    final al = formData.scheduleAl;

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
            title: 'Ordinary Income',
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
                'Ordinary Income',
                CurrencyUtils.formatINR(formData.ordinaryIncome),
              ),
            ],
          ),
          _SummarySection(
            title: 'Capital Gains (Schedule CG)',
            icon: Icons.trending_up,
            rows: [
              ('STCG (Sec 111A)', CurrencyUtils.formatINR(cg.totalStcg111A)),
              ('STCG (Other)', CurrencyUtils.formatINR(cg.totalStcgOther)),
              ('LTCG (Sec 112A)', CurrencyUtils.formatINR(cg.totalLtcg112A)),
              (
                'LTCG (Property)',
                CurrencyUtils.formatINR(cg.totalLtcgOnProperty),
              ),
              ('LTCG (Other)', CurrencyUtils.formatINR(cg.totalLtcgOther)),
              (
                'Net STCG (after set-off)',
                CurrencyUtils.formatINR(cg.netStcgAfterSetOff),
              ),
              (
                'Net LTCG (after set-off)',
                CurrencyUtils.formatINR(cg.netLtcgAfterSetOff),
              ),
            ],
          ),
          if (fa.assets.isNotEmpty)
            _SummarySection(
              title: 'Foreign Assets (Schedule FA)',
              icon: Icons.public,
              rows: [
                ('Number of Assets', '${fa.assets.length}'),
                (
                  'Total Value (INR)',
                  CurrencyUtils.formatINR(fa.totalValueInINR),
                ),
                (
                  'Income Offered',
                  CurrencyUtils.formatINR(fa.totalIncomeOffered),
                ),
              ],
            ),
          if (al != null)
            _SummarySection(
              title: 'Assets & Liabilities (Schedule AL)',
              icon: Icons.account_balance_outlined,
              rows: [
                ('Total Assets', CurrencyUtils.formatINR(al.totalAssets)),
                (
                  'Total Liabilities',
                  CurrencyUtils.formatINR(al.totalLiabilities),
                ),
                ('Net Worth', CurrencyUtils.formatINR(al.netWorth)),
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
                'Allowable Deductions',
                CurrencyUtils.formatINR(formData.allowableDeductions),
              ),
            ],
          ),
          _SummarySection(
            title: 'Tax Computation',
            icon: Icons.calculate_outlined,
            rows: [
              ('Selected Regime', formData.selectedRegime.label),
              (
                'Taxable Ordinary Income',
                CurrencyUtils.formatINR(formData.taxableOrdinaryIncome),
              ),
              (
                'Capital Gains',
                CurrencyUtils.formatINR(formData.capitalGainsTotal),
              ),
              (
                'Total Taxable Income',
                CurrencyUtils.formatINR(formData.taxableIncome),
              ),
              (
                'Gross Total Income',
                CurrencyUtils.formatINR(formData.grossTotalIncome),
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
              onPressed: () => _handleExportPlaceholder(context),
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
            child: OutlinedButton.icon(
              onPressed: () => _handleFileOnPortal(context),
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text('File on Portal'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleExportPlaceholder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ITR-2 export service is under development.'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  void _handleFileOnPortal(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Portal filing requires exporting JSON first. '
          'Export JSON, then use the portal automation from the Filing Dashboard.',
        ),
        backgroundColor: AppColors.warning,
        duration: Duration(seconds: 4),
      ),
    );
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
              value.isEmpty ? '\u2014' : value,
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
