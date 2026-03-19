import 'package:ca_app/features/faceless_assessment/data/providers/faceless_assessment_providers.dart';
import 'package:ca_app/features/faceless_assessment/domain/models/hearing_schedule.dart';
import 'package:ca_app/features/faceless_assessment/presentation/hearing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/widget_test_helpers.dart';

void main() {
  // Build a scheduled hearing with a future date
  HearingSchedule scheduledHearing() => HearingSchedule(
    id: 'test-hs1',
    proceedingId: 'ep1',
    clientName: 'Test Client',
    hearingDate: DateTime.now().add(const Duration(days: 10)),
    hearingTime: '10:00 AM',
    platform: HearingPlatform.nfacPortal,
    agenda: 'Discuss capital gains computation',
    documentsToSubmit: ['Bank statement', 'Form 26AS'],
    representativeName: 'CA Test',
    status: HearingStatus.scheduled,
  );

  HearingSchedule completedHearing() => HearingSchedule(
    id: 'test-hs2',
    proceedingId: 'ep2',
    clientName: 'Another Client',
    hearingDate: DateTime.now().subtract(const Duration(days: 5)),
    hearingTime: '02:00 PM',
    platform: HearingPlatform.videoConference,
    agenda: 'Penalty proceedings',
    documentsToSubmit: [],
    representativeName: 'CA Demo',
    status: HearingStatus.completed,
    notes: 'Hearing went well',
  );

  HearingSchedule adjournedHearing() => HearingSchedule(
    id: 'test-hs3',
    proceedingId: 'ep3',
    clientName: 'Third Client',
    hearingDate: DateTime.now().add(const Duration(days: 2)),
    hearingTime: '11:00 AM',
    platform: HearingPlatform.nfacPortal,
    agenda: 'Scrutiny assessment',
    documentsToSubmit: ['Audit report'],
    representativeName: 'CA Another',
    status: HearingStatus.adjourned,
  );

  group('HearingScreen - not found', () {
    testWidgets('renders "Hearing not found" when hearingId does not exist', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const HearingScreen(hearingId: 'nonexistent-id'),
        overrides: [
          hearingSchedulesProvider.overrideWith(() => _EmptyHearingsNotifier()),
        ],
      );

      expect(find.text('Hearing not found'), findsOneWidget);
    });

    testWidgets('shows Go Back button when hearing not found', (tester) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const HearingScreen(hearingId: 'nonexistent-id'),
        overrides: [
          hearingSchedulesProvider.overrideWith(() => _EmptyHearingsNotifier()),
        ],
      );

      expect(find.text('Go Back'), findsOneWidget);
    });

    testWidgets('shows "Hearing Detail" in AppBar when not found', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      await pumpTestWidget(
        tester,
        const HearingScreen(hearingId: 'nonexistent-id'),
        overrides: [
          hearingSchedulesProvider.overrideWith(() => _EmptyHearingsNotifier()),
        ],
      );

      expect(find.text('Hearing Detail'), findsOneWidget);
    });
  });

  group('HearingScreen - scheduled hearing', () {
    testWidgets('renders without crash for a scheduled hearing', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      final hearing = scheduledHearing();
      await pumpTestWidget(
        tester,
        HearingScreen(hearingId: hearing.id),
        overrides: [
          hearingSchedulesProvider.overrideWith(
            () => _SingleHearingNotifier(hearing),
          ),
        ],
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows client name in AppBar title', (tester) async {
      await setDesktopViewport(tester);
      final hearing = scheduledHearing();
      await pumpTestWidget(
        tester,
        HearingScreen(hearingId: hearing.id),
        overrides: [
          hearingSchedulesProvider.overrideWith(
            () => _SingleHearingNotifier(hearing),
          ),
        ],
      );

      expect(find.textContaining('Test Client'), findsWidgets);
    });

    testWidgets('shows "Documents to Submit" section header', (tester) async {
      await setDesktopViewport(tester);
      final hearing = scheduledHearing();
      await pumpTestWidget(
        tester,
        HearingScreen(hearingId: hearing.id),
        overrides: [
          hearingSchedulesProvider.overrideWith(
            () => _SingleHearingNotifier(hearing),
          ),
        ],
      );

      expect(find.text('Documents to Submit'), findsOneWidget);
    });

    testWidgets('shows document names when documents present', (tester) async {
      await setDesktopViewport(tester);
      final hearing = scheduledHearing();
      await pumpTestWidget(
        tester,
        HearingScreen(hearingId: hearing.id),
        overrides: [
          hearingSchedulesProvider.overrideWith(
            () => _SingleHearingNotifier(hearing),
          ),
        ],
      );

      expect(find.text('Bank statement'), findsOneWidget);
      expect(find.text('Form 26AS'), findsOneWidget);
    });

    testWidgets('shows Add Document button', (tester) async {
      await setDesktopViewport(tester);
      final hearing = scheduledHearing();
      await pumpTestWidget(
        tester,
        HearingScreen(hearingId: hearing.id),
        overrides: [
          hearingSchedulesProvider.overrideWith(
            () => _SingleHearingNotifier(hearing),
          ),
        ],
      );

      expect(find.text('Add Document'), findsOneWidget);
    });

    testWidgets('shows "Hearing Notes / Minutes" section', (tester) async {
      await setDesktopViewport(tester);
      final hearing = scheduledHearing();
      await pumpTestWidget(
        tester,
        HearingScreen(hearingId: hearing.id),
        overrides: [
          hearingSchedulesProvider.overrideWith(
            () => _SingleHearingNotifier(hearing),
          ),
        ],
      );

      expect(find.text('Hearing Notes / Minutes'), findsOneWidget);
    });

    testWidgets('shows Request Adjournment card for scheduled status', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      final hearing = scheduledHearing();
      await pumpTestWidget(
        tester,
        HearingScreen(hearingId: hearing.id),
        overrides: [
          hearingSchedulesProvider.overrideWith(
            () => _SingleHearingNotifier(hearing),
          ),
        ],
      );

      expect(find.text('Request Adjournment'), findsWidgets);
    });

    testWidgets('shows Mark as Attended button for non-completed hearing', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      final hearing = scheduledHearing();
      await pumpTestWidget(
        tester,
        HearingScreen(hearingId: hearing.id),
        overrides: [
          hearingSchedulesProvider.overrideWith(
            () => _SingleHearingNotifier(hearing),
          ),
        ],
      );

      expect(find.text('Mark as Attended'), findsOneWidget);
    });
  });

  group('HearingScreen - completed hearing', () {
    testWidgets('shows "Hearing completed" banner for completed status', (
      tester,
    ) async {
      await setDesktopViewport(tester);
      final hearing = completedHearing();
      await pumpTestWidget(
        tester,
        HearingScreen(hearingId: hearing.id),
        overrides: [
          hearingSchedulesProvider.overrideWith(
            () => _SingleHearingNotifier(hearing),
          ),
        ],
      );

      expect(find.text('Hearing completed'), findsOneWidget);
    });

    testWidgets('shows existing notes when present', (tester) async {
      await setDesktopViewport(tester);
      final hearing = completedHearing();
      await pumpTestWidget(
        tester,
        HearingScreen(hearingId: hearing.id),
        overrides: [
          hearingSchedulesProvider.overrideWith(
            () => _SingleHearingNotifier(hearing),
          ),
        ],
      );

      expect(find.text('Hearing went well'), findsOneWidget);
    });

    testWidgets(
      'shows "No documents required" when documentsToSubmit is empty',
      (tester) async {
        await setDesktopViewport(tester);
        final hearing = completedHearing();
        await pumpTestWidget(
          tester,
          HearingScreen(hearingId: hearing.id),
          overrides: [
            hearingSchedulesProvider.overrideWith(
              () => _SingleHearingNotifier(hearing),
            ),
          ],
        );

        expect(find.text('No documents required'), findsOneWidget);
      },
    );
  });

  group('HearingScreen - adjourned hearing', () {
    testWidgets('shows adjourned banner for adjourned status', (tester) async {
      await setDesktopViewport(tester);
      final hearing = adjournedHearing();
      await pumpTestWidget(
        tester,
        HearingScreen(hearingId: hearing.id),
        overrides: [
          hearingSchedulesProvider.overrideWith(
            () => _SingleHearingNotifier(hearing),
          ),
        ],
      );

      expect(find.textContaining('Adjourned'), findsWidgets);
    });
  });
}

// ---------------------------------------------------------------------------
// Test notifiers
// ---------------------------------------------------------------------------

class _EmptyHearingsNotifier extends HearingSchedulesNotifier {
  @override
  List<HearingSchedule> build() => [];
}

class _SingleHearingNotifier extends HearingSchedulesNotifier {
  _SingleHearingNotifier(this._hearing);

  final HearingSchedule _hearing;

  @override
  List<HearingSchedule> build() => [_hearing];
}
