import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/core/widgets/period_selector.dart';

import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _defaultPeriods = ['FY 2022-23', 'FY 2023-24', 'FY 2024-25'];

/// PopupMenuButton uses InkResponse which requires a Material ancestor.
/// Wrapping in Scaffold provides one.
Widget _buildSubject({
  String selected = 'FY 2024-25',
  List<String> periods = _defaultPeriods,
  required ValueChanged<String> onChanged,
}) {
  return Scaffold(
    body: Center(
      child: PeriodSelector(
        selected: selected,
        periods: periods,
        onChanged: onChanged,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('PeriodSelector', () {
    group('rendering selected period', () {
      testWidgets('shows current selected period label', (tester) async {
        await pumpTestWidget(
          tester,
          _buildSubject(selected: 'FY 2024-25', onChanged: (_) {}),
        );

        expect(find.text('FY 2024-25'), findsOneWidget);
      });

      testWidgets('shows different selected period label', (tester) async {
        await pumpTestWidget(
          tester,
          _buildSubject(selected: 'FY 2022-23', onChanged: (_) {}),
        );

        expect(find.text('FY 2022-23'), findsOneWidget);
      });

      testWidgets('dropdown arrow icon is shown', (tester) async {
        await pumpTestWidget(tester, _buildSubject(onChanged: (_) {}));

        expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
      });

      testWidgets('uses PopupMenuButton widget', (tester) async {
        await pumpTestWidget(tester, _buildSubject(onChanged: (_) {}));

        expect(find.byType(PopupMenuButton<String>), findsOneWidget);
      });
    });

    group('popup menu', () {
      testWidgets('tapping opens popup menu with all period options', (
        tester,
      ) async {
        await pumpTestWidget(tester, _buildSubject(onChanged: (_) {}));

        await tester.tap(find.byType(PopupMenuButton<String>));
        await tester.pumpAndSettle();

        // All three periods appear in the menu
        expect(find.text('FY 2022-23'), findsOneWidget);
        expect(find.text('FY 2023-24'), findsOneWidget);
        expect(find.text('FY 2024-25'), findsWidgets);
      });

      testWidgets('selected period shows a check icon in menu', (tester) async {
        await pumpTestWidget(
          tester,
          _buildSubject(selected: 'FY 2024-25', onChanged: (_) {}),
        );

        await tester.tap(find.byType(PopupMenuButton<String>));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      });

      testWidgets('non-selected periods do not have a check icon', (
        tester,
      ) async {
        await pumpTestWidget(
          tester,
          _buildSubject(selected: 'FY 2024-25', onChanged: (_) {}),
        );

        await tester.tap(find.byType(PopupMenuButton<String>));
        await tester.pumpAndSettle();

        // Only one check icon for the selected period
        expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      });

      testWidgets('selecting a period calls onChanged with the chosen value', (
        tester,
      ) async {
        String? selected;

        await pumpTestWidget(
          tester,
          _buildSubject(selected: 'FY 2024-25', onChanged: (v) => selected = v),
        );

        await tester.tap(find.byType(PopupMenuButton<String>));
        await tester.pumpAndSettle();

        await tester.tap(find.text('FY 2022-23'));
        await tester.pumpAndSettle();

        expect(selected, equals('FY 2022-23'));
      });

      testWidgets('selecting current period still calls onChanged', (
        tester,
      ) async {
        int callCount = 0;
        String? lastValue;

        await pumpTestWidget(
          tester,
          _buildSubject(
            selected: 'FY 2024-25',
            onChanged: (v) {
              callCount++;
              lastValue = v;
            },
          ),
        );

        await tester.tap(find.byType(PopupMenuButton<String>));
        await tester.pumpAndSettle();

        // Tap the currently selected period in the menu
        // Since 'FY 2024-25' appears in both the button and menu, find last
        await tester.tap(find.text('FY 2024-25').last);
        await tester.pumpAndSettle();

        expect(callCount, equals(1));
        expect(lastValue, equals('FY 2024-25'));
      });
    });

    group('different period lists', () {
      testWidgets('shows all provided financial year options in menu', (
        tester,
      ) async {
        const periods = [
          'FY 2020-21',
          'FY 2021-22',
          'FY 2022-23',
          'FY 2023-24',
          'FY 2024-25',
        ];

        await pumpTestWidget(
          tester,
          _buildSubject(
            selected: 'FY 2024-25',
            periods: periods,
            onChanged: (_) {},
          ),
        );

        await tester.tap(find.byType(PopupMenuButton<String>));
        await tester.pumpAndSettle();

        for (final period in periods) {
          expect(find.text(period), findsWidgets);
        }
      });

      testWidgets('works with a single period option', (tester) async {
        await pumpTestWidget(
          tester,
          _buildSubject(
            selected: 'FY 2024-25',
            periods: const ['FY 2024-25'],
            onChanged: (_) {},
          ),
        );

        expect(find.text('FY 2024-25'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('layout', () {
      testWidgets('renders without overflow on phone viewport', (tester) async {
        await setPhoneViewport(tester);

        await pumpTestWidget(tester, _buildSubject(onChanged: (_) {}));

        expect(tester.takeException(), isNull);
      });

      testWidgets('renders without overflow on tablet viewport', (
        tester,
      ) async {
        await setTabletViewport(tester);

        await pumpTestWidget(tester, _buildSubject(onChanged: (_) {}));

        expect(tester.takeException(), isNull);
      });
    });
  });
}
