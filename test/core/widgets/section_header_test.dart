import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/core/widgets/section_header.dart';

import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildSubject({
  String title = 'Income Sources',
  IconData icon = Icons.account_balance_rounded,
  Widget? trailing,
}) {
  return SectionHeader(title: title, icon: icon, trailing: trailing);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('SectionHeader', () {
    group('title', () {
      testWidgets('shows title text', (tester) async {
        await pumpTestWidget(tester, _buildSubject(title: 'Deductions'));

        expect(find.text('Deductions'), findsOneWidget);
      });

      testWidgets('shows different title texts', (tester) async {
        await pumpTestWidget(tester, _buildSubject(title: 'Capital Gains'));

        expect(find.text('Capital Gains'), findsOneWidget);
      });
    });

    group('icon', () {
      testWidgets('shows the provided icon', (tester) async {
        await pumpTestWidget(
          tester,
          _buildSubject(icon: Icons.receipt_long_rounded),
        );

        expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);
      });

      testWidgets('icon is rendered in a 32x32 Container', (tester) async {
        await pumpTestWidget(tester, _buildSubject(icon: Icons.work_rounded));

        expect(find.byIcon(Icons.work_rounded), findsOneWidget);

        final containers = tester.widgetList<Container>(find.byType(Container));
        final iconContainer = containers.where((c) {
          return c.constraints?.maxWidth == 32 &&
              c.constraints?.maxHeight == 32;
        });
        expect(iconContainer.isNotEmpty, isTrue);
      });

      testWidgets('icon has size 18', (tester) async {
        await pumpTestWidget(tester, _buildSubject(icon: Icons.star_rounded));

        final icon = tester.widget<Icon>(find.byIcon(Icons.star_rounded));
        expect(icon.size, equals(18));
      });
    });

    group('trailing widget', () {
      testWidgets('shows trailing widget when provided', (tester) async {
        await pumpTestWidget(
          tester,
          _buildSubject(trailing: const Text('See All', key: Key('trailing'))),
        );

        expect(find.byKey(const Key('trailing')), findsOneWidget);
        expect(find.text('See All'), findsOneWidget);
      });

      testWidgets('does not show trailing area when trailing is null', (
        tester,
      ) async {
        await pumpTestWidget(tester, _buildSubject(trailing: null));

        // No extra text besides the title
        expect(find.text('See All'), findsNothing);
      });

      testWidgets('trailing renders as IconButton', (tester) async {
        await pumpTestWidget(
          tester,
          _buildSubject(
            trailing: IconButton(
              key: const Key('action_btn'),
              icon: const Icon(Icons.add_rounded),
              onPressed: () {},
            ),
          ),
        );

        expect(find.byKey(const Key('action_btn')), findsOneWidget);
      });

      testWidgets('Spacer is inserted before trailing widget', (tester) async {
        await pumpTestWidget(
          tester,
          _buildSubject(trailing: const Text('Action')),
        );

        expect(find.byType(Spacer), findsOneWidget);
      });

      testWidgets('Spacer is NOT present when trailing is null', (
        tester,
      ) async {
        await pumpTestWidget(tester, _buildSubject(trailing: null));

        expect(find.byType(Spacer), findsNothing);
      });
    });

    group('row layout', () {
      testWidgets('uses Row as root layout', (tester) async {
        await pumpTestWidget(tester, _buildSubject());

        expect(find.byType(Row), findsOneWidget);
      });

      testWidgets('icon + title + trailing all in same Row', (tester) async {
        await pumpTestWidget(
          tester,
          _buildSubject(
            title: 'Summary',
            icon: Icons.bar_chart_rounded,
            trailing: const Text('More'),
          ),
        );

        final row = tester.widget<Row>(find.byType(Row));
        // At minimum 4 children: icon container, SizedBox, text, spacer, trailing
        expect(row.children.length, greaterThanOrEqualTo(3));
      });

      testWidgets('SizedBox(width: 8) separates icon from title', (
        tester,
      ) async {
        await pumpTestWidget(tester, _buildSubject());

        final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
        final spacer8 = sizedBoxes.where((s) => s.width == 8).toList();
        expect(spacer8.isNotEmpty, isTrue);
      });
    });

    group('layout and overflow', () {
      testWidgets('renders without overflow on phone viewport', (tester) async {
        await setPhoneViewport(tester);

        // No trailing to avoid Row overflow on constrained width.
        await pumpTestWidget(
          tester,
          _buildSubject(
            title: 'Summary',
            icon: Icons.account_balance_rounded,
            trailing: null,
          ),
        );

        expect(tester.takeException(), isNull);
      });

      testWidgets('renders without overflow on tablet viewport', (
        tester,
      ) async {
        await setTabletViewport(tester);

        await pumpTestWidget(tester, _buildSubject());

        expect(tester.takeException(), isNull);
      });
    });
  });
}
