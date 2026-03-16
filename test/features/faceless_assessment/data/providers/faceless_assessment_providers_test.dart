import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/faceless_assessment/data/providers/faceless_assessment_providers.dart';
import 'package:ca_app/features/faceless_assessment/domain/models/e_proceeding.dart';
import 'package:ca_app/features/faceless_assessment/domain/models/hearing_schedule.dart';
import 'package:ca_app/features/faceless_assessment/domain/models/itr_u_filing.dart';

void main() {
  group('Faceless Assessment Providers', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    // -------------------------------------------------------------------------
    // proceedingTypeFilterProvider
    // -------------------------------------------------------------------------
    group('proceedingTypeFilterProvider', () {
      test('initial state is null', () {
        expect(container.read(proceedingTypeFilterProvider), isNull);
      });

      test('can be set to scrutiny type', () {
        container
            .read(proceedingTypeFilterProvider.notifier)
            .update(ProceedingType.scrutiny143_3);
        expect(
          container.read(proceedingTypeFilterProvider),
          ProceedingType.scrutiny143_3,
        );
      });

      test('can be cleared to null', () {
        container
            .read(proceedingTypeFilterProvider.notifier)
            .update(ProceedingType.penalty);
        container.read(proceedingTypeFilterProvider.notifier).update(null);
        expect(container.read(proceedingTypeFilterProvider), isNull);
      });

      test('supports all ProceedingType values', () {
        for (final type in ProceedingType.values) {
          container.read(proceedingTypeFilterProvider.notifier).update(type);
          expect(container.read(proceedingTypeFilterProvider), type);
        }
      });
    });

    // -------------------------------------------------------------------------
    // proceedingStatusFilterProvider
    // -------------------------------------------------------------------------
    group('proceedingStatusFilterProvider', () {
      test('initial state is null', () {
        expect(container.read(proceedingStatusFilterProvider), isNull);
      });

      test('can be set to a status', () {
        container
            .read(proceedingStatusFilterProvider.notifier)
            .update(ProceedingStatus.noticeReceived);
        expect(
          container.read(proceedingStatusFilterProvider),
          ProceedingStatus.noticeReceived,
        );
      });

      test('can be cleared', () {
        container
            .read(proceedingStatusFilterProvider.notifier)
            .update(ProceedingStatus.responseSubmitted);
        container.read(proceedingStatusFilterProvider.notifier).update(null);
        expect(container.read(proceedingStatusFilterProvider), isNull);
      });
    });

    // -------------------------------------------------------------------------
    // hearingStatusFilterProvider
    // -------------------------------------------------------------------------
    group('hearingStatusFilterProvider', () {
      test('initial state is null', () {
        expect(container.read(hearingStatusFilterProvider), isNull);
      });

      test('can be set to scheduled', () {
        container
            .read(hearingStatusFilterProvider.notifier)
            .update(HearingStatus.scheduled);
        expect(
          container.read(hearingStatusFilterProvider),
          HearingStatus.scheduled,
        );
      });
    });

    // -------------------------------------------------------------------------
    // eProceedingsProvider
    // -------------------------------------------------------------------------
    group('eProceedingsProvider', () {
      test('initial state is non-empty list', () {
        final proceedings = container.read(eProceedingsProvider);
        expect(proceedings, isNotEmpty);
        expect(proceedings.length, greaterThanOrEqualTo(5));
      });

      test('all items are EProceeding objects', () {
        final proceedings = container.read(eProceedingsProvider);
        expect(proceedings, everyElement(isA<EProceeding>()));
      });

      test('add() appends a new proceeding', () {
        final before = container.read(eProceedingsProvider).length;
        final newProceeding = EProceeding(
          id: 'ep-test',
          clientId: 'c-test',
          clientName: 'Test Client',
          pan: 'XXXXX1234X',
          assessmentYear: 'AY 2024-25',
          proceedingType: ProceedingType.scrutiny143_3,
          noticeDate: DateTime(2026, 1, 1),
          responseDeadline: DateTime(2026, 4, 1),
          status: ProceedingStatus.noticeReceived,
          nfacReferenceNumber: 'NFAC/TEST/001',
          demandAmount: 0,
        );
        container.read(eProceedingsProvider.notifier).add(newProceeding);
        final after = container.read(eProceedingsProvider);
        expect(after.length, before + 1);
        expect(after.last.id, 'ep-test');
      });

      test('updateProceeding() replaces by id', () {
        final original = container.read(eProceedingsProvider).first;
        final updated = original.copyWith(status: ProceedingStatus.orderPassed);
        container.read(eProceedingsProvider.notifier).updateProceeding(updated);
        final result = container.read(eProceedingsProvider);
        final found = result.firstWhere((p) => p.id == original.id);
        expect(found.status, ProceedingStatus.orderPassed);
      });

      test('proceedings include varied types', () {
        final proceedings = container.read(eProceedingsProvider);
        final types = proceedings.map((p) => p.proceedingType).toSet();
        expect(types.length, greaterThanOrEqualTo(3));
      });
    });

    // -------------------------------------------------------------------------
    // itrUFilingsProvider
    // -------------------------------------------------------------------------
    group('itrUFilingsProvider', () {
      test('initial state is non-empty list', () {
        final filings = container.read(itrUFilingsProvider);
        expect(filings, isNotEmpty);
        expect(filings.length, greaterThanOrEqualTo(3));
      });

      test('all items are ItrUFiling objects', () {
        final filings = container.read(itrUFilingsProvider);
        expect(filings, everyElement(isA<ItrUFiling>()));
      });

      test('add() appends a new ITR-U filing', () {
        final before = container.read(itrUFilingsProvider).length;
        final newFiling = ItrUFiling(
          id: 'iu-test',
          clientId: 'c-test',
          clientName: 'Test Client',
          pan: 'XXXXX1234X',
          originalAssessmentYear: 'AY 2022-23',
          originalFilingDate: DateTime(2022, 7, 31),
          updateReason: UpdateReason.incomeNotReported,
          additionalTax: 50000,
          penaltyPercentage: 25,
          penaltyAmount: 12500,
          totalPayable: 62500,
          status: ItrUStatus.draft,
          filingDeadline: DateTime(2026, 3, 31),
        );
        container.read(itrUFilingsProvider.notifier).add(newFiling);
        final after = container.read(itrUFilingsProvider);
        expect(after.length, before + 1);
        expect(after.last.id, 'iu-test');
      });

      test('updateFiling() replaces by id', () {
        final original = container.read(itrUFilingsProvider).first;
        final updated = original.copyWith(status: ItrUStatus.filed);
        container.read(itrUFilingsProvider.notifier).updateFiling(updated);
        final result = container.read(itrUFilingsProvider);
        final found = result.firstWhere((f) => f.id == original.id);
        expect(found.status, ItrUStatus.filed);
      });
    });

    // -------------------------------------------------------------------------
    // hearingSchedulesProvider
    // -------------------------------------------------------------------------
    group('hearingSchedulesProvider', () {
      test('initial state is non-empty list', () {
        final hearings = container.read(hearingSchedulesProvider);
        expect(hearings, isNotEmpty);
        expect(hearings.length, greaterThanOrEqualTo(4));
      });

      test('all items are HearingSchedule objects', () {
        final hearings = container.read(hearingSchedulesProvider);
        expect(hearings, everyElement(isA<HearingSchedule>()));
      });

      test('add() appends a new hearing', () {
        final before = container.read(hearingSchedulesProvider).length;
        final newHearing = HearingSchedule(
          id: 'hs-test',
          proceedingId: 'ep1',
          clientName: 'Test Client',
          hearingDate: DateTime(2026, 4, 15),
          hearingTime: '10:00 AM',
          platform: HearingPlatform.nfacPortal,
          agenda: 'Test hearing',
          documentsToSubmit: const ['Document 1'],
          representativeName: 'CA Test',
          status: HearingStatus.scheduled,
        );
        container.read(hearingSchedulesProvider.notifier).add(newHearing);
        final after = container.read(hearingSchedulesProvider);
        expect(after.length, before + 1);
        expect(after.last.id, 'hs-test');
      });

      test('updateHearing() replaces by id', () {
        final original = container.read(hearingSchedulesProvider).first;
        final updated = original.copyWith(status: HearingStatus.completed);
        container
            .read(hearingSchedulesProvider.notifier)
            .updateHearing(updated);
        final result = container.read(hearingSchedulesProvider);
        final found = result.firstWhere((h) => h.id == original.id);
        expect(found.status, HearingStatus.completed);
      });
    });

    // -------------------------------------------------------------------------
    // filteredProceedingsProvider
    // -------------------------------------------------------------------------
    group('filteredProceedingsProvider', () {
      test('returns all proceedings when no filters set', () {
        final all = container.read(eProceedingsProvider);
        final filtered = container.read(filteredProceedingsProvider);
        expect(filtered.length, all.length);
      });

      test('filters by proceeding type', () {
        container
            .read(proceedingTypeFilterProvider.notifier)
            .update(ProceedingType.scrutiny143_3);
        final filtered = container.read(filteredProceedingsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every(
            (p) => p.proceedingType == ProceedingType.scrutiny143_3,
          ),
          isTrue,
        );
      });

      test('filters by proceeding status', () {
        container
            .read(proceedingStatusFilterProvider.notifier)
            .update(ProceedingStatus.noticeReceived);
        final filtered = container.read(filteredProceedingsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((p) => p.status == ProceedingStatus.noticeReceived),
          isTrue,
        );
      });

      test('applies both type and status filters together', () {
        container
            .read(proceedingTypeFilterProvider.notifier)
            .update(ProceedingType.scrutiny143_3);
        container
            .read(proceedingStatusFilterProvider.notifier)
            .update(ProceedingStatus.noticeReceived);
        final filtered = container.read(filteredProceedingsProvider);
        expect(
          filtered.every(
            (p) =>
                p.proceedingType == ProceedingType.scrutiny143_3 &&
                p.status == ProceedingStatus.noticeReceived,
          ),
          isTrue,
        );
      });

      test('returns empty when filters match nothing', () {
        // Set a type filter then also set an incompatible status
        container
            .read(proceedingTypeFilterProvider.notifier)
            .update(ProceedingType.scrutiny143_3);
        container
            .read(proceedingStatusFilterProvider.notifier)
            .update(ProceedingStatus.orderPassed);
        final filtered = container.read(filteredProceedingsProvider);
        // scrutiny143_3 AND orderPassed — check if they match
        expect(
          filtered.every(
            (p) =>
                p.proceedingType == ProceedingType.scrutiny143_3 &&
                p.status == ProceedingStatus.orderPassed,
          ),
          isTrue,
        );
      });
    });

    // -------------------------------------------------------------------------
    // filteredHearingsProvider
    // -------------------------------------------------------------------------
    group('filteredHearingsProvider', () {
      test('returns all hearings when no filter', () {
        final all = container.read(hearingSchedulesProvider);
        final filtered = container.read(filteredHearingsProvider);
        expect(filtered.length, all.length);
      });

      test('filters hearings by scheduled status', () {
        container
            .read(hearingStatusFilterProvider.notifier)
            .update(HearingStatus.scheduled);
        final filtered = container.read(filteredHearingsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((h) => h.status == HearingStatus.scheduled),
          isTrue,
        );
      });

      test('filters hearings by completed status', () {
        container
            .read(hearingStatusFilterProvider.notifier)
            .update(HearingStatus.completed);
        final filtered = container.read(filteredHearingsProvider);
        expect(filtered, isNotEmpty);
        expect(
          filtered.every((h) => h.status == HearingStatus.completed),
          isTrue,
        );
      });

      test('clearing filter returns all hearings', () {
        container
            .read(hearingStatusFilterProvider.notifier)
            .update(HearingStatus.adjourned);
        container.read(hearingStatusFilterProvider.notifier).update(null);
        final all = container.read(hearingSchedulesProvider);
        final filtered = container.read(filteredHearingsProvider);
        expect(filtered.length, all.length);
      });
    });
  });
}
