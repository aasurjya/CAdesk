import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/database/app_database.dart';
import 'package:ca_app/features/notice_resolution/domain/models/tax_notice.dart';
import 'package:ca_app/features/notice_resolution/data/mappers/tax_notice_mapper.dart';

AppDatabase _createTestDatabase() =>
    AppDatabase(executor: NativeDatabase.memory());

void main() {
  late AppDatabase database;
  var counter = 0;

  setUpAll(() async {
    database = _createTestDatabase();
  });

  tearDownAll(() async {
    await database.close();
  });

  TaxNotice createNotice({
    String? id,
    String? clientId,
    NoticeType? noticeType,
    DateTime? issuedDate,
    DateTime? dueDate,
    double? demandAmount,
    NoticeStatus? status,
    DateTime? responseDate,
    String? responseNotes,
    List<String>? attachments,
  }) {
    counter++;
    return TaxNotice(
      id: id ?? 'notice-$counter',
      clientId: clientId ?? 'client-$counter',
      noticeType: noticeType ?? NoticeType.section143_1,
      issuedDate: issuedDate ?? DateTime(2024, 9, 1),
      dueDate: dueDate ?? DateTime(2025, 3, 31),
      demandAmount: demandAmount,
      status: status ?? NoticeStatus.received,
      responseDate: responseDate,
      responseNotes: responseNotes,
      attachments: attachments ?? const [],
      createdAt: DateTime(2024, 9, 1),
      updatedAt: DateTime(2024, 9, 1),
    );
  }

  group('TaxNoticesDao', () {
    group('insertNotice', () {
      test('inserts notice and retrieves by ID', () async {
        final notice = createNotice();
        await database.taxNoticesDao.insertNotice(
          TaxNoticeMapper.toCompanion(notice),
        );
        final row = await database.taxNoticesDao.getById(notice.id);
        expect(row, isNotNull);
        expect(row!.id, notice.id);
      });

      test('stored notice has correct clientId', () async {
        final notice = createNotice(clientId: 'notice-client-a');
        await database.taxNoticesDao.insertNotice(
          TaxNoticeMapper.toCompanion(notice),
        );
        final row = await database.taxNoticesDao.getById(notice.id);
        expect(row?.clientId, 'notice-client-a');
      });

      test('stored notice has correct noticeType', () async {
        final notice = createNotice(noticeType: NoticeType.section148);
        await database.taxNoticesDao.insertNotice(
          TaxNoticeMapper.toCompanion(notice),
        );
        final row = await database.taxNoticesDao.getById(notice.id);
        expect(row?.noticeType, 'section148');
      });

      test('stored notice preserves demandAmount', () async {
        final notice = createNotice(demandAmount: 250000.0);
        await database.taxNoticesDao.insertNotice(
          TaxNoticeMapper.toCompanion(notice),
        );
        final row = await database.taxNoticesDao.getById(notice.id);
        expect(row?.demandAmount, 250000.0);
      });

      test('stored notice handles null demandAmount', () async {
        final notice = createNotice(demandAmount: null);
        await database.taxNoticesDao.insertNotice(
          TaxNoticeMapper.toCompanion(notice),
        );
        final row = await database.taxNoticesDao.getById(notice.id);
        expect(row?.demandAmount, isNull);
      });

      test('stored notice preserves attachments JSON', () async {
        final notice = createNotice(
          attachments: ['path/notice.pdf', 'path/form.pdf'],
        );
        await database.taxNoticesDao.insertNotice(
          TaxNoticeMapper.toCompanion(notice),
        );
        final row = await database.taxNoticesDao.getById(notice.id);
        final domain = TaxNoticeMapper.fromRow(row!);
        expect(domain.attachments, hasLength(2));
        expect(domain.attachments.first, 'path/notice.pdf');
      });

      test('stored notice preserves responseNotes', () async {
        final notice = createNotice(responseNotes: 'Filed with Form 10E');
        await database.taxNoticesDao.insertNotice(
          TaxNoticeMapper.toCompanion(notice),
        );
        final row = await database.taxNoticesDao.getById(notice.id);
        expect(row?.responseNotes, 'Filed with Form 10E');
      });

      test('upsert replaces existing record with same ID', () async {
        final notice = createNotice(status: NoticeStatus.received);
        await database.taxNoticesDao.insertNotice(
          TaxNoticeMapper.toCompanion(notice),
        );
        final updated = notice.copyWith(status: NoticeStatus.disposed);
        await database.taxNoticesDao.insertNotice(
          TaxNoticeMapper.toCompanion(updated),
        );
        final row = await database.taxNoticesDao.getById(notice.id);
        expect(row?.status, 'disposed');
      });
    });

    group('getByClient', () {
      test('returns notices for specified client', () async {
        const clientId = 'notice-client-unique';
        final n1 = createNotice(clientId: clientId);
        final n2 = createNotice(clientId: clientId);
        await database.taxNoticesDao.insertNotice(
          TaxNoticeMapper.toCompanion(n1),
        );
        await database.taxNoticesDao.insertNotice(
          TaxNoticeMapper.toCompanion(n2),
        );
        final rows = await database.taxNoticesDao.getByClient(clientId);
        expect(rows.length, greaterThanOrEqualTo(2));
      });

      test('returns empty for non-existent client', () async {
        final rows = await database.taxNoticesDao.getByClient('ghost-notice');
        expect(rows, isEmpty);
      });

      test('filters by client correctly', () async {
        const cA = 'notice-filter-a';
        const cB = 'notice-filter-b';
        await database.taxNoticesDao.insertNotice(
          TaxNoticeMapper.toCompanion(createNotice(clientId: cA)),
        );
        await database.taxNoticesDao.insertNotice(
          TaxNoticeMapper.toCompanion(createNotice(clientId: cB)),
        );
        final rows = await database.taxNoticesDao.getByClient(cA);
        expect(rows.every((r) => r.clientId == cA), isTrue);
      });
    });

    group('getByType', () {
      test('returns notices of specified type', () async {
        final notice = createNotice(noticeType: NoticeType.gstAudit);
        await database.taxNoticesDao.insertNotice(
          TaxNoticeMapper.toCompanion(notice),
        );
        final rows = await database.taxNoticesDao.getByType('gstAudit');
        expect(rows.any((r) => r.id == notice.id), isTrue);
        expect(rows.every((r) => r.noticeType == 'gstAudit'), isTrue);
      });

      test('returns empty for type with no records', () async {
        final rows = await database.taxNoticesDao.getByType('tdsDefault');
        expect(rows, isEmpty);
      });
    });

    group('getByStatus', () {
      test('returns notices with specified status', () async {
        final notice = createNotice(status: NoticeStatus.appeal);
        await database.taxNoticesDao.insertNotice(
          TaxNoticeMapper.toCompanion(notice),
        );
        final rows = await database.taxNoticesDao.getByStatus('appeal');
        expect(rows.any((r) => r.id == notice.id), isTrue);
      });

      test('returns empty for status with no records', () async {
        final rows = await database.taxNoticesDao.getByStatus('responseFiled');
        expect(rows, isEmpty);
      });
    });

    group('updateStatus', () {
      test('updates status successfully', () async {
        final notice = createNotice(status: NoticeStatus.received);
        await database.taxNoticesDao.insertNotice(
          TaxNoticeMapper.toCompanion(notice),
        );
        final ok = await database.taxNoticesDao.updateStatus(
          notice.id,
          NoticeStatus.inReview.name,
        );
        expect(ok, isTrue);
        final row = await database.taxNoticesDao.getById(notice.id);
        expect(row?.status, 'inReview');
      });

      test('returns false for non-existent ID', () async {
        final ok = await database.taxNoticesDao.updateStatus(
          'ghost',
          'disposed',
        );
        expect(ok, isFalse);
      });

      test('updateStatus marks isDirty', () async {
        final notice = createNotice();
        await database.taxNoticesDao.insertNotice(
          TaxNoticeMapper.toCompanion(notice),
        );
        await database.taxNoticesDao.updateStatus(
          notice.id,
          NoticeStatus.disposed.name,
        );
        final row = await database.taxNoticesDao.getById(notice.id);
        expect(row?.isDirty, isTrue);
      });
    });

    group('getOverdue', () {
      test(
        'returns notices whose dueDate is before asOf and not disposed',
        () async {
          final pastDue = createNotice(
            status: NoticeStatus.received,
            dueDate: DateTime(2024, 1, 1),
          );
          await database.taxNoticesDao.insertNotice(
            TaxNoticeMapper.toCompanion(pastDue),
          );
          final rows = await database.taxNoticesDao.getOverdue(
            DateTime(2025, 1, 1),
          );
          expect(rows.any((r) => r.id == pastDue.id), isTrue);
        },
      );

      test('does not return disposed notices even if overdue', () async {
        final disposed = createNotice(
          status: NoticeStatus.disposed,
          dueDate: DateTime(2020, 1, 1),
        );
        await database.taxNoticesDao.insertNotice(
          TaxNoticeMapper.toCompanion(disposed),
        );
        final rows = await database.taxNoticesDao.getOverdue(
          DateTime(2025, 1, 1),
        );
        expect(rows.any((r) => r.id == disposed.id), isFalse);
      });

      test('does not return notices with future dueDate', () async {
        final future = createNotice(
          status: NoticeStatus.received,
          dueDate: DateTime(2030, 1, 1),
        );
        await database.taxNoticesDao.insertNotice(
          TaxNoticeMapper.toCompanion(future),
        );
        final rows = await database.taxNoticesDao.getOverdue(
          DateTime(2025, 1, 1),
        );
        expect(rows.any((r) => r.id == future.id), isFalse);
      });
    });

    group('deleteNotice', () {
      test('deletes an existing notice', () async {
        final notice = createNotice();
        await database.taxNoticesDao.insertNotice(
          TaxNoticeMapper.toCompanion(notice),
        );
        await database.taxNoticesDao.deleteNotice(notice.id);
        final row = await database.taxNoticesDao.getById(notice.id);
        expect(row, isNull);
      });

      test('delete non-existent ID does not throw', () async {
        await expectLater(
          database.taxNoticesDao.deleteNotice('ghost-notice-delete'),
          completes,
        );
      });
    });

    group('Immutability', () {
      test('TaxNotice copyWith creates new instance', () {
        final n1 = createNotice(status: NoticeStatus.received);
        final n2 = n1.copyWith(status: NoticeStatus.disposed);
        expect(n1.status, NoticeStatus.received);
        expect(n2.status, NoticeStatus.disposed);
        expect(n1.id, n2.id);
      });

      test('copyWith preserves all unchanged fields', () {
        final n1 = createNotice(
          demandAmount: 100000.0,
          noticeType: NoticeType.section156,
          attachments: ['a.pdf'],
        );
        final n2 = n1.copyWith(status: NoticeStatus.inReview);
        expect(n2.demandAmount, 100000.0);
        expect(n2.noticeType, NoticeType.section156);
        expect(n2.attachments, hasLength(1));
        expect(n2.clientId, n1.clientId);
      });
    });
  });
}
