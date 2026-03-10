import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ca_app/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    group('light theme', () {
      test('uses Material 3', () {
        expect(AppTheme.light.useMaterial3, isTrue);
      });

      test('has light brightness', () {
        expect(AppTheme.light.brightness, Brightness.light);
      });

      test('has centered app bar', () {
        expect(AppTheme.light.appBarTheme.centerTitle, isTrue);
      });

      test('has filled input decoration', () {
        expect(AppTheme.light.inputDecorationTheme.filled, isTrue);
      });

      test('has card with rounded corners', () {
        final shape = AppTheme.light.cardTheme.shape as RoundedRectangleBorder;
        expect(shape.borderRadius, BorderRadius.circular(12));
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

      test('has card with rounded corners', () {
        final shape = AppTheme.dark.cardTheme.shape as RoundedRectangleBorder;
        expect(shape.borderRadius, BorderRadius.circular(12));
      });
    });
  });
}
