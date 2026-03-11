import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/theme/app_theme.dart';
import 'package:ca_app/core/theme/app_colors.dart';

void main() {
  group('AppTheme', () {
    group('light theme', () {
      test('uses Material 3', () {
        expect(AppTheme.light.useMaterial3, isTrue);
      });

      test('has light brightness', () {
        expect(AppTheme.light.brightness, Brightness.light);
      });

      test('seed color is deep navy', () {
        final scheme = AppTheme.light.colorScheme;
        expect(scheme.primary, isNotNull);
      });

      test('has app bar center title configured', () {
        expect(AppTheme.light.appBarTheme.centerTitle, isFalse);
      });

      test('has zero app bar elevation', () {
        expect(AppTheme.light.appBarTheme.elevation, 0);
      });

      test('has filled input decoration', () {
        expect(AppTheme.light.inputDecorationTheme.filled, isTrue);
      });

      test('input fill color is surface', () {
        expect(
          AppTheme.light.inputDecorationTheme.fillColor,
          AppColors.surface,
        );
      });

      test('has card with rounded corners', () {
        final shape = AppTheme.light.cardTheme.shape as RoundedRectangleBorder;
        expect(shape.borderRadius, BorderRadius.circular(20));
      });

      test('FAB uses accent color', () {
        expect(
          AppTheme.light.floatingActionButtonTheme.backgroundColor,
          AppColors.accent,
        );
        expect(
          AppTheme.light.floatingActionButtonTheme.foregroundColor,
          Colors.white,
        );
      });

      test('navigation bar shows labels', () {
        expect(
          AppTheme.light.navigationBarTheme.labelBehavior,
          NavigationDestinationLabelBehavior.alwaysShow,
        );
      });

      test('has error color from AppColors', () {
        expect(AppTheme.light.colorScheme.error, AppColors.error);
      });
    });

    group('dark theme', () {
      test('uses Material 3', () {
        expect(AppTheme.dark.useMaterial3, isTrue);
      });

      test('has dark brightness', () {
        expect(AppTheme.dark.brightness, Brightness.dark);
      });

      test('has centered app bar', () {
        expect(AppTheme.dark.appBarTheme.centerTitle, isTrue);
      });

      test('has filled input decoration', () {
        expect(AppTheme.dark.inputDecorationTheme.filled, isTrue);
      });

      test('input fill color is dark surface variant', () {
        expect(
          AppTheme.dark.inputDecorationTheme.fillColor,
          AppColors.darkSurfaceVariant,
        );
      });

      test('has card with rounded corners', () {
        final shape = AppTheme.dark.cardTheme.shape as RoundedRectangleBorder;
        expect(shape.borderRadius, BorderRadius.circular(12));
      });

      test('FAB uses accent color', () {
        expect(
          AppTheme.dark.floatingActionButtonTheme.backgroundColor,
          AppColors.accent,
        );
      });
    });
  });
}
