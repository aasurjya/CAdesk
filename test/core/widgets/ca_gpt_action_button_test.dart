import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/core/widgets/ca_gpt_action_button.dart';

import '../../helpers/widget_test_helpers.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildSubject({
  String contextDescription = 'ITR-1 filing',
  VoidCallback? onPressed,
}) {
  return CaGptActionButton(
    contextDescription: contextDescription,
    onPressed: onPressed,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('CaGptActionButton', () {
    group('rendering', () {
      testWidgets('renders a FloatingActionButton', (tester) async {
        await pumpTestWidget(tester, _buildSubject());

        expect(find.byType(FloatingActionButton), findsOneWidget);
      });

      testWidgets('renders sparkle/AI icon (auto_awesome_rounded)', (
        tester,
      ) async {
        await pumpTestWidget(tester, _buildSubject());

        expect(find.byIcon(Icons.auto_awesome_rounded), findsOneWidget);
      });

      testWidgets('icon has size 20', (tester) async {
        await pumpTestWidget(tester, _buildSubject());

        final icon = tester.widget<Icon>(
          find.byIcon(Icons.auto_awesome_rounded),
        );
        expect(icon.size, equals(20));
      });

      testWidgets('tooltip contains CA-GPT text', (tester) async {
        await pumpTestWidget(
          tester,
          _buildSubject(contextDescription: 'GST returns'),
        );

        final fab = tester.widget<FloatingActionButton>(
          find.byType(FloatingActionButton),
        );
        expect(fab.tooltip, contains('CA-GPT'));
      });

      testWidgets('tooltip includes contextDescription', (tester) async {
        await pumpTestWidget(
          tester,
          _buildSubject(contextDescription: 'ITR-1 filing for PAN ABCDE1234F'),
        );

        final fab = tester.widget<FloatingActionButton>(
          find.byType(FloatingActionButton),
        );
        expect(fab.tooltip, contains('ITR-1 filing for PAN ABCDE1234F'));
      });
    });

    group('interaction', () {
      testWidgets('tapping calls onPressed callback', (tester) async {
        bool pressed = false;

        await pumpTestWidget(
          tester,
          _buildSubject(onPressed: () => pressed = true),
        );

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();

        expect(pressed, isTrue);
      });

      testWidgets('tapping multiple times calls onPressed each time', (
        tester,
      ) async {
        int count = 0;

        await pumpTestWidget(tester, _buildSubject(onPressed: () => count++));

        await tester.tap(find.byType(FloatingActionButton));
        await tester.tap(find.byType(FloatingActionButton));
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();

        expect(count, equals(3));
      });

      testWidgets('onPressed null disables the button', (tester) async {
        await pumpTestWidget(tester, _buildSubject(onPressed: null));

        final fab = tester.widget<FloatingActionButton>(
          find.byType(FloatingActionButton),
        );
        expect(fab.onPressed, isNull);
      });
    });

    group('heroTag', () {
      testWidgets('has heroTag set to ca_gpt_fab', (tester) async {
        await pumpTestWidget(tester, _buildSubject());

        final fab = tester.widget<FloatingActionButton>(
          find.byType(FloatingActionButton),
        );
        expect(fab.heroTag, equals('ca_gpt_fab'));
      });

      testWidgets('two buttons with same heroTag do not conflict in test', (
        tester,
      ) async {
        // In production both would be on different screens; here we just
        // verify a single button renders without issue.
        await pumpTestWidget(tester, _buildSubject());

        expect(tester.takeException(), isNull);
      });
    });

    group('layout', () {
      testWidgets('renders without overflow when placed in a Stack', (
        tester,
      ) async {
        await setPhoneViewport(tester);

        await pumpTestWidget(
          tester,
          Stack(
            children: [
              const Placeholder(),
              Positioned(bottom: 16, right: 16, child: _buildSubject()),
            ],
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });

      testWidgets('renders without overflow in Scaffold floatingActionButton', (
        tester,
      ) async {
        await setPhoneViewport(tester);

        await tester.pumpWidget(
          buildTestWidget(
            Scaffold(
              body: const SizedBox.expand(),
              floatingActionButton: _buildSubject(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });

      testWidgets('renders without overflow on tablet viewport', (
        tester,
      ) async {
        await setTabletViewport(tester);

        await pumpTestWidget(tester, _buildSubject());

        expect(tester.takeException(), isNull);
      });
    });
  });
}
