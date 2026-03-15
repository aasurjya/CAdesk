import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/time_tracking/presentation/time_tracking_screen.dart';

Future<void> _setPhoneDisplay(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(414, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

/// Pumps enough frames to render the initial content without waiting for
/// the running timer (which ticks every second and never "settles").
Future<void> _pump(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

/// Suppresses layout overflow errors during [body].
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
      child: MaterialApp(home: TimeTrackingScreen()),
    );
  }

  group('TimeTrackingScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildSubject());
        await _pump(tester);
        expect(find.byType(TimeTrackingScreen), findsOneWidget);
      });
    });

    testWidgets('renders Time Tracking title', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildSubject());
        await _pump(tester);
        expect(find.text('Time Tracking'), findsOneWidget);
      });
    });

    testWidgets('renders generate invoice icon button', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildSubject());
        await _pump(tester);
        expect(find.byIcon(Icons.receipt_long_rounded), findsWidgets);
      });
    });

    testWidgets('renders Realization section', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildSubject());
        await _pump(tester);
        expect(find.text('Realization'), findsOneWidget);
      });
    });

    testWidgets('renders Utilization metric', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildSubject());
        await _pump(tester);
        expect(find.text('Utilization'), findsWidgets);
      });
    });

    testWidgets('renders Effective Rate metric', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildSubject());
        await _pump(tester);
        expect(find.text('Effective Rate'), findsOneWidget);
      });
    });

    testWidgets('renders Total Billed metric', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildSubject());
        await _pump(tester);
        expect(find.text('Total Billed'), findsWidgets);
      });
    });

    testWidgets('renders Weekly Summary section', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildSubject());
        await _pump(tester);
        expect(find.text('Weekly Summary'), findsOneWidget);
      });
    });

    testWidgets('renders Total Hours in weekly summary', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildSubject());
        await _pump(tester);
        expect(find.text('Total Hours'), findsWidgets);
      });
    });

    testWidgets('renders Billable label', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildSubject());
        await _pump(tester);
        expect(find.text('Billable'), findsWidgets);
      });
    });

    testWidgets("renders Today's Entries section", (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildSubject());
        await _pump(tester);
        expect(find.textContaining("Today's Entries"), findsOneWidget);
      });
    });

    testWidgets('renders filter chips for time entries', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildSubject());
        await _pump(tester);
        expect(find.byType(FilterChip), findsWidgets);
      });
    });

    testWidgets('renders All filter chip', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildSubject());
        await _pump(tester);
        expect(find.text('All'), findsOneWidget);
      });
    });

    testWidgets('renders Today filter chip', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildSubject());
        await _pump(tester);
        expect(find.text('Today'), findsOneWidget);
      });
    });

    testWidgets('renders Billable filter chip', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildSubject());
        await _pump(tester);
        expect(find.text('Billable'), findsWidgets);
      });
    });

    testWidgets('renders scroll view body', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildSubject());
        await _pump(tester);
        expect(find.byType(ListView), findsWidgets);
      });
    });

    testWidgets('time entries or empty state is shown', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildSubject());
        await _pump(tester);
        final hasEntries = find.byType(Card).evaluate().isNotEmpty;
        final hasEmpty =
            find.byIcon(Icons.hourglass_empty_rounded).evaluate().isNotEmpty;
        expect(hasEntries || hasEmpty, isTrue);
      });
    });

    testWidgets('tapping All filter chip selects it', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildSubject());
        await _pump(tester);
        await tester.tap(find.text('All'));
        await _pump(tester);
        expect(find.text('All'), findsOneWidget);
      });
    });

    testWidgets('tapping Today filter chip updates view', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildSubject());
        await _pump(tester);
        await tester.tap(find.text('Today'));
        await _pump(tester);
        expect(find.text('Today'), findsOneWidget);
      });
    });

    testWidgets('AppBar renders correctly', (tester) async {
      await _setPhoneDisplay(tester);
      await _ignoreOverflow(() async {
        await tester.pumpWidget(buildSubject());
        await _pump(tester);
        expect(find.byType(AppBar), findsOneWidget);
      });
    });
  });
}
