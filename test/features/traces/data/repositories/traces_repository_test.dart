import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/traces/data/mock_traces_repository.dart';
import 'package:ca_app/features/traces/data/repositories/traces_repository_impl.dart';
import 'package:ca_app/features/traces/domain/models/traces_challan_status.dart';
import 'package:ca_app/features/traces/domain/models/traces_justification_report.dart';
import 'package:ca_app/features/traces/domain/models/traces_pan_verification.dart';

void main() {
  group('MockTracesRepository', () {
    late MockTracesRepository repo;

    setUp(() {
      repo = MockTracesRepository();
    });

    group('verifyPan', () {
      test('returns valid for well-formed PAN', () async {
        final result = await repo.verifyPan('ABCDE1234F');
        expect(result.status, PanStatus.valid);
        expect(result.pan, 'ABCDE1234F');
      });

      test('returns invalid for malformed PAN', () async {
        final result = await repo.verifyPan('INVALID_PAN');
        expect(result.status, PanStatus.invalid);
      });
    });

    group('getChallanStatus', () {
      test('returns matched status with consumed == deposited', () async {
        final date = DateTime(2025, 7, 7);
        final result = await repo.getChallanStatus(
          '0001234',
          date,
          '00001',
          'MUMR12345A',
        );
        expect(result.status, ChallanBookingStatus.matched);
        expect(result.consumedAmount, result.depositedAmount);
        expect(result.balanceAmount, 0);
      });
    });

    group('requestForm16', () {
      test('returns available status', () async {
        final result = await repo.requestForm16(
          'MUMR12345A',
          'ABCDE1234F',
          2025,
        );
        expect(result.tan, 'MUMR12345A');
        expect(result.pan, 'ABCDE1234F');
        expect(result.financialYear, 2025);
      });
    });

    group('requestBulkForm16', () {
      test('returns one result per PAN', () async {
        final pans = ['ABCDE1234F', 'FGHIJ5678K', 'LMNOP9012L'];
        final results = await repo.requestBulkForm16('MUMR12345A', 2025, pans);
        expect(results, hasLength(3));
        for (var i = 0; i < pans.length; i++) {
          expect(results[i].pan, pans[i]);
        }
      });
    });

    group('getJustificationReport', () {
      test('returns empty report for Q1', () async {
        final result = await repo.getJustificationReport('MUMR12345A', 2025, 1);
        expect(result.tan, 'MUMR12345A');
        expect(result.quarter, TdsQuarter.q1);
        expect(result.shortDeductions, isEmpty);
      });
    });

    group('getAllChallans', () {
      test('returns list of challans', () async {
        final result = await repo.getAllChallans('MUMR12345A', 2025);
        expect(result, isNotEmpty);
        for (final c in result) {
          expect(c.tan, 'MUMR12345A');
        }
      });
    });
  });

  group('TracesRepositoryImpl', () {
    late TracesRepositoryImpl repo;

    setUp(() {
      repo = const TracesRepositoryImpl();
    });

    group('verifyPan', () {
      test('throws ArgumentError for PAN shorter than 10 chars', () async {
        expect(() => repo.verifyPan('SHORT'), throwsArgumentError);
      });

      test('returns result for 10-char PAN', () async {
        final result = await repo.verifyPan('ABCDE1234F');
        expect(result.pan, 'ABCDE1234F');
      });
    });

    group('getAllChallans', () {
      test('returns empty list', () async {
        final result = await repo.getAllChallans('MUMR12345A', 2025);
        expect(result, isEmpty);
      });
    });
  });
}
