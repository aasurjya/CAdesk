import 'package:ca_app/features/gstn_api/domain/services/gstr_submission_service.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const _validGstin = '27AABCE1234F1Z5';
const _period = '032024';

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('MockGstrSubmissionService', () {
    late MockGstrSubmissionService service;

    setUp(() {
      service = const MockGstrSubmissionService();
    });

    // ── saveGstr1 ────────────────────────────────────────────────────────────

    group('saveGstr1', () {
      test('returns success result', () async {
        final result = await service.saveGstr1(_validGstin, _period, {
          'test': 'data',
        });
        expect(result.success, isTrue);
      });

      test('result has correct gstin', () async {
        final result = await service.saveGstr1(_validGstin, _period, {});
        expect(result.gstin, _validGstin);
      });

      test('result has correct period', () async {
        final result = await service.saveGstr1(_validGstin, _period, {});
        expect(result.period, _period);
      });

      test('result returnType is GSTR1', () async {
        final result = await service.saveGstr1(_validGstin, _period, {});
        expect(result.returnType, 'GSTR1');
      });

      test('result referenceId is non-null', () async {
        final result = await service.saveGstr1(_validGstin, _period, {});
        expect(result.referenceId, isNotNull);
        expect(result.referenceId, isNotEmpty);
      });

      test('result referenceId contains GSTIN', () async {
        final result = await service.saveGstr1(_validGstin, _period, {});
        expect(result.referenceId, contains(_validGstin));
      });

      test('errorMessage is null on success', () async {
        final result = await service.saveGstr1(_validGstin, _period, {});
        expect(result.errorMessage, isNull);
      });

      test('accepts any non-null payload map', () async {
        final result = await service.saveGstr1(_validGstin, _period, {
          'gstin': _validGstin,
          'ret_period': _period,
          'sup_details': [],
          'itc_elg': {},
        });
        expect(result.success, isTrue);
      });
    });

    // ── submitGstr1 ──────────────────────────────────────────────────────────

    group('submitGstr1', () {
      test('returns success result', () async {
        final result = await service.submitGstr1(_validGstin, _period);
        expect(result.success, isTrue);
      });

      test('result has correct gstin and period', () async {
        final result = await service.submitGstr1(_validGstin, _period);
        expect(result.gstin, _validGstin);
        expect(result.period, _period);
      });

      test('result returnType is GSTR1', () async {
        final result = await service.submitGstr1(_validGstin, _period);
        expect(result.returnType, 'GSTR1');
      });

      test('submissionToken is non-null', () async {
        final result = await service.submitGstr1(_validGstin, _period);
        expect(result.submissionToken, isNotNull);
        expect(result.submissionToken, isNotEmpty);
      });

      test('submissionToken contains GSTIN', () async {
        final result = await service.submitGstr1(_validGstin, _period);
        expect(result.submissionToken, contains(_validGstin));
      });

      test('errorMessage is null on success', () async {
        final result = await service.submitGstr1(_validGstin, _period);
        expect(result.errorMessage, isNull);
      });
    });

    // ── fileGstr1WithEvc ─────────────────────────────────────────────────────

    group('fileGstr1WithEvc', () {
      test('returns success result', () async {
        final result = await service.fileGstr1WithEvc(
          _validGstin,
          _period,
          '123456',
        );
        expect(result.success, isTrue);
      });

      test('result has correct gstin and period', () async {
        final result = await service.fileGstr1WithEvc(
          _validGstin,
          _period,
          '123456',
        );
        expect(result.gstin, _validGstin);
        expect(result.period, _period);
      });

      test('result returnType is GSTR1', () async {
        final result = await service.fileGstr1WithEvc(
          _validGstin,
          _period,
          '999999',
        );
        expect(result.returnType, 'GSTR1');
      });

      test('ARN is non-null and non-empty', () async {
        final result = await service.fileGstr1WithEvc(
          _validGstin,
          _period,
          '123456',
        );
        expect(result.arn, isNotNull);
        expect(result.arn, isNotEmpty);
      });

      test('filedAt is non-null and recent', () async {
        final before = DateTime.now().subtract(const Duration(seconds: 5));
        final result = await service.fileGstr1WithEvc(
          _validGstin,
          _period,
          '123456',
        );
        expect(result.filedAt, isNotNull);
        expect(result.filedAt!.isAfter(before), isTrue);
      });

      test('errorMessage is null on success', () async {
        final result = await service.fileGstr1WithEvc(
          _validGstin,
          _period,
          '123456',
        );
        expect(result.errorMessage, isNull);
      });
    });

    // ── getFilingStatus ──────────────────────────────────────────────────────

    group('getFilingStatus', () {
      test('returns filed status for GSTR1', () async {
        final result = await service.getFilingStatus(
          _validGstin,
          _period,
          'GSTR1',
        );
        expect(result.statusCode, GstrFilingStatusCode.filed);
        expect(result.isFiled, isTrue);
      });

      test('returns filed status for GSTR3B', () async {
        final result = await service.getFilingStatus(
          _validGstin,
          _period,
          'GSTR3B',
        );
        expect(result.statusCode, GstrFilingStatusCode.filed);
      });

      test('result has correct gstin, period and returnType', () async {
        final result = await service.getFilingStatus(
          _validGstin,
          _period,
          'GSTR9',
        );
        expect(result.gstin, _validGstin);
        expect(result.period, _period);
        expect(result.returnType, 'GSTR9');
      });

      test('ARN is non-null', () async {
        final result = await service.getFilingStatus(
          _validGstin,
          _period,
          'GSTR1',
        );
        expect(result.arn, isNotNull);
        expect(result.arn, isNotEmpty);
      });

      test('filedAt is a specific date', () async {
        final result = await service.getFilingStatus(
          _validGstin,
          _period,
          'GSTR1',
        );
        expect(result.filedAt, isNotNull);
        expect(result.filedAt, DateTime(2024, 8, 20));
      });

      test('lastUpdatedAt is recent', () async {
        final before = DateTime.now().subtract(const Duration(seconds: 5));
        final result = await service.getFilingStatus(
          _validGstin,
          _period,
          'GSTR1',
        );
        expect(result.lastUpdatedAt, isNotNull);
        expect(result.lastUpdatedAt!.isAfter(before), isTrue);
      });
    });

    // ── GstrFilingStatusCode enum ─────────────────────────────────────────────

    group('GstrFilingStatusCode.fromCode', () {
      test('"SAV" maps to saved', () {
        expect(
          GstrFilingStatusCode.fromCode('SAV'),
          GstrFilingStatusCode.saved,
        );
      });

      test('"SUB" maps to submitted', () {
        expect(
          GstrFilingStatusCode.fromCode('SUB'),
          GstrFilingStatusCode.submitted,
        );
      });

      test('"FIL" maps to filed', () {
        expect(
          GstrFilingStatusCode.fromCode('FIL'),
          GstrFilingStatusCode.filed,
        );
      });

      test('"CNF" also maps to filed', () {
        expect(
          GstrFilingStatusCode.fromCode('CNF'),
          GstrFilingStatusCode.filed,
        );
      });

      test('"PRO" maps to processed', () {
        expect(
          GstrFilingStatusCode.fromCode('PRO'),
          GstrFilingStatusCode.processed,
        );
      });

      test('"REJ" maps to rejected', () {
        expect(
          GstrFilingStatusCode.fromCode('REJ'),
          GstrFilingStatusCode.rejected,
        );
      });

      test('unknown code maps to notFiled', () {
        expect(
          GstrFilingStatusCode.fromCode('XYZ'),
          GstrFilingStatusCode.notFiled,
        );
      });

      test('lowercase code is normalised', () {
        expect(
          GstrFilingStatusCode.fromCode('fil'),
          GstrFilingStatusCode.filed,
        );
      });
    });

    // ── isFiled computed property ─────────────────────────────────────────────

    group('GstrFilingStatus.isFiled', () {
      test('is true for filed status', () {
        const status = GstrFilingStatus(
          gstin: _validGstin,
          period: _period,
          returnType: 'GSTR1',
          statusCode: GstrFilingStatusCode.filed,
        );
        expect(status.isFiled, isTrue);
      });

      test('is true for processed status', () {
        const status = GstrFilingStatus(
          gstin: _validGstin,
          period: _period,
          returnType: 'GSTR1',
          statusCode: GstrFilingStatusCode.processed,
        );
        expect(status.isFiled, isTrue);
      });

      test('is false for submitted status', () {
        const status = GstrFilingStatus(
          gstin: _validGstin,
          period: _period,
          returnType: 'GSTR1',
          statusCode: GstrFilingStatusCode.submitted,
        );
        expect(status.isFiled, isFalse);
      });

      test('is false for notFiled status', () {
        const status = GstrFilingStatus(
          gstin: _validGstin,
          period: _period,
          returnType: 'GSTR1',
          statusCode: GstrFilingStatusCode.notFiled,
        );
        expect(status.isFiled, isFalse);
      });
    });

    // ── full filing flow ─────────────────────────────────────────────────────

    group('full filing flow: save → submit → fileWithEvc', () {
      test('completes without error', () async {
        // save
        final saveResult = await service.saveGstr1(_validGstin, _period, {
          'gstin': _validGstin,
        });
        expect(saveResult.success, isTrue);

        // submit
        final submitResult = await service.submitGstr1(_validGstin, _period);
        expect(submitResult.success, isTrue);
        expect(submitResult.submissionToken, isNotNull);

        // file with EVC
        final fileResult = await service.fileGstr1WithEvc(
          _validGstin,
          _period,
          '654321',
        );
        expect(fileResult.success, isTrue);
        expect(fileResult.arn, isNotNull);
      });

      test('getFilingStatus reflects filed after filing', () async {
        await service.saveGstr1(_validGstin, _period, {});
        await service.submitGstr1(_validGstin, _period);
        await service.fileGstr1WithEvc(_validGstin, _period, '123456');

        final status = await service.getFilingStatus(
          _validGstin,
          _period,
          'GSTR1',
        );
        expect(status.isFiled, isTrue);
      });
    });
  });
}
