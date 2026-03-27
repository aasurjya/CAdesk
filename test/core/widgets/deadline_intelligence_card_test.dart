import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/deadline_intelligence_card.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  group('DeadlineIntelligenceCard', () {
    final baseDate = DateTime.now().add(const Duration(days: 10));

    Widget buildSubject({
      String title = 'GSTR-3B Filing',
      DateTime? dueDate,
      double riskScore = 0.3,
      double? penaltyAmount,
      String? category,
      VoidCallback? onTap,
    }) {
      return DeadlineIntelligenceCard(
        title: title,
        dueDate: dueDate ?? baseDate,
        riskScore: riskScore,
        penaltyAmount: penaltyAmount,
        category: category,
        onTap: onTap,
      );
    }

    group('content rendering', () {
      testWidgets('renders deadline title', (tester) async {
        await pumpTestWidget(tester, buildSubject(title: 'GSTR-3B Filing'));

        expect(find.text('GSTR-3B Filing'), findsOneWidget);
      });

      testWidgets('renders due date in formatted form', (tester) async {
        final date = DateTime(2026, 3, 20);
        await pumpTestWidget(tester, buildSubject(dueDate: date));

        expect(find.text('20 Mar 2026'), findsOneWidget);
      });

      testWidgets('renders countdown text when days remain', (tester) async {
        // Use 100 days to avoid any day-boundary flakiness.
        final future = DateTime.now().add(const Duration(days: 100));
        await pumpTestWidget(tester, buildSubject(dueDate: future));

        expect(find.textContaining('days left'), findsOneWidget);
      });

      testWidgets('renders "Due tomorrow" for ~36 hours remaining', (
        tester,
      ) async {
        // Use 36 hours to reliably get inDays == 1. The widget checks
        // diff.inDays == 1 for "Due tomorrow". At 36h: inDays = 1.
        final future36h = DateTime.now().add(const Duration(hours: 36));
        await pumpTestWidget(tester, buildSubject(dueDate: future36h));

        expect(find.text('Due tomorrow'), findsOneWidget);
      });

      testWidgets('renders "Due today" for ~12 hours remaining', (
        tester,
      ) async {
        // Use 12 hours so inDays == 0 regardless of pump timing.
        // diff.inDays == 0 for any duration < 24h.
        final future12h = DateTime.now().add(const Duration(hours: 12));
        await pumpTestWidget(tester, buildSubject(dueDate: future12h));

        expect(find.text('Due today'), findsOneWidget);
      });

      testWidgets('renders overdue countdown for past date', (tester) async {
        final past = DateTime.now().subtract(const Duration(days: 3));
        await pumpTestWidget(tester, buildSubject(dueDate: past));

        expect(find.textContaining('Overdue'), findsOneWidget);
      });
    });

    group('risk bar', () {
      testWidgets('renders LinearProgressIndicator as risk bar', (
        tester,
      ) async {
        await pumpTestWidget(tester, buildSubject(riskScore: 0.5));

        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      });

      testWidgets('risk bar reflects riskScore value', (tester) async {
        await pumpTestWidget(tester, buildSubject(riskScore: 0.75));

        final bar = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        expect(bar.value, 0.75);
      });

      testWidgets('clamps riskScore of 1.0 to 1.0', (tester) async {
        await pumpTestWidget(tester, buildSubject(riskScore: 1.0));

        final bar = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        expect(bar.value, 1.0);
      });
    });

    group('urgency color based on riskScore', () {
      testWidgets('riskScore >= 0.75 uses error color (red)', (tester) async {
        await pumpTestWidget(tester, buildSubject(riskScore: 0.75));

        final bar = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        final animation = bar.valueColor as AlwaysStoppedAnimation<Color>;
        expect(animation.value, AppColors.error);
      });

      testWidgets('riskScore >= 0.5 uses warning color (orange)', (
        tester,
      ) async {
        await pumpTestWidget(tester, buildSubject(riskScore: 0.5));

        final bar = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        final animation = bar.valueColor as AlwaysStoppedAnimation<Color>;
        expect(animation.value, AppColors.warning);
      });

      testWidgets('riskScore >= 0.25 uses accent color', (tester) async {
        await pumpTestWidget(tester, buildSubject(riskScore: 0.25));

        final bar = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        final animation = bar.valueColor as AlwaysStoppedAnimation<Color>;
        expect(animation.value, AppColors.accent);
      });

      testWidgets('riskScore < 0.25 uses success color (green)', (
        tester,
      ) async {
        await pumpTestWidget(tester, buildSubject(riskScore: 0.1));

        final bar = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );
        final animation = bar.valueColor as AlwaysStoppedAnimation<Color>;
        expect(animation.value, AppColors.success);
      });
    });

    group('penalty warning', () {
      testWidgets('shows penalty warning when penaltyAmount is provided', (
        tester,
      ) async {
        await pumpTestWidget(tester, buildSubject(penaltyAmount: 5000));

        expect(find.textContaining('Penalty risk'), findsOneWidget);
        expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      });

      testWidgets('penalty amounts below 1000 show raw value', (tester) async {
        await pumpTestWidget(tester, buildSubject(penaltyAmount: 500));

        expect(find.textContaining('₹500'), findsOneWidget);
      });

      testWidgets('penalty amounts >= 1000 show K suffix', (tester) async {
        await pumpTestWidget(tester, buildSubject(penaltyAmount: 5000));

        expect(find.textContaining('₹5K'), findsOneWidget);
      });

      testWidgets('penalty amounts >= 100000 show L suffix', (tester) async {
        await pumpTestWidget(tester, buildSubject(penaltyAmount: 200000));

        expect(find.textContaining('₹2.0L'), findsOneWidget);
      });

      testWidgets('does not show penalty warning when penaltyAmount is null', (
        tester,
      ) async {
        await pumpTestWidget(tester, buildSubject());

        expect(find.textContaining('Penalty risk'), findsNothing);
        expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
      });
    });

    group('category badge', () {
      testWidgets('shows category badge when category is provided', (
        tester,
      ) async {
        await pumpTestWidget(tester, buildSubject(category: 'GST'));

        expect(find.text('GST'), findsOneWidget);
      });

      testWidgets('does not show category badge when category is null', (
        tester,
      ) async {
        await pumpTestWidget(tester, buildSubject());

        // No StatusBadge should be rendered when category is null
        // (the title widget's Text is the only text visible)
        expect(find.text('GST'), findsNothing);
      });
    });

    group('tap interaction', () {
      testWidgets('onTap callback fires when card is tapped', (tester) async {
        var tapped = false;
        await pumpTestWidget(tester, buildSubject(onTap: () => tapped = true));

        await tester.tap(find.byType(InkWell).first);
        await tester.pump();

        expect(tapped, isTrue);
      });

      testWidgets('no error when onTap is null', (tester) async {
        await pumpTestWidget(tester, buildSubject());

        await tester.tap(find.byType(InkWell).first);
        await tester.pump();

        expect(tester.takeException(), isNull);
      });
    });
  });
}
