import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/litigation/domain/models/tax_notice.dart';
import 'package:ca_app/features/litigation/domain/models/response_template.dart';
import 'package:ca_app/features/litigation/domain/services/response_template_service.dart';

void main() {
  // ---------------------------------------------------------------------------
  // getTemplate
  // ---------------------------------------------------------------------------

  group('ResponseTemplateService.getTemplate', () {
    test('143(1) intimation → template with correct noticeType', () {
      final template = ResponseTemplateService.getTemplate(
        NoticeType.intimation143_1,
      );
      expect(template.noticeType, NoticeType.intimation143_1);
    });

    test('143(2) scrutiny → template returned', () {
      final template = ResponseTemplateService.getTemplate(
        NoticeType.scrutiny143_2,
      );
      expect(template.noticeType, NoticeType.scrutiny143_2);
    });

    test('143(3) assessment → template returned', () {
      final template = ResponseTemplateService.getTemplate(
        NoticeType.assessment143_3,
      );
      expect(template.noticeType, NoticeType.assessment143_3);
    });

    test('148 reopening → template returned', () {
      final template = ResponseTemplateService.getTemplate(
        NoticeType.reopening148,
      );
      expect(template.noticeType, NoticeType.reopening148);
    });

    test('penalty 156 → template returned', () {
      final template = ResponseTemplateService.getTemplate(
        NoticeType.penalty156,
      );
      expect(template.noticeType, NoticeType.penalty156);
    });

    test('show cause → template returned', () {
      final template = ResponseTemplateService.getTemplate(
        NoticeType.showCause,
      );
      expect(template.noticeType, NoticeType.showCause);
    });

    test('high pitch assessment → template returned', () {
      final template = ResponseTemplateService.getTemplate(
        NoticeType.highPitchAssessment,
      );
      expect(template.noticeType, NoticeType.highPitchAssessment);
    });

    test('search & seizure → template returned', () {
      final template = ResponseTemplateService.getTemplate(
        NoticeType.searchSeizure,
      );
      expect(template.noticeType, NoticeType.searchSeizure);
    });

    test('template has non-empty title', () {
      final template = ResponseTemplateService.getTemplate(
        NoticeType.intimation143_1,
      );
      expect(template.title, isNotEmpty);
    });

    test('template has non-empty templateText', () {
      final template = ResponseTemplateService.getTemplate(
        NoticeType.intimation143_1,
      );
      expect(template.templateText, isNotEmpty);
    });

    test('143(1) template has requiredDocuments', () {
      final template = ResponseTemplateService.getTemplate(
        NoticeType.intimation143_1,
      );
      expect(template.requiredDocuments, isNotEmpty);
    });

    test('143(1) template has legalGrounds', () {
      final template = ResponseTemplateService.getTemplate(
        NoticeType.intimation143_1,
      );
      expect(template.legalGrounds, isNotEmpty);
    });

    test('template successRate is between 0.0 and 1.0', () {
      for (final type in NoticeType.values) {
        final template = ResponseTemplateService.getTemplate(type);
        expect(template.successRate, inInclusiveRange(0.0, 1.0));
      }
    });

    test('148 template references limitation period', () {
      final template = ResponseTemplateService.getTemplate(
        NoticeType.reopening148,
      );
      expect(
        template.templateText.toLowerCase(),
        anyOf(
          contains('limitation'),
          contains('148'),
          contains('reassessment'),
        ),
      );
    });

    test('penalty template references bona fide or reasonable cause', () {
      final template = ResponseTemplateService.getTemplate(
        NoticeType.penalty156,
      );
      final text = template.templateText.toLowerCase();
      expect(
        text,
        anyOf(
          contains('bona fide'),
          contains('reasonable cause'),
          contains('271'),
        ),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // fillTemplate
  // ---------------------------------------------------------------------------

  group('ResponseTemplateService.fillTemplate', () {
    test('placeholders are replaced with provided facts', () {
      const template = ResponseTemplate(
        templateId: 'T1',
        noticeType: NoticeType.intimation143_1,
        title: 'Test',
        templateText: 'Dear Sir, PAN: {pan}, AY: {assessmentYear}.',
        requiredDocuments: [],
        legalGrounds: [],
        successRate: 0.75,
      );
      final filled = ResponseTemplateService.fillTemplate(template, {
        'pan': 'ABCDE1234F',
        'assessmentYear': '2023-24',
      });
      expect(filled, contains('ABCDE1234F'));
      expect(filled, contains('2023-24'));
      expect(filled, isNot(contains('{')));
    });

    test('unfilled placeholders remain if not in facts map', () {
      const template = ResponseTemplate(
        templateId: 'T2',
        noticeType: NoticeType.intimation143_1,
        title: 'Test',
        templateText: 'PAN: {pan}, Amount: {amount}.',
        requiredDocuments: [],
        legalGrounds: [],
        successRate: 0.75,
      );
      final filled = ResponseTemplateService.fillTemplate(template, {
        'pan': 'ABCDE1234F',
      });
      expect(filled, contains('ABCDE1234F'));
      expect(filled, contains('{amount}'));
    });

    test('empty facts map leaves template unchanged', () {
      const template = ResponseTemplate(
        templateId: 'T3',
        noticeType: NoticeType.intimation143_1,
        title: 'Test',
        templateText: 'Hello {name}.',
        requiredDocuments: [],
        legalGrounds: [],
        successRate: 0.5,
      );
      final filled = ResponseTemplateService.fillTemplate(template, {});
      expect(filled, 'Hello {name}.');
    });

    test('template with no placeholders returns text unchanged', () {
      const template = ResponseTemplate(
        templateId: 'T4',
        noticeType: NoticeType.intimation143_1,
        title: 'Test',
        templateText: 'No placeholders here.',
        requiredDocuments: [],
        legalGrounds: [],
        successRate: 0.5,
      );
      final filled = ResponseTemplateService.fillTemplate(template, {
        'pan': 'ABCDE1234F',
      });
      expect(filled, 'No placeholders here.');
    });
  });

  // ---------------------------------------------------------------------------
  // getRequiredDocuments
  // ---------------------------------------------------------------------------

  group('ResponseTemplateService.getRequiredDocuments', () {
    test('143(1) → Form 26AS / TDS documents', () {
      final docs = ResponseTemplateService.getRequiredDocuments(
        NoticeType.intimation143_1,
      );
      expect(docs, isNotEmpty);
      // Should include TDS-related documents
      expect(
        docs.any(
          (d) =>
              d.toLowerCase().contains('26as') ||
              d.toLowerCase().contains('tds') ||
              d.toLowerCase().contains('form'),
        ),
        isTrue,
      );
    });

    test('148 → previous return copy and evidence', () {
      final docs = ResponseTemplateService.getRequiredDocuments(
        NoticeType.reopening148,
      );
      expect(docs, isNotEmpty);
    });

    test('penalty 156 → cause justification documents', () {
      final docs = ResponseTemplateService.getRequiredDocuments(
        NoticeType.penalty156,
      );
      expect(docs, isNotEmpty);
    });

    test('every notice type returns a non-empty document list', () {
      for (final type in NoticeType.values) {
        final docs = ResponseTemplateService.getRequiredDocuments(type);
        expect(docs, isNotEmpty, reason: 'Empty docs for $type');
      }
    });
  });

  // ---------------------------------------------------------------------------
  // ResponseTemplate model immutability
  // ---------------------------------------------------------------------------

  group('ResponseTemplate model', () {
    const t = ResponseTemplate(
      templateId: 'T99',
      noticeType: NoticeType.intimation143_1,
      title: 'Test Template',
      templateText: 'Hello {name}.',
      requiredDocuments: ['Form 26AS'],
      legalGrounds: ['Section 154'],
      successRate: 0.80,
    );

    test('copyWith returns new instance with updated field', () {
      final updated = t.copyWith(successRate: 0.90);
      expect(updated.successRate, 0.90);
      expect(t.successRate, 0.80);
    });

    test('equality by templateId', () {
      const t2 = ResponseTemplate(
        templateId: 'T99',
        noticeType: NoticeType.intimation143_1,
        title: 'Test Template',
        templateText: 'Hello {name}.',
        requiredDocuments: ['Form 26AS'],
        legalGrounds: ['Section 154'],
        successRate: 0.80,
      );
      expect(t, equals(t2));
    });

    test('different templateId → not equal', () {
      final other = t.copyWith(templateId: 'T100');
      expect(other, isNot(equals(t)));
    });

    test('hashCode equals templateId hashCode', () {
      expect(t.hashCode, t.templateId.hashCode);
    });
  });
}
