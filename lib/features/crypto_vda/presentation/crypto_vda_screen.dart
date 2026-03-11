import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/crypto_vda/domain/models/vda_transaction.dart';
import 'package:ca_app/features/crypto_vda/data/providers/crypto_vda_providers.dart';
import 'package:ca_app/features/crypto_vda/presentation/widgets/vda_transaction_tile.dart';
import 'package:ca_app/features/crypto_vda/presentation/widgets/vda_summary_card.dart';
import 'package:ca_app/features/crypto_vda/presentation/widgets/vda_schedule_sheet.dart';
import 'package:ca_app/features/crypto_vda/presentation/widgets/tds_194s_widget.dart';

/// Main Crypto / VDA Taxation screen (Module 26).
/// Tabs: Overview, Transactions, Client Summaries, TDS 194S.
class CryptoVdaScreen extends ConsumerWidget {
  const CryptoVdaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crypto / VDA Taxation'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Transactions'),
              Tab(text: 'Clients'),
              Tab(text: 'TDS 194S'),
            ],
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.neutral400,
          ),
        ),
        body: const TabBarView(
          children: [
            _OverviewTab(),
            _TransactionsTab(),
            _SummariesTab(),
            _Tds194sTab(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Overview tab — summary banner + aggregate metrics
// ---------------------------------------------------------------------------

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final VdaTaxOverview overview = ref.watch(vdaTaxOverviewProvider);
    final List<({String id, String name})> clients =
        ref.watch(vdaClientNamesProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        _OverviewBanner(overview: overview, clientCount: clients.length),
        const SizedBox(height: 16),
        _SectionTitle(title: 'Section 115BBH — Key Rules'),
        _RuleCard(
          icon: Icons.percent_rounded,
          color: AppColors.error,
          title: '30% Flat Tax + 4% Cess',
          body: 'All VDA gains are taxed at a flat 30% rate plus '
              '4% Health & Education Cess. No deductions, no '
              'basic exemption limit benefit.',
        ),
        _RuleCard(
          icon: Icons.block_rounded,
          color: AppColors.warning,
          title: 'Loss Disallowance',
          body: 'Losses from VDA transfers cannot be set off '
              'against any other income — salary, business, '
              'LTCG, STCG or other VDA gains.',
        ),
        _RuleCard(
          icon: Icons.account_balance_rounded,
          color: AppColors.secondary,
          title: 'TDS u/s 194S — 1% at Source',
          body: 'Exchanges deduct 1% TDS on each transaction '
              'above ₹50,000 p.a. (₹10,000 for specified '
              'persons). Credit appears in Form 26AS / AIS.',
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _OverviewBanner extends StatelessWidget {
  const _OverviewBanner({
    required this.overview,
    required this.clientCount,
  });

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

// ---------------------------------------------------------------------------
// Transactions tab
// ---------------------------------------------------------------------------

class _TransactionsTab extends ConsumerWidget {
  const _TransactionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<VdaTransaction> transactions =
        ref.watch(filteredVdaTransactionsProvider);

    return Column(
      children: [
        const _TransactionFilters(),
        Expanded(
          child: transactions.isEmpty
              ? const _EmptyState(
                  icon: Icons.currency_bitcoin_rounded,
                  message: 'No VDA transactions found',
                  hint: 'Adjust filters to see transactions.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: transactions.length,
                  itemBuilder: (BuildContext context, int index) {
                    return VdaTransactionTile(
                      transaction: transactions[index],
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _TransactionFilters extends ConsumerWidget {
  const _TransactionFilters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? selectedClient = ref.watch(selectedVdaClientProvider);
    final List<({String id, String name})> clientNames =
        ref.watch(vdaClientNamesProvider);
    final VdaAssetType? selectedAsset = ref.watch(selectedAssetTypeProvider);
    final VdaTransactionType? selectedTxn =
        ref.watch(selectedTransactionTypeProvider);
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Client dropdown
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.neutral200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: selectedClient,
                      isDense: true,
                      isExpanded: true,
                      style: theme.textTheme.bodyMedium,
                      hint: const Text('All Clients'),
                      icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Clients'),
                        ),
                        ...clientNames.map(
                          (({String id, String name}) c) =>
                              DropdownMenuItem<String?>(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        ),
                      ],
                      onChanged: (String? value) {
                        ref
                            .read(selectedVdaClientProvider.notifier)
                            .update(value);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Asset type + transaction type chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All Assets',
                  isSelected: selectedAsset == null,
                  onTap: () =>
                      ref.read(selectedAssetTypeProvider.notifier).update(null),
                ),
                ...VdaAssetType.values.map(
                  (VdaAssetType a) => _FilterChip(
                    label: a.label,
                    isSelected: selectedAsset == a,
                    onTap: () =>
                        ref.read(selectedAssetTypeProvider.notifier).update(a),
                  ),
                ),
                const SizedBox(width: 12),
                Container(width: 1, height: 24, color: AppColors.neutral200),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'All Types',
                  isSelected: selectedTxn == null,
                  onTap: () => ref
                      .read(selectedTransactionTypeProvider.notifier)
                      .update(null),
                ),
                ...VdaTransactionType.values.map(
                  (VdaTransactionType t) => _FilterChip(
                    label: t.label,
                    isSelected: selectedTxn == t,
                    onTap: () => ref
                        .read(selectedTransactionTypeProvider.notifier)
                        .update(t),
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
// Summaries tab — tap card to open Schedule VDA sheet
// ---------------------------------------------------------------------------

class _SummariesTab extends ConsumerWidget {
  const _SummariesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(vdaSummariesProvider);

    return Column(
      children: [
        const VdaTaxOverviewCard(),
        Expanded(
          child: summaries.isEmpty
              ? const _EmptyState(
                  icon: Icons.summarize_rounded,
                  message: 'No client summaries',
                  hint: 'VDA summaries will appear here.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: summaries.length,
                  itemBuilder: (BuildContext context, int index) {
                    final summary = summaries[index];
                    return GestureDetector(
                      onTap: () => showVdaScheduleSheet(
                        context,
                        clientId: summary.clientId,
                        clientName: summary.clientName,
                        assessmentYear: summary.assessmentYear,
                      ),
                      child: VdaSummaryCard(summary: summary),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// TDS 194S tab
// ---------------------------------------------------------------------------

class _Tds194sTab extends StatelessWidget {
  const _Tds194sTab();

  @override
  Widget build(BuildContext context) {
    return const Tds194sWidget();
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.accent.withValues(alpha: 0.18),
        checkmarkColor: AppColors.accent,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.accent : AppColors.neutral600,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 12,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
    required this.hint,
  });

  final IconData icon;
  final String message;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: AppColors.neutral200),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}
