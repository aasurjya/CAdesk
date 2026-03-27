import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/utils/currency_utils.dart';
import 'package:ca_app/features/filing/data/providers/filing_job_providers.dart';
import 'package:ca_app/features/filing/domain/models/filing_job.dart';

class FilingAnalyticsScreen extends ConsumerWidget {
  const FilingAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(filingJobsProvider);
    final filed = jobs
        .where(
          (j) =>
              j.status == FilingJobStatus.filed ||
              j.status == FilingJobStatus.verified,
        )
        .length;
    final pending = jobs
        .where(
          (j) =>
              j.status != FilingJobStatus.filed &&
              j.status != FilingJobStatus.verified &&
              j.status != FilingJobStatus.rejected,
        )
        .length;
    final totalFees = jobs.fold<double>(
      0,
      (sum, j) => sum + (j.feeQuoted ?? 0),
    );
    final receivedFees = jobs.fold<double>(
      0,
      (sum, j) => sum + (j.feeReceived ?? 0),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Filing Analytics', style: TextStyle(fontSize: 16)),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    'Total',
                    '${jobs.length}',
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard('Filed', '$filed', AppColors.success),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard('Pending', '$pending', AppColors.warning),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    'Revenue Quoted',
                    CurrencyUtils.formatINR(totalFees),
                    AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    'Received',
                    CurrencyUtils.formatINR(receivedFees),
                    AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Status Breakdown',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            ...FilingJobStatus.values.map((status) {
              final count = jobs.where((j) => j.status == status).length;
              if (count == 0) return const SizedBox.shrink();
              return _StatusRow(
                status: status,
                count: count,
                total: jobs.length,
              );
            }),
            const SizedBox(height: 24),
            const Text(
              'Upcoming Deadlines',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            const _DeadlineRow(
              'ITR-1/ITR-4 Due Date',
              'July 31, 2026',
              Icons.calendar_today,
            ),
            const _DeadlineRow(
              'ITR-2/ITR-3 Due Date',
              'July 31, 2026',
              Icons.calendar_today,
            ),
            const _DeadlineRow(
              'Audit Cases (44AB)',
              'October 31, 2026',
              Icons.calendar_today,
            ),
            const _DeadlineRow(
              'Belated/Revised Return',
              'December 31, 2026',
              Icons.warning_amber,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.label, this.value, this.color);

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.neutral400),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.status,
    required this.count,
    required this.total,
  });

  final FilingJobStatus status;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          ExcludeSemantics(
            child: Icon(status.icon, size: 16, color: status.color),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 96,
            child: Text(status.label, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: Semantics(
              label: '${status.label}: $count of $total',
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: AppColors.neutral200,
                valueColor: AlwaysStoppedAnimation<Color>(status.color),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _DeadlineRow extends StatelessWidget {
  const _DeadlineRow(this.label, this.date, this.icon);

  final String label;
  final String date;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: ExcludeSemantics(
          child: Icon(icon, size: 16, color: AppColors.warning),
        ),
        title: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        trailing: Text(
          date,
          style: const TextStyle(fontSize: 12, color: AppColors.neutral600),
        ),
        dense: true,
      ),
    );
  }
}
