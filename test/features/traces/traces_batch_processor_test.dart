import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/traces/data/mock_traces_repository.dart';
import 'package:ca_app/features/traces/domain/models/traces_form16_request.dart';
import 'package:ca_app/features/traces/domain/services/traces_batch_processor.dart';

void main() {
  late MockTracesRepository repo;
  const processor = TracesBatchProcessor();

  setUp(() {
    repo = MockTracesRepository();
  });

  group('TracesBatchProcessor.batchVerifyPans', () {
    test('verifies a single PAN', () async {
      final results = await processor.batchVerifyPans(
        ['ABCDE1234F'],
        repo,
      );
      expect(results.length, 1);
      expect(results.first.pan, 'ABCDE1234F');
    });

    test('verifies multiple PANs', () async {
      final pans = ['ABCDE1234F', 'PQRST5678A', 'LMNOP9012B'];
      final results = await processor.batchVerifyPans(pans, repo);
      expect(results.length, 3);
    });

    test('returns empty list for empty input', () async {
      final results = await processor.batchVerifyPans([], repo);
      expect(results, isEmpty);
    });

    test('processes exactly 50 PANs in one chunk', () async {
      final pans = List.generate(50, (i) {
        final letters = String.fromCharCodes(
          List.generate(5, (_) => 65 + (i % 26)),
        );
        final digits = (1000 + i % 9000).toString();
        return '$letters${digits}A';
      });
      final results = await processor.batchVerifyPans(pans, repo);
      expect(results.length, 50);
    });

    test('processes more than 50 PANs (multi-chunk)', () async {
      // Generate 75 unique valid-format PANs
      final pans = List.generate(75, (i) {
        final c1 = String.fromCharCode(65 + i ~/ 26 % 26);
        final c2 = String.fromCharCode(65 + i % 26);
        final digits = (1000 + (i % 9000)).toString().padLeft(4, '0');
        return 'A$c1${c2}DE${digits}F';
      });
      final results = await processor.batchVerifyPans(pans, repo);
      expect(results.length, 75);
    });

    test('result order matches input order', () async {
      final pans = ['ABCDE1234F', 'PQRST5678A'];
      final results = await processor.batchVerifyPans(pans, repo);
      expect(results[0].pan, 'ABCDE1234F');
      expect(results[1].pan, 'PQRST5678A');
    });
  });

  group('TracesBatchProcessor.batchRequestForm16', () {
    test('returns one request per PAN', () async {
      final pans = ['ABCDE1234F', 'PQRST5678A'];
      final results = await processor.batchRequestForm16(
        'MUMA12345B',
        pans,
        2024,
        repo,
      );
      expect(results.length, 2);
    });

    test('returns empty list for empty PANs', () async {
      final results = await processor.batchRequestForm16(
        'MUMA12345B',
        [],
        2024,
        repo,
      );
      expect(results, isEmpty);
    });

    test('all results carry the correct TAN', () async {
      final pans = ['ABCDE1234F', 'PQRST5678A', 'LMNOP9012B'];
      final results = await processor.batchRequestForm16(
        'MUMA12345B',
        pans,
        2024,
        repo,
      );
      for (final req in results) {
        expect(req.tan, 'MUMA12345B');
      }
    });

    test('processes 51 PANs across two chunks', () async {
      final pans = List.generate(51, (i) {
        final c1 = String.fromCharCode(65 + i ~/ 26 % 26);
        final c2 = String.fromCharCode(65 + i % 26);
        final digits = (1000 + (i % 9000)).toString().padLeft(4, '0');
        return 'A$c1${c2}DE${digits}F';
      });
      final results = await processor.batchRequestForm16(
        'MUMA12345B',
        pans,
        2024,
        repo,
      );
      expect(results.length, 51);
    });
  });

  group('TracesBatchProcessor.computeBatchProgress', () {
    test('returns 0.0 for empty list', () {
      expect(processor.computeBatchProgress([]), 0.0);
    });

    test('returns 0.0 when all are submitted', () {
      final requests = [
        _makeRequest(Form16RequestStatus.submitted),
        _makeRequest(Form16RequestStatus.submitted),
      ];
      expect(processor.computeBatchProgress(requests), 0.0);
    });

    test('returns 1.0 when all are downloaded', () {
      final requests = [
        _makeRequest(Form16RequestStatus.downloaded),
        _makeRequest(Form16RequestStatus.downloaded),
      ];
      expect(processor.computeBatchProgress(requests), 1.0);
    });

    test('returns 1.0 when all are available', () {
      final requests = [
        _makeRequest(Form16RequestStatus.available),
        _makeRequest(Form16RequestStatus.available),
      ];
      expect(processor.computeBatchProgress(requests), 1.0);
    });

    test('returns 0.5 for half available half submitted', () {
      final requests = [
        _makeRequest(Form16RequestStatus.available),
        _makeRequest(Form16RequestStatus.submitted),
      ];
      expect(processor.computeBatchProgress(requests), 0.5);
    });

    test('returns value between 0 and 1 for mixed statuses', () {
      final requests = [
        _makeRequest(Form16RequestStatus.downloaded),
        _makeRequest(Form16RequestStatus.available),
        _makeRequest(Form16RequestStatus.processing),
        _makeRequest(Form16RequestStatus.submitted),
        _makeRequest(Form16RequestStatus.failed),
      ];
      final progress = processor.computeBatchProgress(requests);
      expect(progress, greaterThanOrEqualTo(0.0));
      expect(progress, lessThanOrEqualTo(1.0));
    });

    test('failed requests count as complete (progress moves forward)', () {
      final requests = [
        _makeRequest(Form16RequestStatus.failed),
        _makeRequest(Form16RequestStatus.failed),
      ];
      expect(processor.computeBatchProgress(requests), 1.0);
    });
  });
}

TracesForm16Request _makeRequest(Form16RequestStatus status) {
  return TracesForm16Request(
    requestId: 'REQ001',
    tan: 'MUMA12345B',
    pan: 'ABCDE1234F',
    financialYear: 2024,
    requestType: Form16RequestType.form16,
    status: status,
    requestedAt: DateTime(2024, 4, 1),
  );
}
