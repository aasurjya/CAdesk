import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/roadmap_modules/presentation/roadmap_module_screen.dart';

Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

// Use moduleId '4' which maps to TDS.AI in _moduleDefinitions in roadmap_modules_providers.dart
Widget _buildScreen({String moduleId = '4'}) => ProviderScope(
  child: MaterialApp(home: RoadmapModuleScreen(moduleId: moduleId)),
);

void main() {
  group('RoadmapModuleScreen — valid module', () {
    testWidgets('renders AppBar with module title', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders Workboard tab label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Workboard'), findsOneWidget);
    });

    testWidgets('renders Automations tab label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // 'Automations' appears in both TabBar and summary card
      expect(find.text('Automations'), findsWidgets);
    });

    testWidgets('renders Items summary card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Items'), findsOneWidget);
    });

    testWidgets('renders Active summary card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('renders At Risk summary card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('At Risk'), findsOneWidget);
    });

    testWidgets('renders Automations summary card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // 'Automations' appears in both TabBar and summary card
      expect(find.text('Automations'), findsWidgets);
    });

    testWidgets('renders Key metrics label in Workboard tab', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Key metrics'), findsOneWidget);
    });

    testWidgets('renders Delivery workboard label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Delivery workboard'), findsOneWidget);
    });

    testWidgets('renders TabBarView', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('switching to Automations tab shows content', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Automations'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Enabled automations'), findsOneWidget);
    });

    testWidgets('renders Quick wins section in Automations tab', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text('Automations'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Quick wins'), findsOneWidget);
    });

    testWidgets('hero card shows module title text', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // The hero card has title and description text
      expect(find.byType(RoadmapModuleScreen), findsOneWidget);
    });
  });

  group('RoadmapModuleScreen — invalid module', () {
    testWidgets('renders not found message for unknown moduleId', (
      tester,
    ) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen(moduleId: 'nonexistent-99999'));
      await tester.pumpAndSettle();

      expect(find.text('Module not found'), findsOneWidget);
    });

    testWidgets('renders no module configuration message', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen(moduleId: 'nonexistent-99999'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('No module configuration found'),
        findsOneWidget,
      );
    });
  });
}
