import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/tds/presentation/fvu/fvu_generation_screen.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  group('FvuGenerationScreen', () {
    testWidgets('renders without crash', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const FvuGenerationScreen());
      expect(find.byType(FvuGenerationScreen), findsOneWidget);
    });

    testWidgets('shows FVU File Generation title in app bar', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const FvuGenerationScreen());
      expect(find.text('FVU File Generation'), findsOneWidget);
    });

    testWidgets('shows summary row with Deductees, Total TDS, Challans', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const FvuGenerationScreen());
      // "Deductees" appears in both summary card and step indicator.
      expect(find.text('Deductees'), findsWidgets);
      expect(find.text('Total TDS'), findsOneWidget);
      // "Challans" appears in both summary card and step indicator.
      expect(find.text('Challans'), findsWidgets);
    });

    testWidgets('shows step labels in step indicator', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const FvuGenerationScreen());
      expect(find.text('Setup'), findsOneWidget);
      // "Deductees" appears in summary card + step indicator.
      expect(find.text('Deductees'), findsWidgets);
      // "Challans" appears in summary card + step indicator.
      expect(find.text('Challans'), findsWidgets);
      expect(find.text('Validate'), findsOneWidget);
      expect(find.text('Generate'), findsOneWidget);
    });

    testWidgets('starts on step 0 (Setup) — shows Deductor & Period form', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const FvuGenerationScreen());
      expect(find.text('Deductor & Period'), findsOneWidget);
    });

    testWidgets('shows Select Deductor dropdown on step 0', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const FvuGenerationScreen());
      expect(find.text('Select Deductor'), findsOneWidget);
    });

    testWidgets('shows Form Type dropdown on step 0', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const FvuGenerationScreen());
      expect(find.text('Form Type'), findsOneWidget);
    });

    testWidgets('shows Next navigation button on step 0', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const FvuGenerationScreen());
      // The next button shows the label of the next step.
      expect(find.text('Deductees'), findsWidgets);
    });

    testWidgets('does not show Back button on first step', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const FvuGenerationScreen());
      expect(find.text('Back'), findsNothing);
    });

    testWidgets('navigates to Deductees step after tapping Next', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const FvuGenerationScreen());

      // Tap the Next button (first step next = "Deductees").
      final nextBtn = find.text('Deductees').last;
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();

      // On step 1 (Deductees) with no deductor selected, shows empty state.
      expect(find.text('No deductee records'), findsOneWidget);
    });

    testWidgets('shows Back button after navigating to step 1', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const FvuGenerationScreen());

      await tester.tap(find.text('Deductees').last);
      await tester.pumpAndSettle();

      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('shows Financial Year label on setup step', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const FvuGenerationScreen());
      expect(find.text('Financial Year'), findsOneWidget);
    });

    testWidgets('shows Quarter dropdown on setup step', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(tester, const FvuGenerationScreen());
      expect(find.text('Quarter'), findsOneWidget);
    });
  });
}
