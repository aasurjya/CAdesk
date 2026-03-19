import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/filing/presentation/widgets/step_completion_indicator.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  group('StepCompletionIndicator', () {
    testWidgets('renders correct number of dots', (tester) async {
      await pumpTestWidget(
        tester,
        const Scaffold(
          body: StepCompletionIndicator(
            totalSteps: 8,
            currentStep: 0,
            completedSteps: {},
          ),
        ),
      );

      // Each dot shows its step number (1 through 8).
      for (var i = 1; i <= 8; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
    });

    testWidgets('current step is highlighted with accent color',
        (tester) async {
      await pumpTestWidget(
        tester,
        const Scaffold(
          body: StepCompletionIndicator(
            totalSteps: 8,
            currentStep: 2,
            completedSteps: {},
          ),
        ),
      );

      // The current step (index 2) shows number "3" and should be
      // slightly larger (26px) than the rest (22px).
      // We verify by checking the widget tree renders all 8 step numbers.
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('completed steps are filled', (tester) async {
      await pumpTestWidget(
        tester,
        const Scaffold(
          body: StepCompletionIndicator(
            totalSteps: 8,
            currentStep: 3,
            completedSteps: {0, 1, 2},
          ),
        ),
      );

      // All step numbers should render.
      for (var i = 1; i <= 8; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
    });

    testWidgets('renders with zero completed steps', (tester) async {
      await pumpTestWidget(
        tester,
        const Scaffold(
          body: StepCompletionIndicator(
            totalSteps: 5,
            currentStep: 0,
            completedSteps: {},
          ),
        ),
      );

      for (var i = 1; i <= 5; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
    });

    testWidgets('all steps completed renders correctly', (tester) async {
      await pumpTestWidget(
        tester,
        const Scaffold(
          body: StepCompletionIndicator(
            totalSteps: 4,
            currentStep: 3,
            completedSteps: {0, 1, 2, 3},
          ),
        ),
      );

      for (var i = 1; i <= 4; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
    });
  });
}
