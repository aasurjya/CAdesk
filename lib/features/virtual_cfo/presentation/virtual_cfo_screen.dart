import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/virtual_cfo/data/providers/virtual_cfo_providers.dart';
import 'package:ca_app/features/virtual_cfo/presentation/widgets/mis_report_card.dart';
import 'package:ca_app/features/virtual_cfo/presentation/widgets/scenario_tile.dart';

/// Main screen for the Virtual CFO Platform module.
///
/// Displays KPI summary, MIS reports (with status filter), and financial
/// scenarios (with category filter) across a two-tab layout.
class VirtualCfoScreen extends ConsumerStatefulWidget {
  const VirtualCfoScreen({super.key});

  @override
  ConsumerState<VirtualCfoScreen> createState() => _VirtualCfoScreenState();
}

class _VirtualCfoScreenState extends ConsumerState<VirtualCfoScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kpi = ref.watch(virtualCfoKpiProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('Virtual CFO Platform'),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.neutral400,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'MIS Reports'),
            Tab(text: 'Scenarios'),
          ],
        ),
      ),
      body: Column(
        children: [
          // KPI summary row
          _KpiSummaryRow(kpi: kpi),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _MisReportsTab(),
                _ScenariosTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// KPI summary
// ---------------------------------------------------------------------------

class _KpiSummaryRow extends StatelessWidget {
  const _KpiSummaryRow({required this.kpi});

  final Map<String, String> kpi;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          _KpiCard(
            icon: Icons.people_outline_rounded,
            label: 'Clients',
            value: kpi['clients'] ?? '—',
          ),
          const SizedBox(width: 8),
          _KpiCard(
            icon: Icons.currency_rupee_rounded,
            label: 'Total AUM',
            value: kpi['aum'] ?? '—',
          ),
          const SizedBox(width: 8),
          _KpiCard(
            icon: Icons.trending_up_rounded,
            label: 'Avg EBITDA',
            value: kpi['avgEbitda'] ?? '—',
          ),
          const SizedBox(width: 8),
          _KpiCard(
            icon: Icons.description_outlined,
            label: 'Reports',
            value: kpi['reportsThisMonth'] ?? '—',
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.neutral50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.neutral400,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// MIS Reports tab
// ---------------------------------------------------------------------------

class _MisReportsTab extends ConsumerWidget {
  const _MisReportsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedStatus = ref.watch(selectedMisStatusProvider);
    final reports = ref.watch(filteredMisReportsProvider);

    const statuses = ['All', 'Draft', 'Review', 'Approved', 'Delivered'];

    return CustomScrollView(
      slivers: [
        // Status filter chips
        SliverToBoxAdapter(
          child: _FilterChipRow(
            options: statuses,
            selected: selectedStatus ?? 'All',
            onSelected: (value) {
              ref.read(selectedMisStatusProvider.notifier).update(
                    value == 'All' ? null : value,
                  );
            },
          ),
        ),

        // Report cards
        if (reports.isEmpty)
          const SliverFillRemaining(
            child: _EmptyState(message: 'No reports match this filter'),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return MisReportCard(report: reports[index]);
              },
              childCount: reports.length,
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Scenarios tab
// ---------------------------------------------------------------------------

class _ScenariosTab extends ConsumerWidget {
  const _ScenariosTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedScenarioCategoryProvider);
    final scenarios = ref.watch(filteredCfoScenariosProvider);

    const categories = [
      'All',
      'Revenue',
      'Cost',
      'Funding',
      'Tax',
      'Working Capital',
    ];

    return CustomScrollView(
      slivers: [
        // Category filter chips
        SliverToBoxAdapter(
          child: _FilterChipRow(
            options: categories,
            selected: selectedCategory ?? 'All',
            onSelected: (value) {
              ref.read(selectedScenarioCategoryProvider.notifier).update(
                    value == 'All' ? null : value,
                  );
            },
          ),
        ),

        // Scenario tiles
        if (scenarios.isEmpty)
          const SliverFillRemaining(
            child: _EmptyState(message: 'No scenarios match this filter'),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return ScenarioTile(scenario: scenarios[index]);
              },
              childCount: scenarios.length,
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared filter chip row
// ---------------------------------------------------------------------------

class _FilterChipRow extends StatelessWidget {
  const _FilterChipRow({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: options.length,
        separatorBuilder: (context, idx) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = option == selected;
          return GestureDetector(
            onTap: () => onSelected(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isSelected ? AppColors.primary : AppColors.neutral300,
                ),
              ),
              child: Text(
                option,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? AppColors.surface
                          : AppColors.neutral600,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 48,
            color: AppColors.neutral300,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.neutral400,
                ),
          ),
        ],
      ),
    );
  }
}
