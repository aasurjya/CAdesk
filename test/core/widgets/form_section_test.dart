import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/core/widgets/form_section.dart';

import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildSubject({
  String title = 'Personal Info',
  List<Widget> children = const [],
  IconData? icon,
}) {
  return FormSection(title: title, children: children, icon: icon);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('FormSection', () {
    group('title rendering', () {
      testWidgets('shows title text (no icon)', (tester) async {
        await pumpTestWidget(tester, _buildSubject(title: 'Tax Details'));

        expect(find.text('Tax Details'), findsOneWidget);
      });

      testWidgets('shows title text with icon', (tester) async {
        await pumpTestWidget(
          tester,
          _buildSubject(
            title: 'Income Sources',
            icon: Icons.account_balance_rounded,
          ),
        );

        expect(find.text('Income Sources'), findsOneWidget);
      });

      testWidgets('renders icon in 32x32 container when icon provided', (
        tester,
      ) async {
        await pumpTestWidget(
          tester,
          _buildSubject(title: 'Deductions', icon: Icons.receipt_long_rounded),
        );

        expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);

        // There should be a 32x32 Container wrapping the icon
        final containers = tester.widgetList<Container>(find.byType(Container));
        final iconContainer = containers.where((c) {
          return c.constraints?.maxWidth == 32 &&
              c.constraints?.maxHeight == 32;
        });
        expect(iconContainer.isNotEmpty, isTrue);
      });

      testWidgets('no icon is rendered when icon is null', (tester) async {
        await pumpTestWidget(
          tester,
          _buildSubject(title: 'Bank Details', icon: null),
        );

        // Should not find any Icon widget
        expect(find.byType(Icon), findsNothing);
      });

      testWidgets(
        'title uses Row layout with icon (has Row containing icon and text)',
        (tester) async {
          await pumpTestWidget(
            tester,
            _buildSubject(title: 'Salary', icon: Icons.work_rounded),
          );

          // Row containing icon and title text
          final rows = tester.widgetList<Row>(find.byType(Row)).toList();
          expect(rows.isNotEmpty, isTrue);
        },
      );
    });

    group('children rendering', () {
      testWidgets('renders single child widget', (tester) async {
        await pumpTestWidget(
          tester,
          _buildSubject(
            title: 'Address',
            children: [const Text('123 Main Street')],
          ),
        );

        expect(find.text('123 Main Street'), findsOneWidget);
      });

      testWidgets('renders multiple children', (tester) async {
        await pumpTestWidget(
          tester,
          _buildSubject(
            title: 'Form',
            children: [
              const Text('Field 1'),
              const Text('Field 2'),
              const Text('Field 3'),
            ],
          ),
        );

        expect(find.text('Field 1'), findsOneWidget);
        expect(find.text('Field 2'), findsOneWidget);
        expect(find.text('Field 3'), findsOneWidget);
      });

      testWidgets('renders with empty children list', (tester) async {
        await pumpTestWidget(
          tester,
          _buildSubject(title: 'Empty Section', children: []),
        );

        expect(find.text('Empty Section'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('spacing', () {
      testWidgets('uses Column layout for title + children', (tester) async {
        await pumpTestWidget(
          tester,
          _buildSubject(
            title: 'Spacing Test',
            children: [const Text('A'), const Text('B')],
          ),
        );

        expect(find.byType(Column), findsWidgets);
      });

      testWidgets('SizedBox spacing between multiple children', (tester) async {
        await pumpTestWidget(
          tester,
          _buildSubject(
            title: 'Section',
            children: [
              const Text('Child 1'),
              const Text('Child 2'),
              const Text('Child 3'),
            ],
          ),
        );

        // 3 children → 2 spacers of height 12 between them
        // plus 1 spacer of height 8 between title and children
        final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
        final spacers12 = sizedBoxes.where((s) => s.height == 12).toList();
        expect(spacers12.length, equals(2));
      });

      testWidgets('SizedBox height:8 separates title from children', (
        tester,
      ) async {
        await pumpTestWidget(
          tester,
          _buildSubject(title: 'Section', children: [const Text('Field')]),
        );

        final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
        final titleSpacer = sizedBoxes.where((s) => s.height == 8).toList();
        expect(titleSpacer.isNotEmpty, isTrue);
      });
    });

    group('layout and overflow', () {
      testWidgets('renders without overflow on phone viewport', (tester) async {
        await setPhoneViewport(tester);

        await pumpTestWidget(
          tester,
          _buildSubject(
            title: 'Income',
            icon: Icons.money_rounded,
            children: [
              const Text('Salary'),
              const Text('Business'),
              const Text('Capital Gains'),
            ],
          ),
        );

        expect(tester.takeException(), isNull);
      });

      testWidgets('renders without overflow on tablet viewport', (
        tester,
      ) async {
        await setTabletViewport(tester);

        await pumpTestWidget(
          tester,
          _buildSubject(
            title: 'Deductions',
            children: [const Text('80C'), const Text('80D')],
          ),
        );

        expect(tester.takeException(), isNull);
      });
    });
  });
}
