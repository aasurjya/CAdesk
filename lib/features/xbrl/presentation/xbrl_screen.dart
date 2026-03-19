import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../data/providers/xbrl_providers.dart';
import '../domain/models/xbrl_element.dart';
import '../domain/models/xbrl_filing.dart';
import 'widgets/xbrl_element_tile.dart';
import 'widgets/xbrl_filing_tile.dart';

class XbrlScreen extends ConsumerStatefulWidget {
  const XbrlScreen({super.key});

  @override
  ConsumerState<XbrlScreen> createState() => _XbrlScreenState();
}

class _XbrlScreenState extends ConsumerState<XbrlScreen>
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
    final selectedFilingId = ref.watch(xbrlSelectedFilingIdProvider);

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('XBRL Filing'),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filter Filings',
            onPressed: () => _showStatusFilterSheet(context),
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
          tabs: const [
            Tab(text: 'Filings'),
            Tab(text: 'Elements'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FilingsTab(
            onFilingSelected: (id) {
              ref.read(xbrlSelectedFilingIdProvider.notifier).update(id);
              _tabController.animateTo(1);
            },
          ),
          _ElementsTab(selectedFilingId: selectedFilingId),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'xbrl_fab',
        onPressed: () => _showNewFilingSheet(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New XBRL'),
      ),
    );
  }

  void _showStatusFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const _StatusFilterSheet(),
    );
  }

  void _showNewFilingSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const _NewXbrlSheet(),
    );
  }
}

// ---------------------------------------------------------------------------
// Filings tab
// ---------------------------------------------------------------------------

class _FilingsTab extends ConsumerWidget {
  const _FilingsTab({required this.onFilingSelected});

  final ValueChanged<String> onFilingSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filings = ref.watch(xbrlFilteredFilingsProvider);

    if (filings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 48, color: AppColors.neutral200),
            SizedBox(height: 12),
            Text(
              'No XBRL filings found',
              style: TextStyle(color: AppColors.neutral400, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _ProgressSummaryBar(filings: filings),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 4, bottom: 80),
            itemCount: filings.length,
            itemBuilder: (_, i) => XbrlFilingTile(
              filing: filings[i],
              onTap: () => onFilingSelected(filings[i].id),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Progress summary bar
// ---------------------------------------------------------------------------

class _ProgressSummaryBar extends StatelessWidget {
  const _ProgressSummaryBar({required this.filings});

  final List<XbrlFiling> filings;

  @override
  Widget build(BuildContext context) {
    final totalTags = filings.fold<int>(0, (s, f) => s + f.totalTags);
    final completedTags = filings.fold<int>(0, (s, f) => s + f.completedTags);
    final totalErrors = filings.fold<int>(0, (s, f) => s + f.validationErrors);
    final filed = filings
        .where((f) => f.status == XbrlFilingStatus.filed)
        .length;
    final overallPct = totalTags > 0
        ? (completedTags / totalTags).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SumCard(
                label: 'Filings',
                value: '${filings.length}',
                icon: Icons.folder_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              _SumCard(
                label: 'Filed',
                value: '$filed',
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              _SumCard(
                label: 'Errors',
                value: '$totalErrors',
                icon: Icons.error_rounded,
                color: AppColors.error,
              ),
              const SizedBox(width: 8),
              _SumCard(
                label: 'Tags',
                value: '$completedTags/$totalTags',
                icon: Icons.tag_rounded,
                color: AppColors.primaryVariant,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                'Overall',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.neutral400,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: overallPct,
                    minHeight: 6,
                    backgroundColor: AppColors.neutral200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      overallPct >= 1.0
                          ? AppColors.success
                          : AppColors.primaryVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(overallPct * 100).round()}%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SumCard extends StatelessWidget {
  const _SumCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.neutral400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Elements tab
// ---------------------------------------------------------------------------

class _ElementsTab extends ConsumerWidget {
  const _ElementsTab({required this.selectedFilingId});

  final String? selectedFilingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (selectedFilingId == null) {
      return const Center(
        child: Text(
          'Select a filing from the Filings tab\nto view its elements.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.neutral400, fontSize: 14),
        ),
      );
    }

    final elements = ref.watch(xbrlActiveElementsProvider);
    final filings = ref.watch(xbrlFilingsProvider);
    final filing = filings.where((f) => f.id == selectedFilingId).firstOrNull;

    if (elements.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 48, color: AppColors.neutral200),
            SizedBox(height: 12),
            Text(
              'No elements available for this filing',
              style: TextStyle(color: AppColors.neutral400, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (filing != null) _ElementsHeader(filing: filing),
        const _TypeLegend(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 4, bottom: 80),
            itemCount: elements.length,
            itemBuilder: (_, i) => XbrlElementTile(element: elements[i]),
          ),
        ),
      ],
    );
  }
}

class _ElementsHeader extends StatelessWidget {
  const _ElementsHeader({required this.filing});

  final XbrlFiling filing;

  @override
  Widget build(BuildContext context) {
    final completed = (filing.completionPercentage * 100).round();

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  filing.companyName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'FY ${filing.financialYear} • ${filing.reportType.label}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Text(
                '$completed%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const Text(
                'complete',
                style: TextStyle(fontSize: 9, color: AppColors.neutral400),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeLegend extends StatelessWidget {
  const _TypeLegend();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: XbrlElementType.values
            .map(
              (t) => Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: t.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      t.label,
                      style: TextStyle(
                        fontSize: 10,
                        color: t.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status filter sheet
// ---------------------------------------------------------------------------

class _StatusFilterSheet extends ConsumerWidget {
  const _StatusFilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(xbrlStatusFilterProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
            'Filter by Status',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 16),
          // All option
          _StatusOption(
            label: 'All Statuses',
            icon: Icons.list_rounded,
            color: AppColors.neutral400,
            isSelected: current == null,
            onTap: () {
              ref.read(xbrlStatusFilterProvider.notifier).update(null);
              Navigator.of(context).pop();
            },
          ),
          ...XbrlFilingStatus.values.map(
            (s) => _StatusOption(
              label: s.label,
              icon: s.icon,
              color: s.color,
              isSelected: current == s,
              onTap: () {
                ref.read(xbrlStatusFilterProvider.notifier).update(s);
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  const _StatusOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color, size: 20),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          color: AppColors.neutral900,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_rounded, color: AppColors.primary, size: 20)
          : null,
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}

// ---------------------------------------------------------------------------
// New XBRL bottom sheet
// ---------------------------------------------------------------------------

class _NewXbrlSheet extends ConsumerStatefulWidget {
  const _NewXbrlSheet();

  @override
  ConsumerState<_NewXbrlSheet> createState() => _NewXbrlSheetState();
}

class _NewXbrlSheetState extends ConsumerState<_NewXbrlSheet> {
  XbrlReportType _reportType = XbrlReportType.standalone;
  String _financialYear = '2024-25';

  @override
  Widget build(BuildContext context) {
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
            'New XBRL Filing',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 20),

          // CIN input
          const TextField(
            decoration: InputDecoration(
              labelText: 'CIN',
              hintText: 'U74999MH2018PTC123456',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.fingerprint_rounded),
            ),
          ),
          const SizedBox(height: 16),

          // Financial year
          DropdownButtonFormField<String>(
            initialValue: _financialYear,
            decoration: const InputDecoration(
              labelText: 'Financial Year',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today_rounded),
            ),
            items: const [
              DropdownMenuItem(value: '2024-25', child: Text('2024-25')),
              DropdownMenuItem(value: '2023-24', child: Text('2023-24')),
              DropdownMenuItem(value: '2022-23', child: Text('2022-23')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _financialYear = val);
            },
          ),
          const SizedBox(height: 16),

          // Report type selector
          Row(
            children: XbrlReportType.values.map((t) {
              final isSelected = _reportType == t;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _reportType = t),
                  child: Container(
                    margin: EdgeInsets.only(
                      right: t == XbrlReportType.standalone ? 8 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.neutral50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.neutral200,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        t.label,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.neutral600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'XBRL filing initiated ($_financialYear • ${_reportType.label})',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create Filing'),
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
