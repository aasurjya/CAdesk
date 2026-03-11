import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/theme/app_colors.dart';

void main() {
  group('AppColors', () {
    test('primary is deep navy', () {
      expect(AppColors.primary, const Color(0xFF1B3A5C));
    });

    test('secondary is warm teal', () {
      expect(AppColors.secondary, const Color(0xFF0D7C7C));
    });

    test('accent is amber', () {
      expect(AppColors.accent, const Color(0xFFE8890C));
    });

    test('success is forest green', () {
      expect(AppColors.success, const Color(0xFF1A7A3A));
    });

    test('warning is amber yellow', () {
      expect(AppColors.warning, const Color(0xFFD4890E));
    });

    test('error is crimson', () {
      expect(AppColors.error, const Color(0xFFC62828));
    });

    test('neutral scale is ordered dark to light', () {
      expect(
        AppColors.neutral900.computeLuminance(),
        lessThan(AppColors.neutral600.computeLuminance()),
      );
      expect(
        AppColors.neutral600.computeLuminance(),
        lessThan(AppColors.neutral400.computeLuminance()),
      );
      expect(
        AppColors.neutral400.computeLuminance(),
        lessThan(AppColors.neutral200.computeLuminance()),
      );
      expect(
        AppColors.neutral200.computeLuminance(),
        lessThan(AppColors.neutral50.computeLuminance()),
      );
    });

    test('surface is white', () {
      expect(AppColors.surface, const Color(0xFFFFFFFF));
    });

    test('dark surface colors are defined', () {
      expect(AppColors.darkSurface, isNotNull);
      expect(AppColors.darkSurfaceVariant, isNotNull);
      expect(
        AppColors.darkSurface.computeLuminance(),
        lessThan(AppColors.darkSurfaceVariant.computeLuminance()),
      );
    });
  });
}
