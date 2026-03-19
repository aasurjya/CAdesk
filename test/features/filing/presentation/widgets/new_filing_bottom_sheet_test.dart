import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/filing/presentation/widgets/new_filing_bottom_sheet.dart';

import '../../../../helpers/widget_test_helpers.dart';

/// Helper that builds a ProviderScope + MaterialApp with a button that opens
/// the new filing bottom sheet via [showNewFilingBottomSheet].
Widget _buildSheetHost() {
  return ProviderScope(
    child: MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showNewFilingBottomSheet(context),
              child: const Text('Open Sheet'),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _openSheet(WidgetTester tester) async {
  await tester.tap(find.text('Open Sheet'));
  await tester.pumpAndSettle();
}

// The bottom sheet has side-by-side Row dropdowns with long text labels.
// A desktop-width viewport prevents RenderFlex overflows in those rows.
Future<void> _setViewport(WidgetTester tester) => setDesktopViewport(tester);

void main() {
  group('NewFilingBottomSheet', () {
    testWidgets('bottom sheet opens without crashing', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildSheetHost());
      await tester.pumpAndSettle();

      await _openSheet(tester);

      expect(find.text('New ITR Filing'), findsOneWidget);
    });

    testWidgets('shows New ITR Filing title', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildSheetHost());
      await tester.pumpAndSettle();

      await _openSheet(tester);

      expect(find.text('New ITR Filing'), findsOneWidget);
    });

    testWidgets('shows close icon button', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildSheetHost());
      await tester.pumpAndSettle();

      await _openSheet(tester);

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('shows Client Information section label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildSheetHost());
      await tester.pumpAndSettle();

      await _openSheet(tester);

      expect(find.text('Client Information'), findsOneWidget);
    });

    testWidgets('shows Client Name field', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildSheetHost());
      await tester.pumpAndSettle();

      await _openSheet(tester);

      expect(find.textContaining('Client Name'), findsOneWidget);
    });

    testWidgets('shows PAN field', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildSheetHost());
      await tester.pumpAndSettle();

      await _openSheet(tester);

      expect(find.textContaining('PAN'), findsOneWidget);
    });

    testWidgets('shows Filing Details section label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildSheetHost());
      await tester.pumpAndSettle();

      await _openSheet(tester);

      expect(find.text('Filing Details'), findsOneWidget);
    });

    testWidgets('shows ITR Type dropdown', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildSheetHost());
      await tester.pumpAndSettle();

      await _openSheet(tester);

      expect(find.textContaining('ITR Type'), findsOneWidget);
    });

    testWidgets('shows Assignment & Workflow section label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildSheetHost());
      await tester.pumpAndSettle();

      await _openSheet(tester);

      expect(find.text('Assignment & Workflow'), findsOneWidget);
    });

    testWidgets('shows Create Filing submit button', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildSheetHost());
      await tester.pumpAndSettle();

      await _openSheet(tester);

      expect(find.text('Create Filing'), findsOneWidget);
    });

    testWidgets('shows validation error when submitting empty form', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildSheetHost());
      await tester.pumpAndSettle();

      await _openSheet(tester);

      await tester.tap(find.text('Create Filing'));
      await tester.pumpAndSettle();

      expect(find.text('Client name is required'), findsOneWidget);
    });

    testWidgets('shows PAN validation error when PAN is invalid', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildSheetHost());
      await tester.pumpAndSettle();

      await _openSheet(tester);

      // Enter a client name so that validation proceeds to PAN check
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Client Name *'),
        'Test Client',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'PAN *'),
        'INVALID',
      );

      await tester.tap(find.text('Create Filing'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid PAN format'), findsOneWidget);
    });

    testWidgets('close button dismisses the sheet', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildSheetHost());
      await tester.pumpAndSettle();

      await _openSheet(tester);
      expect(find.text('New ITR Filing'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('New ITR Filing'), findsNothing);
    });
  });
}
