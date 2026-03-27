import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/urgency_border_card.dart';
import 'package:ca_app/features/compliance/domain/models/compliance_deadline.dart';
import 'package:ca_app/features/today/presentation/widgets/kanban_card.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  ComplianceDeadline makeDeadline({
    String id = 'd1',
    String title = 'File GSTR-3B',
    ComplianceCategory category = ComplianceCategory.gst,
    ComplianceStatus status = ComplianceStatus.upcoming,
    DateTime? dueDate,
    int? daysFromNow,
  }) {
    final due = dueDate ??
        (daysFromNow != null
            ? DateTime.now().add(Duration(days: daysFromNow))
            : DateTime.now().add(const Duration(days: 5)));
    return ComplianceDeadline(
      id: id,
      title: title,
      description: 'Monthly GST return',
      category: category,
      dueDate: due,
      applicableTo: const ['all'],
      isRecurring: true,
      frequency: ComplianceFrequency.monthly,
      status: status,
    );
  }

  Widget buildSubject({
    ComplianceDeadline? deadline,
    VoidCallback? onTap,
  }) {
    return KanbanCard(
      deadline: deadline ?? makeDeadline(),
      onTap: onTap,
    );
  }

  // ---------------------------------------------------------------------------
  // Tests
  // ---------------------------------------------------------------------------

  group('KanbanCard (today)', () {
    group('title rendering', () {
      testWidgets(
          'test_KanbanCard_withTitle_rendersDeadlineTitle',
          (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(deadline: makeDeadline(title: 'Pay Advance Tax')),
        );

        expect(find.text('Pay Advance Tax'), findsOneWidget);
      });
    });

    group('category badge', () {
      testWidgets(
          'test_KanbanCard_withGstCategory_rendersCategoryShortLabel',
          (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(
            deadline: makeDeadline(category: ComplianceCategory.gst),
          ),
        );

        expect(find.text('GST'), findsOneWidget);
      });

      testWidgets(
          'test_KanbanCard_withItrCategory_rendersCategoryShortLabel',
          (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(
            deadline: makeDeadline(category: ComplianceCategory.incomeTax),
          ),
        );

        expect(find.text('ITR'), findsOneWidget);
      });

      testWidgets(
          'test_KanbanCard_withTdsCategory_rendersCategoryShortLabel',
          (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(
            deadline: makeDeadline(category: ComplianceCategory.tds),
          ),
        );

        expect(find.text('TDS'), findsOneWidget);
      });
    });

    group('due date row', () {
      testWidgets(
          'test_KanbanCard_withDueDate_rendersFormattedDate',
          (tester) async {
        final dueDate = DateTime(2026, 6, 15);
        await pumpTestWidget(
          tester,
          buildSubject(deadline: makeDeadline(dueDate: dueDate)),
        );

        final formatter = DateFormat('d MMM');
        expect(find.text(formatter.format(dueDate)), findsOneWidget);
      });

      testWidgets(
          'test_KanbanCard_withZeroDaysRemaining_rendersTodayLabel',
          (tester) async {
        // Due today
        await pumpTestWidget(
          tester,
          buildSubject(deadline: makeDeadline(daysFromNow: 0)),
        );

        expect(find.text('Today'), findsOneWidget);
      });

      testWidgets(
          'test_KanbanCard_withOneDayRemaining_rendsOneDayLabel',
          (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(deadline: makeDeadline(daysFromNow: 1)),
        );

        expect(find.text('1 day'), findsOneWidget);
      });

      testWidgets(
          'test_KanbanCard_withFiveDaysRemaining_rendersFiveDaysLabel',
          (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(deadline: makeDeadline(daysFromNow: 5)),
        );

        expect(find.text('5 days'), findsOneWidget);
      });

      testWidgets(
          'test_KanbanCard_withOverdueOneDay_rendsOneDayAgoLabel',
          (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(deadline: makeDeadline(daysFromNow: -1)),
        );

        expect(find.text('1 day ago'), findsOneWidget);
      });

      testWidgets(
          'test_KanbanCard_withOverdueManyDays_rendersMultipleDaysAgoLabel',
          (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(deadline: makeDeadline(daysFromNow: -3)),
        );

        expect(find.text('3 days ago'), findsOneWidget);
      });
    });

    group('urgency color', () {
      testWidgets(
          'test_KanbanCard_withOverdueStatus_usesUrgencyBorderCard',
          (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(
            deadline: makeDeadline(
              daysFromNow: -2,
              status: ComplianceStatus.overdue,
            ),
          ),
        );

        expect(find.byType(UrgencyBorderCard), findsOneWidget);
      });

      testWidgets(
          'test_KanbanCard_withCompletedStatus_rendersGreyUrgencyColor',
          (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(
            deadline: makeDeadline(
              daysFromNow: 10,
              status: ComplianceStatus.completed,
            ),
          ),
        );

        final urgencyCard = tester.widget<UrgencyBorderCard>(
          find.byType(UrgencyBorderCard),
        );
        expect(urgencyCard.urgencyColor, AppColors.neutral300);
      });

      testWidgets(
          'test_KanbanCard_withFutureDate_rendersGreenUrgencyColor',
          (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(deadline: makeDeadline(daysFromNow: 30)),
        );

        final urgencyCard = tester.widget<UrgencyBorderCard>(
          find.byType(UrgencyBorderCard),
        );
        expect(urgencyCard.urgencyColor, AppColors.success);
      });

      testWidgets(
          'test_KanbanCard_withDueSoon_rendersWarningUrgencyColor',
          (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(deadline: makeDeadline(daysFromNow: 3)),
        );

        final urgencyCard = tester.widget<UrgencyBorderCard>(
          find.byType(UrgencyBorderCard),
        );
        expect(urgencyCard.urgencyColor, AppColors.warning);
      });

      testWidgets(
          'test_KanbanCard_withOverdueDate_rendersRedUrgencyColor',
          (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(deadline: makeDeadline(daysFromNow: -5)),
        );

        final urgencyCard = tester.widget<UrgencyBorderCard>(
          find.byType(UrgencyBorderCard),
        );
        expect(urgencyCard.urgencyColor, AppColors.error);
      });
    });

    group('tap interaction', () {
      testWidgets(
          'test_KanbanCard_withOnTap_firesCallbackOnTap',
          (tester) async {
        var tapped = false;
        await pumpTestWidget(
          tester,
          buildSubject(onTap: () => tapped = true),
        );

        await tester.tap(find.byType(UrgencyBorderCard));
        await tester.pump();

        expect(tapped, isTrue);
      });

      testWidgets(
          'test_KanbanCard_withNullOnTap_doesNotThrowOnTap',
          (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(
            // onTap intentionally omitted
            deadline: makeDeadline(title: 'No Tap'),
          ),
        );

        // Should not throw even without tap callback.
        expect(find.text('No Tap'), findsOneWidget);
        await tester.tap(find.byType(UrgencyBorderCard));
        await tester.pump();

        expect(tester.takeException(), isNull);
      });
    });

    group('calendar icon', () {
      testWidgets(
          'test_KanbanCard_always_rendersCalendarIcon',
          (tester) async {
        await pumpTestWidget(tester, buildSubject());

        expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
      });
    });
  });
}
