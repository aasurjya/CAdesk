import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/core/theme/app_colors.dart';
import 'package:ca_app/core/widgets/urgency_border_card.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  group('UrgencyBorderCard', () {
    group('child rendering', () {
      testWidgets('renders child content', (tester) async {
        await pumpTestWidget(
          tester,
          UrgencyBorderCard(
            urgencyColor: AppColors.error,
            child: const Text('Child Content'),
          ),
        );

        expect(find.text('Child Content'), findsOneWidget);
      });

      testWidgets('renders nested widget tree as child', (tester) async {
        await pumpTestWidget(
          tester,
          UrgencyBorderCard(
            urgencyColor: AppColors.success,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Title'),
                Text('Subtitle'),
              ],
            ),
          ),
        );

        expect(find.text('Title'), findsOneWidget);
        expect(find.text('Subtitle'), findsOneWidget);
      });
    });

    group('urgency color border', () {
      testWidgets('shows red left border for overdue', (tester) async {
        await pumpTestWidget(
          tester,
          UrgencyBorderCard(
            urgencyColor: AppColors.error,
            child: const SizedBox(width: 100, height: 50),
          ),
        );

        final container = tester.widget<Container>(
          find.byType(Container).at(1),
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.border, isNotNull);
        final border = decoration.border as Border;
        expect(border.left.color, AppColors.error);
      });

      testWidgets('shows amber left border for due soon', (tester) async {
        await pumpTestWidget(
          tester,
          UrgencyBorderCard(
            urgencyColor: AppColors.warning,
            child: const SizedBox(width: 100, height: 50),
          ),
        );

        final container = tester.widget<Container>(
          find.byType(Container).at(1),
        );
        final decoration = container.decoration as BoxDecoration;
        final border = decoration.border as Border;
        expect(border.left.color, AppColors.warning);
      });

      testWidgets('shows green left border for safe', (tester) async {
        await pumpTestWidget(
          tester,
          UrgencyBorderCard(
            urgencyColor: AppColors.success,
            child: const SizedBox(width: 100, height: 50),
          ),
        );

        final container = tester.widget<Container>(
          find.byType(Container).at(1),
        );
        final decoration = container.decoration as BoxDecoration;
        final border = decoration.border as Border;
        expect(border.left.color, AppColors.success);
      });

      testWidgets('shows grey left border for completed', (tester) async {
        await pumpTestWidget(
          tester,
          UrgencyBorderCard(
            urgencyColor: AppColors.neutral300,
            child: const SizedBox(width: 100, height: 50),
          ),
        );

        final container = tester.widget<Container>(
          find.byType(Container).at(1),
        );
        final decoration = container.decoration as BoxDecoration;
        final border = decoration.border as Border;
        expect(border.left.color, AppColors.neutral300);
      });
    });

    group('custom borderWidth', () {
      testWidgets('applies custom border width', (tester) async {
        await pumpTestWidget(
          tester,
          UrgencyBorderCard(
            urgencyColor: AppColors.error,
            borderWidth: 6.0,
            child: const SizedBox(width: 100, height: 50),
          ),
        );

        final container = tester.widget<Container>(
          find.byType(Container).at(1),
        );
        final decoration = container.decoration as BoxDecoration;
        final border = decoration.border as Border;
        expect(border.left.width, 6.0);
      });

      testWidgets('default border width is 4.0', (tester) async {
        await pumpTestWidget(
          tester,
          UrgencyBorderCard(
            urgencyColor: AppColors.success,
            child: const SizedBox(width: 100, height: 50),
          ),
        );

        final container = tester.widget<Container>(
          find.byType(Container).at(1),
        );
        final decoration = container.decoration as BoxDecoration;
        final border = decoration.border as Border;
        expect(border.left.width, 4.0);
      });
    });

    group('onTap callback', () {
      testWidgets('wraps content in GestureDetector when onTap provided', (
        tester,
      ) async {
        var tapped = false;

        await pumpTestWidget(
          tester,
          UrgencyBorderCard(
            urgencyColor: AppColors.success,
            onTap: () => tapped = true,
            child: const SizedBox(width: 100, height: 50),
          ),
        );

        expect(find.byType(GestureDetector), findsOneWidget);
        await tester.tap(find.byType(GestureDetector));
        expect(tapped, isTrue);
      });

      testWidgets('no GestureDetector when onTap is null', (tester) async {
        await pumpTestWidget(
          tester,
          UrgencyBorderCard(
            urgencyColor: AppColors.success,
            child: const SizedBox(width: 100, height: 50),
          ),
        );

        expect(find.byType(GestureDetector), findsNothing);
      });
    });

    group('elevation', () {
      testWidgets('applies box shadow when elevation is set', (tester) async {
        await pumpTestWidget(
          tester,
          UrgencyBorderCard(
            urgencyColor: AppColors.error,
            elevation: 2,
            child: const SizedBox(width: 100, height: 50),
          ),
        );

        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.boxShadow, isNotNull);
        expect(decoration.boxShadow!.length, 1);
      });

      testWidgets('no shadow when elevation is null', (tester) async {
        await pumpTestWidget(
          tester,
          UrgencyBorderCard(
            urgencyColor: AppColors.error,
            child: const SizedBox(width: 100, height: 50),
          ),
        );

        final container = tester.widget<Container>(
          find.byType(Container).first,
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.boxShadow, isNull);
      });
    });
  });

  group('urgencyColorFromDays', () {
    test('returns red for overdue (negative days)', () {
      expect(urgencyColorFromDays(-1), AppColors.error);
      expect(urgencyColorFromDays(-10), AppColors.error);
    });

    test('returns red for 0 days remaining (due today)', () {
      expect(urgencyColorFromDays(0), AppColors.error);
    });

    test('returns amber for 1 day remaining', () {
      expect(urgencyColorFromDays(1), AppColors.warning);
    });

    test('returns amber for 7 days remaining (boundary)', () {
      expect(urgencyColorFromDays(7), AppColors.warning);
    });

    test('returns green for 8 days remaining', () {
      expect(urgencyColorFromDays(8), AppColors.success);
    });

    test('returns green for far future', () {
      expect(urgencyColorFromDays(100), AppColors.success);
    });

    test('returns grey when isCompleted is true regardless of days', () {
      expect(
        urgencyColorFromDays(-5, isCompleted: true),
        AppColors.neutral300,
      );
      expect(
        urgencyColorFromDays(0, isCompleted: true),
        AppColors.neutral300,
      );
      expect(
        urgencyColorFromDays(3, isCompleted: true),
        AppColors.neutral300,
      );
      expect(
        urgencyColorFromDays(30, isCompleted: true),
        AppColors.neutral300,
      );
    });

    test('boundary value: -1 is red', () {
      expect(urgencyColorFromDays(-1), AppColors.error);
    });

    test('boundary value: 0 is red', () {
      expect(urgencyColorFromDays(0), AppColors.error);
    });

    test('boundary value: 1 is amber', () {
      expect(urgencyColorFromDays(1), AppColors.warning);
    });

    test('boundary value: 7 is amber', () {
      expect(urgencyColorFromDays(7), AppColors.warning);
    });

    test('boundary value: 8 is green', () {
      expect(urgencyColorFromDays(8), AppColors.success);
    });
  });
}
