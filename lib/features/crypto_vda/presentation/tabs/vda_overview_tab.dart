import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/crypto_vda/data/providers/crypto_vda_providers.dart';

/// Overview tab: AY banner + Section 115BBH rule cards.
class VdaOverviewTab extends ConsumerWidget {
  const VdaOverviewTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final VdaTaxOverview overview = ref.watch(vdaTaxOverviewProvider);
    final List<({String id, String name})> clients = ref.watch(
      vdaClientNamesProvider,
    );

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        _OverviewBanner(overview: overview, clientCount: clients.length),
        const SizedBox(height: 16),
        const _SectionTitle(title: 'Section 115BBH — Key Rules'),
        const _RuleCard(
          icon: Icons.percent_rounded,
          color: AppColors.error,
          title: '30% Flat Tax + 4% Cess',
          body:
              'All VDA gains are taxed at a flat 30% rate plus '
              '4% Health & Education Cess. No deductions, no '
              'basic exemption limit benefit.',
        ),
        const _RuleCard(
          icon: Icons.block_rounded,
          color: AppColors.warning,
          title: 'Loss Disallowance',
          body:
              'Losses from VDA transfers cannot be set off '
              'against any other income — salary, business, '
              'LTCG, STCG or other VDA gains.',
        ),
        const _RuleCard(
          icon: Icons.account_balance_rounded,
          color: AppColors.secondary,
          title: 'TDS u/s 194S — 1% at Source',
          body:
              'Exchanges deduct 1% TDS on each transaction '
              'above ₹50,000 p.a. (₹10,000 for specified '
              'persons). Credit appears in Form 26AS / AIS.',
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Banner
// ---------------------------------------------------------------------------

class _OverviewBanner extends StatelessWidget {
  const _OverviewBanner({required this.overview, required this.clientCount});

  final VdaTaxOverview overview;
  final int clientCount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        color: AppColors.primary.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.currency_bitcoin_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AY 2026-27 — VDA Portfolio',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _BannerStat(
                    label: 'Clients',
                    value: clientCount.toString(),
                    color: AppColors.primary,
                  ),
                  _BannerStat(
                    label: 'Total Gains',
                    value: _compact(overview.totalGains),
                    color: AppColors.success,
                  ),
                  _BannerStat(
                    label: 'Total Tax',
                    value: _compact(overview.totalTaxLiability),
                    color: AppColors.error,
                  ),
                  _BannerStat(
                    label: 'TDS Credit',
                    value: _compact(overview.totalTdsCollected),
                    color: AppColors.secondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _compact(double value) {
    if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(2)}L';
    }
    if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(1)}K';
    }
    return '₹${value.toStringAsFixed(0)}';
  }
}

class _BannerStat extends StatelessWidget {
  const _BannerStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.neutral400,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared section title + rule card
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.neutral600,
        ),
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.neutral200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
