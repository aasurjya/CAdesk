import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/core/widgets/summary_card.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  group('SummaryCard', () {
    Widget buildSubject({
      String label = 'Total Clients',
      String value = '42',
      IconData icon = Icons.people_rounded,
      Color color = Colors.blue,
    }) {
      // SummaryCard wraps itself in Expanded, so it needs a Row parent.
      return Row(
        children: [
          SummaryCard(label: label, value: value, icon: icon, color: color),
        ],
      );
    }

    group('content rendering', () {
      testWidgets('renders label text', (tester) async {
        await pumpTestWidget(tester, buildSubject(label: 'Total Clients'));

        expect(find.text('Total Clients'), findsOneWidget);
      });

      testWidgets('renders value text', (tester) async {
        await pumpTestWidget(tester, buildSubject(value: '99'));

        expect(find.text('99'), findsOneWidget);
      });

      testWidgets('renders provided icon', (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(icon: Icons.description_rounded),
        );

        expect(find.byIcon(Icons.description_rounded), findsOneWidget);
      });

      testWidgets('applies color to icon', (tester) async {
        const testColor = Colors.red;
        await pumpTestWidget(
          tester,
          buildSubject(icon: Icons.star, color: testColor),
        );

        final icon = tester.widget<Icon>(find.byIcon(Icons.star));
        expect(icon.color, testColor);
      });

      testWidgets('applies color to value text', (tester) async {
        const testColor = Colors.green;
        await pumpTestWidget(
          tester,
          buildSubject(value: '7', color: testColor),
        );

        final textWidgets = tester.widgetList<Text>(find.text('7'));
        final valueText = textWidgets.first;
        expect(valueText.style?.color, testColor);
      });
    });

    group('layout', () {
      testWidgets('renders card widget', (tester) async {
        await pumpTestWidget(tester, buildSubject());

        expect(find.byType(Card), findsOneWidget);
      });

      testWidgets('renders without overflow in phone viewport', (tester) async {
        await setPhoneViewport(tester);
        await pumpTestWidget(tester, buildSubject());

        expect(tester.takeException(), isNull);
        expect(find.byType(SummaryCard), findsOneWidget);
      });

      testWidgets('renders without overflow in tablet viewport', (
        tester,
      ) async {
        await setTabletViewport(tester);
        await pumpTestWidget(tester, buildSubject());

        expect(tester.takeException(), isNull);
        expect(find.byType(SummaryCard), findsOneWidget);
      });

      testWidgets('multiple cards distribute evenly in a row', (tester) async {
        await setPhoneViewport(tester);
        await pumpTestWidget(
          tester,
          Row(
            children: [
              SummaryCard(
                label: 'Clients',
                value: '10',
                icon: Icons.people_rounded,
                color: Colors.blue,
              ),
              SummaryCard(
                label: 'Filed',
                value: '5',
                icon: Icons.check_circle_rounded,
                color: Colors.green,
              ),
            ],
          ),
        );

        expect(find.byType(SummaryCard), findsNWidgets(2));
        expect(find.text('Clients'), findsOneWidget);
        expect(find.text('Filed'), findsOneWidget);
      });
    });

    group('different values', () {
      testWidgets('renders large number values', (tester) async {
        await pumpTestWidget(tester, buildSubject(value: '1,234'));

        expect(find.text('1,234'), findsOneWidget);
      });

      testWidgets('renders currency values', (tester) async {
        await pumpTestWidget(tester, buildSubject(value: '₹12.5L'));

        expect(find.text('₹12.5L'), findsOneWidget);
      });

      testWidgets('renders zero value', (tester) async {
        await pumpTestWidget(tester, buildSubject(value: '0'));

        expect(find.text('0'), findsOneWidget);
      });
    });
  });
}
