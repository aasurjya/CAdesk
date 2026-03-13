import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/traces/data/mock_traces_repository.dart';
import 'package:ca_app/features/traces/domain/models/traces_pan_verification.dart';
import 'package:ca_app/features/traces/domain/models/traces_challan_status.dart';
import 'package:ca_app/features/traces/domain/models/traces_form16_request.dart';

void main() {
  late MockTracesRepository repo;

  setUp(() {
    repo = MockTracesRepository();
  });

  group('MockTracesRepository.verifyPan', () {
    test('returns valid status for a well-formed PAN', () async {
      final result = await repo.verifyPan('ABCDE1234F');
      expect(result.pan, 'ABCDE1234F');
      expect(result.status, PanStatus.valid);
    });

    test('returns invalid status for a malformed PAN (wrong length)', () async {
      final result = await repo.verifyPan('ABC123');
      expect(result.status, PanStatus.invalid);
    });

    test('returns invalid status for PAN with lowercase letters', () async {
      final result = await repo.verifyPan('abcde1234f');
      expect(result.status, PanStatus.invalid);
    });

    test('returns invalid status for PAN with wrong digit placement', () async {
      // 5 digits then 4 letters then 1 letter — wrong
      final result = await repo.verifyPan('12345ABCF1');
      expect(result.status, PanStatus.invalid);
    });

    test('valid PAN has non-empty name field', () async {
      final result = await repo.verifyPan('PQRST5678A');
      expect(result.name, isNotEmpty);
    });

    test('valid PAN has a verifiedAt timestamp', () async {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final result = await repo.verifyPan('ABCDE1234F');
      expect(result.verifiedAt.isAfter(before), isTrue);
    });

    test('verifyPan returns TracesPanVerification with consistent fields', () async {
      final result = await repo.verifyPan('ABCDE1234F');
      // Confirm the same instance compares equal to itself (operator== sanity)
      expect(result, equals(result));
      // Confirm hashCode is stable for the same object
      expect(result.hashCode, result.hashCode);
    });

    test('copyWith produces new instance with updated status', () async {
      final result = await repo.verifyPan('ABCDE1234F');
      final updated = result.copyWith(status: PanStatus.inactive);
      expect(updated.status, PanStatus.inactive);
      expect(updated.pan, result.pan);
    });
  });

  group('MockTracesRepository.getChallanStatus', () {
    test('returns matched status for any challan query', () async {
      final result = await repo.getChallanStatus(
        '0001234',
        DateTime(2024, 4, 1),
        '00001',
        'MUMA12345B',
      );
      expect(result.status, ChallanBookingStatus.matched);
    });

    test('consumed amount equals deposited amount', () async {
      final result = await repo.getChallanStatus(
        '0001234',
        DateTime(2024, 4, 1),
        '00001',
        'MUMA12345B',
      );
      expect(result.consumedAmount, result.depositedAmount);
      expect(result.balanceAmount, 0);
    });

    test('returns the provided bsr code', () async {
      final result = await repo.getChallanStatus(
        '9998887',
        DateTime(2024, 6, 15),
        '00123',
        'DELA99999Z',
      );
      expect(result.bsrCode, '9998887');
      expect(result.challanSerial, '00123');
      expect(result.tan, 'DELA99999Z');
    });

    test('copyWith creates new challan status with updated fields', () async {
      final result = await repo.getChallanStatus(
        '0001234',
        DateTime(2024, 4, 1),
        '00001',
        'MUMA12345B',
      );
      final updated = result.copyWith(
        status: ChallanBookingStatus.overBooked,
      );
      expect(updated.status, ChallanBookingStatus.overBooked);
      expect(updated.bsrCode, result.bsrCode);
    });
  });

  group('MockTracesRepository.requestForm16', () {
    test('returns available status immediately', () async {
      final result = await repo.requestForm16(
        'MUMA12345B',
        'ABCDE1234F',
        2024,
      );
      expect(result.status, Form16RequestStatus.available);
    });

    test('returned request has correct tan and pan', () async {
      final result = await repo.requestForm16(
        'MUMA12345B',
        'ABCDE1234F',
        2024,
      );
      expect(result.tan, 'MUMA12345B');
      expect(result.pan, 'ABCDE1234F');
      expect(result.financialYear, 2024);
    });

    test('returned request has a non-empty requestId', () async {
      final result = await repo.requestForm16(
        'MUMA12345B',
        'ABCDE1234F',
        2024,
      );
      expect(result.requestId, isNotEmpty);
    });

    test('downloadUrl is non-null for available status', () async {
      final result = await repo.requestForm16(
        'MUMA12345B',
        'ABCDE1234F',
        2024,
      );
      expect(result.downloadUrl, isNotNull);
    });

    test('copyWith updates fields correctly', () async {
      final result = await repo.requestForm16(
        'MUMA12345B',
        'ABCDE1234F',
        2024,
      );
      final updated = result.copyWith(
        status: Form16RequestStatus.downloaded,
      );
      expect(updated.status, Form16RequestStatus.downloaded);
      expect(updated.requestId, result.requestId);
    });
  });

  group('MockTracesRepository.requestBulkForm16', () {
    test('returns one request per PAN', () async {
      final pans = ['ABCDE1234F', 'PQRST5678A', 'LMNOP9012B'];
      final result = await repo.requestBulkForm16(
        'MUMA12345B',
        2024,
        pans,
      );
      expect(result.length, pans.length);
    });

    test('all bulk requests have available status', () async {
      final pans = ['ABCDE1234F', 'PQRST5678A'];
      final results = await repo.requestBulkForm16(
        'MUMA12345B',
        2024,
        pans,
      );
      for (final req in results) {
        expect(req.status, Form16RequestStatus.available);
      }
    });

    test('bulk request with empty list returns empty list', () async {
      final result = await repo.requestBulkForm16('MUMA12345B', 2024, []);
      expect(result, isEmpty);
    });
  });

  group('MockTracesRepository.getJustificationReport', () {
    test('returns empty shortfall report by default', () async {
      final result = await repo.getJustificationReport(
        'MUMA12345B',
        2024,
        1,
      );
      expect(result.shortDeductions, isEmpty);
      expect(result.lateDeductions, isEmpty);
      expect(result.totalShortfall, 0);
      expect(result.totalInterestDemand, 0);
    });

    test('returned report has correct tan and financialYear', () async {
      final result = await repo.getJustificationReport(
        'MUMA12345B',
        2024,
        2,
      );
      expect(result.tan, 'MUMA12345B');
      expect(result.financialYear, 2024);
    });

    test('quarter maps correctly for all four quarters', () async {
      for (var q = 1; q <= 4; q++) {
        final result = await repo.getJustificationReport(
          'MUMA12345B',
          2024,
          q,
        );
        expect(result.quarter.index + 1, q);
      }
    });

    test('copyWith updates totalShortfall', () async {
      final result = await repo.getJustificationReport(
        'MUMA12345B',
        2024,
        1,
      );
      final updated = result.copyWith(totalShortfall: 10000);
      expect(updated.totalShortfall, 10000);
      expect(updated.tan, result.tan);
    });
  });

  group('MockTracesRepository.getAllChallans', () {
    test('returns a non-empty list of challans for a TAN', () async {
      final result = await repo.getAllChallans('MUMA12345B', 2024);
      expect(result, isNotEmpty);
    });

    test('all challans belong to the requested TAN', () async {
      final result = await repo.getAllChallans('MUMA12345B', 2024);
      for (final c in result) {
        expect(c.tan, 'MUMA12345B');
      }
    });
  });
}
