import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/clients/domain/models/client.dart';
import 'package:ca_app/features/clients/presentation/clients_list_screen.dart';

Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() =>
    const ProviderScope(child: MaterialApp(home: ClientsListScreen()));

void main() {
  group('ClientsListScreen', () {
    testWidgets('renders Clients app bar title', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Clients'), findsOneWidget);
    });

    testWidgets('renders search icon button in app bar', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('renders sort icon button in app bar', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.sort), findsOneWidget);
    });

    testWidgets('renders All status segment', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(SegmentedButton<ClientStatus?>),
          matching: find.text('All'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Active status segment', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(SegmentedButton<ClientStatus?>),
          matching: find.text('Active'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Inactive status segment', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(SegmentedButton<ClientStatus?>),
          matching: find.text('Inactive'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Prospect status segment', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(SegmentedButton<ClientStatus?>),
          matching: find.text('Prospect'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders All type filter chip', (tester) async {
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

    testWidgets('renders Individual type filter chip', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(FilterChip),
          matching: find.text('Individual'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Company type filter chip', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(FilterChip),
          matching: find.text('Company'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Add Client FAB', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Add Client'), findsOneWidget);
    });

    testWidgets('renders person_add icon in FAB', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person_add), findsOneWidget);
    });

    testWidgets('renders client count text', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining('client'), findsWidgets);
    });

    testWidgets('tapping search icon shows text field', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders LLP type filter chip', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(FilterChip),
          matching: find.text('LLP'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('body is a Column with a scrollable area', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(Column), findsWidgets);
    });
  });
}
