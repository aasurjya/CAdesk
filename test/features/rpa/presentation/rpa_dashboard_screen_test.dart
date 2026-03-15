import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/features/rpa/presentation/rpa_dashboard_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Wraps the screen in a GoRouter so that context.push calls don't throw.
Widget _buildScreen() {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const RpaDashboardScreen(),
        routes: [
          GoRoute(path: 'rpa/new', builder: (context, state) => const Scaffold()),
          GoRoute(path: 'rpa/scripts', builder: (context, state) => const Scaffold()),
          GoRoute(path: 'rpa/task', builder: (context, state) => const Scaffold()),
        ],
      ),
    ],
  );
  return ProviderScope(child: MaterialApp.router(routerConfig: router));
}

Future<void> _setDisplay(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

/// Pump helper that settles route transitions without infinite timer loops.
Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('RpaDashboardScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);
      expect(find.byType(RpaDashboardScreen), findsOneWidget);
    });

    testWidgets('renders RPA Automation title', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);
      expect(find.text('RPA Automation'), findsOneWidget);
    });

    testWidgets('renders Portal bot execution centre subtitle', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);
      expect(find.text('Portal bot execution centre'), findsOneWidget);
    });

    testWidgets('renders New Task button in app bar', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);
      expect(find.text('New Task'), findsWidgets);
    });

    testWidgets('renders Total Tasks stat card', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);
      expect(find.text('Total Tasks'), findsOneWidget);
    });

    testWidgets('renders Success Rate stat card', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);
      expect(find.text('Success Rate'), findsOneWidget);
    });

    testWidgets('renders Active stat card', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('renders Recent Tasks section header', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);
      expect(find.text('Recent Tasks'), findsOneWidget);
    });

    testWidgets('renders Script Library button', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);
      expect(find.text('Script Library'), findsOneWidget);
    });

    testWidgets('renders Run Bot FAB', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);
      expect(find.text('Run Bot'), findsOneWidget);
    });

    testWidgets('renders smart_toy icon on FAB', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);
      expect(find.byIcon(Icons.smart_toy_rounded), findsOneWidget);
    });

    testWidgets('renders task_alt icon in stat row', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);
      expect(find.byIcon(Icons.task_alt_rounded), findsOneWidget);
    });

    testWidgets('renders stat cards', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('renders add_rounded icon in New Task button', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);
      expect(find.byIcon(Icons.add_rounded), findsWidgets);
    });

    testWidgets('shows task list or empty state message', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);
      // Either task cards or the "No tasks yet" message should be present
      final hasTasks = find.byType(Card).evaluate().length > 2;
      final hasEmpty =
          find.text('No tasks yet. Tap + New Task to get started.')
              .evaluate()
              .isNotEmpty;
      expect(hasTasks || hasEmpty, isTrue);
    });
  });
}
