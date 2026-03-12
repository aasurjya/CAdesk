import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/filing/data/providers/filing_job_providers.dart';
import 'package:ca_app/features/filing/domain/models/filing_job.dart';
import 'package:ca_app/features/income_tax/domain/models/itr_type.dart';

/// Lists ITR form types and allows the CA to start a new filing.
/// ITR-1 and ITR-4 are enabled; the rest are shown as coming soon.
class FilingTypePickerScreen extends ConsumerWidget {
  const FilingTypePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Start New Filing'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: ItrType.values.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final type = ItrType.values[index];
          final isEnabled = type == ItrType.itr1 || type == ItrType.itr4;
          return _ItrTypeTile(
            itrType: type,
            isEnabled: isEnabled,
            onTap: isEnabled ? () => _startFiling(context, ref, type) : null,
          );
        },
      ),
    );
  }

  void _startFiling(BuildContext context, WidgetRef ref, ItrType type) {
    final newJobId = 'job-${DateTime.now().millisecondsSinceEpoch}';
    final newJob = FilingJob(
      id: newJobId,
      clientId: '',
      clientName: 'New Client',
      pan: '',
      assessmentYear: 'AY 2026-27',
      itrType: type,
      status: FilingJobStatus.draft,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    ref.read(filingJobsProvider.notifier).add(newJob);
    final route = switch (type) {
      ItrType.itr1 => '/filing/itr1/$newJobId',
      ItrType.itr4 => '/filing/itr4/$newJobId',
      _ => '/filing/itr1/$newJobId',
    };
    context.push(route);
  }
}

// ---------------------------------------------------------------------------
// Individual ITR type tile
// ---------------------------------------------------------------------------

class _ItrTypeTile extends StatelessWidget {
  const _ItrTypeTile({
    required this.itrType,
    required this.isEnabled,
    this.onTap,
  });

  final ItrType itrType;
  final bool isEnabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            border: Border.all(
              color: isEnabled ? AppColors.primary : AppColors.neutral300,
              width: isEnabled ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isEnabled ? AppColors.surface : AppColors.neutral100,
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isEnabled ? AppColors.primary : AppColors.neutral300,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  itrType.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itrType.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: isEnabled
                            ? AppColors.neutral900
                            : AppColors.neutral400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      itrType.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isEnabled
                            ? AppColors.neutral600
                            : AppColors.neutral400,
                      ),
                    ),
                  ],
                ),
              ),
              if (isEnabled)
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.primary,
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.neutral300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Coming Soon',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.neutral600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
