import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/platform/data/providers/platform_providers.dart';
import 'package:ca_app/features/platform/domain/models/audit_log_entry.dart';
import 'package:ca_app/features/platform/presentation/widgets/audit_log_tile.dart';

/// Audit log viewer with severity filter chips, user search, and
/// pull-to-refresh.
class AuditTrailScreen extends ConsumerStatefulWidget {
  const AuditTrailScreen({super.key});

  @override
  ConsumerState<AuditTrailScreen> createState() => _AuditTrailScreenState();
}

class _AuditTrailScreenState extends ConsumerState<AuditTrailScreen> {
  LogSeverity? _severityFilter;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allLogs = ref.watch(auditLogsProvider);
    final filtered = _applyFilters(allLogs);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Audit Trail',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral900,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search by user…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 4),
          _SeverityFilterBar(
            selected: _severityFilter,
            onSelected: (s) => setState(() => _severityFilter = s),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future<void>.delayed(const Duration(milliseconds: 600));
                ref.read(auditLogsProvider.notifier).refresh();
              },
              child: filtered.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => Column(
                        children: [
                          AuditLogTile(entry: filtered[i]),
                          if (i < filtered.length - 1)
                            const Divider(indent: 72, height: 1),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  List<AuditLogEntry> _applyFilters(List<AuditLogEntry> logs) {
    var result = logs;
    if (_severityFilter != null) {
      result = result.where((e) => e.severity == _severityFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((e) => e.userName.toLowerCase().contains(q))
          .toList();
    }
    return result;
  }
}

// ---------------------------------------------------------------------------
// Severity filter bar
// ---------------------------------------------------------------------------

class _SeverityFilterBar extends StatelessWidget {
  const _SeverityFilterBar({
    required this.selected,
    required this.onSelected,
  });

  final LogSeverity? selected;
  final ValueChanged<LogSeverity?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('All'),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
            ),
          ),
          ...LogSeverity.values.map(
            (s) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                avatar: Icon(
                  _severityIcon(s),
                  size: 16,
                  color: selected == s ? Colors.white : _severityColor(s),
                ),
                label: Text(_severityLabel(s)),
                selected: selected == s,
                selectedColor: _severityColor(s),
                onSelected: (_) => onSelected(s),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _severityLabel(LogSeverity s) {
    switch (s) {
      case LogSeverity.info:
        return 'Info';
      case LogSeverity.warning:
        return 'Warning';
      case LogSeverity.critical:
        return 'Critical';
    }
  }

  static IconData _severityIcon(LogSeverity s) {
    switch (s) {
      case LogSeverity.info:
        return Icons.info_outline_rounded;
      case LogSeverity.warning:
        return Icons.warning_amber_rounded;
      case LogSeverity.critical:
        return Icons.gpp_bad_rounded;
    }
  }

  static Color _severityColor(LogSeverity s) {
    switch (s) {
      case LogSeverity.info:
        return AppColors.secondary;
      case LogSeverity.warning:
        return AppColors.warning;
      case LogSeverity.critical:
        return AppColors.error;
    }
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_toggle_off_rounded,
            size: 64,
            color: AppColors.neutral300,
          ),
          const SizedBox(height: 16),
          Text(
            'No logs match the current filters.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}
