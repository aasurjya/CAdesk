import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/llp/data/providers/llp_providers.dart';
import 'package:ca_app/features/llp/presentation/widgets/llp_card.dart';

/// LLP list screen with filing status, penalty calculator, strike-off risk.
class LlpScreen extends ConsumerWidget {
  const LlpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final llps = ref.watch(llpListProvider);
    final overdueCount = ref.watch(llpOverdueCountProvider);
    final theme = Theme.of(context);

    final strikeOffRisk = llps.where((l) {
      return l.form8Status == LlpFilingStatus.overdue &&
          l.form11Status == LlpFilingStatus.overdue;
    }).length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LLP Compliance',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Form 8, Form 11, ITR-5 filings',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.neutral50, Color(0xFFF9FBFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SummaryBanner(
              totalLlps: llps.length,
              overdueFilings: overdueCount,
              strikeOffRisk: strikeOffRisk,
            ),
            const SizedBox(height: 16),
            _SectionHeader(title: 'LLP Entities', icon: Icons.business_rounded),
            const SizedBox(height: 10),
            ...llps.map(
              (llp) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: LlpCard(
                  llp: llp,
                  onTap: () {
                    ref.read(selectedLlpIdProvider.notifier).select(llp.id);
                    context.push('/llp/detail');
                  },
                ),
              ),
            ),
            if (strikeOffRisk > 0) ...[
              const SizedBox(height: 16),
              _StrikeOffWarning(count: strikeOffRisk),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary banner
// ---------------------------------------------------------------------------

class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner({
    required this.totalLlps,
    required this.overdueFilings,
    required this.strikeOffRisk,
  });

  final int totalLlps;
  final int overdueFilings;
  final int strikeOffRisk;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FBFF), Color(0xFFF5FAF9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.neutral100),
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          _StatItem(label: 'Total LLPs', value: '$totalLlps'),
          _StatItem(
            label: 'Overdue',
            value: '$overdueFilings',
            color: overdueFilings > 0 ? AppColors.error : null,
          ),
          _StatItem(
            label: 'Strike-off Risk',
            value: '$strikeOffRisk',
            color: strikeOffRisk > 0 ? AppColors.error : null,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color ?? AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Strike-off warning
// ---------------------------------------------------------------------------

class _StrikeOffWarning extends StatelessWidget {
  const _StrikeOffWarning({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withAlpha(40)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Strike-Off Risk',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count LLP(s) have both Form 8 and Form 11 overdue. '
                  'MCA may initiate strike-off proceedings.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }
}
