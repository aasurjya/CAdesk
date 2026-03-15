import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/industry_playbooks/presentation/industry_playbooks_screen.dart';

Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() =>
    const ProviderScope(child: MaterialApp(home: IndustryPlaybooksScreen()));

void main() {
  group('IndustryPlaybooksScreen', () {
    testWidgets('renders Industry Playbooks title', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Industry Playbooks'), findsOneWidget);
    });

    testWidgets('renders Practice Overview summary card', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Practice Overview'), findsOneWidget);
    });

    testWidgets('renders Verticals metric in summary', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Verticals'), findsOneWidget);
    });

    testWidgets('renders Total Clients metric in summary', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Total Clients'), findsOneWidget);
    });

    testWidgets('renders Avg Win Rate metric in summary', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Avg Win Rate'), findsOneWidget);
    });

    testWidgets('renders All filter chip', (tester) async {
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

    testWidgets('renders E-Commerce filter chip', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(FilterChip),
          matching: find.text('E-Commerce'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Doctors filter chip', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(FilterChip),
          matching: find.text('Doctors'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders CustomScrollView with slivers', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // CustomScrollView contains playbooks list and service bundles
      expect(find.byType(CustomScrollView), findsOneWidget);
      // SliverList is used for both sections
      expect(find.byType(SliverList), findsWidgets);
    });

    testWidgets('renders Best Margin Vertical label', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Best Margin Vertical'), findsOneWidget);
    });

    testWidgets('renders CustomScrollView', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('renders filter chip row', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('renders E-Commerce filter chip', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(FilterChip),
          matching: find.text('E-Commerce'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Real Estate filter chip', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(FilterChip),
          matching: find.text('Real Estate'),
        ),
        findsOneWidget,
      );
    });
  });
}
