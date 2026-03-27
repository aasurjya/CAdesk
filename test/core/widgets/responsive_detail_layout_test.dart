import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/core/widgets/responsive_detail_layout.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _listKey = Key('list_pane');
const _detailKey = Key('detail_pane');

/// Wraps the widget with an explicit MediaQuery so ResponsiveDetailLayout
/// sees the desired [width]. Using MediaQuery() directly is necessary because
/// setSurfaceSize() does not propagate to MediaQuery.sizeOf() in Flutter tests.
Widget _buildWithWidth(double width, {double? breakpoint}) {
  final layout = breakpoint != null
      ? ResponsiveDetailLayout(
          breakpoint: breakpoint,
          listPane: const SizedBox(key: _listKey, child: Text('List')),
          detailPane: const SizedBox(key: _detailKey, child: Text('Detail')),
        )
      : const ResponsiveDetailLayout(
          listPane: SizedBox(key: _listKey, child: Text('List')),
          detailPane: SizedBox(key: _detailKey, child: Text('Detail')),
        );

  return ProviderScope(
    child: MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: Size(width, 800)),
        child: layout,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ResponsiveDetailLayout', () {
    group('narrow screen (width < default breakpoint 900)', () {
      testWidgets('only list pane is shown at 390px', (tester) async {
        await tester.pumpWidget(_buildWithWidth(390));
        await tester.pumpAndSettle();

        expect(find.byKey(_listKey), findsOneWidget);
        expect(find.text('List'), findsOneWidget);
      });

      testWidgets('detail pane is NOT shown at 390px', (tester) async {
        await tester.pumpWidget(_buildWithWidth(390));
        await tester.pumpAndSettle();

        expect(find.byKey(_detailKey), findsNothing);
        expect(find.text('Detail'), findsNothing);
      });

      testWidgets('no Row rendered at 390px', (tester) async {
        await tester.pumpWidget(_buildWithWidth(390));
        await tester.pumpAndSettle();

        expect(find.byType(Row), findsNothing);
      });

      testWidgets('detail pane NOT shown at 899px (just below breakpoint)', (
        tester,
      ) async {
        await tester.pumpWidget(_buildWithWidth(899));
        await tester.pumpAndSettle();

        expect(find.byKey(_detailKey), findsNothing);
      });
    });

    group('wide screen (width >= default breakpoint 900)', () {
      testWidgets('both list and detail panes shown at 900px', (tester) async {
        await tester.pumpWidget(_buildWithWidth(900));
        await tester.pumpAndSettle();

        expect(find.byKey(_listKey), findsOneWidget);
        expect(find.byKey(_detailKey), findsOneWidget);
        expect(find.text('List'), findsOneWidget);
        expect(find.text('Detail'), findsOneWidget);
      });

      testWidgets('both panes shown at 1000px', (tester) async {
        await tester.pumpWidget(_buildWithWidth(1000));
        await tester.pumpAndSettle();

        expect(find.byKey(_listKey), findsOneWidget);
        expect(find.byKey(_detailKey), findsOneWidget);
      });

      testWidgets('side-by-side layout uses Row at 1000px', (tester) async {
        await tester.pumpWidget(_buildWithWidth(1000));
        await tester.pumpAndSettle();

        expect(find.byType(Row), findsOneWidget);
      });

      testWidgets('VerticalDivider is rendered between panes at 1000px', (
        tester,
      ) async {
        await tester.pumpWidget(_buildWithWidth(1000));
        await tester.pumpAndSettle();

        expect(find.byType(VerticalDivider), findsOneWidget);
      });

      testWidgets('both panes shown at 1440px (desktop)', (tester) async {
        await tester.pumpWidget(_buildWithWidth(1440));
        await tester.pumpAndSettle();

        expect(find.byKey(_listKey), findsOneWidget);
        expect(find.byKey(_detailKey), findsOneWidget);
      });
    });

    group('custom breakpoint', () {
      testWidgets(
        'detail pane NOT shown when width < custom breakpoint (800 < 1200)',
        (tester) async {
          await tester.pumpWidget(_buildWithWidth(800, breakpoint: 1200));
          await tester.pumpAndSettle();

          expect(find.byKey(_detailKey), findsNothing);
        },
      );

      testWidgets(
        'both panes shown when width >= custom breakpoint (800 >= 600)',
        (tester) async {
          await tester.pumpWidget(_buildWithWidth(800, breakpoint: 600));
          await tester.pumpAndSettle();

          expect(find.byKey(_listKey), findsOneWidget);
          expect(find.byKey(_detailKey), findsOneWidget);
        },
      );

      testWidgets('at exactly breakpoint (900 >= 900) — wide layout', (
        tester,
      ) async {
        // ResponsiveDetailLayout shows detail when width >= breakpoint
        await tester.pumpWidget(_buildWithWidth(900, breakpoint: 900));
        await tester.pumpAndSettle();

        expect(find.byKey(_listKey), findsOneWidget);
        expect(find.byKey(_detailKey), findsOneWidget);
      });

      testWidgets('just below breakpoint (899 < 900) — narrow layout', (
        tester,
      ) async {
        await tester.pumpWidget(_buildWithWidth(899, breakpoint: 900));
        await tester.pumpAndSettle();

        expect(find.byKey(_detailKey), findsNothing);
      });
    });

    group('listPane always rendered', () {
      testWidgets('listPane visible on narrow screen', (tester) async {
        await tester.pumpWidget(_buildWithWidth(400));
        await tester.pumpAndSettle();

        expect(find.byKey(_listKey), findsOneWidget);
      });

      testWidgets('listPane visible on wide screen', (tester) async {
        await tester.pumpWidget(_buildWithWidth(1200));
        await tester.pumpAndSettle();

        expect(find.byKey(_listKey), findsOneWidget);
      });
    });

    group('layout correctness', () {
      testWidgets('renders without overflow on narrow screen', (tester) async {
        await tester.pumpWidget(_buildWithWidth(390));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('renders without overflow on wide screen', (tester) async {
        await tester.pumpWidget(_buildWithWidth(1200));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    });
  });
}
