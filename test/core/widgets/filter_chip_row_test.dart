import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/core/widgets/filter_chip_row.dart';

import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

enum _Status { all, active, inactive, pending }

/// FilterChip requires a Material ancestor. Wrapping in Scaffold guarantees one.
Widget _wrapInScaffold(Widget child) => Scaffold(body: child);

Widget _buildStringRow({
  required List<String> items,
  String? selected,
  required ValueChanged<String?> onSelected,
}) {
  return _wrapInScaffold(
    FilterChipRow<String>(
      items: items,
      selected: selected,
      labelBuilder: (s) => s,
      onSelected: onSelected,
    ),
  );
}

Widget _buildEnumRow({
  required List<_Status> items,
  _Status? selected,
  required ValueChanged<_Status?> onSelected,
}) {
  return _wrapInScaffold(
    FilterChipRow<_Status>(
      items: items,
      selected: selected,
      labelBuilder: (s) => s.name,
      onSelected: onSelected,
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('FilterChipRow', () {
    const stringItems = ['All', 'Active', 'Inactive', 'Pending'];
    const enumItems = _Status.values;

    group('rendering', () {
      testWidgets('renders all provided string items as chips', (tester) async {
        await pumpTestWidget(
          tester,
          _buildStringRow(
            items: stringItems,
            selected: null,
            onSelected: (_) {},
          ),
        );

        for (final item in stringItems) {
          expect(find.text(item), findsOneWidget);
        }
        expect(find.byType(FilterChip), findsNWidgets(stringItems.length));
      });

      testWidgets('renders all enum items as chips', (tester) async {
        await pumpTestWidget(
          tester,
          _buildEnumRow(items: enumItems, selected: null, onSelected: (_) {}),
        );

        for (final item in enumItems) {
          expect(find.text(item.name), findsOneWidget);
        }
        expect(find.byType(FilterChip), findsNWidgets(enumItems.length));
      });

      testWidgets('uses labelBuilder to render chip labels', (tester) async {
        await pumpTestWidget(
          tester,
          _wrapInScaffold(
            FilterChipRow<int>(
              items: const [0, 1, 2],
              selected: null,
              labelBuilder: (i) => 'Item $i',
              onSelected: (_) {},
            ),
          ),
        );

        expect(find.text('Item 0'), findsOneWidget);
        expect(find.text('Item 1'), findsOneWidget);
        expect(find.text('Item 2'), findsOneWidget);
      });
    });

    group('selection state', () {
      testWidgets('first chip is selected when selected is null (all option)', (
        tester,
      ) async {
        await pumpTestWidget(
          tester,
          _buildStringRow(
            items: stringItems,
            selected: null,
            onSelected: (_) {},
          ),
        );

        final chips = tester
            .widgetList<FilterChip>(find.byType(FilterChip))
            .toList();

        expect(chips.first.selected, isTrue);
        for (final chip in chips.skip(1)) {
          expect(chip.selected, isFalse);
        }
      });

      testWidgets('chip matching selected value has selected: true', (
        tester,
      ) async {
        await pumpTestWidget(
          tester,
          _buildStringRow(
            items: stringItems,
            selected: 'Active',
            onSelected: (_) {},
          ),
        );

        final chips = tester
            .widgetList<FilterChip>(find.byType(FilterChip))
            .toList();

        // Index 0 = 'All' (first/null), index 1 = 'Active'
        expect(chips[0].selected, isFalse);
        expect(chips[1].selected, isTrue);
        expect(chips[2].selected, isFalse);
        expect(chips[3].selected, isFalse);
      });

      testWidgets('all chips are unselected except the matching one', (
        tester,
      ) async {
        await pumpTestWidget(
          tester,
          _buildEnumRow(
            items: enumItems,
            selected: _Status.inactive,
            onSelected: (_) {},
          ),
        );

        final chips = tester
            .widgetList<FilterChip>(find.byType(FilterChip))
            .toList();

        expect(chips[0].selected, isFalse); // all
        expect(chips[1].selected, isFalse); // active
        expect(chips[2].selected, isTrue); // inactive
        expect(chips[3].selected, isFalse); // pending
      });
    });

    group('interaction', () {
      testWidgets('tapping first (All) chip calls onSelected with null', (
        tester,
      ) async {
        String? received = 'Active';

        await pumpTestWidget(
          tester,
          _buildStringRow(
            items: stringItems,
            selected: 'Active',
            onSelected: (v) => received = v,
          ),
        );

        await tester.tap(find.byType(FilterChip).first);
        await tester.pump();

        expect(received, isNull);
      });

      testWidgets('tapping a non-first chip calls onSelected with that item', (
        tester,
      ) async {
        String? received;

        await pumpTestWidget(
          tester,
          _buildStringRow(
            items: stringItems,
            selected: null,
            onSelected: (v) => received = v,
          ),
        );

        await tester.tap(find.text('Inactive'));
        await tester.pump();

        expect(received, equals('Inactive'));
      });

      testWidgets('tapping enum chip calls onSelected with the enum value', (
        tester,
      ) async {
        _Status? received;

        await pumpTestWidget(
          tester,
          _buildEnumRow(
            items: enumItems,
            selected: null,
            onSelected: (v) => received = v,
          ),
        );

        await tester.tap(find.text('pending'));
        await tester.pump();

        expect(received, equals(_Status.pending));
      });

      testWidgets(
        'tapping an already-selected non-first chip still calls onSelected',
        (tester) async {
          int callCount = 0;
          String? lastValue;

          await pumpTestWidget(
            tester,
            _buildStringRow(
              items: stringItems,
              selected: 'Active',
              onSelected: (v) {
                callCount++;
                lastValue = v;
              },
            ),
          );

          await tester.tap(find.text('Active'));
          await tester.pump();

          expect(callCount, equals(1));
          expect(lastValue, equals('Active'));
        },
      );
    });

    group('layout', () {
      testWidgets('widget is a fixed-height SizedBox with ListView', (
        tester,
      ) async {
        await pumpTestWidget(
          tester,
          _buildStringRow(
            items: stringItems,
            selected: null,
            onSelected: (_) {},
          ),
        );

        expect(find.byType(SizedBox), findsWidgets);
        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('renders without overflow when many chips are provided', (
        tester,
      ) async {
        await setPhoneViewport(tester);

        final manyItems = List.generate(20, (i) => 'Option $i');

        await pumpTestWidget(
          tester,
          _buildStringRow(items: manyItems, selected: null, onSelected: (_) {}),
        );

        expect(tester.takeException(), isNull);
      });

      testWidgets('renders without overflow on phone viewport', (tester) async {
        await setPhoneViewport(tester);

        await pumpTestWidget(
          tester,
          _buildStringRow(
            items: stringItems,
            selected: null,
            onSelected: (_) {},
          ),
        );

        expect(tester.takeException(), isNull);
      });
    });
  });
}
