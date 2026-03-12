import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/features/portal_export/tds_export/services/fvu_validator.dart';

void main() {
  group('FvuValidator', () {
    group('validateTan', () {
      test('accepts valid TAN format', () {
        expect(FvuValidator.validateTan('AAATA1234X'), isTrue);
      });

      test('accepts valid TAN with different chars', () {
        expect(FvuValidator.validateTan('MUMM12345Z'), isTrue);
      });

      test('rejects TAN with lowercase letters', () {
        expect(FvuValidator.validateTan('aaata1234x'), isFalse);
      });

      test('rejects TAN shorter than 10 chars', () {
        expect(FvuValidator.validateTan('AAATA123'), isFalse);
      });

      test('rejects TAN longer than 10 chars', () {
        expect(FvuValidator.validateTan('AAATA1234XY'), isFalse);
      });

      test('rejects TAN with incorrect pattern', () {
        // Must be: 4 uppercase letters, 5 digits, 1 uppercase letter
        expect(FvuValidator.validateTan('1AATA1234X'), isFalse);
      });

      test('rejects empty string', () {
        expect(FvuValidator.validateTan(''), isFalse);
      });

      test('rejects TAN ending with digit', () {
        expect(FvuValidator.validateTan('AAATA12345'), isFalse);
      });
    });

    group('validatePan', () {
      test('accepts valid PAN format', () {
        expect(FvuValidator.validatePan('ABCDE1234F'), isTrue);
      });

      test('accepts PANNOTAVBL as valid sentinel', () {
        expect(FvuValidator.validatePan('PANNOTAVBL'), isTrue);
      });

      test('rejects PAN with lowercase letters', () {
        expect(FvuValidator.validatePan('abcde1234f'), isFalse);
      });

      test('rejects PAN shorter than 10 chars', () {
        expect(FvuValidator.validatePan('ABCDE123F'), isFalse);
      });

      test('rejects PAN with wrong pattern', () {
        // Pattern: 5 uppercase letters, 4 digits, 1 uppercase letter
        expect(FvuValidator.validatePan('1BCDE1234F'), isFalse);
      });

      test('rejects empty string', () {
        expect(FvuValidator.validatePan(''), isFalse);
      });
    });

    group('validateChallanBsrCode', () {
      test('accepts valid 7-digit BSR code', () {
        expect(FvuValidator.validateChallanBsrCode('0012345'), isTrue);
      });

      test('accepts BSR code with leading zeros', () {
        expect(FvuValidator.validateChallanBsrCode('0000001'), isTrue);
      });

      test('rejects BSR code shorter than 7 digits', () {
        expect(FvuValidator.validateChallanBsrCode('12345'), isFalse);
      });

      test('rejects BSR code longer than 7 digits', () {
        expect(FvuValidator.validateChallanBsrCode('00123456'), isFalse);
      });

      test('rejects BSR code with letters', () {
        expect(FvuValidator.validateChallanBsrCode('ABC1234'), isFalse);
      });

      test('rejects empty string', () {
        expect(FvuValidator.validateChallanBsrCode(''), isFalse);
      });
    });

    group('validateFvuContent', () {
      // Minimal valid FVU content
      const validFvu =
          'BH|AAATA1234X|26Q|2024|Q1\n'
          'CD|0012345|01042024|0000000001|000000001000000|0000000002|194C      \n'
          'DD|ABCDE1234F|John Doe                                |000000010000000|000000001000000|01042024  |194C      |2\n'
          'DD|PANNOTAVBL|Jane Smith                              |000000005000000|000000000500000|01042024  |194C      |2\n'
          'BT|0000000001|0000000002|000000001500000';

      test('returns empty list for valid FVU content', () {
        final errors = FvuValidator.validateFvuContent(validFvu);
        expect(errors, isEmpty);
      });

      test('reports error when BH record is missing', () {
        const content = 'CD|BSR\nBT|1|1|100';
        final errors = FvuValidator.validateFvuContent(content);
        expect(errors, contains(contains('BH')));
      });

      test('reports error when BT record is missing', () {
        const content = 'BH|AAATA1234X\nCD|BSR';
        final errors = FvuValidator.validateFvuContent(content);
        expect(errors, contains(contains('BT')));
      });

      test('reports error for empty content', () {
        final errors = FvuValidator.validateFvuContent('');
        expect(errors, isNotEmpty);
      });

      test('reports error when record counts do not match', () {
        // BT says 1 challan, but there are 0 CD records
        const content =
            'BH|AAATA1234X\n'
            'BT|0000000001|0000000000|000000000000000';
        final errors = FvuValidator.validateFvuContent(content);
        expect(errors, contains(contains('challan')));
      });

      test('reports error when deductee counts do not match', () {
        // BT says 2 deductees, but there is only 1 DD record
        const content =
            'BH|AAATA1234X\n'
            'CD|0012345|01042024|0000000001|000000001000000|0000000001|194C      \n'
            'DD|ABCDE1234F|John Doe                                |000000010000000|000000001000000|01042024  |194C      |2\n'
            'BT|0000000001|0000000002|000000001000000';
        final errors = FvuValidator.validateFvuContent(content);
        expect(errors, contains(contains('deductee')));
      });
    });
  });
}
