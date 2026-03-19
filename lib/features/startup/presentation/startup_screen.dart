import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/startup/data/providers/startup_providers.dart';
import 'package:ca_app/features/startup/domain/services/angel_tax_service.dart';
import 'package:ca_app/features/startup/domain/services/section80iac_service.dart';
import 'package:ca_app/features/startup/presentation/widgets/startup_card.dart';

/// Startup dashboard: startup list, DPIIT status, 80-IAC calculator, angel tax.
class StartupScreen extends ConsumerWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startups = ref.watch(startupListProvider);
    final theme = Theme.of(context);

    final dpiitRegistered = startups
        .where((s) => s.dpiitStatus == DpiitStatus.registered)
        .length;
    final iac80Approved = startups
        .where((s) => s.iac80Status == Iac80Status.approved)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Startup (80-IAC)',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'DPIIT registration & tax exemptions',
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
              startupCount: startups.length,
              dpiitRegistered: dpiitRegistered,
              iac80Approved: iac80Approved,
            ),
            const SizedBox(height: 16),
            const _SectionHeader(
              title: 'Startups',
              icon: Icons.rocket_launch_rounded,
            ),
            const SizedBox(height: 10),
            ...startups.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: StartupCard(
                  startup: s,
                  onTap: () {
                    ref.read(selectedStartupIdProvider.notifier).select(s.id);
                    context.push('/startup/detail');
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _SectionHeader(
              title: '80-IAC Eligibility Summary',
              icon: Icons.verified_rounded,
            ),
            const SizedBox(height: 10),
            _EligibilitySummaryCard(startups: startups),
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
    required this.startupCount,
    required this.dpiitRegistered,
    required this.iac80Approved,
  });

  final int startupCount;
  final int dpiitRegistered;
  final int iac80Approved;

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
          _StatItem(label: 'Startups', value: '$startupCount'),
          _StatItem(label: 'DPIIT Reg.', value: '$dpiitRegistered'),
          _StatItem(label: '80-IAC OK', value: '$iac80Approved'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

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
              color: AppColors.primary,
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
// Eligibility summary card
// ---------------------------------------------------------------------------

class _EligibilitySummaryCard extends StatelessWidget {
  const _EligibilitySummaryCard({required this.startups});

  final List<StartupEntity> startups;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: startups.map((s) {
            final data = StartupData(
              name: s.name,
              pan: s.pan,
              dpiitNumber: s.dpiitNumber,
              incorporationDate: s.incorporationDate,
              entityType: s.entityType,
              netProfitPaise: s.netProfitPaise,
              financialYears80IACApplied: s.financialYears80IACApplied,
            );
            final deduction = Section80IACService.instance.computeDeduction(
              data,
              2026,
            );
            final isExempt = AngelTaxService.instance.isDpiitExempt(
              s.dpiitNumber,
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      s.name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      deduction > 0
                          ? '80-IAC: ${_formatPaise(deduction)}'
                          : '80-IAC: N/A',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: deduction > 0
                            ? AppColors.success
                            : AppColors.neutral400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    isExempt ? 'Angel Tax Exempt' : 'Angel Tax Applicable',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isExempt ? AppColors.success : AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
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

String _formatPaise(int paise) {
  final rupees = paise ~/ 100;
  if (rupees >= 100000) {
    return '\u20B9${(rupees / 100000).toStringAsFixed(2)} L';
  }
  if (rupees >= 1000) {
    return '\u20B9${(rupees / 1000).toStringAsFixed(1)}K';
  }
  return '\u20B9$rupees';
}
