import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/notice_resolution/data/mappers/tax_notice_mapper.dart';
import 'package:ca_app/features/notice_resolution/domain/models/tax_notice.dart';

void main() {
  group('TaxNoticeMapper', () {
    // -------------------------------------------------------------------------
    // fromJson
    // -------------------------------------------------------------------------
    group('fromJson', () {
      test('maps all core fields from JSON', () {
        final json = {
          'id': 'notice-001',
          'client_id': 'client-001',
          'notice_type': 'section143_1',
          'issued_date': '2025-09-01T00:00:00.000Z',
          'due_date': '2025-10-01T00:00:00.000Z',
          'demand_amount': 50000.0,
          'status': 'received',
          'response_date': '2025-09-25T00:00:00.000Z',
          'response_notes': 'Submitted Form 35A',
          'attachments': ['notice.pdf', 'response.pdf'],
          'created_at': '2025-09-02T00:00:00.000Z',
          'updated_at': '2025-09-25T00:00:00.000Z',
        };

        final notice = TaxNoticeMapper.fromJson(json);

        expect(notice.id, 'notice-001');
        expect(notice.clientId, 'client-001');
        expect(notice.noticeType, NoticeType.section143_1);
        expect(notice.demandAmount, 50000.0);
        expect(notice.status, NoticeStatus.received);
        expect(notice.responseDate, isNotNull);
        expect(notice.responseNotes, 'Submitted Form 35A');
        expect(notice.attachments, ['notice.pdf', 'response.pdf']);
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'notice-002',
          'client_id': 'client-002',
          'notice_type': 'gstAudit',
          'issued_date': '2025-09-01T00:00:00.000Z',
          'due_date': '2025-10-01T00:00:00.000Z',
          'status': 'inReview',
          'attachments': [],
          'created_at': '2025-09-02T00:00:00.000Z',
          'updated_at': '2025-09-02T00:00:00.000Z',
        };

        final notice = TaxNoticeMapper.fromJson(json);
        expect(notice.demandAmount, isNull);
        expect(notice.responseDate, isNull);
        expect(notice.responseNotes, isNull);
        expect(notice.attachments, isEmpty);
      });

      test('defaults notice_type to other for unknown value', () {
        final json = {
          'id': 'notice-003',
          'client_id': 'c1',
          'notice_type': 'unknownType',
          'issued_date': '2025-09-01T00:00:00.000Z',
          'due_date': '2025-10-01T00:00:00.000Z',
          'status': 'received',
          'attachments': [],
          'created_at': '2025-09-02T00:00:00.000Z',
          'updated_at': '2025-09-02T00:00:00.000Z',
        };

        final notice = TaxNoticeMapper.fromJson(json);
        expect(notice.noticeType, NoticeType.other);
      });

      test('defaults status to received for unknown value', () {
        final json = {
          'id': 'notice-004',
          'client_id': 'c1',
          'notice_type': 'section148',
          'issued_date': '2025-09-01T00:00:00.000Z',
          'due_date': '2025-10-01T00:00:00.000Z',
          'status': 'unknownStatus',
          'attachments': [],
          'created_at': '2025-09-02T00:00:00.000Z',
          'updated_at': '2025-09-02T00:00:00.000Z',
        };

        final notice = TaxNoticeMapper.fromJson(json);
        expect(notice.status, NoticeStatus.received);
      });

      test('handles null attachments as empty list', () {
        final json = {
          'id': 'notice-005',
          'client_id': 'c1',
          'notice_type': 'other',
          'issued_date': '2025-09-01T00:00:00.000Z',
          'due_date': '2025-10-01T00:00:00.000Z',
          'status': 'received',
          'attachments': null,
          'created_at': '2025-09-02T00:00:00.000Z',
          'updated_at': '2025-09-02T00:00:00.000Z',
        };

        final notice = TaxNoticeMapper.fromJson(json);
        expect(notice.attachments, isEmpty);
      });

      test('handles all NoticeType values', () {
        for (final type in NoticeType.values) {
          final json = {
            'id': 'notice-type-${type.name}',
            'client_id': 'c1',
            'notice_type': type.name,
            'issued_date': '2025-09-01T00:00:00.000Z',
            'due_date': '2025-10-01T00:00:00.000Z',
            'status': 'received',
            'attachments': [],
            'created_at': '2025-09-02T00:00:00.000Z',
            'updated_at': '2025-09-02T00:00:00.000Z',
          };
          final notice = TaxNoticeMapper.fromJson(json);
          expect(notice.noticeType, type);
        }
      });

      test('handles all NoticeStatus values', () {
        for (final status in NoticeStatus.values) {
          final json = {
            'id': 'notice-status-${status.name}',
            'client_id': 'c1',
            'notice_type': 'other',
            'issued_date': '2025-09-01T00:00:00.000Z',
            'due_date': '2025-10-01T00:00:00.000Z',
            'status': status.name,
            'attachments': [],
            'created_at': '2025-09-02T00:00:00.000Z',
            'updated_at': '2025-09-02T00:00:00.000Z',
          };
          final notice = TaxNoticeMapper.fromJson(json);
          expect(notice.status, status);
        }
      });

      test('parses demand_amount as double from integer JSON value', () {
        final json = {
          'id': 'notice-006',
          'client_id': 'c1',
          'notice_type': 'section156',
          'issued_date': '2025-09-01T00:00:00.000Z',
          'due_date': '2025-10-01T00:00:00.000Z',
          'demand_amount': 125000,
          'status': 'received',
          'attachments': [],
          'created_at': '2025-09-02T00:00:00.000Z',
          'updated_at': '2025-09-02T00:00:00.000Z',
        };

        final notice = TaxNoticeMapper.fromJson(json);
        expect(notice.demandAmount, 125000.0);
        expect(notice.demandAmount, isA<double>());
      });
    });

    // -------------------------------------------------------------------------
    // toJson
    // -------------------------------------------------------------------------
    group('toJson', () {
      late TaxNotice sampleNotice;

      setUp(() {
        sampleNotice = TaxNotice(
          id: 'notice-json-001',
          clientId: 'client-json-001',
          noticeType: NoticeType.section143_2,
          issuedDate: DateTime(2025, 9, 1),
          dueDate: DateTime(2025, 10, 1),
          demandAmount: 250000.0,
          status: NoticeStatus.responseFiled,
          responseDate: DateTime(2025, 9, 28),
          responseNotes: 'Detailed response submitted with supporting docs',
          attachments: const ['notice.pdf', 'form35.pdf', 'computation.xlsx'],
          createdAt: DateTime(2025, 9, 2),
          updatedAt: DateTime(2025, 9, 28),
        );
      });

      test('includes all fields', () {
        final json = TaxNoticeMapper.toJson(sampleNotice);

        expect(json['id'], 'notice-json-001');
        expect(json['client_id'], 'client-json-001');
        expect(json['notice_type'], 'section143_2');
        expect(json['demand_amount'], 250000.0);
        expect(json['status'], 'responseFiled');
        expect(json['response_notes'],
            'Detailed response submitted with supporting docs');
        expect(json['attachments'],
            ['notice.pdf', 'form35.pdf', 'computation.xlsx']);
      });

      test('serializes all dates as ISO strings', () {
        final json = TaxNoticeMapper.toJson(sampleNotice);
        expect(json['issued_date'], startsWith('2025-09-01'));
        expect(json['due_date'], startsWith('2025-10-01'));
        expect(json['response_date'], startsWith('2025-09-28'));
        expect(json['created_at'], startsWith('2025-09-02'));
        expect(json['updated_at'], startsWith('2025-09-28'));
      });

      test('serializes null response_date and notes correctly', () {
        final newNotice = TaxNotice(
          id: 'notice-new',
          clientId: 'c1',
          noticeType: NoticeType.tdsDefault,
          issuedDate: DateTime(2025, 9, 1),
          dueDate: DateTime(2025, 10, 1),
          status: NoticeStatus.received,
          attachments: const [],
          createdAt: DateTime(2025, 9, 2),
          updatedAt: DateTime(2025, 9, 2),
        );
        final json = TaxNoticeMapper.toJson(newNotice);
        expect(json['demand_amount'], isNull);
        expect(json['response_date'], isNull);
        expect(json['response_notes'], isNull);
      });

      test('serializes empty attachments as empty list', () {
        final noAttachNotice = TaxNotice(
          id: 'notice-noattach',
          clientId: 'c1',
          noticeType: NoticeType.other,
          issuedDate: DateTime(2025, 9, 1),
          dueDate: DateTime(2025, 10, 1),
          status: NoticeStatus.received,
          attachments: const [],
          createdAt: DateTime(2025, 9, 2),
          updatedAt: DateTime(2025, 9, 2),
        );
        final json = TaxNoticeMapper.toJson(noAttachNotice);
        expect(json['attachments'], isEmpty);
      });

      test('round-trip fromJson(toJson) preserves all fields', () {
        final json = TaxNoticeMapper.toJson(sampleNotice);
        final restored = TaxNoticeMapper.fromJson(json);

        expect(restored.id, sampleNotice.id);
        expect(restored.clientId, sampleNotice.clientId);
        expect(restored.noticeType, sampleNotice.noticeType);
        expect(restored.demandAmount, sampleNotice.demandAmount);
        expect(restored.status, sampleNotice.status);
        expect(restored.responseNotes, sampleNotice.responseNotes);
        expect(restored.attachments, sampleNotice.attachments);
      });
    });
  });
}
