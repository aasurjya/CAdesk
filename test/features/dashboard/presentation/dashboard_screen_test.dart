import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:ca_app/features/dashboard/presentation/widgets/activity_feed_widget.dart';
import 'package:ca_app/features/dashboard/presentation/widgets/compliance_deadline_widget.dart';

/// Sets the virtual display to a comfortable phone viewport that avoids
/// overflow errors from the quick-action grid at the default 800x600 size.
Future<void> _setLargeDisplay(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(414, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

void main() {
  group('DashboardScreen', () {
    Widget buildSubject() {
      return const ProviderScope(child: MaterialApp(home: DashboardScreen()));
    }

    testWidgets('renders app bar with CADesk title', (tester) async {
      await _setLargeDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('CADesk'), findsOneWidget);
    });

    testWidgets('renders daily practice overview subtitle', (tester) async {
      await _setLargeDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Daily practice overview'), findsOneWidget);
    });

    testWidgets('renders notifications icon button', (tester) async {
      await _setLargeDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('renders greeting section', (tester) async {
      await _setLargeDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final greetingFinder = find.textContaining('morning');
      final afternoonFinder = find.textContaining('afternoon');
      final eveningFinder = find.textContaining('evening');

      expect(
        greetingFinder.evaluate().isNotEmpty ||
            afternoonFinder.evaluate().isNotEmpty ||
            eveningFinder.evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('renders firm performance snapshot copy', (tester) async {
      await _setLargeDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.textContaining('firm performance snapshot'), findsOneWidget);
    });

    testWidgets('renders Quick Actions section title', (tester) async {
      await _setLargeDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Quick Actions'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Quick Actions'), findsOneWidget);
    });

    testWidgets('renders File ITR quick action card', (tester) async {
      await _setLargeDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('File ITR'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('File ITR'), findsOneWidget);
    });

    testWidgets('renders File GST quick action card', (tester) async {
      await _setLargeDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('File GST'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('File GST'), findsOneWidget);
    });

    testWidgets('renders New Client quick action card', (tester) async {
      await _setLargeDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('New Client'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('New Client'), findsOneWidget);
    });

    testWidgets('renders KPI stats — Due this week', (tester) async {
      await _setLargeDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Due this week'), findsOneWidget);
    });

    testWidgets('renders KPI stats — ITR pending', (tester) async {
      await _setLargeDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('ITR pending'), findsOneWidget);
    });

    testWidgets('renders KPI stats — GST pending', (tester) async {
      await _setLargeDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('GST pending'), findsOneWidget);
    });

    testWidgets('body contains a ListView', (tester) async {
      await _setLargeDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('body contains a RefreshIndicator', (tester) async {
      await _setLargeDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('Upcoming Deadlines section is visible after scrolling', (
      tester,
    ) async {
      await _setLargeDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Scroll down to reveal deadlines section
      await tester.scrollUntilVisible(
        find.text('Upcoming Deadlines'),
        400,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Upcoming Deadlines'), findsOneWidget);
    });

    testWidgets('ComplianceDeadlineWidget is visible after scrolling', (
      tester,
    ) async {
      await _setLargeDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byType(ComplianceDeadlineWidget),
        400,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.byType(ComplianceDeadlineWidget), findsOneWidget);
    });

    testWidgets('Recent Activity section is visible after scrolling', (
      tester,
    ) async {
      await _setLargeDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Recent Activity'),
        400,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Recent Activity'), findsOneWidget);
    });

    testWidgets('ActivityFeedWidget is visible after scrolling', (
      tester,
    ) async {
      await _setLargeDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byType(ActivityFeedWidget),
        400,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.byType(ActivityFeedWidget), findsOneWidget);
    });
  });

  group('ActivityFeedWidget', () {
    Widget buildSubject() {
      return const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: ActivityFeedWidget()),
          ),
        ),
      );
    }

    testWidgets('renders activity items from provider', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // The provider produces up to 8 activities from ITR/GST/TDS data.
      // At least one activity card should be rendered.
      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('renders activity items from provider data', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // The provider aggregates ITR, GST, and TDS data; at least one card
      // should contain a recognisable module prefix.
      final itr = find.text('ITR Filed');
      final gst = find.textContaining('GST');
      final tds = find.textContaining('TDS');

      expect(
        itr.evaluate().isNotEmpty ||
            gst.evaluate().isNotEmpty ||
            tds.evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('wraps activity rows in InkWell for navigation', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(InkWell), findsWidgets);
    });
  });

  group('ComplianceDeadlineWidget', () {
    Widget buildSubject() {
      return const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: ComplianceDeadlineWidget()),
          ),
        ),
      );
    }

    testWidgets('renders deadline items from compliance provider', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // The provider returns upcoming deadlines from the compliance module.
      // At least one deadline should be visible (GST-3B, TDS Return, GSTR-9,
      // or future-month items depending on the current date).
      final gst = find.textContaining('GST');
      final tds = find.textContaining('TDS');
      final empty = find.text('No upcoming deadlines');

      expect(
        gst.evaluate().isNotEmpty ||
            tds.evaluate().isNotEmpty ||
            empty.evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('renders deadline type badges', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Short labels from ComplianceCategory enum
      expect(find.text('TDS'), findsWidgets);
    });

    testWidgets('renders days remaining pills', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // At least one deadline should show "days left" or "Today" or "days overdue"
      final daysLeft = find.textContaining('days left');
      final today = find.text('Today');
      final overdue = find.textContaining('overdue');

      expect(
        daysLeft.evaluate().isNotEmpty ||
            today.evaluate().isNotEmpty ||
            overdue.evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('wraps deadline tiles in InkWell for navigation', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(InkWell), findsWidgets);
    });
  });
}
