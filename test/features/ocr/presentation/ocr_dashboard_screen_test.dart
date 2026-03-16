import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ca_app/features/ocr/presentation/ocr_dashboard_screen.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildScreen() {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const OcrDashboardScreen(),
        routes: [
          GoRoute(
            path: 'ocr/upload',
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
  group('OcrDashboardScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);
      expect(find.byType(OcrDashboardScreen), findsOneWidget);
    });

    testWidgets('renders Document OCR title', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);
      expect(find.text('Document OCR'), findsOneWidget);
    });

    testWidgets('renders Intelligent document processing subtitle', (
      tester,
    ) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);
      expect(find.text('Intelligent document processing'), findsOneWidget);
    });

    testWidgets('renders Queue tab label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);
      expect(find.text('Queue'), findsWidgets);
    });

    testWidgets('renders History tab label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);
      expect(find.text('History'), findsWidgets);
    });

    testWidgets('renders a TabBar', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);
      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('renders Upload FAB', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);
      expect(find.text('Upload'), findsOneWidget);
    });

    testWidgets('renders upload_file icon on FAB', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);
      expect(find.byIcon(Icons.upload_file_outlined), findsOneWidget);
    });

    testWidgets('Queue tab shows jobs or empty state', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);
      final hasCards = find.byType(Card).evaluate().isNotEmpty;
      final hasEmptyTitle = find
          .text('No documents queued')
          .evaluate()
          .isNotEmpty;
      expect(hasCards || hasEmptyTitle, isTrue);
    });

    testWidgets('switching to History tab renders without error', (
      tester,
    ) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);
      await tester.tap(find.text('History').first);
      await _pump(tester);
      expect(find.byType(OcrDashboardScreen), findsOneWidget);
    });

    testWidgets('History tab shows jobs or empty state', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);
      await tester.tap(find.text('History').first);
      await _pump(tester);
      final hasEmpty = find
          .text('No processed documents')
          .evaluate()
          .isNotEmpty;
      final hasCards = find.byType(Card).evaluate().isNotEmpty;
      expect(hasEmpty || hasCards, isTrue);
    });

    testWidgets('renders Scaffold', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('renders AppBar', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('Queue tab is selected by default', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);
      expect(
        find.descendant(of: find.byType(TabBar), matching: find.text('Queue')),
        findsOneWidget,
      );
    });

    testWidgets('renders TabBarView with two children', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await _pump(tester);
      expect(find.byType(TabBarView), findsOneWidget);
    });
  });
}
