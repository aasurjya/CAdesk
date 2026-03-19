import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/gst/presentation/gstr1/gstr1_wizard_screen.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  group('Gstr1WizardScreen', () {
    testWidgets('renders without layout errors at desktop viewport', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const Gstr1WizardScreen());
      // No unhandled exceptions
    });

    testWidgets('shows step 1 label (Period & GSTIN) initially', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const Gstr1WizardScreen());

      // Step header shows "Step 1 of 8" and the step title
      expect(find.textContaining('Step 1'), findsOneWidget);
      expect(find.textContaining('Period'), findsWidgets);
    });

    testWidgets('shows GSTR-1 Wizard in app bar when GSTIN is empty', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const Gstr1WizardScreen());

      expect(find.text('GSTR-1 Wizard'), findsOneWidget);
    });

    testWidgets('shows a linear progress indicator in app bar', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const Gstr1WizardScreen());

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('progress indicator value is 1/8 on step 0', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const Gstr1WizardScreen());

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, closeTo(1 / 8, 0.001));
    });

    testWidgets('Next button is present on first step', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const Gstr1WizardScreen());

      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('Back button is disabled on first step', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const Gstr1WizardScreen());

      final outlinedButtons = tester.widgetList<OutlinedButton>(
        find.byType(OutlinedButton),
      );
      // At least one OutlinedButton (Back) is disabled on step 0
      expect(outlinedButtons.any((b) => b.onPressed == null), isTrue);
    });

    testWidgets('tapping Next advances to step 2', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const Gstr1WizardScreen());

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Step 2'), findsOneWidget);
    });

    testWidgets('step indicator shows total steps count', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const Gstr1WizardScreen());

      // "Step 1 of 8" pattern
      expect(find.textContaining('of 8'), findsOneWidget);
    });

    testWidgets('Save Draft button is present', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const Gstr1WizardScreen());

      expect(find.text('Save Draft'), findsOneWidget);
    });

    testWidgets('tapping Next twice advances to step 3', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const Gstr1WizardScreen());

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Step 3'), findsOneWidget);
    });

    testWidgets('wizard has Back button widget in nav bar', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const Gstr1WizardScreen());

      expect(find.text('Back'), findsOneWidget);
    });
  });
}
