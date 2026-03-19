import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/gst/presentation/gstr3b/gstr3b_wizard_screen.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  group('Gstr3bWizardScreen', () {
    testWidgets('renders without layout errors at desktop viewport', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const Gstr3bWizardScreen());
    });

    testWidgets('shows GSTR-3B Wizard in app bar when GSTIN is empty', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const Gstr3bWizardScreen());

      expect(find.text('GSTR-3B Wizard'), findsOneWidget);
    });

    testWidgets('shows step 1 label (Period & GSTIN) initially', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const Gstr3bWizardScreen());

      expect(find.textContaining('Step 1'), findsOneWidget);
      expect(find.textContaining('Period'), findsWidgets);
    });

    testWidgets('progress indicator shows 1/5 on first step', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const Gstr3bWizardScreen());

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, closeTo(1 / 5, 0.001));
    });

    testWidgets('step indicator shows 5 total steps', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const Gstr3bWizardScreen());

      expect(find.textContaining('of 5'), findsOneWidget);
    });

    testWidgets('Next button is present on first step', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const Gstr3bWizardScreen());

      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('Back button is disabled on first step', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const Gstr3bWizardScreen());

      final outlinedButtons = tester.widgetList<OutlinedButton>(
        find.byType(OutlinedButton),
      );
      expect(outlinedButtons.any((b) => b.onPressed == null), isTrue);
    });

    testWidgets('tapping Next advances to step 2', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const Gstr3bWizardScreen());

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Step 2'), findsOneWidget);
    });

    testWidgets('step 2 shows Tax Liability in header', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const Gstr3bWizardScreen());

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Tax Liability'), findsWidgets);
    });

    testWidgets('Save Draft button is present', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const Gstr3bWizardScreen());

      expect(find.text('Save Draft'), findsOneWidget);
    });

    testWidgets('shows Done button after navigating to last step (step 4)', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const Gstr3bWizardScreen());

      // Navigate through all 5 steps (0 → 4)
      for (int i = 0; i < 4; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }

      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Next'), findsNothing);
    });

    testWidgets('linear progress indicator is present', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const Gstr3bWizardScreen());

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
