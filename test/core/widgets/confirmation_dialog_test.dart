import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/core/widgets/confirmation_dialog.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  group('ConfirmationDialog', () {
    /// Helper that pumps a button which opens the dialog and returns the result.
    Future<bool?> showAndCapture(
      WidgetTester tester, {
      String title = 'Confirm Action',
      String message = 'Are you sure you want to delete this item?',
      String confirmLabel = 'Delete',
      Color? confirmColor,
      IconData? icon,
    }) async {
      bool? result;

      await pumpTestWidget(
        tester,
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await ConfirmationDialog.show(
                context,
                title: title,
                message: message,
                confirmLabel: confirmLabel,
                confirmColor: confirmColor,
                icon: icon,
              );
            },
            child: const Text('Open Dialog'),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      return result;
    }

    group('content rendering', () {
      testWidgets('dialog shows title text', (tester) async {
        await showAndCapture(tester, title: 'Confirm Deletion');

        expect(find.text('Confirm Deletion'), findsOneWidget);
      });

      testWidgets('dialog shows message text', (tester) async {
        await showAndCapture(tester, message: 'This action cannot be undone.');

        expect(find.text('This action cannot be undone.'), findsOneWidget);
      });

      testWidgets('dialog shows default confirm label "Delete"', (
        tester,
      ) async {
        await showAndCapture(tester);

        expect(find.text('Delete'), findsOneWidget);
      });

      testWidgets('dialog shows custom confirmLabel on confirm button', (
        tester,
      ) async {
        await showAndCapture(tester, confirmLabel: 'Yes, Remove');

        expect(find.text('Yes, Remove'), findsOneWidget);
        expect(find.text('Delete'), findsNothing);
      });

      testWidgets('dialog always shows Cancel button', (tester) async {
        await showAndCapture(tester);

        expect(find.text('Cancel'), findsOneWidget);
      });

      testWidgets('dialog shows icon when provided', (tester) async {
        await showAndCapture(tester, icon: Icons.warning_amber_rounded);

        expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      });

      testWidgets('dialog does not show icon when none provided', (
        tester,
      ) async {
        await showAndCapture(tester);

        // No icon widget in the AlertDialog's icon slot.
        expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
      });
    });

    group('user interactions', () {
      testWidgets('confirm button returns true', (tester) async {
        bool? result;

        await pumpTestWidget(
          tester,
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await ConfirmationDialog.show(
                  context,
                  title: 'Confirm Action',
                  message: 'Sure?',
                  confirmLabel: 'Proceed',
                );
              },
              child: const Text('Open'),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Tap the FilledButton labeled "Proceed" (the confirm button).
        await tester.tap(find.widgetWithText(FilledButton, 'Proceed'));
        await tester.pumpAndSettle();

        expect(result, isTrue);
      });

      testWidgets('cancel button returns false', (tester) async {
        bool? result;

        await pumpTestWidget(
          tester,
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await ConfirmationDialog.show(
                  context,
                  title: 'Delete',
                  message: 'Sure?',
                );
              },
              child: const Text('Open'),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(result, isFalse);
      });

      testWidgets('dismissing dialog (tap barrier) returns false', (
        tester,
      ) async {
        bool? result;

        await pumpTestWidget(
          tester,
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await ConfirmationDialog.show(
                  context,
                  title: 'Delete',
                  message: 'Sure?',
                );
              },
              child: const Text('Open'),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Tap outside the dialog to dismiss it.
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        // show() returns result ?? false, so null becomes false.
        expect(result, isFalse);
      });
    });

    group('ConfirmationDialog widget directly', () {
      testWidgets('builds without error', (tester) async {
        await pumpTestWidget(
          tester,
          const ConfirmationDialog(title: 'Test', message: 'Test message'),
        );

        expect(find.byType(ConfirmationDialog), findsOneWidget);
        expect(find.text('Test'), findsOneWidget);
        expect(find.text('Test message'), findsOneWidget);
      });

      testWidgets('back button (Cancel) calls Navigator.pop with false', (
        tester,
      ) async {
        await pumpTestWidget(
          tester,
          const ConfirmationDialog(
            title: 'Delete?',
            message: 'This will be removed.',
          ),
        );

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // After pop, the dialog is gone.
        expect(find.byType(ConfirmationDialog), findsNothing);
      });
    });
  });
}
