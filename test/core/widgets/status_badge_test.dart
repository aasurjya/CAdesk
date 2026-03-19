import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/core/widgets/status_badge.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  group('StatusBadge', () {
    group('content rendering', () {
      testWidgets('renders label text', (tester) async {
        await pumpTestWidget(
          tester,
          const StatusBadge(label: 'Active', color: Colors.green),
        );

        expect(find.text('Active'), findsOneWidget);
      });

      testWidgets('renders short label without overflow', (tester) async {
        await pumpTestWidget(
          tester,
          const StatusBadge(label: 'Ok', color: Colors.blue),
        );

        expect(find.text('Ok'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('renders longer status label', (tester) async {
        await pumpTestWidget(
          tester,
          const StatusBadge(label: 'Under Review', color: Colors.orange),
        );

        expect(find.text('Under Review'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('color application', () {
      testWidgets('text foreground uses the full color', (tester) async {
        const testColor = Colors.red;
        await pumpTestWidget(
          tester,
          const StatusBadge(label: 'Overdue', color: testColor),
        );

        final text = tester.widget<Text>(find.text('Overdue'));
        expect(text.style?.color, testColor);
      });

      testWidgets('container background uses color.withAlpha(26)', (
        tester,
      ) async {
        const testColor = Color(0xFF2196F3); // Colors.blue 500
        await pumpTestWidget(
          tester,
          const StatusBadge(label: 'Draft', color: testColor),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, testColor.withAlpha(26));
      });

      testWidgets('green badge has green-tinted background', (tester) async {
        const green = Color(0xFF4CAF50);
        await pumpTestWidget(
          tester,
          const StatusBadge(label: 'Filed', color: green),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, green.withAlpha(26));
      });

      testWidgets('red badge has red-tinted background', (tester) async {
        const red = Color(0xFFF44336);
        await pumpTestWidget(
          tester,
          const StatusBadge(label: 'Overdue', color: red),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, red.withAlpha(26));
      });

      testWidgets('different colors produce different backgrounds', (
        tester,
      ) async {
        const colorA = Color(0xFF4CAF50); // green
        const colorB = Color(0xFFF44336); // red

        expect(colorA.withAlpha(26), isNot(equals(colorB.withAlpha(26))));
      });
    });

    group('text styling', () {
      testWidgets('text is semibold (weight 600)', (tester) async {
        await pumpTestWidget(
          tester,
          const StatusBadge(label: 'Pending', color: Colors.orange),
        );

        final text = tester.widget<Text>(find.text('Pending'));
        expect(text.style?.fontWeight, FontWeight.w600);
      });

      testWidgets('text font size is 12', (tester) async {
        await pumpTestWidget(
          tester,
          const StatusBadge(label: 'Filed', color: Colors.green),
        );

        final text = tester.widget<Text>(find.text('Filed'));
        expect(text.style?.fontSize, 12);
      });
    });

    group('container shape', () {
      testWidgets('container has rounded border radius', (tester) async {
        await pumpTestWidget(
          tester,
          const StatusBadge(label: 'Active', color: Colors.blue),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.borderRadius, BorderRadius.circular(12));
      });
    });

    group('compact size', () {
      testWidgets('renders without overflow on small labels', (tester) async {
        await pumpTestWidget(
          tester,
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [StatusBadge(label: 'GST', color: Colors.indigo)],
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('GST'), findsOneWidget);
      });
    });
  });
}
