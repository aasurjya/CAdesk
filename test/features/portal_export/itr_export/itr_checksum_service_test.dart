import 'package:ca_app/features/portal_export/itr_export/models/itr_export_result.dart';
import 'package:ca_app/features/portal_export/itr_export/services/itr_checksum_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ItrChecksumService', () {
    group('computeSha256', () {
      test('returns 64-character hex string', () {
        final hash = ItrChecksumService.computeSha256('hello');
        expect(hash.length, 64);
        expect(RegExp(r'^[0-9a-f]+$').hasMatch(hash), isTrue);
      });

      test('returns known SHA-256 for empty string', () {
        // SHA-256("") = e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
        final hash = ItrChecksumService.computeSha256('');
        expect(
          hash,
          'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
        );
      });

      test('same input produces same output (deterministic)', () {
        const payload = '{"ITR":{"ITR1":{"PAN":"ABCDE1234F"}}}';
        final h1 = ItrChecksumService.computeSha256(payload);
        final h2 = ItrChecksumService.computeSha256(payload);
        expect(h1, h2);
      });

      test('different inputs produce different outputs', () {
        final h1 = ItrChecksumService.computeSha256('payload_a');
        final h2 = ItrChecksumService.computeSha256('payload_b');
        expect(h1, isNot(h2));
      });
    });

    group('computeSimpleHash', () {
      test('returns non-empty hex string', () {
        final hash = ItrChecksumService.computeSimpleHash('test');
        expect(hash.isNotEmpty, isTrue);
        expect(RegExp(r'^[0-9a-f]+$').hasMatch(hash), isTrue);
      });

      test('is deterministic', () {
        const payload = 'sample_payload';
        final h1 = ItrChecksumService.computeSimpleHash(payload);
        final h2 = ItrChecksumService.computeSimpleHash(payload);
        expect(h1, h2);
      });

      test('different inputs produce different hashes', () {
        final h1 = ItrChecksumService.computeSimpleHash('abc');
        final h2 = ItrChecksumService.computeSimpleHash('xyz');
        expect(h1, isNot(h2));
      });

      test('empty string returns 8-character hex', () {
        final hash = ItrChecksumService.computeSimpleHash('');
        expect(hash.length, 8);
      });
    });

    group('verifyChecksum', () {
      test('returns true when checksum matches payload', () {
        const payload = '{"ITR":{"ITR1":{}}}';
        final checksum = ItrChecksumService.computeSha256(payload);
        final result = ItrExportResult(
          itrType: ItrType.itr1,
          jsonPayload: payload,
          checksum: checksum,
          exportedAt: DateTime(2024, 4, 1),
          assessmentYear: '2024-25',
          panNumber: 'ABCDE1234F',
          validationErrors: const [],
        );
        expect(ItrChecksumService.verifyChecksum(result), isTrue);
      });

      test('returns false when checksum does not match payload', () {
        const payload = '{"ITR":{"ITR1":{}}}';
        final result = ItrExportResult(
          itrType: ItrType.itr1,
          jsonPayload: payload,
          checksum: 'invalid_checksum',
          exportedAt: DateTime(2024, 4, 1),
          assessmentYear: '2024-25',
          panNumber: 'ABCDE1234F',
          validationErrors: const [],
        );
        expect(ItrChecksumService.verifyChecksum(result), isFalse);
      });
    });
  });
}
