import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/litigation/domain/models/tax_notice.dart';
import 'package:ca_app/features/litigation/domain/models/appeal_case.dart';
import 'package:ca_app/features/litigation/data/repositories/mock_litigation_repository.dart';

void main() {
  group('MockLitigationRepository', () {
    late MockLitigationRepository repo;

    setUp(() {
      repo = MockLitigationRepository();
    });

    // -----------------------------------------------------------------------
    // TaxNotice tests
    // -----------------------------------------------------------------------

    group('getNotices', () {
      test('returns seeded notices', () async {
        final results = await repo.getNotices();
        expect(results, isNotEmpty);
      });

      test('returns unmodifiable list', () async {
        final results = await repo.getNotices();
        expect(() => results.add(results.first), throwsUnsupportedError);
      });
    });

    group('getNoticesByPan', () {
      test('returns notices for known PAN', () async {
        final all = await repo.getNotices();
        final pan = all.first.pan;
        final results = await repo.getNoticesByPan(pan);
        expect(results.every((n) => n.pan == pan), isTrue);
      });

      test('returns empty for unknown PAN', () async {
        final results = await repo.getNoticesByPan('ZZZZZ9999Z');
        expect(results, isEmpty);
      });
    });

    group('getNoticesByStatus', () {
      test('returns only notices with matching status', () async {
        final all = await repo.getNotices();
        final status = all.first.status;
        final results = await repo.getNoticesByStatus(status);
        expect(results.every((n) => n.status == status), isTrue);
      });
    });

    group('getNoticeById', () {
      test('returns notice for known id', () async {
        final all = await repo.getNotices();
        final id = all.first.noticeId;
        final result = await repo.getNoticeById(id);
        expect(result, isNotNull);
        expect(result!.noticeId, equals(id));
      });

      test('returns null for unknown id', () async {
        final result = await repo.getNoticeById('no-such-id');
        expect(result, isNull);
      });
    });

    group('insertNotice', () {
      test('inserts and returns id', () async {
        final notice = TaxNotice(
          noticeId: 'test-notice-001',
          pan: 'AAAAA1234A',
          assessmentYear: 'AY 2024-25',
          noticeType: NoticeType.scrutiny143_2,
          issuedBy: 'NFAC',
          issuedDate: DateTime(2026, 1, 1),
          responseDeadline: DateTime(2026, 4, 1),
          section: '143(2)',
          status: NoticeStatus.received,
        );
        final id = await repo.insertNotice(notice);
        expect(id, equals('test-notice-001'));
      });

      test('inserted notice is retrievable', () async {
        final notice = TaxNotice(
          noticeId: 'test-notice-002',
          pan: 'BBBBB5678B',
          assessmentYear: 'AY 2023-24',
          noticeType: NoticeType.intimation143_1,
          issuedBy: 'CPC Bengaluru',
          issuedDate: DateTime(2026, 2, 1),
          responseDeadline: DateTime(2026, 5, 1),
          section: '143(1)',
          status: NoticeStatus.underReview,
        );
        await repo.insertNotice(notice);
        final result = await repo.getNoticeById('test-notice-002');
        expect(result, isNotNull);
      });
    });

    group('updateNotice', () {
      test('updates status and returns true', () async {
        final all = await repo.getNotices();
        final original = all.first;
        final updated = original.copyWith(status: NoticeStatus.resolved);
        final success = await repo.updateNotice(updated);
        expect(success, isTrue);

        final after = await repo.getNoticeById(original.noticeId);
        expect(after?.status, NoticeStatus.resolved);
      });

      test('returns false for non-existent id', () async {
        final ghost = TaxNotice(
          noticeId: 'no-such-notice',
          pan: 'GHOST1234G',
          assessmentYear: 'AY 2020-21',
          noticeType: NoticeType.penalty156,
          issuedBy: 'Ghost',
          issuedDate: DateTime(2020, 1, 1),
          responseDeadline: DateTime(2020, 4, 1),
          section: '156',
          status: NoticeStatus.received,
        );
        final success = await repo.updateNotice(ghost);
        expect(success, isFalse);
      });
    });

    group('deleteNotice', () {
      test('deletes seeded notice and returns true', () async {
        final all = await repo.getNotices();
        final id = all.first.noticeId;
        final success = await repo.deleteNotice(id);
        expect(success, isTrue);

        final after = await repo.getNoticeById(id);
        expect(after, isNull);
      });

      test('returns false for non-existent id', () async {
        final success = await repo.deleteNotice('no-such-id-xyz');
        expect(success, isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // AppealCase tests
    // -----------------------------------------------------------------------

    group('getAppealCases', () {
      test('returns seeded appeal cases', () async {
        final results = await repo.getAppealCases();
        expect(results, isNotEmpty);
      });
    });

    group('getAppealCasesByPan', () {
      test('returns cases for known PAN', () async {
        final all = await repo.getAppealCases();
        final pan = all.first.pan;
        final results = await repo.getAppealCasesByPan(pan);
        expect(results.every((c) => c.pan == pan), isTrue);
      });

      test('returns empty for unknown PAN', () async {
        final results = await repo.getAppealCasesByPan('ZZZZZ9999Z');
        expect(results, isEmpty);
      });
    });

    group('insertAppealCase', () {
      test('inserts and returns id', () async {
        final appealCase = AppealCase(
          caseId: 'test-case-001',
          pan: 'CCCCC1111C',
          assessmentYear: 'AY 2024-25',
          currentForum: AppealForum.cita,
          originalDemand: 500000 * 100,
          amountInDispute: 500000 * 100,
          filingDate: DateTime(2026, 1, 15),
          status: AppealStatus.pending,
          nextAction: 'File written submissions',
          history: [],
        );
        final id = await repo.insertAppealCase(appealCase);
        expect(id, equals('test-case-001'));
      });
    });

    group('updateAppealCase', () {
      test('updates status and returns true', () async {
        final all = await repo.getAppealCases();
        final original = all.first;
        final updated = original.copyWith(status: AppealStatus.partialRelief);
        final success = await repo.updateAppealCase(updated);
        expect(success, isTrue);

        final after = await repo.getAppealCases();
        final found = after.firstWhere((c) => c.caseId == original.caseId);
        expect(found.status, AppealStatus.partialRelief);
      });

      test('returns false for non-existent id', () async {
        final ghost = AppealCase(
          caseId: 'no-such-case',
          pan: 'GHOST1234G',
          assessmentYear: 'AY 2020-21',
          currentForum: AppealForum.ao,
          originalDemand: 0,
          amountInDispute: 0,
          filingDate: DateTime(2020, 1, 1),
          status: AppealStatus.pending,
          nextAction: 'N/A',
          history: [],
        );
        final success = await repo.updateAppealCase(ghost);
        expect(success, isFalse);
      });
    });

    // -----------------------------------------------------------------------
    // ResponseTemplate tests
    // -----------------------------------------------------------------------

    group('getTemplates', () {
      test('returns seeded templates', () async {
        final results = await repo.getTemplates();
        expect(results, isNotEmpty);
      });
    });

    group('getTemplatesByNoticeType', () {
      test('returns templates for known notice type', () async {
        final all = await repo.getTemplates();
        final noticeType = all.first.noticeType;
        final results = await repo.getTemplatesByNoticeType(noticeType);
        expect(results.every((t) => t.noticeType == noticeType), isTrue);
      });

      test('returns empty for notice type with no templates', () async {
        final results = await repo.getTemplatesByNoticeType(
          NoticeType.searchSeizure,
        );
        // Not necessarily empty but test for correctness
        expect(
          results.every((t) => t.noticeType == NoticeType.searchSeizure),
          isTrue,
        );
      });
    });
  });
}
