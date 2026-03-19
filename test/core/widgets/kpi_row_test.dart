import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/core/widgets/kpi_row.dart';
import 'package:ca_app/core/widgets/summary_card.dart';

import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

SummaryCard _card(String label, String value) => SummaryCard(
  label: label,
  value: value,
  icon: Icons.info_outline_rounded,
  color: Colors.blue,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('KpiRow', () {
    group('empty state', () {
      testWidgets('returns SizedBox.shrink when cards list is empty', (
        tester,
      ) async {
        await pumpTestWidget(tester, const KpiRow(cards: []));

        expect(find.byType(Row), findsNothing);
        // SizedBox.shrink is still a SizedBox
        expect(find.byType(KpiRow), findsOneWidget);
      });
    });

    group('single card', () {
      testWidgets('renders one card', (tester) async {
        await pumpTestWidget(tester, KpiRow(cards: [_card('Total', '10')]));

        expect(find.byType(SummaryCard), findsOneWidget);
        expect(find.text('Total'), findsOneWidget);
        expect(find.text('10'), findsOneWidget);
      });

      testWidgets('wraps in a Row', (tester) async {
        await pumpTestWidget(tester, KpiRow(cards: [_card('A', '1')]));

        expect(find.byType(Row), findsOneWidget);
      });
    });

    group('multiple cards', () {
      testWidgets('renders two cards with their labels and values', (
        tester,
      ) async {
        await setPhoneViewport(tester);

        await pumpTestWidget(
          tester,
          KpiRow(cards: [_card('Filed', '5'), _card('Pending', '3')]),
        );

        expect(find.byType(SummaryCard), findsNWidgets(2));
        expect(find.text('Filed'), findsOneWidget);
        expect(find.text('Pending'), findsOneWidget);
        expect(find.text('5'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
      });

      testWidgets('renders three cards', (tester) async {
        await setPhoneViewport(tester);

        await pumpTestWidget(
          tester,
          KpiRow(cards: [_card('A', '1'), _card('B', '2'), _card('C', '3')]),
        );

        expect(find.byType(SummaryCard), findsNWidgets(3));
        expect(find.text('A'), findsOneWidget);
        expect(find.text('B'), findsOneWidget);
        expect(find.text('C'), findsOneWidget);
      });

      testWidgets('renders four cards', (tester) async {
        await setPhoneViewport(tester);

        await pumpTestWidget(
          tester,
          KpiRow(
            cards: [
              _card('W', '1'),
              _card('X', '2'),
              _card('Y', '3'),
              _card('Z', '4'),
            ],
          ),
        );

        expect(find.byType(SummaryCard), findsNWidgets(4));
      });

      testWidgets('cards are arranged horizontally in a Row', (tester) async {
        await setTabletViewport(tester);

        await pumpTestWidget(
          tester,
          KpiRow(cards: [_card('Left', '10'), _card('Right', '20')]),
        );

        final row = tester.widget<Row>(find.byType(Row));
        // Row children include SummaryCards and SizedBox spacers
        expect(row.children.isNotEmpty, isTrue);
        expect(find.byType(SummaryCard), findsNWidgets(2));
      });

      testWidgets('spacing SizedBoxes are inserted between cards', (
        tester,
      ) async {
        await setPhoneViewport(tester);

        await pumpTestWidget(
          tester,
          KpiRow(cards: [_card('A', '1'), _card('B', '2'), _card('C', '3')]),
        );

        // 3 cards → 2 spacing SizedBox(width:8) inside the Row
        final row = tester.widget<Row>(find.byType(Row));
        final spacers = row.children
            .whereType<SizedBox>()
            .where((s) => s.width == 8.0)
            .toList();
        expect(spacers.length, equals(2));
      });
    });

    group('layout padding', () {
      testWidgets('has outer Padding widget', (tester) async {
        await pumpTestWidget(tester, KpiRow(cards: [_card('T', '1')]));

        expect(find.byType(Padding), findsWidgets);
      });

      testWidgets('renders without overflow on phone viewport', (tester) async {
        await setPhoneViewport(tester);

        await pumpTestWidget(
          tester,
          KpiRow(cards: [_card('A', '1'), _card('B', '2'), _card('C', '3')]),
        );

        expect(tester.takeException(), isNull);
      });

      testWidgets('renders without overflow on tablet viewport', (
        tester,
      ) async {
        await setTabletViewport(tester);

        await pumpTestWidget(
          tester,
          KpiRow(
            cards: [
              _card('W', '1'),
              _card('X', '2'),
              _card('Y', '3'),
              _card('Z', '4'),
            ],
          ),
        );

        expect(tester.takeException(), isNull);
      });
    });
  });
}
