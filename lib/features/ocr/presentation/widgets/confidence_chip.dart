import 'package:flutter/material.dart';

/// Small chip displaying a confidence percentage with color-coded background.
///
/// - green  : confidence >= 0.80
/// - amber  : confidence >= 0.60
/// - red    : confidence <  0.60
class ConfidenceChip extends StatelessWidget {
  const ConfidenceChip({
    super.key,
    required this.confidence,
  });

  final double confidence;

  @override
  Widget build(BuildContext context) {
    final (bgColor, labelColor) = _colors(context);
    final label = '${(confidence * 100).round()}%';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: labelColor,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  (Color bg, Color label) _colors(BuildContext context) {
    if (confidence >= 0.80) {
      return (
        const Color(0xFFDCFCE7), // green-100
        const Color(0xFF166534), // green-800
      );
    }
    if (confidence >= 0.60) {
      return (
        const Color(0xFFFEF9C3), // yellow-100
        const Color(0xFF854D0E), // amber-800
      );
    }
    return (
      const Color(0xFFFEE2E2), // red-100
      const Color(0xFF991B1B), // red-800
    );
  }
}
