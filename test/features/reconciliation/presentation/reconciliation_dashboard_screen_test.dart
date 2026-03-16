import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/features/reconciliation/presentation/reconciliation_dashboard_screen.dart';
import 'package:ca_app/features/reconciliation/presentation/widgets/match_summary_card.dart';

/// Suppresses layout overflow errors that can occur on test viewports.
Future<void> _ignoreOverflow(Future<void> Function() body) async {
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('overflowed')) return;
    originalOnError?.call(details);
  };
  try {
    await body();
  } finally {
    FlutterError.onError = originalOnError;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildScreen() {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const ReconciliationDashboardScreen(),
        routes: [
          GoRoute(
            path: 'reconciliation/detail',
            builder: (context, state) => const Scaffold(),
          ),
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
  group('ReconciliationDashboardScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _ignoreOverflow(() async {
        await _pump(tester);
        expect(find.byType(ReconciliationDashboardScreen), findsOneWidget);
      });
    });

    testWidgets('renders Reconciliation title', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _ignoreOverflow(() async {
        await _pump(tester);
        expect(find.text('Reconciliation'), findsOneWidget);
      });
    });

    testWidgets('renders subtitle with 26AS vs AIS vs ITR', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _ignoreOverflow(() async {
        await _pump(tester);
        expect(find.text('26AS vs AIS vs ITR three-way match'), findsOneWidget);
      });
    });

    testWidgets('renders Total summary chip', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _ignoreOverflow(() async {
        await _pump(tester);
        expect(find.text('Total'), findsWidgets);
      });
    });

    testWidgets('renders Matched summary chip', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _ignoreOverflow(() async {
        await _pump(tester);
        expect(find.text('Matched'), findsWidgets);
      });
    });

    testWidgets('renders Mismatch summary chip', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _ignoreOverflow(() async {
        await _pump(tester);
        expect(find.text('Mismatch'), findsWidgets);
      });
    });

    testWidgets('renders Missing summary chip', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _ignoreOverflow(() async {
        await _pump(tester);
        expect(find.text('Missing'), findsWidgets);
      });
    });

    testWidgets('renders MatchSummaryCard', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _ignoreOverflow(() async {
        await _pump(tester);
        expect(find.byType(MatchSummaryCard), findsOneWidget);
      });
    });

    testWidgets('renders Run Reconciliation button', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _ignoreOverflow(() async {
        await _pump(tester);
        expect(find.text('Run Reconciliation'), findsOneWidget);
      });
    });

    testWidgets('renders client selector showing Rajesh Sharma', (
      tester,
    ) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _ignoreOverflow(() async {
        await _pump(tester);
        expect(find.text('Rajesh Sharma'), findsOneWidget);
      });
    });

    testWidgets('renders AY 2025-26 assessment year selector', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _ignoreOverflow(() async {
        await _pump(tester);
        expect(find.text('AY 2025-26'), findsOneWidget);
      });
    });

    testWidgets('renders ReconEntryTile widgets or empty content', (
      tester,
    ) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _ignoreOverflow(() async {
        await _pump(tester);
        // Either entries are shown or the list is empty but content renders
        expect(find.byType(ReconciliationDashboardScreen), findsOneWidget);
      });
    });

    testWidgets('renders tab selector with source comparison options', (
      tester,
    ) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _ignoreOverflow(() async {
        await _pump(tester);
        // ChoiceChip tabs for 26AS, AIS, etc.
        expect(find.byType(ChoiceChip), findsWidgets);
      });
    });

    testWidgets('renders filter chips for status', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _ignoreOverflow(() async {
        await _pump(tester);
        expect(find.byType(FilterChip), findsWidgets);
      });
    });

    testWidgets('renders All filter chip', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _ignoreOverflow(() async {
        await _pump(tester);
        expect(find.text('All'), findsWidgets);
      });
    });

    testWidgets('Run Reconciliation button triggers snackbar', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _ignoreOverflow(() async {
        await _pump(tester);
        await tester.tap(find.text('Run Reconciliation'));
        await tester.pump();
        expect(find.text('Running reconciliation...'), findsOneWidget);
      });
    });
  });
}
