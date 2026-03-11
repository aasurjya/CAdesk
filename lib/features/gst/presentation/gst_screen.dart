import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import '../data/providers/gst_providers.dart';
import '../domain/models/gst_return.dart';
import 'widgets/gst_client_detail_sheet.dart';
import 'widgets/gst_client_tile.dart';
import 'widgets/gst_summary_card.dart';

/// Tab definitions for the GST screen.
class _TabDef {
  const _TabDef(this.label, this.type);
  final String label;
  final GstReturnType? type; // null = all
}

const _tabs = [
  _TabDef('GSTR-1', GstReturnType.gstr1),
  _TabDef('GSTR-3B', GstReturnType.gstr3b),
  _TabDef('GSTR-9', GstReturnType.gstr9),
  _TabDef('All Returns', null),
];

class GstScreen extends ConsumerStatefulWidget {
  const GstScreen({super.key});

  @override
  ConsumerState<GstScreen> createState() => _GstScreenState();
}

class _GstScreenState extends ConsumerState<GstScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // -----------------------------------------------------------------------
  // Period picker
  // -----------------------------------------------------------------------

  Future<void> _pickPeriod() async {
    final current = ref.read(gstSelectedPeriodProvider);
    final initialDate = DateTime(current.year, current.month);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030, 12),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: 'Select period',
    );

    if (picked != null) {
      ref.read(gstSelectedPeriodProvider.notifier).update(
          (month: picked.month, year: picked.year));
    }
  }

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(gstSummaryProvider);
    final period = ref.watch(gstSelectedPeriodProvider);
    final periodLabel = DateFormat('MMM yyyy')
        .format(DateTime(period.year, period.month));

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('GST'),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 1,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.neutral400,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
        ),
      ),
      body: Column(
        children: [
          // Period selector
          _PeriodSelector(
            label: periodLabel,
            onTap: _pickPeriod,
          ),

          // Summary row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                GstSummaryCard(
                  label: 'Total GSTINs',
                  count: summary.totalGstins,
                  icon: Icons.business_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                GstSummaryCard(
                  label: 'Returns Due',
                  count: summary.returnsDue,
                  icon: Icons.schedule_rounded,
                  color: AppColors.warning,
                  trendUp: summary.returnsDue > 3 ? true : null,
                ),
                const SizedBox(width: 8),
                GstSummaryCard(
                  label: 'Filed',
                  count: summary.filedThisMonth,
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.success,
                  trendUp: summary.filedThisMonth > 0 ? true : null,
                ),
                const SizedBox(width: 8),
                GstSummaryCard(
                  label: 'Overdue',
                  count: summary.overdue,
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.error,
                  trendUp: summary.overdue > 0 ? false : null,
                ),
              ],
            ),
          ),

          // ITC reconciliation summary banner
          const _ItcReconBanner(),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((tab) {
                return _ReturnListTab(returnType: tab.type);
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'gst_fab',
        onPressed: () {
          _showNewReturnSheet(context);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Return'),
      ),
    );
  }

  void _showNewReturnSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const _NewReturnSheet(),
    );
  }
}

// ---------------------------------------------------------------------------
// Period selector bar
// ---------------------------------------------------------------------------

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: AppColors.surface,
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_rounded,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Period: $label',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: AppColors.neutral400,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab content: filtered list of clients with their returns
// ---------------------------------------------------------------------------

class _ReturnListTab extends ConsumerWidget {
  const _ReturnListTab({required this.returnType});

  final GstReturnType? returnType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(gstClientsProvider);
    final returns = ref.watch(gstReturnsByTypeProvider(returnType));

    // Build a map of clientId -> returns for fast lookup.
    final returnsByClient = <String, List<GstReturn>>{};
    for (final r in returns) {
      returnsByClient.putIfAbsent(r.clientId, () => []).add(r);
    }

    // Filter clients to those that have at least one return in this view,
    // or show all clients if "All Returns" tab.
    final visibleClients = returnType == null
        ? clients
        : clients
            .where((c) => returnsByClient.containsKey(c.id))
            .toList();

    if (visibleClients.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 48,
              color: AppColors.neutral200,
            ),
            const SizedBox(height: 12),
            Text(
              'No returns found for this period',
              style: TextStyle(
                color: AppColors.neutral400,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 80),
      itemCount: visibleClients.length,
      itemBuilder: (context, index) {
        final client = visibleClients[index];
        final clientReturns = returnsByClient[client.id] ?? [];
        return GstClientTile(
          client: client,
          returns: clientReturns,
          onTap: () => _openClientDetail(context, client.id),
        );
      },
    );
  }

  void _openClientDetail(BuildContext context, String clientId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => GstClientDetailSheet(clientId: clientId),
    );
  }
}

// ---------------------------------------------------------------------------
// ITC reconciliation summary banner
// ---------------------------------------------------------------------------

class _ItcReconBanner extends ConsumerWidget {
  const _ItcReconBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(itcReconSummaryProvider);
    final mismatchLakhs = summary.totalMismatch / 100000;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.sync_alt_rounded, size: 16, color: AppColors.secondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.neutral600,
                  ),
                  children: [
                    const TextSpan(
                      text: 'ITC Recon: ',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: '${summary.reconciled}/${summary.total} reconciled',
                    ),
                    const TextSpan(text: ' • '),
                    TextSpan(
                      text: '₹${mismatchLakhs.toStringAsFixed(2)}L mismatch',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: summary.totalMismatch > 50000
                            ? AppColors.warning
                            : AppColors.neutral600,
                      ),
                    ),
                    if (summary.escalated > 0) ...[
                      const TextSpan(text: ' • '),
                      TextSpan(
                        text: '${summary.escalated} escalated',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// New return bottom sheet (placeholder form)
// ---------------------------------------------------------------------------

class _NewReturnSheet extends ConsumerStatefulWidget {
  const _NewReturnSheet();

  @override
  ConsumerState<_NewReturnSheet> createState() => _NewReturnSheetState();
}

class _NewReturnSheetState extends ConsumerState<_NewReturnSheet> {
  String? _selectedClientId;
  GstReturnType _selectedType = GstReturnType.gstr1;

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(gstClientsProvider);
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
            'File New Return',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 20),

          // Client dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedClientId,
            decoration: const InputDecoration(
              labelText: 'Select Client',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.business_rounded),
            ),
            items: clients
                .map(
                  (c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(
                      c.businessName,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) => setState(() => _selectedClientId = val),
          ),
          const SizedBox(height: 16),

          // Return type dropdown
          DropdownButtonFormField<GstReturnType>(
            initialValue: _selectedType,
            decoration: const InputDecoration(
              labelText: 'Return Type',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description_rounded),
            ),
            items: GstReturnType.values
                .map(
                  (t) => DropdownMenuItem(
                    value: t,
                    child: Text('${t.label} - ${t.description}'),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedType = val);
            },
          ),
          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: _selectedClientId == null
                ? null
                : () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${_selectedType.label} filing initiated',
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
