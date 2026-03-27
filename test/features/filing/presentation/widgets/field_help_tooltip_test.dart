import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/filing/presentation/widgets/field_help_tooltip.dart';

import '../../../../helpers/widget_test_helpers.dart';

void main() {
  group('FieldHelpTooltip', () {
    testWidgets('renders info icon', (tester) async {
      await pumpTestWidget(
        tester,
        const Scaffold(
          body: Center(child: FieldHelpTooltip(helpText: 'Test help')),
        ),
      );

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('shows tooltip text on tap', (tester) async {
      const helpText = 'Your 10-character PAN';

      await pumpTestWidget(
        tester,
        const Scaffold(
          body: Center(child: FieldHelpTooltip(helpText: helpText)),
        ),
      );

      // Tap the info icon to trigger the tooltip.
      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(helpText), findsOneWidget);
    });

    testWidgets('icon has correct size and color', (tester) async {
      await pumpTestWidget(
        tester,
        const Scaffold(
          body: Center(child: FieldHelpTooltip(helpText: 'Info')),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.info_outline));
      expect(icon.size, 18);
    });
  });
}
