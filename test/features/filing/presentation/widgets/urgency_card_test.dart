import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/urgency_border_card.dart';
import 'package:ca_app/features/filing/domain/models/filing_hub_item.dart';
import 'package:ca_app/features/filing/presentation/widgets/urgency_card.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  FilingHubItem makeItem({
    String id = 'item-1',
    String clientName = 'Mehta & Sons',
    FilingCategory filingType = FilingCategory.gst,
    String subType = 'GSTR-3B',
    FilingHubStatus status = FilingHubStatus.dueThisWeek,
    DateTime? dueDate,
    int? daysFromNow,
  }) {
    final due = dueDate ??
        (daysFromNow != null
            ? DateTime.now().add(Duration(days: daysFromNow))
            : DateTime.now().add(const Duration(days: 3)));
    return FilingHubItem(
      id: id,
      clientName: clientName,
      filingType: filingType,
      subType: subType,
      status: status,
      dueDate: due,
    );
  }

  Widget buildSubject({FilingHubItem? item, VoidCallback? onTap}) {
    return SizedBox(
      height: 200,
      child: UrgencyCard(item: item ?? makeItem(), onTap: onTap),
    );
  }

  // ---------------------------------------------------------------------------
  // Tests
  // ---------------------------------------------------------------------------

  group('UrgencyCard', () {
    group('content rendering', () {
      testWidgets(
          'test_UrgencyCard_withSubType_rendersSubType',
          (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(item: makeItem(subType: 'GSTR-3B')),
        );

        expect(find.text('GSTR-3B'), findsOneWidget);
      });

      testWidgets(
          'test_UrgencyCard_withClientName_rendersClientName',
          (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(item: makeItem(clientName: 'ABC Corp')),
        );

        expect(find.text('ABC Corp'), findsOneWidget);
      });

      testWidgets(
          'test_UrgencyCard_withGstType_rendersGstShortLabel',
          (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(item: makeItem(filingType: FilingCategory.gst)),
        );

        expect(find.text('GST'), findsOneWidget);
      });

      testWidgets(
          'test_UrgencyCard_withItrType_rendersItrShortLabel',
          (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(item: makeItem(filingType: FilingCategory.itr)),
        );

        expect(find.text('ITR'), findsOneWidget);
      });

      testWidgets(
          'test_UrgencyCard_withTdsType_rendersTdsShortLabel',
          (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(item: makeItem(filingType: FilingCategory.tds)),
        );

        expect(find.text('TDS'), findsOneWidget);
      });

      testWidgets(
          'test_UrgencyCard_withMcaType_rendersMcaShortLabel',
          (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(item: makeItem(filingType: FilingCategory.mca)),
        );

        expect(find.text('MCA'), findsOneWidget);
      });
    });

    group('due date display', () {
      testWidgets(
          'test_UrgencyCard_withDueDate_rendersFormattedDate',
          (tester) async {
        final dueDate = DateTime(2026, 7, 20);
        await pumpTestWidget(
          tester,
          buildSubject(item: makeItem(dueDate: dueDate)),
        );

        final formatter = DateFormat('d MMM');
        expect(find.textContaining(formatter.format(dueDate)), findsOneWidget);
      });

      testWidgets(
          'test_UrgencyCard_withZeroDaysRemaining_rendersDueTodayLabel',
          (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(item: makeItem(daysFromNow: 0)),
        );

        expect(find.textContaining('Due today'), findsOneWidget);
      });

      testWidgets(
          'test_UrgencyCard_withFiveDaysRemaining_rendersDueInLabel',
          (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(item: makeItem(daysFromNow: 5)),
        );

        expect(find.textContaining('Due in 5 days'), findsOneWidget);
      });

      testWidgets(
          'test_UrgencyCard_withOneDayRemaining_rendersSingularDayLabel',
          (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(item: makeItem(daysFromNow: 1)),
        );

        expect(find.textContaining('Due in 1 day'), findsOneWidget);
      });

      testWidgets(
          'test_UrgencyCard_withOverdueOneDay_rendersOneDayOverdueLabel',
          (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(
            item: makeItem(
              daysFromNow: -1,
              status: FilingHubStatus.overdue,
            ),
          ),
        );

        expect(find.textContaining('1 day overdue'), findsOneWidget);
      });

      testWidgets(
          'test_UrgencyCard_withOverdueThreeDays_rendersThreeDaysOverdueLabel',
          (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(
            item: makeItem(
              daysFromNow: -3,
              status: FilingHubStatus.overdue,
            ),
          ),
        );

        expect(find.textContaining('3 days overdue'), findsOneWidget);
      });
    });

    group('border color', () {
      testWidgets(
          'test_UrgencyCard_withOverdueStatus_rendersErrorBorderColor',
          (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(
            item: makeItem(
              status: FilingHubStatus.overdue,
              daysFromNow: -2,
            ),
          ),
        );

        final urgencyCard = tester.widget<UrgencyBorderCard>(
          find.byType(UrgencyBorderCard),
        );
        expect(urgencyCard.urgencyColor, AppColors.error);
      });

      testWidgets(
          'test_UrgencyCard_withDueThisWeekStatus_rendersWarningBorderColor',
          (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(
            item: makeItem(status: FilingHubStatus.dueThisWeek),
          ),
        );

        final urgencyCard = tester.widget<UrgencyBorderCard>(
          find.byType(UrgencyBorderCard),
        );
        expect(urgencyCard.urgencyColor, AppColors.warning);
      });
    });

    group('status icon', () {
      testWidgets(
          'test_UrgencyCard_withOverdueStatus_rendersWarningIcon',
          (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(item: makeItem(status: FilingHubStatus.overdue)),
        );

        expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
      });

      testWidgets(
          'test_UrgencyCard_withDueThisWeekStatus_rendersScheduleIcon',
          (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(item: makeItem(status: FilingHubStatus.dueThisWeek)),
        );

        expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);
      });
    });

    group('calendar icon', () {
      testWidgets(
          'test_UrgencyCard_always_rendersCalendarIcon',
          (tester) async {
        await pumpTestWidget(tester, buildSubject());

        expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
      });
    });

    group('tap interaction', () {
      testWidgets(
          'test_UrgencyCard_withOnTap_firesCallbackOnTap',
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
          'test_UrgencyCard_withNullOnTap_doesNotThrowOnTap',
          (tester) async {
        await pumpTestWidget(
          tester,
          buildSubject(
            item: makeItem(subType: 'ITR-1'),
            // onTap intentionally omitted
          ),
        );

        expect(find.text('ITR-1'), findsOneWidget);
      });
    });

    group('card dimensions', () {
      testWidgets(
          'test_UrgencyCard_always_rendersUrgencyBorderCard',
          (tester) async {
        await pumpTestWidget(tester, buildSubject());

        expect(find.byType(UrgencyBorderCard), findsOneWidget);
      });
    });
  });
}
