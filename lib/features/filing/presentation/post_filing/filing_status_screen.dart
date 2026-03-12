import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/filing/data/providers/filing_job_providers.dart';
import 'package:ca_app/features/filing/presentation/post_filing/widgets/filing_timeline_widget.dart';
import 'package:ca_app/features/filing/presentation/post_filing/widgets/intimation_card.dart';

class FilingStatusScreen extends ConsumerWidget {
  const FilingStatusScreen({required this.jobId, super.key});

  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(filingJobsProvider);
    final job = jobs.where((j) => j.id == jobId).firstOrNull;

    if (job == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Filing Status')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search_off,
                size: 48,
                color: AppColors.neutral300,
              ),
              const SizedBox(height: 16),
              const Text('Filing job not found'),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Status — ${job.clientName}',
          style: const TextStyle(fontSize: 16),
        ),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow('Client', job.clientName),
                    _infoRow('PAN', job.pan),
                    _infoRow('Assessment Year', job.assessmentYear),
                    _infoRow('ITR Type', job.itrType.label),
                    _infoRow('Current Status', job.status.label),
                    if (job.acknowledgementNumber != null)
                      _infoRow('Ack. No.', job.acknowledgementNumber!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Filing Timeline',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            FilingTimelineWidget(job: job),
            const SizedBox(height: 16),
            const Text(
              'Intimation u/s 143(1)',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            const IntimationCard(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/filing/e-verify/${job.id}'),
                icon: const Icon(Icons.verified_user_outlined, size: 16),
                label: const Text('E-Verify Return'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 128,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.neutral600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
