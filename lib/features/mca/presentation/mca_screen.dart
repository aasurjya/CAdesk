import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../data/providers/mca_providers.dart';
import '../domain/models/mca_filing.dart';
import 'widgets/company_tile.dart';
import 'widgets/mca_filing_tile.dart';

final _dateFmt = DateFormat('dd MMM yyyy');

class McaScreen extends ConsumerStatefulWidget {
  const McaScreen({super.key});

  @override
  ConsumerState<McaScreen> createState() => _McaScreenState();
}

class _McaScreenState extends ConsumerState<McaScreen>
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
    final overdueCount = ref.watch(mcaOverdueCountProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('MCA / ROC Compliance'),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filters',
            onPressed: () => _showFiltersSheet(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.neutral400,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: [
            const Tab(text: 'Companies'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Filings'),
                  if (overdueCount > 0) ...[
                    const SizedBox(width: 6),
                    _OverdueBadge(count: overdueCount),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Upcoming deadlines banner
          _UpcomingDeadlinesBanner(),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [_CompaniesTab(), _FilingsTab()],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'mca_fab',
        onPressed: () => _showNewFilingSheet(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Filing'),
      ),
    );
  }

  void _showFiltersSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const _FiltersSheet(),
    );
  }

  void _showNewFilingSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const _NewFilingSheet(),
    );
  }
}

// ---------------------------------------------------------------------------
// Overdue count badge
// ---------------------------------------------------------------------------

class _OverdueBadge extends StatelessWidget {
  const _OverdueBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Upcoming deadlines banner
// ---------------------------------------------------------------------------

class _UpcomingDeadlinesBanner extends ConsumerWidget {
  const _UpcomingDeadlinesBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcoming = ref.watch(mcaUpcomingFilingsProvider);
    if (upcoming.isEmpty) return const SizedBox.shrink();

    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              children: [
                const Icon(
                  Icons.upcoming_rounded,
                  size: 16,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 6),
                Text(
                  'Upcoming Deadlines (next 30 days)',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 68,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              itemCount: upcoming.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _DeadlineCard(filing: upcoming[i]),
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

class _DeadlineCard extends StatelessWidget {
  const _DeadlineCard({required this.filing});

  final McaFiling filing;

  @override
  Widget build(BuildContext context) {
    final daysLeft = filing.dueDate.difference(DateTime(2026, 3, 10)).inDays;

    return Container(
      width: 160,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: filing.formType.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  filing.formType.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: filing.formType.color,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'in ${daysLeft}d',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            filing.companyName,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            _dateFmt.format(filing.dueDate),
            style: const TextStyle(fontSize: 10, color: AppColors.neutral400),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Companies tab
// ---------------------------------------------------------------------------

class _CompaniesTab extends ConsumerWidget {
  const _CompaniesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companies = ref.watch(mcaCompaniesProvider);

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 80),
      itemCount: companies.length,
      itemBuilder: (_, i) => CompanyTile(company: companies[i]),
    );
  }
}

// ---------------------------------------------------------------------------
// Filings tab
// ---------------------------------------------------------------------------

class _FilingsTab extends ConsumerWidget {
  const _FilingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filings = ref.watch(mcaFilteredFilingsProvider);

    if (filings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 48, color: AppColors.neutral200),
            SizedBox(height: 12),
            Text(
              'No filings match the current filters',
              style: TextStyle(color: AppColors.neutral400, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 80),
      itemCount: filings.length,
      itemBuilder: (_, i) => McaFilingTile(filing: filings[i]),
    );
  }
}

// ---------------------------------------------------------------------------
// Filters bottom sheet
// ---------------------------------------------------------------------------

class _FiltersSheet extends ConsumerWidget {
  const _FiltersSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusFilter = ref.watch(mcaStatusFilterProvider);
    final formTypeFilter = ref.watch(mcaFormTypeFilterProvider);
    final rocFilter = ref.watch(mcaRocFilterProvider);
    final rocOptions = ref.watch(mcaRocJurisdictionsProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Filter Filings',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 20),

            // Status filter
            DropdownButtonFormField<McaFilingStatus?>(
              initialValue: statusFilter,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag_rounded),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Statuses'),
                ),
                ...McaFilingStatus.values.map(
                  (s) => DropdownMenuItem(value: s, child: Text(s.label)),
                ),
              ],
              onChanged: (val) =>
                  ref.read(mcaStatusFilterProvider.notifier).update(val),
            ),
            const SizedBox(height: 16),

            // Form type filter
            DropdownButtonFormField<McaFormType?>(
              initialValue: formTypeFilter,
              decoration: const InputDecoration(
                labelText: 'Form Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description_rounded),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Form Types'),
                ),
                ...McaFormType.values.map(
                  (t) => DropdownMenuItem(
                    value: t,
                    child: Text('${t.label} - ${t.description}'),
                  ),
                ),
              ],
              onChanged: (val) =>
                  ref.read(mcaFormTypeFilterProvider.notifier).update(val),
            ),
            const SizedBox(height: 16),

            // ROC filter
            DropdownButtonFormField<String?>(
              initialValue: rocFilter,
              decoration: const InputDecoration(
                labelText: 'ROC Jurisdiction',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city_rounded),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Jurisdictions'),
                ),
                ...rocOptions.map(
                  (r) => DropdownMenuItem(value: r, child: Text(r)),
                ),
              ],
              onChanged: (val) =>
                  ref.read(mcaRocFilterProvider.notifier).update(val),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(mcaStatusFilterProvider.notifier).update(null);
                      ref.read(mcaFormTypeFilterProvider.notifier).update(null);
                      ref.read(mcaRocFilterProvider.notifier).update(null);
                    },
                    child: const Text('Clear All'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// New filing bottom sheet
// ---------------------------------------------------------------------------

class _NewFilingSheet extends ConsumerStatefulWidget {
  const _NewFilingSheet();

  @override
  ConsumerState<_NewFilingSheet> createState() => _NewFilingSheetState();
}

class _NewFilingSheetState extends ConsumerState<_NewFilingSheet> {
  String? _selectedCompanyId;
  McaFormType _selectedFormType = McaFormType.mgt7;

  @override
  Widget build(BuildContext context) {
    final companies = ref.watch(mcaCompaniesProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'New MCA Filing',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            initialValue: _selectedCompanyId,
            decoration: const InputDecoration(
              labelText: 'Select Company',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.business_rounded),
            ),
            items: companies
                .map(
                  (c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.companyName, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (val) => setState(() => _selectedCompanyId = val),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<McaFormType>(
            initialValue: _selectedFormType,
            decoration: const InputDecoration(
              labelText: 'Form Type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description_rounded),
            ),
            items: McaFormType.values
                .map(
                  (t) => DropdownMenuItem(
                    value: t,
                    child: Text('${t.label} — ${t.description}'),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedFormType = val);
            },
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _selectedCompanyId == null
                ? null
                : () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${_selectedFormType.label} filing initiated',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text('Start Filing'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
