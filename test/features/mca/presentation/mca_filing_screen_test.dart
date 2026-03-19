import 'package:ca_app/features/mca/presentation/mca_filing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  group('McaFilingScreen - renders', () {
    testWidgets('renders without crash', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const McaFilingScreen());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows "MCA Filing Wizard" in AppBar', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const McaFilingScreen());
      expect(find.text('MCA Filing Wizard'), findsOneWidget);
    });

    testWidgets('shows step indicator with 5 steps', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const McaFilingScreen());
      // Step indicator shows step numbers 1-5
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });
  });

  group('McaFilingScreen - step 1: form selection', () {
    testWidgets('shows "Select Form & Company" header on step 1', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const McaFilingScreen());
      expect(find.text('Select Form & Company'), findsOneWidget);
    });

    testWidgets('shows Company dropdown', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const McaFilingScreen());
      expect(find.text('Company'), findsOneWidget);
    });

    testWidgets('shows Financial Year dropdown', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const McaFilingScreen());
      expect(find.text('Financial Year'), findsOneWidget);
    });

    testWidgets('shows "Select Form Type" label', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const McaFilingScreen());
      expect(find.text('Select Form Type'), findsOneWidget);
    });

    testWidgets('shows "Next: Data Entry" button on step 1', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const McaFilingScreen());
      expect(find.text('Next: Data Entry'), findsOneWidget);
    });
  });

  group('McaFilingScreen - step 2: data entry', () {
    Future<void> navigateToStep2(WidgetTester tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const McaFilingScreen());
      await tester.tap(find.text('Next: Data Entry'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows data entry header after advancing to step 2', (
      tester,
    ) async {
      await navigateToStep2(tester);
      expect(find.textContaining('Data Entry'), findsOneWidget);
    });

    testWidgets('shows Authorised Capital field on step 2', (tester) async {
      await navigateToStep2(tester);
      expect(find.text('Authorised Capital'), findsOneWidget);
    });

    testWidgets('shows Back and Next buttons on step 2', (tester) async {
      await navigateToStep2(tester);
      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Next: Validate'), findsOneWidget);
    });
  });

  group('McaFilingScreen - step 3: validation', () {
    Future<void> navigateToStep3(WidgetTester tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const McaFilingScreen());
      await tester.tap(find.text('Next: Data Entry'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next: Validate'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows "Pre-Scrutiny Validation" header on step 3', (
      tester,
    ) async {
      await navigateToStep3(tester);
      expect(find.text('Pre-Scrutiny Validation'), findsOneWidget);
    });

    testWidgets('shows "All Checks Passed" on step 3 (no errors by default)', (
      tester,
    ) async {
      await navigateToStep3(tester);
      expect(find.text('All Checks Passed'), findsOneWidget);
    });

    testWidgets('shows "Re-run Validation" button on step 3', (tester) async {
      await navigateToStep3(tester);
      expect(find.text('Re-run Validation'), findsOneWidget);
    });
  });

  group('McaFilingScreen - step 5: submit', () {
    Future<void> navigateToStep5(WidgetTester tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const McaFilingScreen());
      // Step 1 → 2
      await tester.tap(find.text('Next: Data Entry'));
      await tester.pumpAndSettle();
      // Step 2 → 3
      await tester.tap(find.text('Next: Validate'));
      await tester.pumpAndSettle();
      // Step 3: errors empty by default, nav shows "Next: DSC Signing"
      await tester.tap(find.text('Next: DSC Signing'));
      await tester.pumpAndSettle();
      // Step 4: sign DSC (async — triggers step advance internally)
      await tester.tap(find.text('Sign with DSC'));
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    }

    testWidgets('shows "Review & Submit" on step 5', (tester) async {
      await navigateToStep5(tester);
      expect(find.text('Review & Submit'), findsOneWidget);
    });

    testWidgets('shows "Submit to MCA" button on step 5', (tester) async {
      await navigateToStep5(tester);
      expect(find.text('Submit to MCA'), findsOneWidget);
    });
  });
}
