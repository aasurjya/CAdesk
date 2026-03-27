import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/data/module_registry.dart';
import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/features/clients/data/providers/client_providers.dart';
import 'package:ca_app/features/clients/domain/models/client.dart';
import 'package:ca_app/features/compliance/data/providers/compliance_providers.dart';
import 'package:ca_app/features/compliance/domain/models/compliance_deadline.dart';
import 'package:ca_app/features/filing/data/providers/filing_hub_providers.dart';

// ---------------------------------------------------------------------------
// Search result types
// ---------------------------------------------------------------------------

/// Category tag for a search result, used for badge color and grouping.
enum SearchResultCategory {
  modules('Modules', AppColors.primary),
  clients('Clients', AppColors.secondary),
  deadlines('Deadlines', AppColors.accent),
  filings('Filings', AppColors.primaryVariant);

  const SearchResultCategory(this.label, this.color);

  final String label;
  final Color color;
}

/// A single search result with display data and navigation target.
class SearchResult {
  const SearchResult({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.category,
    this.route,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final SearchResultCategory category;
  final String? route;
}

/// Grouped search results across all categories.
class GlobalSearchResults {
  const GlobalSearchResults({
    this.modules = const [],
    this.clients = const [],
    this.deadlines = const [],
    this.filings = const [],
  });

  final List<SearchResult> modules;
  final List<SearchResult> clients;
  final List<SearchResult> deadlines;
  final List<SearchResult> filings;

  bool get isEmpty =>
      modules.isEmpty &&
      clients.isEmpty &&
      deadlines.isEmpty &&
      filings.isEmpty;

  int get totalCount =>
      modules.length + clients.length + deadlines.length + filings.length;
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// The current search query text.
final globalSearchQueryProvider =
    NotifierProvider<GlobalSearchQueryNotifier, String>(
      GlobalSearchQueryNotifier.new,
    );

/// Notifier backing [globalSearchQueryProvider].
class GlobalSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;
}

/// Combined search results drawn from modules, clients, deadlines, and
/// filings. Each data source is filtered independently against the query.
final globalSearchResultsProvider = Provider<GlobalSearchResults>((ref) {
  final query = ref.watch(globalSearchQueryProvider).toLowerCase().trim();
  if (query.isEmpty) return const GlobalSearchResults();

  return GlobalSearchResults(
    modules: _searchModules(query),
    clients: _searchClients(ref, query),
    deadlines: _searchDeadlines(ref, query),
    filings: _searchFilings(ref, query),
  );
});

// ---------------------------------------------------------------------------
// Per-category search helpers
// ---------------------------------------------------------------------------

List<SearchResult> _searchModules(String query) {
  return allModules
      .where(
        (m) =>
            m.title.toLowerCase().contains(query) ||
            m.subtitle.toLowerCase().contains(query),
      )
      .take(8)
      .map(
        (m) => SearchResult(
          icon: m.icon,
          title: m.title,
          subtitle: m.subtitle,
          category: SearchResultCategory.modules,
          route: m.route,
        ),
      )
      .toList();
}

List<SearchResult> _searchClients(Ref ref, String query) {
  final clients = ref.watch(allClientsProvider).asData?.value ?? <Client>[];
  return clients
      .where(
        (c) =>
            c.name.toLowerCase().contains(query) ||
            c.pan.toLowerCase().contains(query) ||
            (c.email?.toLowerCase().contains(query) ?? false) ||
            (c.phone?.contains(query) ?? false),
      )
      .take(8)
      .map(
        (c) => SearchResult(
          icon: Icons.person_outline,
          title: c.name,
          subtitle:
              '${c.clientType.label} - ***${c.pan.substring(c.pan.length > 4 ? c.pan.length - 4 : 0)}',
          category: SearchResultCategory.clients,
          route: '/clients/${c.id}',
        ),
      )
      .toList();
}

List<SearchResult> _searchDeadlines(Ref ref, String query) {
  final deadlines =
      ref.watch(allComplianceDeadlinesProvider).asData?.value ??
      <ComplianceDeadline>[];
  final dateFormat = DateFormat('dd MMM yyyy');
  return deadlines
      .where(
        (d) =>
            d.title.toLowerCase().contains(query) ||
            d.description.toLowerCase().contains(query) ||
            d.category.label.toLowerCase().contains(query),
      )
      .take(8)
      .map(
        (d) => SearchResult(
          icon: d.category.icon,
          title: d.title,
          subtitle: 'Due ${dateFormat.format(d.dueDate)}',
          category: SearchResultCategory.deadlines,
          route: '/compliance',
        ),
      )
      .toList();
}

List<SearchResult> _searchFilings(Ref ref, String query) {
  final filings = ref.watch(filingHubItemsProvider);
  return filings
      .where(
        (f) =>
            f.clientName.toLowerCase().contains(query) ||
            f.subType.toLowerCase().contains(query) ||
            f.filingType.label.toLowerCase().contains(query),
      )
      .take(8)
      .map(
        (f) => SearchResult(
          icon: f.filingType.icon,
          title: '${f.subType} - ${f.clientName}',
          subtitle: '${f.filingType.label} - ${f.status.label}',
          category: SearchResultCategory.filings,
          route: '/filing',
        ),
      )
      .toList();
}
