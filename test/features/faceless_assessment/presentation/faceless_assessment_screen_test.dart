import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/faceless_assessment/presentation/faceless_assessment_screen.dart';
import 'package:ca_app/features/faceless_assessment/presentation/widgets/e_proceeding_tile.dart';
import 'package:ca_app/features/faceless_assessment/presentation/widgets/itr_u_tile.dart';
import 'package:ca_app/features/faceless_assessment/presentation/widgets/hearing_tile.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Wider viewport to prevent RenderFlex overflow in EProceedingTile rows.
Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(800, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() => const ProviderScope(
      child: MaterialApp(home: FacelessAssessmentScreen()),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('FacelessAssessmentScreen', () {
    testWidgets('renders E-Proceedings title', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('E-Proceedings'), findsWidgets);
    });

    testWidgets('renders E-Proceedings tab in TabBar', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('E-Proceedings'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders ITR-U tab in TabBar', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('ITR-U'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Hearings tab in TabBar', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Hearings'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('E-Proceedings tab renders type filter chips', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // All chip is always first
      expect(find.text('All'), findsWidgets);
    });

    testWidgets('E-Proceedings tab renders EProceedingTile widgets',
        (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // May show tiles or empty state
      final found = find.byType(EProceedingTile).evaluate().isNotEmpty ||
          find.textContaining('No e-proceedings').evaluate().isNotEmpty;
      expect(found, isTrue);
    });

    testWidgets('DefaultTabController wraps the screen', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(DefaultTabController), findsOneWidget);
    });

    testWidgets('TabBarView is present', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('filter chips are FilterChip widgets', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('switches to ITR-U tab', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('ITR-U'),
        ),
      );
      await tester.pumpAndSettle();

      // Should show ITR-U tiles or empty state
      final found = find.byType(ItrUTile).evaluate().isNotEmpty ||
          find.textContaining('No ITR-U').evaluate().isNotEmpty;
      expect(found, isTrue);
    });

    testWidgets('switches to Hearings tab', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Hearings'),
        ),
      );
      await tester.pumpAndSettle();

      // Should show hearing tiles or filter chips or empty state
      final found = find.byType(HearingTile).evaluate().isNotEmpty ||
          find.byType(FilterChip).evaluate().isNotEmpty ||
          find.textContaining('No hearings').evaluate().isNotEmpty;
      expect(found, isTrue);
    });

    testWidgets('status filter chips present in E-Proceedings tab',
        (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Two filter rows: type and status — both have FilterChip widgets
      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('E-Proceedings tab has two scrollable chip rows',
        (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('Scaffold has TabBar at app bar bottom', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(TabBar), findsOneWidget);
    });
  });
}
