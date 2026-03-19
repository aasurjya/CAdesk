/// Phase 8: Adaptive Layout Verification
///
/// Verifies that [ResponsiveDetailLayout] renders the correct chrome
/// at each of the three target viewport widths:
///   - Phone (390px) — below 900 breakpoint → single pane (list only)
///   - Tablet (820px) — below 900 breakpoint → single pane (list only)
///   - Desktop (1440px) — above 900 breakpoint → side-by-side master-detail
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/core/widgets/responsive_detail_layout.dart';

void main() {
  Widget buildLayout({required double width, double breakpoint = 900}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: Size(width, 900)),
        child: Scaffold(
          body: ResponsiveDetailLayout(
            listPane: const SizedBox(key: Key('list'), width: 100, height: 100),
            detailPane: const SizedBox(
              key: Key('detail'),
              width: 100,
              height: 100,
            ),
            breakpoint: breakpoint,
          ),
        ),
      ),
    );
  }

  group('ResponsiveDetailLayout adaptive layout verification', () {
    group('phone viewport (390px — below 900 breakpoint)', () {
      testWidgets('renders only the list pane', (tester) async {
        await tester.pumpWidget(buildLayout(width: 390));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('list')), findsOneWidget);
        expect(find.byKey(const Key('detail')), findsNothing);
      });

      testWidgets('no VerticalDivider present', (tester) async {
        await tester.pumpWidget(buildLayout(width: 390));
        await tester.pumpAndSettle();

        expect(find.byType(VerticalDivider), findsNothing);
      });

      testWidgets('no 3-child Row layout present', (tester) async {
        await tester.pumpWidget(buildLayout(width: 390));
        await tester.pumpAndSettle();

        final rows = tester.widgetList<Row>(find.byType(Row)).toList();
        final hasMasterDetailRow = rows.any((row) => row.children.length >= 3);
        expect(hasMasterDetailRow, isFalse);
      });
    });

    group('tablet viewport (820px — below default 900 breakpoint)', () {
      testWidgets('shows only list pane at 820px', (tester) async {
        await tester.pumpWidget(buildLayout(width: 820));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('list')), findsOneWidget);
        expect(find.byKey(const Key('detail')), findsNothing);
      });

      testWidgets('shows side-by-side at 1000px (tablet landscape)', (
        tester,
      ) async {
        await tester.pumpWidget(buildLayout(width: 1000));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('list')), findsOneWidget);
        expect(find.byKey(const Key('detail')), findsOneWidget);
        expect(find.byType(VerticalDivider), findsOneWidget);
      });
    });

    group('desktop viewport (1440px — above breakpoint)', () {
      testWidgets('shows both list and detail panes', (tester) async {
        await tester.pumpWidget(buildLayout(width: 1440));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('list')), findsOneWidget);
        expect(find.byKey(const Key('detail')), findsOneWidget);
      });

      testWidgets('renders VerticalDivider between panes', (tester) async {
        await tester.pumpWidget(buildLayout(width: 1440));
        await tester.pumpAndSettle();

        expect(find.byType(VerticalDivider), findsOneWidget);
      });

      testWidgets('lays out panes in a 3-child Row (list + divider + detail)', (
        tester,
      ) async {
        await tester.pumpWidget(buildLayout(width: 1440));
        await tester.pumpAndSettle();

        final rows = tester.widgetList<Row>(find.byType(Row)).toList();
        final masterDetailRow = rows.firstWhere(
          (row) => row.children.length == 3,
          orElse: () =>
              throw TestFailure('Expected a 3-child Row for master-detail'),
        );
        expect(masterDetailRow.children, hasLength(3));
      });
    });

    group('custom breakpoint', () {
      testWidgets('breakpoint=600 shows side-by-side at 700px', (tester) async {
        await tester.pumpWidget(buildLayout(width: 700, breakpoint: 600));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('list')), findsOneWidget);
        expect(find.byKey(const Key('detail')), findsOneWidget);
      });

      testWidgets('at exactly breakpoint (900) shows side-by-side', (
        tester,
      ) async {
        // 900 is NOT < 900, so master-detail renders
        await tester.pumpWidget(buildLayout(width: 900));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('list')), findsOneWidget);
        expect(find.byKey(const Key('detail')), findsOneWidget);
      });
    });

    group('overflow safety', () {
      testWidgets('no overflow at minimum phone width (320px)', (tester) async {
        await tester.pumpWidget(buildLayout(width: 320));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('no overflow at ultra-wide desktop (2560px)', (tester) async {
        await tester.pumpWidget(buildLayout(width: 2560));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    });
  });
}
