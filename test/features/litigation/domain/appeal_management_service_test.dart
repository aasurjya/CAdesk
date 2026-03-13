import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/litigation/domain/models/tax_notice.dart';
import 'package:ca_app/features/litigation/domain/models/appeal_case.dart';
import 'package:ca_app/features/litigation/domain/models/appeal_stage.dart';
import 'package:ca_app/features/litigation/domain/services/appeal_management_service.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  TaxNotice makeNotice({
    String noticeId = 'N001',
    NoticeType noticeType = NoticeType.assessment143_3,
    int demandAmount = 50_000_000, // ₹5L
    String assessmentYear = '2023-24',
    String pan = 'ABCDE1234F',
  }) {
    return TaxNotice(
      noticeId: noticeId,
      pan: pan,
      assessmentYear: assessmentYear,
      noticeType: noticeType,
      issuedBy: 'ITO',
      issuedDate: DateTime(2026, 1, 1),
      responseDeadline: DateTime(2026, 2, 1),
      demandAmount: demandAmount,
      section: '143(3)',
      status: NoticeStatus.received,
    );
  }

  // ---------------------------------------------------------------------------
  // createAppeal
  // ---------------------------------------------------------------------------

  group('AppealManagementService.createAppeal', () {
    test('creates appeal with correct PAN and AY from notice', () {
      final notice = makeNotice(pan: 'XYZPQ9876G', assessmentYear: '2022-23');
      final appeal = AppealManagementService.createAppeal(
        notice,
        'Addition without jurisdiction',
      );
      expect(appeal.pan, 'XYZPQ9876G');
      expect(appeal.assessmentYear, '2022-23');
    });

    test('new appeal starts at CIT(A) forum', () {
      final notice = makeNotice();
      final appeal = AppealManagementService.createAppeal(notice, 'grounds');
      expect(appeal.currentForum, AppealForum.cita);
    });

    test('new appeal status is pending', () {
      final notice = makeNotice();
      final appeal = AppealManagementService.createAppeal(notice, 'grounds');
      expect(appeal.status, AppealStatus.pending);
    });

    test('originalDemand matches notice demandAmount', () {
      final notice = makeNotice(demandAmount: 80_000_000);
      final appeal = AppealManagementService.createAppeal(notice, 'grounds');
      expect(appeal.originalDemand, 80_000_000);
    });

    test('amountInDispute defaults to originalDemand on creation', () {
      final notice = makeNotice(demandAmount: 30_000_000);
      final appeal = AppealManagementService.createAppeal(notice, 'grounds');
      expect(appeal.amountInDispute, 30_000_000);
    });

    test('filingDate is set', () {
      final notice = makeNotice();
      final appeal = AppealManagementService.createAppeal(notice, 'grounds');
      expect(appeal.filingDate, isNotNull);
    });

    test('history is empty on creation', () {
      final notice = makeNotice();
      final appeal = AppealManagementService.createAppeal(notice, 'grounds');
      expect(appeal.history, isEmpty);
    });

    test('caseId is non-empty', () {
      final notice = makeNotice();
      final appeal = AppealManagementService.createAppeal(notice, 'grounds');
      expect(appeal.caseId, isNotEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // transitionAppeal
  // ---------------------------------------------------------------------------

  group('AppealManagementService.transitionAppeal', () {
    AppealCase baseAppeal() {
      return AppealManagementService.createAppeal(makeNotice(), 'Test grounds');
    }

    test('filed event keeps status pending', () {
      final appeal = baseAppeal();
      final updated = AppealManagementService.transitionAppeal(
        appeal,
        AppealEvent.filed,
      );
      expect(updated.status, AppealStatus.pending);
    });

    test('admitted event updates status to admitted', () {
      final appeal = baseAppeal();
      final updated = AppealManagementService.transitionAppeal(
        appeal,
        AppealEvent.admitted,
      );
      expect(updated.status, AppealStatus.admitted);
    });

    test('hearingScheduled event sets hearingDate', () {
      final appeal = baseAppeal();
      final updated = AppealManagementService.transitionAppeal(
        appeal,
        AppealEvent.hearingScheduled,
        hearingDate: DateTime(2026, 6, 15),
      );
      expect(updated.hearingDate, DateTime(2026, 6, 15));
    });

    test('orderPassed with partial relief → partialRelief status', () {
      final appeal = baseAppeal();
      final updated = AppealManagementService.transitionAppeal(
        appeal,
        AppealEvent.orderPassed,
        outcome: StageOutcome.partiallyAllowed,
        reliefGranted: 10_000_000,
        orderSummary: 'Partial relief granted',
        orderDate: DateTime(2026, 8, 1),
      );
      expect(updated.status, AppealStatus.partialRelief);
    });

    test('orderPassed with full relief → fullRelief status', () {
      final appeal = baseAppeal();
      final updated = AppealManagementService.transitionAppeal(
        appeal,
        AppealEvent.orderPassed,
        outcome: StageOutcome.allowed,
        reliefGranted: 50_000_000,
        orderSummary: 'Full relief granted',
        orderDate: DateTime(2026, 8, 1),
      );
      expect(updated.status, AppealStatus.fullRelief);
    });

    test('orderPassed dismissed → dismissed status', () {
      final appeal = baseAppeal();
      final updated = AppealManagementService.transitionAppeal(
        appeal,
        AppealEvent.orderPassed,
        outcome: StageOutcome.dismissed,
        reliefGranted: 0,
        orderSummary: 'Appeal dismissed',
        orderDate: DateTime(2026, 8, 1),
      );
      expect(updated.status, AppealStatus.dismissed);
    });

    test('furtherAppeal transitions forum from CIT(A) to ITAT', () {
      final appeal = baseAppeal();
      final withOrder = AppealManagementService.transitionAppeal(
        appeal,
        AppealEvent.orderPassed,
        outcome: StageOutcome.dismissed,
        reliefGranted: 0,
        orderSummary: 'Dismissed',
        orderDate: DateTime(2026, 8, 1),
      );
      final elevated = AppealManagementService.transitionAppeal(
        withOrder,
        AppealEvent.furtherAppeal,
      );
      expect(elevated.currentForum, AppealForum.itat);
    });

    test('furtherAppeal transitions forum from ITAT to HC', () {
      final base = AppealCase(
        caseId: 'C1',
        pan: 'ABCDE1234F',
        assessmentYear: '2023-24',
        currentForum: AppealForum.itat,
        originalDemand: 50_000_000,
        amountInDispute: 50_000_000,
        filingDate: DateTime(2026, 1, 1),
        status: AppealStatus.dismissed,
        nextAction: 'File HC appeal',
        history: const [],
      );
      final elevated = AppealManagementService.transitionAppeal(
        base,
        AppealEvent.furtherAppeal,
      );
      expect(elevated.currentForum, AppealForum.highCourt);
    });

    test('furtherAppeal from HC → SC', () {
      final base = AppealCase(
        caseId: 'C2',
        pan: 'ABCDE1234F',
        assessmentYear: '2023-24',
        currentForum: AppealForum.highCourt,
        originalDemand: 50_000_000,
        amountInDispute: 50_000_000,
        filingDate: DateTime(2026, 1, 1),
        status: AppealStatus.dismissed,
        nextAction: 'File SC appeal',
        history: const [],
      );
      final elevated = AppealManagementService.transitionAppeal(
        base,
        AppealEvent.furtherAppeal,
      );
      expect(elevated.currentForum, AppealForum.supremeCourt);
    });

    test('withdrawn event → withdrawn status', () {
      final appeal = baseAppeal();
      final updated = AppealManagementService.transitionAppeal(
        appeal,
        AppealEvent.withdrawn,
      );
      expect(updated.status, AppealStatus.withdrawn);
    });

    test('transition is immutable — original not mutated', () {
      final appeal = baseAppeal();
      final originalStatus = appeal.status;
      AppealManagementService.transitionAppeal(appeal, AppealEvent.admitted);
      expect(appeal.status, originalStatus);
    });

    test('orderPassed appends stage to history', () {
      final appeal = baseAppeal();
      final updated = AppealManagementService.transitionAppeal(
        appeal,
        AppealEvent.orderPassed,
        outcome: StageOutcome.dismissed,
        reliefGranted: 0,
        orderSummary: 'Dismissed',
        orderDate: DateTime(2026, 8, 1),
      );
      expect(updated.history.length, 1);
    });
  });

  // ---------------------------------------------------------------------------
  // computeStatuteOfLimitations
  // ---------------------------------------------------------------------------

  group('AppealManagementService.computeStatuteOfLimitations', () {
    test('CIT(A) — 30 days from last order date in history', () {
      final orderDate = DateTime(2026, 5, 1);
      final stage = AppealStage(
        forum: AppealForum.ao,
        outcome: StageOutcome.dismissed,
        orderDate: orderDate,
        orderSummary: 'AO order',
        reliefGranted: 0,
      );
      final appeal = AppealCase(
        caseId: 'C3',
        pan: 'ABCDE1234F',
        assessmentYear: '2023-24',
        currentForum: AppealForum.cita,
        originalDemand: 50_000_000,
        amountInDispute: 50_000_000,
        filingDate: DateTime(2026, 1, 1),
        status: AppealStatus.pending,
        nextAction: 'File CIT(A)',
        history: [stage],
      );
      final deadline = AppealManagementService.computeStatuteOfLimitations(
        appeal,
      );
      expect(deadline, DateTime(2026, 5, 31));
    });

    test('ITAT — 60 days from last CIT(A) order', () {
      final orderDate = DateTime(2026, 5, 1);
      final stage = AppealStage(
        forum: AppealForum.cita,
        outcome: StageOutcome.dismissed,
        orderDate: orderDate,
        orderSummary: 'CIT(A) dismissed',
        reliefGranted: 0,
      );
      final appeal = AppealCase(
        caseId: 'C4',
        pan: 'ABCDE1234F',
        assessmentYear: '2023-24',
        currentForum: AppealForum.itat,
        originalDemand: 50_000_000,
        amountInDispute: 50_000_000,
        filingDate: DateTime(2026, 1, 1),
        status: AppealStatus.pending,
        nextAction: 'File ITAT',
        history: [stage],
      );
      final deadline = AppealManagementService.computeStatuteOfLimitations(
        appeal,
      );
      expect(deadline, DateTime(2026, 6, 30));
    });

    test('HC — 120 days from last ITAT order', () {
      final orderDate = DateTime(2026, 5, 1);
      final stage = AppealStage(
        forum: AppealForum.itat,
        outcome: StageOutcome.dismissed,
        orderDate: orderDate,
        orderSummary: 'ITAT dismissed',
        reliefGranted: 0,
      );
      final appeal = AppealCase(
        caseId: 'C5',
        pan: 'ABCDE1234F',
        assessmentYear: '2023-24',
        currentForum: AppealForum.highCourt,
        originalDemand: 50_000_000,
        amountInDispute: 50_000_000,
        filingDate: DateTime(2026, 1, 1),
        status: AppealStatus.pending,
        nextAction: 'File HC',
        history: [stage],
      );
      final deadline = AppealManagementService.computeStatuteOfLimitations(
        appeal,
      );
      expect(deadline, DateTime(2026, 8, 29));
    });
  });

  // ---------------------------------------------------------------------------
  // getAppealLadder
  // ---------------------------------------------------------------------------

  group('AppealManagementService.getAppealLadder', () {
    test('from AO level → remaining: cita, itat, HC, SC', () {
      final appeal = AppealCase(
        caseId: 'C6',
        pan: 'ABCDE1234F',
        assessmentYear: '2023-24',
        currentForum: AppealForum.ao,
        originalDemand: 50_000_000,
        amountInDispute: 50_000_000,
        filingDate: DateTime(2026, 1, 1),
        status: AppealStatus.pending,
        nextAction: '',
        history: const [],
      );
      final ladder = AppealManagementService.getAppealLadder(appeal);
      expect(ladder, [
        AppealForum.cita,
        AppealForum.itat,
        AppealForum.highCourt,
        AppealForum.supremeCourt,
      ]);
    });

    test('from CIT(A) level → remaining: itat, HC, SC', () {
      final appeal = AppealCase(
        caseId: 'C7',
        pan: 'ABCDE1234F',
        assessmentYear: '2023-24',
        currentForum: AppealForum.cita,
        originalDemand: 50_000_000,
        amountInDispute: 50_000_000,
        filingDate: DateTime(2026, 1, 1),
        status: AppealStatus.pending,
        nextAction: '',
        history: const [],
      );
      final ladder = AppealManagementService.getAppealLadder(appeal);
      expect(ladder, [
        AppealForum.itat,
        AppealForum.highCourt,
        AppealForum.supremeCourt,
      ]);
    });

    test('from SC level → empty ladder', () {
      final appeal = AppealCase(
        caseId: 'C8',
        pan: 'ABCDE1234F',
        assessmentYear: '2023-24',
        currentForum: AppealForum.supremeCourt,
        originalDemand: 50_000_000,
        amountInDispute: 50_000_000,
        filingDate: DateTime(2026, 1, 1),
        status: AppealStatus.pending,
        nextAction: '',
        history: const [],
      );
      final ladder = AppealManagementService.getAppealLadder(appeal);
      expect(ladder, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // computePreDepositRequired
  // ---------------------------------------------------------------------------

  group('AppealManagementService.computePreDepositRequired', () {
    test('ITAT forum → 20% of amountInDispute', () {
      final appeal = AppealCase(
        caseId: 'C9',
        pan: 'ABCDE1234F',
        assessmentYear: '2023-24',
        currentForum: AppealForum.itat,
        originalDemand: 50_000_000,
        amountInDispute: 50_000_000,
        filingDate: DateTime(2026, 1, 1),
        status: AppealStatus.pending,
        nextAction: '',
        history: const [],
      );
      final preDeposit = AppealManagementService.computePreDepositRequired(
        appeal,
      );
      expect(preDeposit, 10_000_000); // 20% of 50L
    });

    test('CIT(A) forum → 0 pre-deposit', () {
      final appeal = AppealCase(
        caseId: 'C10',
        pan: 'ABCDE1234F',
        assessmentYear: '2023-24',
        currentForum: AppealForum.cita,
        originalDemand: 50_000_000,
        amountInDispute: 50_000_000,
        filingDate: DateTime(2026, 1, 1),
        status: AppealStatus.pending,
        nextAction: '',
        history: const [],
      );
      final preDeposit = AppealManagementService.computePreDepositRequired(
        appeal,
      );
      expect(preDeposit, 0);
    });

    test('HC forum → 0 pre-deposit', () {
      final appeal = AppealCase(
        caseId: 'C11',
        pan: 'ABCDE1234F',
        assessmentYear: '2023-24',
        currentForum: AppealForum.highCourt,
        originalDemand: 50_000_000,
        amountInDispute: 30_000_000,
        filingDate: DateTime(2026, 1, 1),
        status: AppealStatus.pending,
        nextAction: '',
        history: const [],
      );
      final preDeposit = AppealManagementService.computePreDepositRequired(
        appeal,
      );
      expect(preDeposit, 0);
    });
  });

  // ---------------------------------------------------------------------------
  // AppealCase model immutability
  // ---------------------------------------------------------------------------

  group('AppealCase model', () {
    final base = AppealCase(
      caseId: 'BASE',
      pan: 'ABCDE1234F',
      assessmentYear: '2023-24',
      currentForum: AppealForum.cita,
      originalDemand: 50_000_000,
      amountInDispute: 50_000_000,
      filingDate: DateTime(2026, 1, 1),
      status: AppealStatus.pending,
      nextAction: 'File CIT(A)',
      history: const [],
    );

    test('copyWith returns new instance with updated field', () {
      final updated = base.copyWith(status: AppealStatus.admitted);
      expect(updated.status, AppealStatus.admitted);
      expect(base.status, AppealStatus.pending);
    });

    test('equality by caseId', () {
      final a = base.copyWith();
      expect(a, equals(base));
    });

    test('different caseId → not equal', () {
      final other = base.copyWith(caseId: 'OTHER');
      expect(other, isNot(equals(base)));
    });
  });

  // ---------------------------------------------------------------------------
  // AppealStage model immutability
  // ---------------------------------------------------------------------------

  group('AppealStage model', () {
    const stage = AppealStage(
      forum: AppealForum.cita,
      outcome: StageOutcome.pending,
      orderDate: null,
      orderSummary: null,
      reliefGranted: 0,
    );

    test('copyWith returns new instance', () {
      final updated = stage.copyWith(outcome: StageOutcome.dismissed);
      expect(updated.outcome, StageOutcome.dismissed);
      expect(stage.outcome, StageOutcome.pending);
    });

    test('equality by all fields', () {
      const s2 = AppealStage(
        forum: AppealForum.cita,
        outcome: StageOutcome.pending,
        orderDate: null,
        orderSummary: null,
        reliefGranted: 0,
      );
      expect(stage, equals(s2));
    });
  });
}
