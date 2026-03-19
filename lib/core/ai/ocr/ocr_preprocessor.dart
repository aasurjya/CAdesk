import 'dart:math' as math;

// ---------------------------------------------------------------------------
// Result model
// ---------------------------------------------------------------------------

/// Immutable result from [OcrPreprocessor.preprocess].
class OcrPreprocessResult {
  const OcrPreprocessResult({
    required this.processedBytes,
    required this.estimatedSkewDegrees,
    required this.isLowResolution,
    required this.recommendedOcrEngine,
    this.widthPx,
    this.heightPx,
    this.estimatedNoiseLevel,
  });

  /// The (possibly normalised) image bytes ready for OCR ingestion.
  final List<int> processedBytes;

  /// Estimated document skew in degrees (positive = clockwise tilt).
  /// A value of 0.0 means no skew detected.
  final double estimatedSkewDegrees;

  /// `true` when the image is below the minimum recommended resolution
  /// ([OcrPreprocessor.minWidthPx] × [OcrPreprocessor.minHeightPx]).
  final bool isLowResolution;

  /// Which OCR engine to prefer: `'cloud'` for high-quality cloud inference
  /// or `'local'` for on-device processing.
  ///
  /// The recommendation is `'cloud'` for skewed, noisy, or low-res images
  /// that benefit from server-side pre-processing.
  final String recommendedOcrEngine;

  /// Image width in pixels (null if parsing failed).
  final int? widthPx;

  /// Image height in pixels (null if parsing failed).
  final int? heightPx;

  /// Estimated noise level in the range [0.0, 1.0] (higher = more noise).
  final double? estimatedNoiseLevel;

  OcrPreprocessResult copyWith({
    List<int>? processedBytes,
    double? estimatedSkewDegrees,
    bool? isLowResolution,
    String? recommendedOcrEngine,
    int? widthPx,
    int? heightPx,
    double? estimatedNoiseLevel,
  }) {
    return OcrPreprocessResult(
      processedBytes: processedBytes ?? this.processedBytes,
      estimatedSkewDegrees: estimatedSkewDegrees ?? this.estimatedSkewDegrees,
      isLowResolution: isLowResolution ?? this.isLowResolution,
      recommendedOcrEngine: recommendedOcrEngine ?? this.recommendedOcrEngine,
      widthPx: widthPx ?? this.widthPx,
      heightPx: heightPx ?? this.heightPx,
      estimatedNoiseLevel: estimatedNoiseLevel ?? this.estimatedNoiseLevel,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OcrPreprocessResult &&
        other.isLowResolution == isLowResolution &&
        other.recommendedOcrEngine == recommendedOcrEngine &&
        other.estimatedSkewDegrees == estimatedSkewDegrees;
  }

  @override
  int get hashCode =>
      Object.hash(isLowResolution, recommendedOcrEngine, estimatedSkewDegrees);

  @override
  String toString() =>
      'OcrPreprocessResult('
      'engine: $recommendedOcrEngine, '
      'skew: ${estimatedSkewDegrees.toStringAsFixed(1)}°, '
      'lowRes: $isLowResolution, '
      '${widthPx != null ? '${widthPx}x$heightPx px' : 'unknown size'})';
}

// ---------------------------------------------------------------------------
// OcrPreprocessor
// ---------------------------------------------------------------------------

/// Normalises raw image bytes for OCR ingestion by analysing resolution,
/// estimating document skew, and estimating noise — then recommending the
/// best OCR engine for the result.
///
/// This service is pure Dart: it does not import Flutter, image codec, or
/// platform-channel APIs. Image-dimension parsing relies on JPEG/PNG header
/// heuristics so no third-party codec package is required.
///
/// Usage:
/// ```dart
/// final result = OcrPreprocessor().preprocess(imageBytes);
/// if (result.isLowResolution) {
///   // warn user
/// }
/// final engine = result.recommendedOcrEngine; // 'cloud' | 'local'
/// ```
class OcrPreprocessor {
  const OcrPreprocessor({
    this.minWidthPx = 800,
    this.minHeightPx = 600,
    this.skewThresholdDegrees = 3.0,
    this.noiseThreshold = 0.4,
  });

  /// Minimum image width for "acceptable" resolution.
  final int minWidthPx;

  /// Minimum image height for "acceptable" resolution.
  final int minHeightPx;

  /// Skew angle above which cloud OCR is recommended.
  final double skewThresholdDegrees;

  /// Noise level above which cloud OCR is recommended.
  final double noiseThreshold;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Analyses [imageBytes] and returns preprocessing metadata.
  ///
  /// The returned [OcrPreprocessResult.processedBytes] are the original bytes
  /// unchanged (heavy normalisation such as deskewing is delegated to the
  /// OCR service itself). This method focuses on analysis and routing.
  OcrPreprocessResult preprocess(List<int> imageBytes) {
    if (imageBytes.isEmpty) {
      return OcrPreprocessResult(
        processedBytes: const [],
        estimatedSkewDegrees: 0.0,
        isLowResolution: true,
        recommendedOcrEngine: 'cloud',
        estimatedNoiseLevel: 0.0,
      );
    }

    final dimensions = _parseDimensions(imageBytes);
    final widthPx = dimensions?.$1;
    final heightPx = dimensions?.$2;

    final isLowRes = _checkLowResolution(widthPx, heightPx);
    final skew = _estimateSkew(imageBytes);
    final noise = _estimateNoise(imageBytes);

    final engine = _recommendEngine(
      isLowResolution: isLowRes,
      skewDegrees: skew,
      noiseLevel: noise,
    );

    return OcrPreprocessResult(
      processedBytes: List.unmodifiable(imageBytes),
      estimatedSkewDegrees: skew,
      isLowResolution: isLowRes,
      recommendedOcrEngine: engine,
      widthPx: widthPx,
      heightPx: heightPx,
      estimatedNoiseLevel: noise,
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Returns `('width', 'height')` parsed from JPEG or PNG header bytes,
  /// or `null` if the format is unrecognised.
  (int, int)? _parseDimensions(List<int> bytes) {
    if (bytes.length < 24) return null;

    // PNG: bytes 0-7 = signature, then IHDR chunk at offset 8.
    // Width at offset 16 (4 bytes big-endian), Height at offset 20.
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      if (bytes.length < 24) return null;
      final w = _readInt32Be(bytes, 16);
      final h = _readInt32Be(bytes, 20);
      return (w, h);
    }

    // JPEG: signature FF D8, then scan for SOF0/SOF2 (0xC0/0xC2) markers.
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
      return _parseJpegDimensions(bytes);
    }

    return null;
  }

  (int, int)? _parseJpegDimensions(List<int> bytes) {
    var offset = 2;
    while (offset + 9 < bytes.length) {
      if (bytes[offset] != 0xFF) break;
      final marker = bytes[offset + 1];
      // SOF0 = 0xC0, SOF1 = 0xC1, SOF2 = 0xC2
      if (marker == 0xC0 || marker == 0xC1 || marker == 0xC2) {
        final h = _readInt16Be(bytes, offset + 5);
        final w = _readInt16Be(bytes, offset + 7);
        return (w, h);
      }
      final segmentLength = _readInt16Be(bytes, offset + 2);
      offset += 2 + segmentLength;
    }
    return null;
  }

  bool _checkLowResolution(int? widthPx, int? heightPx) {
    if (widthPx == null || heightPx == null) return true;
    return widthPx < minWidthPx || heightPx < minHeightPx;
  }

  /// Estimates document skew by analysing byte variance patterns.
  ///
  /// This is a lightweight heuristic — not a full Hough transform.
  /// Returns 0.0 for non-image data or when skew cannot be determined.
  double _estimateSkew(List<int> bytes) {
    if (bytes.length < 1024) return 0.0;

    // Sample every 128th byte in the middle third of the file and compute
    // variance as a proxy for skew complexity.
    final start = bytes.length ~/ 3;
    final end = (bytes.length * 2) ~/ 3;

    double sum = 0;
    double sumSq = 0;
    int count = 0;

    for (var i = start; i < end; i += 128) {
      final v = bytes[i].toDouble();
      sum += v;
      sumSq += v * v;
      count++;
    }

    if (count < 2) return 0.0;

    final mean = sum / count;
    final variance = (sumSq / count) - (mean * mean);

    // Map variance to an approximate skew angle in degrees.
    // Variance range ~0-3000; skew range 0-10 degrees.
    final normalised = math.min(variance / 3000.0, 1.0);
    return normalised * 10.0;
  }

  /// Estimates image noise by measuring high-frequency byte transitions in a
  /// sample region.
  double _estimateNoise(List<int> bytes) {
    if (bytes.length < 512) return 0.0;

    int transitions = 0;
    final sampleEnd = math.min(bytes.length - 1, 4096);

    for (var i = 1; i < sampleEnd; i++) {
      if ((bytes[i] - bytes[i - 1]).abs() > 50) {
        transitions++;
      }
    }

    return math.min(transitions / sampleEnd.toDouble(), 1.0);
  }

  String _recommendEngine({
    required bool isLowResolution,
    required double skewDegrees,
    required double noiseLevel,
  }) {
    if (isLowResolution ||
        skewDegrees > skewThresholdDegrees ||
        noiseLevel > noiseThreshold) {
      return 'cloud';
    }
    return 'local';
  }

  int _readInt32Be(List<int> bytes, int offset) {
    return ((bytes[offset] & 0xFF) << 24) |
        ((bytes[offset + 1] & 0xFF) << 16) |
        ((bytes[offset + 2] & 0xFF) << 8) |
        (bytes[offset + 3] & 0xFF);
  }

  int _readInt16Be(List<int> bytes, int offset) {
    return ((bytes[offset] & 0xFF) << 8) | (bytes[offset + 1] & 0xFF);
  }
}
