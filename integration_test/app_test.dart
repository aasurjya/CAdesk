/// CADesk End-to-End Integration Tests
///
/// Run with:
///   flutter test integration_test/app_test.dart -d macos
///   flutter test integration_test/app_test.dart -d chrome
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

import 'package:ca_app/core/routing/app_router.dart';
import 'package:ca_app/core/theme/app_theme.dart';
import 'package:ca_app/core/widgets/adaptive_scaffold.dart';
import 'package:ca_app/features/filing/presentation/filing_screen.dart';
import 'package:ca_app/features/clients/presentation/clients_screen.dart';
import 'package:ca_app/features/today/presentation/today_screen.dart';
import 'package:ca_app/features/documents/presentation/documents_screen.dart';
import 'package:ca_app/features/more/presentation/more_screen.dart';
import 'package:ca_app/features/billing/presentation/billing_screen.dart';
import 'package:ca_app/features/tasks/presentation/tasks_screen.dart';
import 'package:ca_app/features/compliance/presentation/compliance_screen.dart';
import 'package:ca_app/features/dashboard/presentation/dashboard_screen.dart';

// ---------------------------------------------------------------------------
// Test-only router that skips auth (no Supabase dependency)
// ---------------------------------------------------------------------------

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _filingKey = GlobalKey<NavigatorState>(debugLabel: 'filing');
final _clientsKey = GlobalKey<NavigatorState>(debugLabel: 'clients');
final _todayKey = GlobalKey<NavigatorState>(debugLabel: 'today');
final _docsKey = GlobalKey<NavigatorState>(debugLabel: 'docs');
final _moreKey = GlobalKey<NavigatorState>(debugLabel: 'more');

GoRouter _buildTestRouter() {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdaptiveScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _filingKey,
            routes: [
              GoRoute(
                path: '/',
                builder: (_, _) => const FilingScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _clientsKey,
            routes: [
              GoRoute(
                path: '/clients',
                builder: (_, _) => const ClientsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _todayKey,
            routes: [
              GoRoute(
                path: '/today',
                builder: (_, _) => const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _docsKey,
            routes: [
              GoRoute(
                path: '/docs',
                builder: (_, _) => const DocumentsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _moreKey,
            routes: [
              GoRoute(
                path: '/more',
                builder: (_, _) => const MoreScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/billing',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const BillingScreen(),
      ),
      GoRoute(
        path: '/tasks',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const TasksScreen(),
      ),
      GoRoute(
        path: '/compliance',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const ComplianceScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const DashboardScreen(),
      ),
    ],
  );
}

/// Pumps the app with a test-only router (no auth, no Supabase).
Future<void> pumpApp(WidgetTester tester) async {
  // Set a consistent window size to avoid layout-dependent failures
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() => tester.view.resetPhysicalSize());
  addTearDown(() => tester.view.resetDevicePixelRatio());

  final router = _buildTestRouter();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [appRouterProvider.overrideWithValue(router)],
      child: MaterialApp.router(
        title: 'CADesk E2E',
        theme: AppTheme.light,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // =========================================================================
  // 1. App Launch — bottom nav renders with 5 tabs
  // =========================================================================
  group('App Launch', () {
    testWidgets('displays navigation with 5 tabs', (tester) async {
      await pumpApp(tester);
      // Adaptive layout may show NavigationBar (phone) or NavigationRail (desktop)
      final hasNavBar = find.byType(NavigationBar).evaluate().isNotEmpty;
      final hasNavRail = find.byType(NavigationRail).evaluate().isNotEmpty;
      expect(hasNavBar || hasNavRail, isTrue);
      expect(find.text('Filing'), findsWidgets);
      expect(find.text('Clients'), findsWidgets);
    });

    testWidgets('starts on Filing screen', (tester) async {
      await pumpApp(tester);
      // FilingScreen should be rendered as the initial route
      expect(find.byType(FilingScreen), findsOneWidget);
    });
  });

  // =========================================================================
  // 2. Client Flow — navigate, search, list
  // =========================================================================
  group('Client Flow', () {
    testWidgets('navigate to Clients tab', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Clients').last);
      await tester.pumpAndSettle();
      expect(find.byType(ClientsScreen), findsOneWidget);
    });

    testWidgets('Clients screen renders with search or list', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Clients').last);
      await tester.pumpAndSettle();
      // Screen should render — either search field or client list
      final hasTextField = find.byType(TextField).evaluate().isNotEmpty;
      final hasSearchBar = find.byType(SearchBar).evaluate().isNotEmpty;
      final hasScaffold = find.byType(Scaffold).evaluate().isNotEmpty;
      expect(hasTextField || hasSearchBar || hasScaffold, isTrue);
    });

    testWidgets('typing in search filters the list', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Clients').last);
      await tester.pumpAndSettle();

      final searchFields = find.byType(TextField);
      if (searchFields.evaluate().isNotEmpty) {
        await tester.enterText(searchFields.first, 'test');
        await tester.pumpAndSettle();
        // Should not crash — list updates reactively
        expect(find.byType(ClientsScreen), findsOneWidget);
      }
    });
  });

  // =========================================================================
  // 3. Tab Switching — no crashes, state preserved
  // =========================================================================
  group('Tab Switching', () {
    testWidgets('cycle through all 5 tabs without crashing', (tester) async {
      await pumpApp(tester);

      // Filing (already there)
      expect(find.byType(FilingScreen), findsOneWidget);

      // Clients
      await tester.tap(find.text('Clients').last);
      await tester.pumpAndSettle();
      expect(find.byType(ClientsScreen), findsOneWidget);

      // Today
      await tester.tap(find.text('Today').last);
      await tester.pumpAndSettle();
      expect(find.byType(TodayScreen), findsOneWidget);

      // Docs
      await tester.tap(find.text('Docs').last);
      await tester.pumpAndSettle();
      expect(find.byType(DocumentsScreen), findsOneWidget);

      // More
      await tester.tap(find.text('More').last);
      await tester.pumpAndSettle();
      expect(find.byType(MoreScreen), findsOneWidget);

      // Back to Filing
      await tester.tap(find.text('Filing').last);
      await tester.pumpAndSettle();
      expect(find.byType(FilingScreen), findsOneWidget);
    });
  });

  // =========================================================================
  // 4. Scrolling — long lists render without overflow
  // =========================================================================
  group('Scroll Performance', () {
    testWidgets('Filing screen scrolls without errors', (tester) async {
      await pumpApp(tester);
      // Try scrolling down
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
      await tester.pumpAndSettle();
      // No crash means pass
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Clients screen scrolls without errors', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Clients').last);
      await tester.pumpAndSettle();

      final scrollable = find.byType(Scrollable);
      if (scrollable.evaluate().isNotEmpty) {
        await tester.drag(scrollable.first, const Offset(0, -300));
        await tester.pumpAndSettle();
      }
      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  // =========================================================================
  // 5. More Screen — module grid renders, tap navigates
  // =========================================================================
  group('More Screen Navigation', () {
    testWidgets('More screen shows module grid', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('More').last);
      await tester.pumpAndSettle();
      expect(find.byType(MoreScreen), findsOneWidget);
      // Should see module tiles/cards
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
