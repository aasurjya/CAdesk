import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/litigation/data/providers/litigation_providers.dart';
import 'package:ca_app/features/litigation/domain/models/tax_notice.dart';
import 'package:ca_app/features/litigation/domain/models/appeal_case.dart';
import 'package:ca_app/features/litigation/domain/models/appeal_stage.dart';
import 'package:ca_app/features/litigation/domain/services/notice_triage_service.dart';
import 'package:ca_app/features/litigation/domain/services/response_template_service.dart';

void main() {
  group('NoticeListNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state has 5 mock notices', () {
      final notices = container.read(noticeListProvider);
      expect(notices.length, 5);
    });

    test('updateStatus changes status of a matching notice', () {
      container.read(noticeListProvider.notifier).updateStatus(
            'NTC-001',
            NoticeStatus.responseDrafted,
          );
      final updated =
          container.read(noticeListProvider).firstWhere((n) => n.noticeId == 'NTC-001');
      expect(updated.status, NoticeStatus.responseDrafted);
    });

    test('add increases list length', () {
      final before = container.read(noticeListProvider).length;
      final newNotice = TaxNotice(
        noticeId: 'NTC-999',
        pan: 'ZZZZZ0000Z',
        assessmentYear: 'AY 2023-24',
        noticeType: NoticeType.intimation143_1,
        issuedBy: 'CPC',
        issuedDate: DateTime(2026, 1, 1),
        responseDeadline: DateTime(2026, 2, 1),
        section: '143(1)',
        status: NoticeStatus.received,
      );
      container.read(noticeListProvider.notifier).add(newNotice);
      expect(container.read(noticeListProvider).length, before + 1);
    });

    test('notices list is unmodifiable', () {
      final notices = container.read(noticeListProvider);
      expect(() => (notices as dynamic).add(null), throwsA(isA<Error>()));
    });
  });

  group('SelectedNoticeNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state is null', () {
      expect(container.read(selectedNoticeProvider), isNull);
    });

    test('can select a notice', () {
      final notice = container.read(noticeListProvider).first;
      container.read(selectedNoticeProvider.notifier).select(notice);
      expect(container.read(selectedNoticeProvider), notice);
    });

    test('can clear selected notice', () {
      final notice = container.read(noticeListProvider).first;
      container.read(selectedNoticeProvider.notifier).select(notice);
      container.read(selectedNoticeProvider.notifier).select(null);
      expect(container.read(selectedNoticeProvider), isNull);
    });
  });

  group('noticeTriageProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns NoticeTriageService instance', () {
      final service = container.read(noticeTriageProvider);
      expect(service, isA<NoticeTriageService>());
    });
  });

  group('responseTemplateProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns ResponseTemplateService instance', () {
      final service = container.read(responseTemplateProvider);
      expect(service, isA<ResponseTemplateService>());
    });
  });

  group('AppealListNotifier', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('initial state has 3 mock appeals', () {
      final appeals = container.read(appealListProvider);
      expect(appeals.length, 3);
    });

    test('add increases list length', () {
      final before = container.read(appealListProvider).length;
      final existing = container.read(appealListProvider).first;
      final newAppeal = AppealCase(
        caseId: 'APC-TEST-999',
        pan: 'AAAAA0000A',
        assessmentYear: 'AY 2024-25',
        currentForum: AppealForum.cita,
        originalDemand: 100000,
        amountInDispute: 100000,
        filingDate: DateTime(2026, 1, 1),
        status: AppealStatus.pending,
        nextAction: 'Test',
        history: const [],
      );
      container.read(appealListProvider.notifier).add(newAppeal);
      expect(container.read(appealListProvider).length, before + 1);
    });
  });

  group('triageResultsProvider', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('returns map with key for each notice', () {
      final notices = container.read(noticeListProvider);
      final results = container.read(triageResultsProvider);
      for (final n in notices) {
        expect(results.containsKey(n.noticeId), isTrue);
      }
    });

    test('map is unmodifiable', () {
      final results = container.read(triageResultsProvider);
      expect(() => (results as dynamic)['NEW'] = null, throwsA(isA<Error>()));
    });
  });
}
