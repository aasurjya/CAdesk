import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/dashboard/presentation/dashboard_screen.dart';
import 'package:ca_app/features/dashboard/presentation/widgets/activity_feed_widget.dart';
import 'package:ca_app/features/dashboard/presentation/widgets/compliance_deadline_widget.dart';

/// Sets the virtual display to a comfortable phone viewport that avoids
/// overflow errors from the quick-action grid at the default 800×600 size.
Future<void> _setLargeDisplay(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(414, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

void main() {
  group('DashboardScreen', () {
    Widget buildSubject() {
      return const ProviderScope(
        child: MaterialApp(
          home: DashboardScreen(),
        ),
      );
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

      expect(
        find.textContaining('firm performance snapshot'),
        findsOneWidget,
      );
    });

    testWidgets('renders Quick Actions section title', (tester) async {
      await _setLargeDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Quick Actions'), findsOneWidget);
    });

    testWidgets('renders File ITR quick action card', (tester) async {
      await _setLargeDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('File ITR'), findsOneWidget);
    });

    testWidgets('renders File GST quick action card', (tester) async {
      await _setLargeDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('File GST'), findsOneWidget);
    });

    testWidgets('renders New Client quick action card', (tester) async {
      await _setLargeDisplay(tester);
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

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

    testWidgets('Upcoming Deadlines section is visible after scrolling',
        (tester) async {
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

    testWidgets('ComplianceDeadlineWidget is visible after scrolling',
        (tester) async {
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

    testWidgets('Recent Activity section is visible after scrolling',
        (tester) async {
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

    testWidgets('ActivityFeedWidget is visible after scrolling', (tester) async {
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
      return const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: ActivityFeedWidget())),
      );
    }

    testWidgets('renders ITR Filed activity', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('ITR Filed'), findsOneWidget);
    });

    testWidgets('renders GST Filed activity', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('GST Filed'), findsOneWidget);
    });

    testWidgets('renders Challan Paid activity', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Challan Paid'), findsOneWidget);
    });
  });

  group('ComplianceDeadlineWidget', () {
    Widget buildSubject() {
      return const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: ComplianceDeadlineWidget()),
        ),
      );
    }

    testWidgets('renders GSTR-3B deadline', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('GST GSTR-3B'), findsOneWidget);
    });

    testWidgets('renders TDS Challan deadline', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('TDS Challan'), findsOneWidget);
    });

    testWidgets('renders Advance Tax deadline', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Advance Tax'), findsOneWidget);
    });

    testWidgets('renders GSTR-1 deadline', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('GSTR-1'), findsOneWidget);
    });

    testWidgets('renders overdue pill for past deadlines', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.textContaining('days overdue'), findsOneWidget);
    });

    testWidgets('renders Today pill for zero-day deadline', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Today'), findsOneWidget);
    });
  });
}
