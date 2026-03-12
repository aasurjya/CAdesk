import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/ca_gpt/domain/models/notice_draft.dart';
import 'package:ca_app/features/ca_gpt/domain/services/notice_drafting_service.dart';

void main() {
  group('NoticeDraftingService — draftReply', () {
    final facts = <String, String>{
      'taxpayerName': 'Ramesh Kumar',
      'pan': 'ABCDE1234F',
      'assessmentYear': '2024-25',
      'groundsOfAppeal': 'CPC disallowed genuine deductions',
      'reliefSought': 'Reversal of demand of ₹50,000',
    };

    test('drafts 143(1) reply with taxpayer details', () {
      final draft = NoticeDraftingService.draftReply('143_1', facts);
      expect(draft.draftId, isNotEmpty);
      expect(draft.taxpayerName, equals('Ramesh Kumar'));
      expect(draft.pan, equals('ABCDE1234F'));
      expect(draft.assessmentYear, equals('2024-25'));
      expect(draft.draftText, isNotEmpty);
      expect(draft.draftText, contains('Ramesh Kumar'));
    });

    test('drafts 143(3) reply', () {
      final draft = NoticeDraftingService.draftReply('143_3', facts);
      expect(draft.noticeType, equals(NoticeType.reply143_3));
      expect(draft.draftText, isNotEmpty);
    });

    test('drafts appeal memo', () {
      final draft = NoticeDraftingService.draftReply('appeal', facts);
      expect(draft.noticeType, equals(NoticeType.appeal));
      expect(draft.draftText, isNotEmpty);
      expect(draft.groundsOfAppeal, isNotEmpty);
    });

    test('all required notice types can be drafted', () {
      for (final type in [
        '143_1',
        '143_3',
        'appeal',
        'rectification',
        'condonation',
        'penalty',
        'revision',
      ]) {
        final draft = NoticeDraftingService.draftReply(type, facts);
        expect(
          draft.draftText,
          isNotEmpty,
          reason: 'Expected draft text for notice type $type',
        );
        expect(draft.noticeType, isA<NoticeType>());
      }
    });

    test('draftId is unique per call', () {
      final d1 = NoticeDraftingService.draftReply('143_1', facts);
      final d2 = NoticeDraftingService.draftReply('143_1', facts);
      expect(d1.draftId, isNot(equals(d2.draftId)));
    });

    test('placeholders are replaced in draft text', () {
      final draft = NoticeDraftingService.draftReply('143_1', facts);
      expect(draft.draftText, isNot(contains('{taxpayerName}')));
      expect(draft.draftText, isNot(contains('{pan}')));
      expect(draft.draftText, isNot(contains('{assessmentYear}')));
    });

    test('groundsOfAppeal populated from facts', () {
      final draft = NoticeDraftingService.draftReply('appeal', facts);
      expect(draft.groundsOfAppeal, isNotEmpty);
    });
  });

  group('NoticeDraftingService — getTemplate', () {
    test('returns template for 143_1', () {
      final template = NoticeDraftingService.getTemplate('143_1');
      expect(template, isNotEmpty);
      expect(template, contains('{taxpayerName}'));
    });

    test('returns template for all notice types', () {
      for (final type in [
        '143_1',
        '143_3',
        'appeal',
        'rectification',
        'condonation',
        'penalty',
        'revision',
      ]) {
        final template = NoticeDraftingService.getTemplate(type);
        expect(template, isNotEmpty, reason: 'Expected template for $type');
      }
    });

    test('returns fallback for unknown type', () {
      final template = NoticeDraftingService.getTemplate('unknown_type');
      expect(template, isNotEmpty);
    });
  });

  group('NoticeDraftingService — fillTemplate', () {
    test('replaces all placeholders', () {
      const template =
          'Dear {taxpayerName}, your PAN is {pan} for AY {assessmentYear}.';
      final facts = <String, String>{
        'taxpayerName': 'Suresh Sharma',
        'pan': 'XYZAB1234C',
        'assessmentYear': '2023-24',
      };
      final filled = NoticeDraftingService.fillTemplate(template, facts);
      expect(filled, contains('Suresh Sharma'));
      expect(filled, contains('XYZAB1234C'));
      expect(filled, contains('2023-24'));
      expect(filled, isNot(contains('{')));
      expect(filled, isNot(contains('}')));
    });

    test('leaves unfilled placeholders when key is missing', () {
      const template = 'Name: {taxpayerName}, Extra: {missingKey}';
      final facts = <String, String>{'taxpayerName': 'Test'};
      final filled = NoticeDraftingService.fillTemplate(template, facts);
      expect(filled, contains('Test'));
      expect(filled, contains('{missingKey}'));
    });

    test('empty template returns empty string', () {
      final filled = NoticeDraftingService.fillTemplate('', {});
      expect(filled, isEmpty);
    });
  });

  group('NoticeDraft model', () {
    test('const constructor and equality', () {
      final date = DateTime(2025, 3, 1);
      final a = NoticeDraft(
        draftId: 'd1',
        noticeType: NoticeType.reply143_1,
        originalNoticeDate: date,
        assessmentYear: '2024-25',
        taxpayerName: 'Ram',
        pan: 'ABCDE1234F',
        groundsOfAppeal: const ['Ground 1'],
        draftText: 'Draft text',
        templateUsed: '143_1',
      );
      final b = NoticeDraft(
        draftId: 'd1',
        noticeType: NoticeType.reply143_1,
        originalNoticeDate: date,
        assessmentYear: '2024-25',
        taxpayerName: 'Ram',
        pan: 'ABCDE1234F',
        groundsOfAppeal: const ['Ground 1'],
        draftText: 'Draft text',
        templateUsed: '143_1',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith creates new instance with updated fields', () {
      final date = DateTime(2025, 3, 1);
      final original = NoticeDraft(
        draftId: 'd1',
        noticeType: NoticeType.reply143_1,
        originalNoticeDate: date,
        assessmentYear: '2024-25',
        taxpayerName: 'Ram',
        pan: 'ABCDE1234F',
        groundsOfAppeal: const ['Ground 1'],
        draftText: 'Old text',
        templateUsed: '143_1',
      );
      final updated = original.copyWith(draftText: 'New text');
      expect(updated.draftText, equals('New text'));
      expect(updated.draftId, equals('d1'));
      expect(updated.taxpayerName, equals('Ram'));
    });

    test('NoticeType enum has all required values', () {
      expect(NoticeType.values, contains(NoticeType.reply143_1));
      expect(NoticeType.values, contains(NoticeType.reply143_3));
      expect(NoticeType.values, contains(NoticeType.appeal));
      expect(NoticeType.values, contains(NoticeType.rectification));
      expect(NoticeType.values, contains(NoticeType.condonation));
      expect(NoticeType.values, contains(NoticeType.penalty));
      expect(NoticeType.values, contains(NoticeType.revision));
    });
  });
}
