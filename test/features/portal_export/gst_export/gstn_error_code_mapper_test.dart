import 'package:ca_app/features/portal_export/gst_export/services/gstn_error_code_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GstnErrorCodeMapper', () {
    late GstnErrorCodeMapper mapper;

    setUp(() {
      mapper = GstnErrorCodeMapper.instance;
    });

    test('is a singleton', () {
      expect(GstnErrorCodeMapper.instance, same(GstnErrorCodeMapper.instance));
    });

    group('getMessage', () {
      test('RET191001 returns invalid GSTIN message', () {
        final msg = mapper.getMessage('RET191001');
        expect(msg, isNotEmpty);
        expect(msg.toLowerCase(), contains('gstin'));
      });

      test('RET191002 returns period mismatch message', () {
        final msg = mapper.getMessage('RET191002');
        expect(msg, isNotEmpty);
        expect(msg.toLowerCase(), contains('period'));
      });

      test('RET191003 returns duplicate filing message', () {
        final msg = mapper.getMessage('RET191003');
        expect(msg, isNotEmpty);
        expect(msg.toLowerCase(), contains('duplicate'));
      });

      test('unknown code returns a generic fallback message', () {
        final msg = mapper.getMessage('RET999999');
        expect(msg, isNotEmpty);
      });

      test('empty code returns a fallback message', () {
        final msg = mapper.getMessage('');
        expect(msg, isNotEmpty);
      });

      test('returns non-empty String for all known codes', () {
        const knownCodes = [
          'RET191001',
          'RET191002',
          'RET191003',
        ];
        for (final code in knownCodes) {
          expect(mapper.getMessage(code), isNotEmpty, reason: 'code $code returned empty');
        }
      });
    });

    group('isRetryable', () {
      test('RET191001 (invalid GSTIN) is not retryable', () {
        expect(mapper.isRetryable('RET191001'), isFalse);
      });

      test('RET191002 (period mismatch) is not retryable', () {
        expect(mapper.isRetryable('RET191002'), isFalse);
      });

      test('RET191003 (duplicate filing) is not retryable', () {
        expect(mapper.isRetryable('RET191003'), isFalse);
      });

      test('unknown error code returns false for isRetryable', () {
        expect(mapper.isRetryable('RET999999'), isFalse);
      });

      test('empty error code returns false for isRetryable', () {
        expect(mapper.isRetryable(''), isFalse);
      });
    });
  });
}
