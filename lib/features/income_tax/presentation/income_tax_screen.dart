import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/income_tax/data/providers/income_tax_providers.dart';
import 'package:ca_app/features/income_tax/domain/models/itr_client.dart';
import 'package:ca_app/features/income_tax/domain/models/itr_type.dart';
import 'package:ca_app/features/income_tax/presentation/widgets/filing_detail_sheet.dart';
import 'package:ca_app/features/income_tax/presentation/widgets/itr_client_tile.dart';
import 'package:ca_app/features/income_tax/presentation/widgets/itr_summary_card.dart';
import 'package:ca_app/features/income_tax/presentation/widgets/new_filing_sheet.dart';

/// Main screen for the Income Tax module.
class IncomeTaxScreen extends ConsumerStatefulWidget {
  const IncomeTaxScreen({super.key});

  @override
  ConsumerState<IncomeTaxScreen> createState() => _IncomeTaxScreenState();
}

class _IncomeTaxScreenState extends ConsumerState<IncomeTaxScreen> {
  bool _showSearch = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(itrSummaryProvider);
    final clients = ref.watch(filteredClientsProvider);
    final selectedType = ref.watch(itrTypeFilterProvider);
    final selectedAY = ref.watch(assessmentYearProvider);

    return Scaffold(
      appBar: AppBar(
        title: _showSearch ? _buildSearchField() : const Text('Income Tax'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary cards
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                ItrSummaryCard(
                  label: 'Total',
                  count: summary.total,
                  icon: Icons.people_alt_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                ItrSummaryCard(
                  label: 'Filed',
                  count: summary.filed,
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.success,
                  trend: summary.filed > 0 ? 2 : null,
                ),
                const SizedBox(width: 8),
                ItrSummaryCard(
                  label: 'Pending',
                  count: summary.pending,
                  icon: Icons.hourglass_empty_rounded,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 8),
                ItrSummaryCard(
                  label: 'Overdue',
                  count: summary.overdue,
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.error,
                ),
              ],
            ),
          ),

          // Assessment year dropdown + filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                _AssessmentYearDropdown(
                  value: selectedAY,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(assessmentYearProvider.notifier).update(value);
                    }
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'All',
                          selected: selectedType == null,
                          onSelected: (_) {
                            ref
                                .read(itrTypeFilterProvider.notifier)
                                .update(null);
                          },
                        ),
                        ..._visibleFilters.map((type) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: _FilterChip(
                              label: type.label,
                              selected: selectedType == type,
                              onSelected: (_) {
                                ref
                                    .read(itrTypeFilterProvider.notifier)
                                    .update(selectedType == type ? null : type);
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Client list
          Expanded(
            child: clients.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      return ItrClientTile(
                        client: clients[index],
                        onTap: () => _showFilingDetail(clients[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'income_tax_fab',
        onPressed: _onAddFiling,
        icon: const Icon(Icons.add),
        label: const Text('New Filing'),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static const _visibleFilters = [
    ItrType.itr1,
    ItrType.itr2,
    ItrType.itr3,
    ItrType.itr4,
  ];

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search by name or PAN...',
        border: InputBorder.none,
        filled: false,
      ),
      onChanged: (value) {
        ref.read(itrSearchQueryProvider.notifier).update(value);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: AppColors.neutral400,
          ),
          const SizedBox(height: 12),
          Text(
            'No filings found',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.neutral400),
          ),
          const SizedBox(height: 4),
          Text(
            'Try adjusting your filters or add a new filing.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.neutral400),
          ),
        ],
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchController.clear();
        ref.read(itrSearchQueryProvider.notifier).update('');
      }
    });
  }

  void _showFilingDetail(ItrClient client) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilingDetailSheet(client: client),
    );
  }

  void _onAddFiling() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NewFilingSheet(),
    );
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _AssessmentYearDropdown extends StatelessWidget {
  const _AssessmentYearDropdown({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String?> onChanged;

  static const _years = [
    'AY 2026-27',
    'AY 2025-26',
    'AY 2024-25',
    'AY 2023-24',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.neutral200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
          items: _years
              .map((y) => DropdownMenuItem(value: y, child: Text(y)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.secondary.withValues(alpha: 0.15),
      checkmarkColor: AppColors.secondary,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        color: selected ? AppColors.secondary : AppColors.neutral600,
      ),
      onSelected: onSelected,
      visualDensity: VisualDensity.compact,
    );
  }
}
