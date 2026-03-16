import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/regulatory_intelligence/presentation/regulatory_intelligence_screen.dart';

Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(800, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() => const ProviderScope(
  child: MaterialApp(home: RegulatoryIntelligenceScreen()),
);

void main() {
  group('RegulatoryIntelligenceScreen', () {
    testWidgets('renders Regulatory Intelligence title', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Regulatory Intelligence'), findsOneWidget);
    });

    testWidgets('renders Circulars tab label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Circulars'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Client Alerts tab label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Client Alerts'),
        ),
        findsOneWidget,
      );
    });

    testWidgets("renders Today's Digest card", (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining("Today's Digest"), findsOneWidget);
    });

    testWidgets('renders New Circulars stat label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('New Circulars'), findsOneWidget);
    });

    testWidgets('renders High Impact stat label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('High Impact'), findsOneWidget);
    });

    testWidgets('renders Clients Affected stat label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Clients Affected'), findsOneWidget);
    });

    testWidgets('renders Income Tax filter chip', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(FilterChip),
          matching: find.text('Income Tax'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders GST filter chip in Circulars tab', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(FilterChip),
          matching: find.text('GST'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders MCA filter chip', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(FilterChip),
          matching: find.text('MCA'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders TabBarView', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('switching to Client Alerts tab shows alerts summary', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Client Alerts'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('urgent alerts'), findsOneWidget);
    });

    testWidgets('renders Urgent filter chip in Client Alerts tab', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Client Alerts'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(FilterChip),
          matching: find.text('Urgent'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders All filter chip in Circulars tab', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(FilterChip),
          matching: find.text('All'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders auto_awesome icon in digest card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.auto_awesome_rounded), findsOneWidget);
    });
  });
}
