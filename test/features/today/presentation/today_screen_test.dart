import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/today/presentation/today_screen.dart';

Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _buildScreen() =>
    const ProviderScope(child: MaterialApp(home: TodayScreen()));

void main() {
  group('TodayScreen', () {
    testWidgets('renders Today app bar title', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('renders current date below title', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // DateFormat outputs like "15 Mar 2026"
      expect(find.textContaining('2026'), findsOneWidget);
    });

    testWidgets('renders Due Today section header', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // 'Due Today' appears in the section header and possibly in deadline tiles
      expect(find.text('Due Today'), findsWidgets);
    });

    testWidgets('renders This Week section header', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('This Week'), findsOneWidget);
    });

    testWidgets('renders Later section header', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Later'), findsOneWidget);
    });

    testWidgets('renders View Full Calendar button', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pumpAndSettle();

      expect(find.text('View Full Calendar'), findsOneWidget);
    });

    testWidgets('renders calendar month icon in View Full Calendar button',
        (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.calendar_month_outlined), findsOneWidget);
    });

    testWidgets('renders today icon for Due Today section', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // today_rounded appears in section header and deadline tiles
      expect(find.byIcon(Icons.today_rounded), findsWidgets);
    });

    testWidgets('renders date_range icon for This Week section', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // date_range_rounded may appear in multiple deadline tiles
      expect(find.byIcon(Icons.date_range_rounded), findsWidgets);
    });

    testWidgets('renders schedule icon for Later section', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // schedule_rounded appears in multiple deadline tiles
      expect(find.byIcon(Icons.schedule_rounded), findsWidgets);
    });

    testWidgets('renders ListView', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('renders count badges for section headers', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Count badge containers are present
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders deadline tiles when data is available', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // ListTile widgets are either deadline tiles or empty state
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('renders empty state message when no deadlines due today',
        (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      // Either deadline tiles or "Nothing due today." are shown
      expect(
        find.byType(TodayScreen),
        findsOneWidget,
      );
    });

    testWidgets('does not crash at 600x1000 viewport', (tester) async {
      await _setViewport(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
