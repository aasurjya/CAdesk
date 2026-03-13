import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/litigation/domain/models/tax_notice.dart';
import 'package:ca_app/features/litigation/domain/models/notice_triage_result.dart';
import 'package:ca_app/features/litigation/domain/services/notice_triage_service.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  TaxNotice makeNotice({
    String noticeId = 'N001',
    String pan = 'ABCDE1234F',
    String assessmentYear = '2023-24',
    NoticeType noticeType = NoticeType.intimation143_1,
    DateTime? issuedDate,
    DateTime? responseDeadline,
    int? demandAmount,
    String section = '143(1)',
    NoticeStatus status = NoticeStatus.received,
    String issuedBy = 'CPC Bengaluru',
  }) {
    final issued = issuedDate ?? DateTime(2026, 1, 1);
    final deadline = responseDeadline ?? DateTime(2026, 2, 1);
    return TaxNotice(
      noticeId: noticeId,
      pan: pan,
      assessmentYear: assessmentYear,
      noticeType: noticeType,
      issuedBy: issuedBy,
      issuedDate: issued,
      responseDeadline: deadline,
      demandAmount: demandAmount,
      section: section,
      status: status,
    );
  }

  // ---------------------------------------------------------------------------
  // assessRisk
  // ---------------------------------------------------------------------------

  group('NoticeTriageService.assessRisk', () {
    test('demand > 10L (₹10,00,000 = 100000000 paise) → critical', () {
      final notice = makeNotice(demandAmount: 100_000_001);
      expect(NoticeTriageService.assessRisk(notice), RiskLevel.critical);
    });

    test('demand exactly 10L → critical (boundary)', () {
      final notice = makeNotice(demandAmount: 100_000_000);
      expect(NoticeTriageService.assessRisk(notice), RiskLevel.critical);
    });

    test('search & seizure notice → critical regardless of demand', () {
      final notice = makeNotice(
        noticeType: NoticeType.searchSeizure,
        demandAmount: 0,
      );
      expect(NoticeTriageService.assessRisk(notice), RiskLevel.critical);
    });

    test('demand between 1L and 10L → high', () {
      final notice = makeNotice(demandAmount: 50_000_000); // ₹5L
      expect(NoticeTriageService.assessRisk(notice), RiskLevel.high);
    });

    test('demand exactly 1L (10000000 paise) → high (boundary)', () {
      final notice = makeNotice(demandAmount: 10_000_000);
      expect(NoticeTriageService.assessRisk(notice), RiskLevel.high);
    });

    test('reopening notice 148 → high', () {
      final notice = makeNotice(
        noticeType: NoticeType.reopening148,
        demandAmount: null,
      );
      expect(NoticeTriageService.assessRisk(notice), RiskLevel.high);
    });

    test('143(1) intimation with small demand → medium', () {
      final notice = makeNotice(
        noticeType: NoticeType.intimation143_1,
        demandAmount: 5_000_000, // ₹50k
      );
      expect(NoticeTriageService.assessRisk(notice), RiskLevel.medium);
    });

    test('penalty notice 156 → medium', () {
      final notice = makeNotice(
        noticeType: NoticeType.penalty156,
        demandAmount: 1_000_000, // ₹10k
      );
      expect(NoticeTriageService.assessRisk(notice), RiskLevel.medium);
    });

    test('show cause notice with no demand → low', () {
      final notice = makeNotice(
        noticeType: NoticeType.showCause,
        demandAmount: null,
      );
      expect(NoticeTriageService.assessRisk(notice), RiskLevel.low);
    });

    test('null demand with non-critical type → low', () {
      final notice = makeNotice(
        noticeType: NoticeType.intimation143_1,
        demandAmount: null,
      );
      expect(NoticeTriageService.assessRisk(notice), RiskLevel.low);
    });
  });

  // ---------------------------------------------------------------------------
  // computeUrgency
  // ---------------------------------------------------------------------------

  group('NoticeTriageService.computeUrgency', () {
    test('< 7 days to deadline → critical', () {
      final deadline = DateTime(2026, 3, 15);
      final today = DateTime(2026, 3, 10); // 5 days before
      final notice = makeNotice(responseDeadline: deadline);
      expect(
        NoticeTriageService.computeUrgency(notice, today),
        UrgencyLevel.critical,
      );
    });

    test('exactly 7 days to deadline → critical (boundary)', () {
      final deadline = DateTime(2026, 3, 17);
      final today = DateTime(2026, 3, 10);
      final notice = makeNotice(responseDeadline: deadline);
      expect(
        NoticeTriageService.computeUrgency(notice, today),
        UrgencyLevel.critical,
      );
    });

    test('8 days to deadline → high', () {
      final deadline = DateTime(2026, 3, 18);
      final today = DateTime(2026, 3, 10);
      final notice = makeNotice(responseDeadline: deadline);
      expect(
        NoticeTriageService.computeUrgency(notice, today),
        UrgencyLevel.high,
      );
    });

    test('15 days to deadline → high (boundary)', () {
      final deadline = DateTime(2026, 3, 25);
      final today = DateTime(2026, 3, 10);
      final notice = makeNotice(responseDeadline: deadline);
      expect(
        NoticeTriageService.computeUrgency(notice, today),
        UrgencyLevel.high,
      );
    });

    test('16 days to deadline → medium', () {
      final deadline = DateTime(2026, 3, 26);
      final today = DateTime(2026, 3, 10);
      final notice = makeNotice(responseDeadline: deadline);
      expect(
        NoticeTriageService.computeUrgency(notice, today),
        UrgencyLevel.medium,
      );
    });

    test('30 days to deadline → medium (boundary)', () {
      final deadline = DateTime(2026, 4, 9);
      final today = DateTime(2026, 3, 10);
      final notice = makeNotice(responseDeadline: deadline);
      expect(
        NoticeTriageService.computeUrgency(notice, today),
        UrgencyLevel.medium,
      );
    });

    test('31 days to deadline → low', () {
      final deadline = DateTime(2026, 4, 10);
      final today = DateTime(2026, 3, 10);
      final notice = makeNotice(responseDeadline: deadline);
      expect(
        NoticeTriageService.computeUrgency(notice, today),
        UrgencyLevel.low,
      );
    });

    test('past deadline → critical', () {
      final deadline = DateTime(2026, 3, 1);
      final today = DateTime(2026, 3, 10);
      final notice = makeNotice(responseDeadline: deadline);
      expect(
        NoticeTriageService.computeUrgency(notice, today),
        UrgencyLevel.critical,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // suggestGrounds
  // ---------------------------------------------------------------------------

  group('NoticeTriageService.suggestGrounds', () {
    test('143(1) notice → TDS / advance tax / arithmetical error grounds', () {
      final notice = makeNotice(noticeType: NoticeType.intimation143_1);
      final grounds = NoticeTriageService.suggestGrounds(notice);
      expect(grounds, contains('TDS credit mismatch'));
      expect(grounds, contains('Advance tax credit not given'));
      expect(grounds, contains('Arithmetical error'));
    });

    test('143(3) scrutiny → addition without jurisdiction etc.', () {
      final notice = makeNotice(noticeType: NoticeType.assessment143_3);
      final grounds = NoticeTriageService.suggestGrounds(notice);
      expect(grounds, contains('Addition without jurisdiction'));
      expect(grounds, contains('No opportunity of hearing'));
      expect(grounds, contains('Addition based on estimate'));
    });

    test(
      '148 reopening → limitation / tangible material / change of opinion',
      () {
        final notice = makeNotice(noticeType: NoticeType.reopening148);
        final grounds = NoticeTriageService.suggestGrounds(notice);
        expect(grounds, contains('Reassessment beyond limitation period'));
        expect(grounds, contains('No tangible material'));
        expect(grounds, contains('Change of opinion'));
      },
    );

    test(
      'penalty notice 156 → bona fide / reasonable cause / no concealment',
      () {
        final notice = makeNotice(noticeType: NoticeType.penalty156);
        final grounds = NoticeTriageService.suggestGrounds(notice);
        expect(grounds, contains('Bona fide belief'));
        expect(grounds, contains('Reasonable cause'));
        expect(grounds, contains('No concealment intent'));
      },
    );

    test('show cause notice → bona fide / reasonable cause grounds', () {
      final notice = makeNotice(noticeType: NoticeType.showCause);
      final grounds = NoticeTriageService.suggestGrounds(notice);
      expect(grounds, isNotEmpty);
    });

    test('scrutiny 143(2) notice → grounds for scrutiny response', () {
      final notice = makeNotice(noticeType: NoticeType.scrutiny143_2);
      final grounds = NoticeTriageService.suggestGrounds(notice);
      expect(grounds, isNotEmpty);
    });

    test('high pitch assessment → high pitch grounds', () {
      final notice = makeNotice(noticeType: NoticeType.highPitchAssessment);
      final grounds = NoticeTriageService.suggestGrounds(notice);
      expect(grounds, isNotEmpty);
    });

    test('search & seizure → search/seizure grounds', () {
      final notice = makeNotice(noticeType: NoticeType.searchSeizure);
      final grounds = NoticeTriageService.suggestGrounds(notice);
      expect(grounds, isNotEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // triage (integration)
  // ---------------------------------------------------------------------------

  group('NoticeTriageService.triage', () {
    test('returns NoticeTriageResult with correct noticeId', () {
      final notice = makeNotice(noticeId: 'N999');
      final result = NoticeTriageService.triage(notice);
      expect(result.noticeId, 'N999');
    });

    test('critical demand → recommended action is appeal or seek stay', () {
      final notice = makeNotice(
        demandAmount: 200_000_000, // ₹20L
        noticeType: NoticeType.assessment143_3,
      );
      final result = NoticeTriageService.triage(notice);
      expect([
        RecommendedAction.appeal,
        RecommendedAction.seekStay,
      ], contains(result.recommendedAction));
    });

    test('143(1) low demand → recommended action is respond or pay', () {
      final notice = makeNotice(
        noticeType: NoticeType.intimation143_1,
        demandAmount: 500_000, // ₹5k
      );
      final result = NoticeTriageService.triage(notice);
      expect([
        RecommendedAction.respond,
        RecommendedAction.pay,
      ], contains(result.recommendedAction));
    });

    test('triage result has non-empty keyIssues', () {
      final notice = makeNotice(noticeType: NoticeType.reopening148);
      final result = NoticeTriageService.triage(notice);
      expect(result.keyIssues, isNotEmpty);
    });

    test('triage result has non-empty suggestedGrounds', () {
      final notice = makeNotice(noticeType: NoticeType.assessment143_3);
      final result = NoticeTriageService.triage(notice);
      expect(result.suggestedGrounds, isNotEmpty);
    });

    test('triage result has non-empty timelineAdvice', () {
      final notice = makeNotice();
      final result = NoticeTriageService.triage(notice);
      expect(result.timelineAdvice, isNotEmpty);
    });

    test('triage preserves demand amount in estimatedDemand', () {
      final notice = makeNotice(demandAmount: 5_000_000);
      final result = NoticeTriageService.triage(notice);
      expect(result.estimatedDemand, 5_000_000);
    });

    test('triage with null demand → estimatedDemand is 0', () {
      final notice = makeNotice(demandAmount: null);
      final result = NoticeTriageService.triage(notice);
      expect(result.estimatedDemand, 0);
    });
  });

  // ---------------------------------------------------------------------------
  // Model immutability: TaxNotice
  // ---------------------------------------------------------------------------

  group('TaxNotice model', () {
    test('copyWith returns new instance with updated field', () {
      final original = makeNotice(
        noticeId: 'A1',
        status: NoticeStatus.received,
      );
      final updated = original.copyWith(status: NoticeStatus.responseFiled);
      expect(updated.status, NoticeStatus.responseFiled);
      expect(original.status, NoticeStatus.received);
    });

    test('equality by noticeId', () {
      final a = makeNotice(noticeId: 'X1');
      final b = makeNotice(noticeId: 'X1');
      expect(a, equals(b));
    });

    test('different noticeIds → not equal', () {
      final a = makeNotice(noticeId: 'X1');
      final b = makeNotice(noticeId: 'X2');
      expect(a, isNot(equals(b)));
    });

    test('hashCode equals noticeId hashCode', () {
      final n = makeNotice(noticeId: 'HASH1');
      expect(n.hashCode, n.noticeId.hashCode);
    });
  });

  // ---------------------------------------------------------------------------
  // Model immutability: NoticeTriageResult
  // ---------------------------------------------------------------------------

  group('NoticeTriageResult model', () {
    const result = NoticeTriageResult(
      noticeId: 'N1',
      recommendedAction: RecommendedAction.respond,
      riskLevel: RiskLevel.medium,
      keyIssues: ['Issue A'],
      suggestedGrounds: ['Ground X'],
      timelineAdvice: 'File within 30 days',
      estimatedDemand: 0,
    );

    test('copyWith returns new instance with updated field', () {
      final updated = result.copyWith(riskLevel: RiskLevel.high);
      expect(updated.riskLevel, RiskLevel.high);
      expect(result.riskLevel, RiskLevel.medium);
    });

    test('equality by noticeId and fields', () {
      const r2 = NoticeTriageResult(
        noticeId: 'N1',
        recommendedAction: RecommendedAction.respond,
        riskLevel: RiskLevel.medium,
        keyIssues: ['Issue A'],
        suggestedGrounds: ['Ground X'],
        timelineAdvice: 'File within 30 days',
        estimatedDemand: 0,
      );
      expect(result, equals(r2));
    });
  });
}
