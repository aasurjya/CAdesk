import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/more/presentation/more_menu_data.dart';
import 'package:ca_app/features/more/presentation/more_screen.dart';

Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() =>
    const ProviderScope(child: MaterialApp(home: MoreScreen()));

void main() {
  // -------------------------------------------------------------------------
  // Existing smoke tests (preserved)
  // -------------------------------------------------------------------------

  group('MoreScreen - smoke tests', () {
    testWidgets('renders More app bar title', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('renders grid view toggle icon', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.view_list), findsOneWidget);
    });

    testWidgets('renders CA Professional profile name', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('CA Professional'), findsOneWidget);
    });

    testWidgets('renders ca@example.com email in profile', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('ca@example.com'), findsOneWidget);
    });

    testWidgets('renders CA avatar initials', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('CA'), findsOneWidget);
    });

    testWidgets('renders Sign Out button when scrolled', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView).first, const Offset(0, -5000));
      await tester.pumpAndSettle();

      expect(find.text('Sign Out'), findsOneWidget);
    });

    testWidgets('renders CADesk version footer when scrolled', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView).first, const Offset(0, -5000));
      await tester.pumpAndSettle();

      expect(find.textContaining('CADesk v'), findsOneWidget);
    });

    testWidgets('renders logout icon in Sign Out button when scrolled', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView).first, const Offset(0, -5000));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.logout), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Section grouping tests
  // -------------------------------------------------------------------------

  group('MoreScreen - section grouping', () {
    testWidgets('renders category section headers as ExpansionTiles', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // All 8 categories should produce ExpansionTile widgets
      expect(find.byType(ExpansionTile), findsNWidgets(8));
    });

    testWidgets('renders Quick Access and Core Filing headers', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Quick Access'), findsOneWidget);
      expect(find.text('Core Filing'), findsOneWidget);
    });

    testWidgets('displays item count badges in section headers', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Quick Access has 3 items
      expect(find.text('3'), findsWidgets);
      // Core Filing has 6 items
      expect(find.text('6'), findsWidgets);
    });

    testWidgets('sections are collapsed by default (no search)', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Individual menu items should NOT be visible when collapsed
      expect(find.text('Dashboard'), findsNothing);
    });

    testWidgets('tapping a section header expands it to reveal items', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsNothing);

      // Tap "Quick Access" section header to expand it
      await tester.tap(find.text('Quick Access'));
      await tester.pumpAndSettle();

      // Now Dashboard should be visible
      expect(find.text('Dashboard'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Search filtering tests
  // -------------------------------------------------------------------------

  group('MoreScreen - search filtering', () {
    testWidgets('renders a search field with search icon', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      // Two search icons: SearchAction in AppBar + prefix icon in TextField
      expect(find.byIcon(Icons.search), findsNWidgets(2));
    });

    testWidgets('search filters items and auto-expands matching sections', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'GST');
      await tester.pumpAndSettle();

      // Core Filing section should be visible (contains GST)
      expect(find.text('Core Filing'), findsOneWidget);

      // Non-matching sections should be hidden
      expect(find.text('Quick Access'), findsNothing);
    });

    testWidgets('search matches on subtitle text', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // "reconciliation" appears in AI & Automation subtitle
      await tester.enterText(find.byType(TextField), 'reconciliation');
      await tester.pumpAndSettle();

      // Modern Practice section should be visible
      expect(find.text('Modern Practice'), findsOneWidget);
    });

    testWidgets('search is case-insensitive', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'gst');
      await tester.pumpAndSettle();

      // Core Filing section should still appear
      expect(find.text('Core Filing'), findsOneWidget);
    });

    testWidgets('clearing search restores all sections', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'GST');
      await tester.pumpAndSettle();

      expect(find.text('Quick Access'), findsNothing);

      // Tap the clear icon
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // All sections should be restored
      expect(find.text('Quick Access'), findsOneWidget);
      expect(find.text('Core Filing'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Empty search state tests
  // -------------------------------------------------------------------------

  group('MoreScreen - empty search state', () {
    testWidgets('shows empty state when search has no matches', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'zzzznonexistent');
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.text('No modules found'), findsOneWidget);
    });

    testWidgets('no ExpansionTiles shown when search yields no results', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'zzzznonexistent');
      await tester.pumpAndSettle();

      expect(find.byType(ExpansionTile), findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  // Toggle view mode tests
  // -------------------------------------------------------------------------

  group('MoreScreen - toggle view mode', () {
    testWidgets('tapping list view toggle switches to list view', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.view_list), findsOneWidget);

      await tester.tap(find.byIcon(Icons.view_list));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.grid_view), findsOneWidget);
    });

    testWidgets('list view shows ListTiles inside expanded section', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Switch to list view
      await tester.tap(find.byIcon(Icons.view_list));
      await tester.pumpAndSettle();

      // Expand Quick Access section
      await tester.tap(find.text('Quick Access'));
      await tester.pumpAndSettle();

      // Should find ListTile widgets for items
      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('grid view shows Wrap layout inside expanded section', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Expand Quick Access section (default is grid view)
      await tester.tap(find.text('Quick Access'));
      await tester.pumpAndSettle();

      // Should find a Wrap widget for the grid layout
      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets('toggling view mode preserves search results', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Search for "Dashboard" to auto-expand Quick Access
      await tester.enterText(find.byType(TextField), 'Dashboard');
      await tester.pumpAndSettle();

      // Dashboard should be visible
      expect(find.text('Dashboard'), findsWidgets);

      // Toggle to list view
      await tester.tap(find.byIcon(Icons.view_list));
      await tester.pumpAndSettle();

      // Dashboard should still be visible
      expect(find.text('Dashboard'), findsWidgets);
    });
  });

  // -------------------------------------------------------------------------
  // Data layer tests (pure functions)
  // -------------------------------------------------------------------------

  group('more_menu_data - filterMenuItems', () {
    test('returns all items when query is empty', () {
      final result = filterMenuItems(kMoreMenuItems, '');
      expect(result.length, kMoreMenuItems.length);
    });

    test('filters by title (case insensitive)', () {
      final result = filterMenuItems(kMoreMenuItems, 'gst');
      expect(result.any((item) => item.title == 'GST'), isTrue);
    });

    test('filters by subtitle', () {
      final result = filterMenuItems(kMoreMenuItems, 'reconciliation');
      expect(result.any((item) => item.title == 'AI & Automation'), isTrue);
    });

    test('returns empty list when no match', () {
      final result = filterMenuItems(kMoreMenuItems, 'zzzznonexistent');
      expect(result, isEmpty);
    });
  });

  group('more_menu_data - groupMenuItemsByCategory', () {
    test('groups all items into 8 categories', () {
      final groups = groupMenuItemsByCategory(kMoreMenuItems);
      expect(groups.length, 8);
    });

    test('preserves canonical category order', () {
      final groups = groupMenuItemsByCategory(kMoreMenuItems);
      expect(groups[0].name, kCategoryQuickAccess);
      expect(groups[1].name, kCategoryCoreFiling);
      expect(groups[7].name, kCategoryGeneral);
    });

    test('Quick Access has 3 items', () {
      final groups = groupMenuItemsByCategory(kMoreMenuItems);
      final quickAccess = groups.firstWhere(
        (g) => g.name == kCategoryQuickAccess,
      );
      expect(quickAccess.items.length, 3);
    });

    test('omits empty categories from filtered results', () {
      // Filter to only Quick Access items
      final filtered = kMoreMenuItems
          .where((item) => item.category == kCategoryQuickAccess)
          .toList();
      final groups = groupMenuItemsByCategory(filtered);
      expect(groups.length, 1);
      expect(groups[0].name, kCategoryQuickAccess);
    });
  });
}
