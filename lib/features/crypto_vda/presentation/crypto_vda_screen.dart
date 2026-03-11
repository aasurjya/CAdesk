import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/crypto_vda/domain/models/vda_transaction.dart';
import 'package:ca_app/features/crypto_vda/data/providers/crypto_vda_providers.dart';
import 'package:ca_app/features/crypto_vda/presentation/widgets/vda_transaction_tile.dart';
import 'package:ca_app/features/crypto_vda/presentation/widgets/vda_summary_card.dart';

/// Main Crypto / VDA Taxation screen (Module 26).
/// Tabs: Transactions, Client Summaries.
class CryptoVdaScreen extends ConsumerWidget {
  const CryptoVdaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crypto / VDA Taxation'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Transactions'),
              Tab(text: 'Client Summaries'),
            ],
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.neutral400,
          ),
        ),
        body: const TabBarView(
          children: [
            _TransactionsTab(),
            _SummariesTab(),
          ],
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
    final transactions = ref.watch(filteredVdaTransactionsProvider);

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
                  itemBuilder: (context, index) {
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
    final selectedClient = ref.watch(selectedVdaClientProvider);
    final clientNames = ref.watch(vdaClientNamesProvider);
    final selectedAsset = ref.watch(selectedAssetTypeProvider);
    final selectedTxn = ref.watch(selectedTransactionTypeProvider);
    final theme = Theme.of(context);

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
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Clients'),
                        ),
                        ...clientNames.map(
                          (c) => DropdownMenuItem<String?>(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        ),
                      ],
                      onChanged: (value) {
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
                  onTap: () => ref
                      .read(selectedAssetTypeProvider.notifier)
                      .update(null),
                ),
                ...VdaAssetType.values.map(
                  (a) => _FilterChip(
                    label: a.label,
                    isSelected: selectedAsset == a,
                    onTap: () => ref
                        .read(selectedAssetTypeProvider.notifier)
                        .update(a),
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
                  (t) => _FilterChip(
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
// Summaries tab
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
                  itemBuilder: (context, index) {
                    return VdaSummaryCard(summary: summaries[index]);
                  },
                ),
        ),
      ],
    );
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
    final theme = Theme.of(context);

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
