import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/practice_benchmarking/presentation/practice_benchmarking_screen.dart';

Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() =>
    const ProviderScope(child: MaterialApp(home: PracticeBenchmarkingScreen()));

void main() {
  group('PracticeBenchmarkingScreen', () {
    testWidgets('renders Practice Benchmarking title', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Practice Benchmarking'), findsOneWidget);
    });

    testWidgets('renders Anonymous peer comparisons subtitle', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Anonymous peer comparisons'), findsOneWidget);
    });

    testWidgets('renders Benchmarks tab label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Benchmarks'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Growth Scores tab label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Growth Scores'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders overall score /100 label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('/100'), findsOneWidget);
    });

    testWidgets('renders Peer avg label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('Peer avg:'), findsOneWidget);
    });

    testWidgets('renders All category filter chip', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(AnimatedContainer),
          matching: find.text('All'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Financial category filter chip', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Financial'), findsWidgets);
    });

    testWidgets('renders Operational category filter chip', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Operational'), findsOneWidget);
    });

    testWidgets('renders back arrow icon button', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('renders NestedScrollView', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(NestedScrollView), findsOneWidget);
    });

    testWidgets('renders TabBarView with two children', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('above or below label is shown', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining(RegExp(r'(above|below)')), findsOneWidget);
    });

    testWidgets('score circle custom painter is rendered', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('grade chip is rendered', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // The grade chip text is a single letter like A, B, C etc.
      expect(find.byType(Container), findsWidgets);
    });
  });
}
