import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/notice_resolution/presentation/notice_resolution_screen.dart';
import 'package:ca_app/features/notice_resolution/presentation/widgets/notice_case_tile.dart';
import 'package:ca_app/features/notice_resolution/presentation/widgets/notice_stats_card.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() =>
    const ProviderScope(child: MaterialApp(home: NoticeResolutionScreen()));

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('NoticeResolutionScreen', () {
    testWidgets('renders app bar title', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Notice Resolution Center'), findsOneWidget);
    });

    testWidgets('renders Active Notices tab label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Active Notices'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Resolved tab label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Resolved'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders NoticeStatsCard widget', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(NoticeStatsCard), findsOneWidget);
    });

    testWidgets('renders Total stat label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Total'), findsWidgets);
    });

    testWidgets('renders Critical stat label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Critical'), findsWidgets);
    });

    testWidgets('renders Due This Week stat label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Due This Week'), findsOneWidget);
    });

    testWidgets('renders Closed stat label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Closed'), findsWidgets);
    });

    testWidgets('renders severity filter chips in Active Notices tab', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('renders NoticeCaseTile list items', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(NoticeCaseTile), findsWidgets);
    });

    testWidgets('renders TabBarView', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('renders TabBar', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('switching to Resolved tab is possible', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Resolved'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('renders Scaffold', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('renders folder_open icon in stats', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.folder_open_rounded), findsOneWidget);
    });

    testWidgets('renders error icon for Critical stat', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_rounded), findsWidgets);
    });

    testWidgets('renders check_circle icon for Closed stat', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle_rounded), findsWidgets);
    });
  });
}
