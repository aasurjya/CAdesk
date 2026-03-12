import 'package:ca_app/features/gst/domain/models/hsn_sac_code.dart';
import 'package:ca_app/features/gst/domain/services/hsn_sac_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HsnSacService.searchByCode', () {
    test('prefix "10" → returns codes starting with 10', () {
      final results = HsnSacService.searchByCode('10');

      expect(results, isNotEmpty);
      for (final code in results) {
        expect(code.code, startsWith('10'));
      }
    });

    test('prefix "1006" → returns rice code', () {
      final results = HsnSacService.searchByCode('1006');

      expect(results, isNotEmpty);
      expect(results.any((c) => c.code.startsWith('1006')), isTrue);
    });

    test('prefix "9982" → returns SAC codes', () {
      final results = HsnSacService.searchByCode('9982');

      expect(results, isNotEmpty);
      for (final code in results) {
        expect(code.type, HsnSacType.sac);
      }
    });

    test('non-existent prefix "9999" → returns empty list', () {
      final results = HsnSacService.searchByCode('9999');

      expect(results, isEmpty);
    });

    test('empty query → returns all codes', () {
      final results = HsnSacService.searchByCode('');

      expect(results.length, greaterThanOrEqualTo(70));
    });
  });

  group('HsnSacService.searchByDescription', () {
    test('case-insensitive "rice" → finds rice', () {
      final results = HsnSacService.searchByDescription('rice');

      expect(results, isNotEmpty);
      expect(
        results.any(
          (c) => c.description.toLowerCase().contains('rice'),
        ),
        isTrue,
      );
    });

    test('case-insensitive "LEGAL" → finds legal services', () {
      final results = HsnSacService.searchByDescription('LEGAL');

      expect(results, isNotEmpty);
      expect(
        results.any(
          (c) => c.description.toLowerCase().contains('legal'),
        ),
        isTrue,
      );
    });

    test('non-existent "xyznonexistent" → returns empty list', () {
      final results = HsnSacService.searchByDescription('xyznonexistent');

      expect(results, isEmpty);
    });
  });

  group('HsnSacService.getByCode', () {
    test('exact code "1006" → returns rice', () {
      final result = HsnSacService.getByCode('1006');

      expect(result, isNotNull);
      expect(result!.code, '1006');
    });

    test('exact SAC code "998221" → returns accounting', () {
      final result = HsnSacService.getByCode('998221');

      expect(result, isNotNull);
      expect(result!.type, HsnSacType.sac);
    });

    test('non-existent code → returns null', () {
      final result = HsnSacService.getByCode('000000');

      expect(result, isNull);
    });
  });

  group('HsnSacService.getGstRate', () {
    test('code "1006" (rice) → returns 5.0', () {
      final rate = HsnSacService.getGstRate('1006');

      expect(rate, 5.0);
    });

    test('code "998221" (accounting) → returns 18.0', () {
      final rate = HsnSacService.getGstRate('998221');

      expect(rate, 18.0);
    });

    test('non-existent code → returns null', () {
      final rate = HsnSacService.getGstRate('000000');

      expect(rate, isNull);
    });
  });

  group('HsnSacService.validateCode', () {
    test('2-digit code → valid', () {
      expect(HsnSacService.validateCode('10'), isTrue);
    });

    test('4-digit code → valid', () {
      expect(HsnSacService.validateCode('1006'), isTrue);
    });

    test('6-digit code → valid', () {
      expect(HsnSacService.validateCode('998221'), isTrue);
    });

    test('8-digit code → valid', () {
      expect(HsnSacService.validateCode('10061010'), isTrue);
    });

    test('3-digit code → invalid', () {
      expect(HsnSacService.validateCode('100'), isFalse);
    });

    test('5-digit code → invalid', () {
      expect(HsnSacService.validateCode('10061'), isFalse);
    });

    test('non-numeric code → invalid', () {
      expect(HsnSacService.validateCode('AB12'), isFalse);
    });

    test('empty code → invalid', () {
      expect(HsnSacService.validateCode(''), isFalse);
    });
  });

  group('HsnSacService.getChapterCodes', () {
    test('chapter 10 → returns codes with chapter 10', () {
      final results = HsnSacService.getChapterCodes(10);

      expect(results, isNotEmpty);
      for (final code in results) {
        expect(code.chapter, 10);
      }
    });

    test('chapter 99 → returns SAC codes', () {
      final results = HsnSacService.getChapterCodes(99);

      expect(results, isNotEmpty);
      for (final code in results) {
        expect(code.chapter, 99);
        expect(code.type, HsnSacType.sac);
      }
    });

    test('non-existent chapter 0 → returns empty list', () {
      final results = HsnSacService.getChapterCodes(0);

      expect(results, isEmpty);
    });
  });

  group('HsnSacService master database', () {
    test('contains at least 50 HSN codes', () {
      final allCodes = HsnSacService.searchByCode('');
      final hsnCount = allCodes.where((c) => c.type == HsnSacType.hsn).length;

      expect(hsnCount, greaterThanOrEqualTo(50));
    });

    test('contains at least 20 SAC codes', () {
      final allCodes = HsnSacService.searchByCode('');
      final sacCount = allCodes.where((c) => c.type == HsnSacType.sac).length;

      expect(sacCount, greaterThanOrEqualTo(20));
    });
  });
}
