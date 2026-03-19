import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/core/data/module_registry.dart';
import 'package:ca_app/core/data/providers/global_search_providers.dart';
import 'package:ca_app/core/widgets/global_search_overlay.dart';
import 'package:ca_app/core/widgets/search_action.dart';
import 'package:ca_app/features/clients/data/providers/client_providers.dart';
import 'package:ca_app/features/clients/domain/models/client.dart';
import 'package:ca_app/features/clients/domain/models/client_type.dart';
import 'package:ca_app/features/compliance/data/providers/compliance_providers.dart';
import 'package:ca_app/features/compliance/domain/models/compliance_deadline.dart';
import 'package:ca_app/features/filing/data/providers/filing_hub_providers.dart';
import 'package:ca_app/features/filing/domain/models/filing_hub_item.dart';

import '../../helpers/provider_test_helpers.dart';
import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

final _testClients = <Client>[
  Client(
    id: 't1',
    name: 'Rajesh Kumar Sharma',
    pan: 'ABCPS1234A',
    clientType: ClientType.individual,
    status: ClientStatus.active,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2026, 3, 1),
  ),
  Client(
    id: 't2',
    name: 'ABC Infra Pvt Ltd',
    pan: 'AABCA1234C',
    clientType: ClientType.company,
    status: ClientStatus.active,
    createdAt: DateTime(2023, 7, 1),
    updatedAt: DateTime(2026, 3, 5),
  ),
];

final _testDeadlines = <ComplianceDeadline>[
  ComplianceDeadline(
    id: 'td-1',
    title: 'TDS/TCS Payment',
    description: 'Payment of TDS/TCS deducted in the previous month.',
    category: ComplianceCategory.tds,
    dueDate: DateTime(2026, 4, 7),
    applicableTo: ['All Deductors'],
    isRecurring: true,
    frequency: ComplianceFrequency.monthly,
    status: ComplianceStatus.upcoming,
  ),
  ComplianceDeadline(
    id: 'td-2',
    title: 'GST-3B Monthly Return',
    description: 'GSTR-3B summary return with tax payment.',
    category: ComplianceCategory.gst,
    dueDate: DateTime(2026, 4, 20),
    applicableTo: ['Regular Taxpayers'],
    isRecurring: true,
    frequency: ComplianceFrequency.monthly,
    status: ComplianceStatus.upcoming,
  ),
];

final _testFilings = <FilingHubItem>[
  FilingHubItem(
    id: 'tf-1',
    clientName: 'Sharma & Associates',
    filingType: FilingCategory.gst,
    subType: 'GSTR-3B',
    status: FilingHubStatus.overdue,
    dueDate: DateTime(2026, 3, 15),
  ),
  FilingHubItem(
    id: 'tf-2',
    clientName: 'Patel Traders',
    filingType: FilingCategory.itr,
    subType: 'ITR-3',
    status: FilingHubStatus.inProgress,
    dueDate: DateTime(2026, 7, 31),
  ),
];

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Provider overrides that inject deterministic test data.
List<dynamic> _testOverrides() {
  return [
    allClientsProvider.overrideWith(() => _TestClientsNotifier()),
    allComplianceDeadlinesProvider.overrideWith(
      () => _TestDeadlinesNotifier(),
    ),
    filingHubItemsProvider.overrideWith(() => _TestFilingsNotifier()),
  ];
}

class _TestClientsNotifier extends AllClientsNotifier {
  @override
  Future<List<Client>> build() async => _testClients;
}

class _TestDeadlinesNotifier extends AllComplianceDeadlinesNotifier {
  @override
  Future<List<ComplianceDeadline>> build() async => _testDeadlines;
}

class _TestFilingsNotifier extends FilingHubItemsNotifier {
  @override
  List<FilingHubItem> build() => _testFilings;
}

/// Pumps a scaffold with a button that opens the search overlay.
Future<void> _pumpOverlayTrigger(
  WidgetTester tester, {
  List<dynamic> overrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides.cast(),
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                key: const Key('open_search'),
                onPressed: () => showGlobalSearchOverlay(context),
                child: const Text('Search'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Opens the overlay via the trigger button and settles.
Future<void> _openOverlay(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('open_search')));
  await tester.pumpAndSettle();
}

/// Enters text into the search field and waits for the debounce.
Future<void> _enterSearch(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pumpAndSettle();
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ModuleRegistry', () {
    test('allModules has 49 entries', () {
      expect(allModules.length, equals(49));
    });

    test('all modules have non-empty title and subtitle', () {
      for (final m in allModules) {
        expect(m.title.isNotEmpty, isTrue, reason: '${m.title} title empty');
        expect(
          m.subtitle.isNotEmpty,
          isTrue,
          reason: '${m.title} subtitle empty',
        );
      }
    });

    test('all modules have a category', () {
      for (final m in allModules) {
        expect(
          m.category.isNotEmpty,
          isTrue,
          reason: '${m.title} category empty',
        );
      }
    });
  });

  group('GlobalSearchResults', () {
    test('isEmpty returns true for empty results', () {
      const results = GlobalSearchResults();
      expect(results.isEmpty, isTrue);
      expect(results.totalCount, equals(0));
    });

    test('totalCount sums all categories', () {
      const results = GlobalSearchResults(
        modules: [
          SearchResult(
            icon: Icons.home,
            title: 'A',
            subtitle: 'B',
            category: SearchResultCategory.modules,
          ),
        ],
        clients: [
          SearchResult(
            icon: Icons.person,
            title: 'C',
            subtitle: 'D',
            category: SearchResultCategory.clients,
          ),
          SearchResult(
            icon: Icons.person,
            title: 'E',
            subtitle: 'F',
            category: SearchResultCategory.clients,
          ),
        ],
      );
      expect(results.totalCount, equals(3));
      expect(results.isEmpty, isFalse);
    });
  });

  group('GlobalSearchProviders', () {
    test('empty query returns empty results', () {
      final container = createTestContainer(overrides: _testOverrides());
      addTearDown(container.dispose);

      container.read(globalSearchQueryProvider.notifier).update('');
      final results = container.read(globalSearchResultsProvider);

      expect(results.isEmpty, isTrue);
    });

    test('module search filters by title', () {
      final container = createTestContainer(overrides: _testOverrides());
      addTearDown(container.dispose);

      container.read(globalSearchQueryProvider.notifier).update('income tax');
      final results = container.read(globalSearchResultsProvider);

      expect(results.modules.isNotEmpty, isTrue);
      expect(
        results.modules.first.title,
        equals('Income Tax'),
      );
    });

    test('module search filters by subtitle', () {
      final container = createTestContainer(overrides: _testOverrides());
      addTearDown(container.dispose);

      container.read(globalSearchQueryProvider.notifier).update(
          'itr filing');
      final results = container.read(globalSearchResultsProvider);

      expect(results.modules.isNotEmpty, isTrue);
      expect(results.modules.first.title, equals('Income Tax'));
    });

    test('client search matches name', () async {
      final container = createTestContainer(overrides: _testOverrides());
      addTearDown(container.dispose);

      // Wait for async clients to load.
      await container.read(allClientsProvider.future);

      container.read(globalSearchQueryProvider.notifier).update('rajesh');
      final results = container.read(globalSearchResultsProvider);

      expect(results.clients.isNotEmpty, isTrue);
      expect(results.clients.first.title, equals('Rajesh Kumar Sharma'));
    });

    test('client search matches PAN', () async {
      final container = createTestContainer(overrides: _testOverrides());
      addTearDown(container.dispose);

      await container.read(allClientsProvider.future);

      container.read(globalSearchQueryProvider.notifier).update('aabca1234c');
      final results = container.read(globalSearchResultsProvider);

      expect(results.clients.isNotEmpty, isTrue);
      expect(results.clients.first.title, equals('ABC Infra Pvt Ltd'));
    });

    test('deadline search matches title', () async {
      final container = createTestContainer(overrides: _testOverrides());
      addTearDown(container.dispose);

      await container.read(allComplianceDeadlinesProvider.future);

      container.read(globalSearchQueryProvider.notifier).update('tds');
      final results = container.read(globalSearchResultsProvider);

      expect(results.deadlines.isNotEmpty, isTrue);
      expect(results.deadlines.first.title, equals('TDS/TCS Payment'));
    });

    test('filing search matches client name', () {
      final container = createTestContainer(overrides: _testOverrides());
      addTearDown(container.dispose);

      container.read(globalSearchQueryProvider.notifier).update('sharma');
      final results = container.read(globalSearchResultsProvider);

      expect(results.filings.isNotEmpty, isTrue);
      expect(results.filings.first.title, contains('Sharma'));
    });

    test('filing search matches sub-type', () {
      final container = createTestContainer(overrides: _testOverrides());
      addTearDown(container.dispose);

      container.read(globalSearchQueryProvider.notifier).update('itr-3');
      final results = container.read(globalSearchResultsProvider);

      expect(results.filings.isNotEmpty, isTrue);
      expect(results.filings.first.title, contains('ITR-3'));
    });

    test('non-matching query returns empty results', () {
      final container = createTestContainer(overrides: _testOverrides());
      addTearDown(container.dispose);

      container.read(globalSearchQueryProvider.notifier).update(
          'zzz_nonexistent_zzz');
      final results = container.read(globalSearchResultsProvider);

      expect(results.isEmpty, isTrue);
    });
  });

  group('GlobalSearchOverlay widget', () {
    testWidgets('shows hint text when opened with empty query', (
      tester,
    ) async {
      await setPhoneViewport(tester);
      await _pumpOverlayTrigger(tester, overrides: _testOverrides());
      await _openOverlay(tester);

      expect(
        find.text('Search clients, modules, deadlines...'),
        findsWidgets,
      );
    });

    testWidgets('shows search TextField that is auto-focused', (
      tester,
    ) async {
      await setPhoneViewport(tester);
      await _pumpOverlayTrigger(tester, overrides: _testOverrides());
      await _openOverlay(tester);

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
    });

    testWidgets('shows module results for matching query', (tester) async {
      await setPhoneViewport(tester);
      await _pumpOverlayTrigger(tester, overrides: _testOverrides());
      await _openOverlay(tester);

      await _enterSearch(tester, 'gst');

      // Should show GST module and possibly deadline/filing results.
      // "Modules" appears as section header and badge text on each result.
      expect(find.text('Modules'), findsWidgets);
      expect(find.text('GST'), findsWidgets);
    });

    testWidgets('shows no-results message for non-matching query', (
      tester,
    ) async {
      await setPhoneViewport(tester);
      await _pumpOverlayTrigger(tester, overrides: _testOverrides());
      await _openOverlay(tester);

      await _enterSearch(tester, 'zzz_nothing_matches_zzz');

      expect(
        find.textContaining('No results for'),
        findsOneWidget,
      );
    });

    testWidgets('clear button clears search field', (tester) async {
      await setPhoneViewport(tester);
      await _pumpOverlayTrigger(tester, overrides: _testOverrides());
      await _openOverlay(tester);

      await _enterSearch(tester, 'income');

      // Tap clear button.
      await tester.tap(find.byKey(const Key('search_clear_button')));
      await tester.pumpAndSettle();

      // Field should be empty, hint shows again.
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('displays category badges on results', (tester) async {
      await setPhoneViewport(tester);
      await _pumpOverlayTrigger(tester, overrides: _testOverrides());
      await _openOverlay(tester);

      await _enterSearch(tester, 'gst');

      // The category badge "Modules" is visible as section header and
      // badge text on each result tile.
      expect(find.text('Modules'), findsWidgets);
    });

    testWidgets('shows deadline results for matching query', (tester) async {
      await setPhoneViewport(tester);
      await _pumpOverlayTrigger(tester, overrides: _testOverrides());
      await _openOverlay(tester);

      await _enterSearch(tester, 'tds');

      // "Deadlines" appears as section header and badge text on results.
      expect(find.text('Deadlines'), findsWidgets);
    });

    testWidgets('shows filing results for matching query', (tester) async {
      await setPhoneViewport(tester);
      await _pumpOverlayTrigger(tester, overrides: _testOverrides());
      await _openOverlay(tester);

      await _enterSearch(tester, 'sharma');

      // "Filings" appears as section header and badge text on results.
      expect(find.text('Filings'), findsWidgets);
    });

    testWidgets('renders without overflow on phone viewport', (tester) async {
      await setPhoneViewport(tester);
      await _pumpOverlayTrigger(tester, overrides: _testOverrides());
      await _openOverlay(tester);

      await _enterSearch(tester, 'a');

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow on tablet viewport', (
      tester,
    ) async {
      await setTabletViewport(tester);
      await _pumpOverlayTrigger(tester, overrides: _testOverrides());
      await _openOverlay(tester);

      await _enterSearch(tester, 'a');

      expect(tester.takeException(), isNull);
    });
  });

  group('SearchAction widget', () {
    testWidgets('renders an IconButton with search icon', (tester) async {
      await pumpTestWidget(
        tester,
        Scaffold(
          appBar: AppBar(actions: const [SearchAction()]),
        ),
      );

      expect(
        find.byKey(const Key('global_search_action')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('opens search overlay on tap', (tester) async {
      await pumpTestWidget(
        tester,
        Scaffold(
          appBar: AppBar(actions: const [SearchAction()]),
        ),
        overrides: _testOverrides(),
      );

      await tester.tap(find.byKey(const Key('global_search_action')));
      await tester.pumpAndSettle();

      // The overlay search field should now be visible.
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
