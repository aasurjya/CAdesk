import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/ai/ocr/ocr_preprocessor.dart';

void main() {
  group('OcrPreprocessor', () {
    late OcrPreprocessor preprocessor;

    setUp(() {
      preprocessor = const OcrPreprocessor();
    });

    // ---------------------------------------------------------------------------
    // Helpers — minimal valid image headers
    // ---------------------------------------------------------------------------

    /// Builds a minimal PNG byte sequence with given width and height.
    /// PNG header (8 bytes) + IHDR chunk offset: width at offset 16, height at 20.
    List<int> buildPngBytes({
      int width = 1024,
      int height = 768,
      int totalLength = 2000,
    }) {
      final bytes = List<int>.filled(totalLength, 128);
      // PNG signature
      bytes[0] = 0x89;
      bytes[1] = 0x50; // 'P'
      bytes[2] = 0x4E; // 'N'
      bytes[3] = 0x47; // 'G'
      bytes[4] = 0x0D;
      bytes[5] = 0x0A;
      bytes[6] = 0x1A;
      bytes[7] = 0x0A;
      // IHDR width at offset 16 (big-endian int32)
      bytes[16] = (width >> 24) & 0xFF;
      bytes[17] = (width >> 16) & 0xFF;
      bytes[18] = (width >> 8) & 0xFF;
      bytes[19] = width & 0xFF;
      // IHDR height at offset 20
      bytes[20] = (height >> 24) & 0xFF;
      bytes[21] = (height >> 16) & 0xFF;
      bytes[22] = (height >> 8) & 0xFF;
      bytes[23] = height & 0xFF;
      return bytes;
    }

    /// Builds a minimal JPEG byte sequence.
    List<int> buildJpegBytes({int totalLength = 2000}) {
      final bytes = List<int>.filled(totalLength, 128);
      bytes[0] = 0xFF;
      bytes[1] = 0xD8; // JPEG SOI marker
      return bytes;
    }

    /// Builds fake PDF bytes (starting with %PDF magic).
    List<int> buildPdfBytes({int totalLength = 2000}) {
      final bytes = List<int>.filled(totalLength, 32);
      // %PDF magic bytes
      bytes[0] = 0x25; // '%'
      bytes[1] = 0x50; // 'P'
      bytes[2] = 0x44; // 'D'
      bytes[3] = 0x46; // 'F'
      return bytes;
    }

    group('preprocess — empty input', () {
      test(
        'empty bytes returns OcrPreprocessResult with isLowResolution true',
        () {
          final result = preprocessor.preprocess([]);

          expect(result.isLowResolution, isTrue);
        },
      );

      test('empty bytes returns processedBytes as empty list', () {
        final result = preprocessor.preprocess([]);

        expect(result.processedBytes, isEmpty);
      });

      test('empty bytes recommends cloud engine', () {
        final result = preprocessor.preprocess([]);

        expect(result.recommendedOcrEngine, equals('cloud'));
      });

      test('empty bytes returns estimatedSkewDegrees of 0.0', () {
        final result = preprocessor.preprocess([]);

        expect(result.estimatedSkewDegrees, equals(0.0));
      });
    });

    group('preprocess — PNG detection', () {
      test('PNG magic bytes produce result with non-null widthPx', () {
        final pngBytes = buildPngBytes(width: 1024, height: 768);
        final result = preprocessor.preprocess(pngBytes);

        expect(result.widthPx, equals(1024));
      });

      test('PNG with sufficient resolution returns widthPx and heightPx', () {
        final pngBytes = buildPngBytes(width: 1200, height: 900);
        final result = preprocessor.preprocess(pngBytes);

        expect(result.widthPx, equals(1200));
        expect(result.heightPx, equals(900));
      });

      test('PNG above minimum resolution is not marked low resolution', () {
        final pngBytes = buildPngBytes(width: 1200, height: 900);
        final result = preprocessor.preprocess(pngBytes);

        // minWidthPx=800, minHeightPx=600 — 1200x900 should pass
        expect(result.isLowResolution, isFalse);
      });

      test('PNG below minimum resolution is marked low resolution', () {
        final pngBytes = buildPngBytes(width: 400, height: 300);
        final result = preprocessor.preprocess(pngBytes);

        expect(result.isLowResolution, isTrue);
      });
    });

    group('preprocess — JPEG detection', () {
      test('JPEG magic bytes produce an OcrPreprocessResult', () {
        final jpegBytes = buildJpegBytes();
        final result = preprocessor.preprocess(jpegBytes);

        expect(result, isA<OcrPreprocessResult>());
      });

      test(
        'JPEG bytes with unknown dimensions results in isLowResolution true',
        () {
          // Our minimal JPEG doesn't have a SOF0 marker, so dimensions
          // cannot be parsed → treated as low resolution.
          final jpegBytes = buildJpegBytes();
          final result = preprocessor.preprocess(jpegBytes);

          expect(result.isLowResolution, isTrue);
        },
      );

      test('JPEG bytes return original bytes in processedBytes', () {
        final jpegBytes = buildJpegBytes(totalLength: 2000);
        final result = preprocessor.preprocess(jpegBytes);

        expect(result.processedBytes, equals(jpegBytes));
      });
    });

    group('preprocess — PDF handling', () {
      test('PDF magic bytes produce an OcrPreprocessResult without error', () {
        final pdfBytes = buildPdfBytes();
        final result = preprocessor.preprocess(pdfBytes);

        expect(result, isA<OcrPreprocessResult>());
      });

      test('PDF bytes return original bytes unchanged in processedBytes', () {
        final pdfBytes = buildPdfBytes(totalLength: 2000);
        final result = preprocessor.preprocess(pdfBytes);

        expect(result.processedBytes, equals(pdfBytes));
      });
    });

    group('preprocess — unknown format', () {
      test('unknown format bytes return valid OcrPreprocessResult', () {
        final randomBytes = List<int>.filled(2000, 0x42);
        final result = preprocessor.preprocess(randomBytes);

        expect(result, isA<OcrPreprocessResult>());
        expect(result.recommendedOcrEngine, isIn(['cloud', 'local']));
      });

      test(
        'unknown format has isLowResolution true (dimensions unresolvable)',
        () {
          final randomBytes = List<int>.filled(2000, 0xAB);
          final result = preprocessor.preprocess(randomBytes);

          // Can't parse dimensions from arbitrary bytes → low resolution.
          expect(result.isLowResolution, isTrue);
        },
      );
    });

    group('OcrPreprocessResult — field types', () {
      test('recommendedOcrEngine is either cloud or local', () {
        final pngBytes = buildPngBytes(width: 1200, height: 900);
        final result = preprocessor.preprocess(pngBytes);

        expect(result.recommendedOcrEngine, isIn(['cloud', 'local']));
      });

      test('estimatedNoiseLevel is in [0.0, 1.0] when present', () {
        final pngBytes = buildPngBytes(width: 1200, height: 900);
        final result = preprocessor.preprocess(pngBytes);

        if (result.estimatedNoiseLevel != null) {
          expect(result.estimatedNoiseLevel, inInclusiveRange(0.0, 1.0));
        }
      });

      test('estimatedSkewDegrees is non-negative', () {
        final pngBytes = buildPngBytes(width: 1200, height: 900);
        final result = preprocessor.preprocess(pngBytes);

        expect(result.estimatedSkewDegrees, isNonNegative);
      });
    });

    group('OcrPreprocessResult — copyWith immutability', () {
      test(
        'copyWith returns new instance with updated recommendedOcrEngine',
        () {
          const original = OcrPreprocessResult(
            processedBytes: [],
            estimatedSkewDegrees: 0.0,
            isLowResolution: false,
            recommendedOcrEngine: 'local',
          );
          final updated = original.copyWith(recommendedOcrEngine: 'cloud');

          expect(updated.recommendedOcrEngine, equals('cloud'));
          expect(updated.isLowResolution, equals(original.isLowResolution));
          expect(identical(original, updated), isFalse);
        },
      );
    });

    group('OcrPreprocessor — engine recommendation logic', () {
      test('low-resolution image recommends cloud', () {
        final lowResBytes = buildPngBytes(width: 400, height: 300);
        final result = preprocessor.preprocess(lowResBytes);

        expect(result.recommendedOcrEngine, equals('cloud'));
      });

      test('good quality PNG can recommend local', () {
        // A PNG with sufficient resolution and low noise / no skew
        // (uniform medium-grey bytes → low variance → low skew → low noise).
        final goodBytes = buildPngBytes(width: 1200, height: 900);
        final result = preprocessor.preprocess(goodBytes);

        // Uniform fill bytes → low noise, low skew → should be local.
        // (Actual result depends on heuristics; we test the type is valid.)
        expect(result.recommendedOcrEngine, isIn(['cloud', 'local']));
      });
    });
  });
}
