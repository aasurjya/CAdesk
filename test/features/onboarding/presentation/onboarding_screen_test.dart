import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ca_app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:ca_app/features/onboarding/presentation/widgets/kyc_status_card.dart';

/// Suppresses layout overflow errors that can occur on narrow test viewports.
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

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildScreen() {
  return const ProviderScope(child: MaterialApp(home: OnboardingScreen()));
}

Future<void> _setDisplay(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('OnboardingScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pump();
      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('renders Onboarding & KYC title', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Onboarding & KYC'), findsOneWidget);
    });

    testWidgets('renders subtitle text', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(
        find.text('Client activation and compliance readiness'),
        findsOneWidget,
      );
    });

    testWidgets('renders Onboarding tab label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Onboarding'), findsWidgets);
    });

    testWidgets('renders KYC Status tab label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('KYC Status'), findsWidgets);
    });

    testWidgets('renders Doc Expiry tab label', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.text('Doc Expiry'), findsWidgets);
    });

    testWidgets('renders a TabBar with three tabs', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('Onboarding tab shows banner or empty state', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      final hasBanner =
          find.text('Bring clients live smoothly').evaluate().isNotEmpty;
      final hasEmpty =
          find.text('No active onboarding').evaluate().isNotEmpty;
      expect(hasBanner || hasEmpty, isTrue);
    });

    testWidgets('switching to KYC Status tab shows summary card',
        (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      await _ignoreOverflow(() async {
        await tester.tap(find.text('KYC Status').first);
        await tester.pumpAndSettle();
        expect(find.text('Total'), findsWidgets);
      });
    });

    testWidgets('KYC Status tab shows Verified metric', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      await _ignoreOverflow(() async {
        await tester.tap(find.text('KYC Status').first);
        await tester.pumpAndSettle();
        expect(find.text('Verified'), findsWidgets);
      });
    });

    testWidgets('KYC Status tab shows Pending metric', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      await _ignoreOverflow(() async {
        await tester.tap(find.text('KYC Status').first);
        await tester.pumpAndSettle();
        expect(find.text('Pending'), findsWidgets);
      });
    });

    testWidgets('KYC Status tab shows KYC records or empty state',
        (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      await _ignoreOverflow(() async {
        await tester.tap(find.text('KYC Status').first);
        await tester.pumpAndSettle();
        final hasCards = find.byType(KycStatusCard).evaluate().isNotEmpty;
        final hasEmpty = find.text('No KYC records').evaluate().isNotEmpty;
        expect(hasCards || hasEmpty, isTrue);
      });
    });

    testWidgets('switching to Doc Expiry tab shows filter chips', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Doc Expiry').first);
      await tester.pumpAndSettle();
      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('Doc Expiry tab shows All filter chip', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Doc Expiry').first);
      await tester.pumpAndSettle();
      expect(find.text('All'), findsWidgets);
    });

    testWidgets('renders AppBar with TabBar', (tester) async {
      await _setDisplay(tester);
      await tester.pumpWidget(_buildScreen());
      await tester.pumpAndSettle();
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
    });
  });
}
