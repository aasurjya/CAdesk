import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/litigation/presentation/case_detail_screen.dart';

import '../../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// CaseDetailScreen ignores the caseId and always renders the mock case
// (_mockCase is defined inside the screen file and hard-coded).
Widget buildSubject() => const CaseDetailScreen(caseId: 'lit-001');

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('CaseDetailScreen', () {
    testWidgets('renders without crash', (tester) async {
      await setTabletViewport(tester);
      await pumpTestWidget(tester, buildSubject());

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows client name in app bar', (tester) async {
      await setTabletViewport(tester);
      await pumpTestWidget(tester, buildSubject());

      expect(find.textContaining('Bharat Industries'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows case section label in header card', (tester) async {
      await setTabletViewport(tester);
      await pumpTestWidget(tester, buildSubject());

      expect(find.textContaining('Section 68'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows status badge in header card', (tester) async {
      await setTabletViewport(tester);
      await pumpTestWidget(tester, buildSubject());

      // The mock case status is hearingScheduled
      expect(find.text('Hearing Scheduled'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows current forum badge', (tester) async {
      await setTabletViewport(tester);
      await pumpTestWidget(tester, buildSubject());

      expect(find.textContaining('ITAT'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows Forum Hierarchy card', (tester) async {
      await setTabletViewport(tester);
      await pumpTestWidget(tester, buildSubject());

      expect(find.text('Forum Hierarchy'), findsOneWidget);
    });

    testWidgets('shows CIT(A) in forum hierarchy', (tester) async {
      await setTabletViewport(tester);
      await pumpTestWidget(tester, buildSubject());

      expect(find.text('CIT(A)'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows client name in case info card', (tester) async {
      await setTabletViewport(tester);
      await pumpTestWidget(tester, buildSubject());

      // Client is shown in the info card as well
      expect(find.text('Bharat Industries Ltd'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows PAN in case info card', (tester) async {
      await setTabletViewport(tester);
      await pumpTestWidget(tester, buildSubject());

      expect(find.text('AAACB1234F'), findsOneWidget);
    });

    testWidgets('shows Hearing Dates timeline card', (tester) async {
      await setTabletViewport(tester);
      await pumpTestWidget(tester, buildSubject());

      expect(find.text('Hearing Dates'), findsOneWidget);
    });

    testWidgets('shows Document Trail card', (tester) async {
      await setTabletViewport(tester);
      await pumpTestWidget(tester, buildSubject());

      await tester.dragUntilVisible(
        find.textContaining('Document Trail'),
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Document Trail'), findsOneWidget);
    });

    testWidgets('shows Outcome Probability card', (tester) async {
      await setTabletViewport(tester);
      await pumpTestWidget(tester, buildSubject());

      await tester.dragUntilVisible(
        find.text('Outcome Probability'),
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      expect(find.text('Outcome Probability'), findsOneWidget);
    });

    testWidgets('shows Prepare Hearing Brief action button', (tester) async {
      await setTabletViewport(tester);
      await pumpTestWidget(tester, buildSubject());

      await tester.dragUntilVisible(
        find.text('Prepare Hearing Brief'),
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      expect(find.text('Prepare Hearing Brief'), findsOneWidget);
    });

    testWidgets('shows File Next Appeal button', (tester) async {
      await setTabletViewport(tester);
      await pumpTestWidget(tester, buildSubject());

      await tester.dragUntilVisible(
        find.text('File Next Appeal'),
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      expect(find.text('File Next Appeal'), findsOneWidget);
    });

    testWidgets('shows lawyer name in case info card', (tester) async {
      await setTabletViewport(tester);
      await pumpTestWidget(tester, buildSubject());

      expect(find.text('Adv. Suresh Patel'), findsOneWidget);
    });
  });
}
