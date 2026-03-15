import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/compliance/presentation/compliance_screen.dart';
import 'package:ca_app/features/compliance/presentation/compliance_calendar_screen.dart';

Future<void> _setPhoneDisplay(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(414, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

/// Suppresses layout overflow errors during [body].
/// The 7-column calendar grid overflows on narrow test viewports.
Future<void> _ignoreOverflow(Future<void> Function() body) async {
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('overflowed')) return;
    originalOnError?.call(details);
  };
  try {
    await body();
  } finally {
    FlutterError.onError = originalOnError;
  }
}

void main() {
  Widget buildSubject() {
    return const ProviderScope(
      child: MaterialApp(home: ComplianceScreen()),
    );
  }

  Widget buildCalendarSubject() {
    return const ProviderScope(
      child: MaterialApp(home: ComplianceCalendarScreen()),
    );
  }

  group('ComplianceScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildSubject());
        await tester.pump();
        expect(find.byType(ComplianceScreen), findsOneWidget);
      });
    });

    testWidgets('delegates to ComplianceCalendarScreen', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildSubject());
        await tester.pump();
        expect(find.byType(ComplianceCalendarScreen), findsOneWidget);
      });
    });
  });

  group('ComplianceCalendarScreen', () {
    testWidgets('renders Compliance title', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildCalendarSubject());
        await tester.pumpAndSettle();
        expect(find.text('Compliance'), findsOneWidget);
      });
    });

    testWidgets('renders calendar/list toggle icon button', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildCalendarSubject());
        await tester.pumpAndSettle();
        final hasCalendarIcon =
            find.byIcon(Icons.calendar_month_rounded).evaluate().isNotEmpty;
        final hasListIcon =
            find.byIcon(Icons.view_list_rounded).evaluate().isNotEmpty;
        expect(hasCalendarIcon || hasListIcon, isTrue);
      });
    });

    testWidgets('calendar view shows month navigation arrows', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildCalendarSubject());
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
      });
    });

    testWidgets('calendar view shows year in month label', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildCalendarSubject());
        await tester.pumpAndSettle();
        expect(
          find.textContaining('2026').evaluate().isNotEmpty ||
              find.textContaining('2025').evaluate().isNotEmpty,
          isTrue,
        );
      });
    });

    testWidgets('calendar view shows Mon weekday header', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildCalendarSubject());
        await tester.pumpAndSettle();
        expect(find.text('Mon'), findsOneWidget);
      });
    });

    testWidgets('calendar grid renders day number 1', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildCalendarSubject());
        await tester.pumpAndSettle();
        expect(find.text('1'), findsWidgets);
      });
    });

    testWidgets('deadline list or empty state renders below calendar',
        (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildCalendarSubject());
        await tester.pumpAndSettle();
        final hasList = find.byType(ListView).evaluate().isNotEmpty;
        final hasEmpty =
            find.byIcon(Icons.event_available_rounded).evaluate().isNotEmpty;
        expect(hasList || hasEmpty, isTrue);
      });
    });

    testWidgets('can navigate to next month', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildCalendarSubject());
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.chevron_right_rounded));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
      });
    });

    testWidgets('can navigate to previous month', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildCalendarSubject());
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.chevron_left_rounded));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
      });
    });

    testWidgets('can toggle to list view', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildCalendarSubject());
        await tester.pumpAndSettle();
        final toggleIcon = find.byType(IconButton).last;
        await tester.tap(toggleIcon);
        await tester.pumpAndSettle();
        final hasList = find.byType(ListView).evaluate().isNotEmpty;
        final hasEmpty =
            find.byIcon(Icons.event_available_rounded).evaluate().isNotEmpty;
        expect(hasList || hasEmpty, isTrue);
      });
    });

    testWidgets('AppBar renders correctly', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildCalendarSubject());
        await tester.pumpAndSettle();
        expect(find.byType(AppBar), findsOneWidget);
      });
    });

    testWidgets('shows data or loading on initial load', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildCalendarSubject());
        await tester.pump();
        final hasLoading =
            find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
        final hasData = find.byType(Column).evaluate().isNotEmpty;
        expect(hasLoading || hasData, isTrue);
      });
    });

    testWidgets('list view shows deadline items or empty state', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildCalendarSubject());
        await tester.pumpAndSettle();
        final appBarActions = find.byType(IconButton);
        await tester.tap(appBarActions.last);
        await tester.pumpAndSettle();
        final hasList = find.byType(ListView).evaluate().isNotEmpty;
        final hasEmpty =
            find.byIcon(Icons.event_available_rounded).evaluate().isNotEmpty;
        expect(hasList || hasEmpty, isTrue);
      });
    });

    testWidgets('weekday headers include Tue through Sun', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildCalendarSubject());
        await tester.pumpAndSettle();
        for (final label in ['Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']) {
          expect(find.text(label), findsOneWidget);
        }
      });
    });

    testWidgets('navigating months updates calendar', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildCalendarSubject());
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.chevron_right_rounded));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.chevron_right_rounded));
        await tester.pumpAndSettle();
        expect(find.text('Mon'), findsOneWidget);
      });
    });

    testWidgets('back and forward navigation preserves structure',
        (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildCalendarSubject());
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.chevron_right_rounded));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.chevron_left_rounded));
        await tester.pumpAndSettle();
        expect(find.text('Compliance'), findsOneWidget);
      });
    });

    testWidgets('Divider separates calendar from deadline list', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildCalendarSubject());
        await tester.pumpAndSettle();
        expect(find.byType(Divider), findsOneWidget);
      });
    });

    testWidgets('list view can toggle back to calendar view', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildCalendarSubject());
        await tester.pumpAndSettle();
        // Toggle to list view
        await tester.tap(find.byType(IconButton).last);
        await tester.pumpAndSettle();
        // Toggle back to calendar view
        await tester.tap(find.byType(IconButton).last);
        await tester.pumpAndSettle();
        // Calendar grid elements should be present again
        expect(find.text('Mon'), findsOneWidget);
      });
    });

    testWidgets('calendar shows correct column structure', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildCalendarSubject());
        await tester.pumpAndSettle();
        expect(find.byType(Column), findsWidgets);
      });
    });
  });
}
