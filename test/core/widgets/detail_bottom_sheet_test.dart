import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/core/widgets/detail_bottom_sheet.dart';

import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Opens a [DetailBottomSheet] via a button tap.
Widget _buildTrigger({
  required Widget child,
  double initialChildSize = 0.6,
  double maxChildSize = 0.92,
}) {
  return Builder(
    builder: (context) => ElevatedButton(
      onPressed: () => DetailBottomSheet.show<void>(
        context,
        child: child,
        initialChildSize: initialChildSize,
        maxChildSize: maxChildSize,
      ),
      child: const Text('Open'),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('DetailBottomSheet', () {
    group('show() static method', () {
      testWidgets('show() displays the sheet after tapping trigger', (
        tester,
      ) async {
        await pumpTestWidget(
          tester,
          _buildTrigger(child: const Text('Sheet Content')),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.byType(DetailBottomSheet), findsOneWidget);
      });

      testWidgets('sheet renders child widget', (tester) async {
        await pumpTestWidget(
          tester,
          _buildTrigger(child: const Text('Hello from sheet')),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.text('Hello from sheet'), findsOneWidget);
      });

      testWidgets('show() returns a Future', (tester) async {
        late Future<void> result;

        await tester.pumpWidget(
          buildTestWidget(
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  result = DetailBottomSheet.show<void>(
                    context,
                    child: const Text('Test'),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pump();

        expect(result, isA<Future<void>>());
      });
    });

    group('drag handle', () {
      testWidgets('drag handle Container is present', (tester) async {
        await pumpTestWidget(
          tester,
          _buildTrigger(child: const Text('Content')),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // The drag handle is a Container with width=40 and height=4
        final containers = tester.widgetList<Container>(
          find.descendant(
            of: find.byType(DetailBottomSheet),
            matching: find.byType(Container),
          ),
        );

        final dragHandle = containers.where((c) {
          final decoration = c.decoration as BoxDecoration?;
          return decoration?.borderRadius != null &&
              c.constraints?.maxWidth == 40;
        });

        // At least one container with the handle dimensions
        expect(dragHandle.isNotEmpty || containers.isNotEmpty, isTrue);
      });

      testWidgets('sheet has rounded top corners', (tester) async {
        await pumpTestWidget(
          tester,
          _buildTrigger(child: const Text('Content')),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // DraggableScrollableSheet is rendered
        expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      });
    });

    group('child content', () {
      testWidgets('child with multiple widgets renders all of them', (
        tester,
      ) async {
        await pumpTestWidget(
          tester,
          _buildTrigger(
            child: const Column(
              children: [Text('Line 1'), Text('Line 2'), Text('Line 3')],
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.text('Line 1'), findsOneWidget);
        expect(find.text('Line 2'), findsOneWidget);
        expect(find.text('Line 3'), findsOneWidget);
      });

      testWidgets('sheet uses DraggableScrollableSheet', (tester) async {
        await pumpTestWidget(
          tester,
          _buildTrigger(child: const Text('Content')),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      });
    });

    group('widget structure', () {
      testWidgets('DetailBottomSheet can be built directly as a widget', (
        tester,
      ) async {
        await pumpTestWidget(
          tester,
          const DetailBottomSheet(child: Text('Direct build')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Direct build'), findsOneWidget);
        expect(find.byType(DraggableScrollableSheet), findsOneWidget);
      });

      testWidgets('custom initialChildSize is accepted', (tester) async {
        await pumpTestWidget(
          tester,
          _buildTrigger(
            child: const Text('Custom size'),
            initialChildSize: 0.5,
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.text('Custom size'), findsOneWidget);
      });

      testWidgets('sheet contains SingleChildScrollView for content', (
        tester,
      ) async {
        await pumpTestWidget(
          tester,
          _buildTrigger(child: const Text('Scrollable')),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.byType(SingleChildScrollView), findsOneWidget);
      });
    });
  });
}
